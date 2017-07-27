function show_eeg_data(dinf, minf)

% show_eeg_data(dinf, minf) visualizes EEG data sets.
%
% show_eeg_data(dinf, minf) visualizes EEG data sets
% including the marker data. Navigation tools are included.
% Intresting data can be selected and exported to the Matlab main 
% Workspace by point and click (via mouse).
% 
% Inputs: dinf - Matrix with EEG data ( time x channels )
%         minf - Matrix with Marker data ( number_of_markers x 2) [optional]
%
% See also ANALYZE_EEG_DATA

% © Tu Ilmenau (BMTI) - Martin Weis - 2009/07/30
%
% $Revision: 1.00$  $Date: 2009/07/30$
% $Revision: 1.01$  $Date: 2009/08/06$
% $Revision: 1.02$  $Date: 2010/01/21$


%% Inits

[Nsamp, NCh] = size(dinf); % extract number of time samples Nsamp and number of channels NCh
center = linspace(0, 1, NCh+2); center = center(2:end-1); % center lines for the channels whithin the axis a1h
fs = 256.0164;             % sampling frequency for the computation of the time values
NWin_init = 1024;          % initial number of time samples in the axis a1h (equals arround 4 seconds with fs = 256)
if (Nsamp-2) < NWin_init   % adopt NWin_init if total number of time samples is smaller
    NWin_init = Nsamp - 2;
end
NWin = 0;    % This variable will always contain the actual number of samples whithin the axis a1h
Max_Win_Samples = 12800; % maximum number of time samples shown whithin the axis a1h (equals arround 50 seconds with fs = 256)
Nstart = 0;  % this variable will be the first index of the visualized data in the axis a1h
Y_Scale = 1; % zoom-factor for changing the y-axis scaling of a1h
X_Scale = 1; % zoom-factor for changing the x-axis scaling of a1h
mouse_line_h = 0; % handle for the vertical line on the cousor position whithn axis a1h
left_button_down = 0;     % switch which indicates whether the left mouse button is pressed or not
max_amp = max(max(dinf)); % maximum data amplitude
Selected_Window_x1 = 1;   % first sample of the mouse selection window whithin axis a1h (relative coordinates)
Selected_Window_x2 = 1;   % last sample of the mouse selection window whithin axis a1h (relative coordinates)
Selected_Window_h = [];   % handle for the mouse selection window in axis a1h
Channel_selection_vector = ones(1, NCh); % boolean vector which indicates which channels are selected
if NCh == 23 % hard coded channel names for watisa EEG speech measurements
    YTickLabel = {'27', '26', '25', '24', 'O2', 'O1', 'T6', 'P4', 'PZ', ...
                  'P3', 'T5', 'T4', 'C4', 'CZ', 'C3', 'T3', 'F8', 'F4', ...
                  'FZ', 'F3', 'F7', 'FP2', 'FP1'};          
else
    YTickLabel = cell(1, NCh);
end
          
          
%% create browser uicontrols
% host figure
f1h = figure('Visible', 'off', 'Name', 'EEG Data Browser', ...
             'MenuBar', 'none', 'Toolbar', 'none', ...
             'Position', [100, 100, 1000, 700], ...
             'Units', 'normalized', ...
             'WindowButtonMotionFcn', {@mouse_move}, ...
             'WindowButtonDownFcn', {@mouse_button_down}, ...
             'WindowButtonUpFcn', {@mouse_button_up});

% panel for the browser elements
p1h = uipanel('Parent', f1h, 'Title', '', 'Position', [0 0 0.9 1]);

% axis to show the data
a1h = axes('Parent', p1h, 'Position', [0.05 0.05 0.9 0.9], ...
           'NextPlot', 'add', 'XLimMode', 'manual', 'YLimMode', 'manual', ...
           'YTick', center, 'XTickLabel', [], 'YTickLabel', YTickLabel, ...
           'XTickMode', 'manual', 'YTickMode', 'manual', 'box', 'on', ...
           'XTick', 0.1:0.1:0.9, 'XGrid', 'on', 'GridLineStyle', '-', ...
           'XAxisLocation', 'top', 'DrawMode', 'fast');
       
% context menu elements (available via right mouse button in the axis a1h)
a1menu = uicontextmenu('Parent', f1h);
mh2 = uimenu(a1menu, 'Label', 'export window data', 'Callback', {@export_window});
mh3 = uimenu(a1menu, 'Label', 'export selected data', 'Enable', 'off', 'Callback', {@export_selection});
mh1 = uimenu(a1menu, 'Label', 'expand selection to window', 'Enable', 'off', 'Callback', {@expand_window});
       
% create slider for browsing along time axis
s1h = uicontrol('Parent', p1h, 'Style', 'slider', 'Min', 1, 'Max', Nsamp - NWin_init, ...
                'Value', 1, 'SliderStep', [10 ./ Nsamp, 200 ./ Nsamp], ...
                'Units', 'normalized', 'Position', [0.092 0.015 0.818 0.025], ...
                'Callback', {@update_eeg_plot});
            
% buttons for changing the y-scale
b1h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', 'Y-', ...
                'Units', 'normalized', 'Position', [0.02 0.045 0.025 0.025], ...
                'Callback', {@inc_y_scale});
            
b2h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', 'Y+', ...
                'Units', 'normalized', 'Position', [0.02 0.93 0.025 0.025], ...
                'Callback', {@dec_y_scale});
            
% buttons for changing x-sclae
b3h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', 'X-', ...
                'Units', 'normalized', 'Position', [0.047 0.015 0.025 0.025], ...
                'Callback', {@inc_x_scale});
            
b4h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', 'X+', ...
                'Units', 'normalized', 'Position', [0.929 0.015 0.025 0.025], ...
                'Callback', {@dec_x_scale});
                     
% buttons for slow browsing through the data (in time direction)
b5h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', '<', ...
                'Units', 'normalized', 'Position', [0.072 0.015 0.02 0.025], ...
                'Callback', {@dec_slider});
            
b6h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', '>', ...
                'Units', 'normalized', 'Position', [0.909 0.015 0.02 0.025], ...
                'Callback', {@inc_slider});
    
% static text for time values
sta = zeros(1, 9);
for ca_counter = 1:9 
    sta(ca_counter) = uicontrol('Parent', p1h, 'Style', 'text', 'String', '999999', ...
                                'Units', 'normalized', 'Position', ...
                                [0.09 + (ca_counter - 1).*0.09025, 0.975, 0.1, 0.02]);
end
  
% checkboxes for channel selection
cah = zeros(1, NCh); 
for ca_counter = 1:NCh
    cah(ca_counter) = uicontrol('Parent', p1h, 'Style', 'checkbox', 'Value', 1, ...
                                'Units', 'normalized', 'Position', ...
                                [0.962, 0.075 .* (23 + 15)./ (NCh + 15) + 0.03775 .* (ca_counter - 1) .* (23 + 1)./ (NCh + 1) , 0.02, 0.02], ...
                                'Callback', {@change_channel_selection});
end

% button for select/unselect of all channels
b7h = uicontrol('Parent', p1h, 'Style', 'togglebutton', 'String', 'U', ...
                'Units', 'normalized', 'Position', [0.961 0.045 0.02 0.025], ...
                'Value', 1, 'Callback', {@select_all_cah});
            
% buttons for browsing through the markers
b8h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', 'M>', ...
                'Units', 'normalized', 'Position', [0.93 0.955 0.025 0.025], ...
                'Callback', {@jump_to_next_marker});
            
e1h = uicontrol('Parent', p1h, 'Style', 'edit', 'String', '0', ...
                'Units', 'normalized', 'Position', [0.905 0.955 0.025 0.025], ...
                'BackgroundColor', 'white');
            
b9h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', '<M', ...
                'Units', 'normalized', 'Position', [0.0470 0.955 0.025 0.025], ...
                'Callback', {@jump_to_prev_marker});
            
e2h = uicontrol('Parent', p1h, 'Style', 'edit', 'String', '0', ...
                'Units', 'normalized', 'Position', [0.0725 0.955 0.025 0.025], ...
                'BackgroundColor', 'white');
            
% button for manual selection of the x-axis scaling            
b10h = uicontrol('Parent', p1h, 'Style', 'pushbutton', 'String', 'XTick', ...
                'Units', 'normalized', 'Position', [0.005 0.015 0.04 0.025], ...
                'Callback', {@adopt_x_scale});
            
%% user defined uicontrols
% panel for the user elements
p2h = uipanel('Parent', f1h, 'Title', '', 'Position', [0.9 0 0.1 1]);
       
% user defined button
b10h = uicontrol('Parent', p2h, 'Style', 'pushbutton', 'String', 'User Button', ...
                'Units', 'normalized', 'Position', [0.05, 0.94, 0.9, 0.05], ...
                'Callback', {@user_button_callback});
            
%% main function body
% in case there are no markers given initialize minf with zeros
if nargin < 2
    minf = [0, 0];
end

% set all UI context menus
set(a1h, 'UIContextMenu', a1menu);
set(f1h, 'UIContextMenu', []);
set(p1h, 'UIContextMenu', []);

% create a link between the marker edit boxes --> they always show the same values
linkprop([e1h, e2h], 'String');

% plot the actual eeg data
update_eeg_plot;

% draw the figure
set(f1h, 'Visible', 'on');


%% Callbacks

%------------------------f1h callbacks-------------------------------------

    function mouse_move(hObject, eventdata)
        % callback function which is called whenever the mouse moves
        
        % get current courser position relative to the axis a1h
        ma_pos = get(a1h, 'CurrentPoint');
        ma_pos = ma_pos(1, 1:2);
        
        if all(ma_pos <= 1) && all(ma_pos >= 0) % only if courser is whithin axis
            
            if ~left_button_down % only if left mouse button is not pressed
                
                % draw vertical mousecurser
                set(mouse_line_h, 'XData', [ma_pos(1), ma_pos(1)]); drawnow;
                
                % calculate data index of mouse coursor
                mcursor_indi = round(ma_pos(1) .* NWin + Nstart - 1);
                
                % calculate corresponding time for coursor index
                mcursor_time = round(1 ./ fs .* mcursor_indi .* 1000);
                
                % adopt information to the host-figure name
                Title_Str = ['EEG Data Browser - Cursor Position: ', int2str(mcursor_indi), ...
                    ' (', int2str(mcursor_time), ' ms)'];
                set(f1h, 'Name', Title_Str);
                
            else % if left mouse button is pressed
                
                % update size of the yellow data selection window
                set(Selected_Window_h, 'XData', [Selected_Window_x1, Selected_Window_x1, ...
                    ma_pos(1), ma_pos(1)]);
                
            end
            
        end
        
    end

    function mouse_button_down(hObject, eventdata)
        % callback function which is called whenever a mouse button is
        % pressed
        
        % get current courser position relative to the axis a1h
        ma_pos = get(a1h, 'CurrentPoint');
        ma_pos = ma_pos(1, 1:2);
        
        if all(ma_pos <= 1) && all(ma_pos >= 0) % only if courser is whithin axis
            
            button = get(f1h, 'SelectionType'); % determine mouse button
            
            if strcmp(button, 'normal') % if left mouse button pressed
                
                % toggle state of the global left_button_down sitch
                left_button_down = 1;
                
                % set starting value of marker window (in relative coordinates)
                Selected_Window_x1 = ma_pos(1);
                
                if isempty(Selected_Window_h) % if there is no marker window
                    
                    % create yellow rectangular marker-window on position Selected_Window_x1
                    Selected_Window_h = patch([Selected_Window_x1, Selected_Window_x1, ...
                        Selected_Window_x1+eps, Selected_Window_x1+eps], [0, 1, 1, 0], ...
                        'y', 'Parent', a1h);
                    
                    % place window in the background of the axis a1h
                    child_obj = get(a1h, 'children');
                    child_obj(child_obj == Selected_Window_h) = [];
                    child_obj = [child_obj; Selected_Window_h];
                    set(a1h, 'children', child_obj);
                    
                else % if marker-window already existing
                    
                    % create new marker-window on position Selected_Window_x1
                    set(Selected_Window_h, 'XData', [Selected_Window_x1, Selected_Window_x1, ...
                        Selected_Window_x1+eps, Selected_Window_x1+eps], 'Visible', 'on');
                end
                
                % make mouse-coursor line invisible
                set(mouse_line_h, 'Visible', 'off');
                
            elseif strcmp(button, 'alt') % if right mouse button pressed
                
                % show the ui context menu for the right mouse button
                set(f1h, 'Units', 'pixels'); % somehow uicontextmenus work only on pixel coordinates
                set(a1menu, 'Position', get(f1h, 'CurrentPoint'), 'Visible', 'on');
                
                if strcmp(get(Selected_Window_h, 'Visible'), 'on') % if there is a yellow marker window
                    set(mh1, 'Enable', 'on'); % switch on entry for expand selection
                    set(mh3, 'Enable', 'on'); % switch on entry for export selection
                else % if there is now selection window
                    set(mh1, 'Enable', 'off'); % switch off entry for expand selection
                    set(mh3, 'Enable', 'off'); % switch off entry for export selection
                end
                
                % switch back to normalized units
                set(f1h, 'Units', 'normalized');
                
            end
            
        end
        
    end

    function mouse_button_up(hObject, eventdata)
        % callback function which is called whenever a mouse button is
        % released
        
        % get current courser position relative to the axis a1h
        ma_pos = get(a1h, 'CurrentPoint');
        ma_pos = ma_pos(1, 1:2);
        
        if all(ma_pos <= 1) && all(ma_pos >= 0) % only if courser is whithin axis
            
            button = get(f1h, 'SelectionType'); % determine mouse button
            
            if strcmp(button, 'normal') % if left mouse button is pressed
                
                % toggle state of the global left_button_down sitch
                left_button_down = 0;
                
                % set end value of marker window (in relative coordinates)
                Selected_Window_x2 = ma_pos(1);
                
                % draw mouse coursor line again
                set(mouse_line_h, 'Visible', 'on');
                
                % if selection window is too small --> make it invisible
                if abs(Selected_Window_x2 - Selected_Window_x1) < 0.001
                    set(Selected_Window_h, 'Visible', 'off');
                end
                
            end
            
        end
        
    end

%------------------------p1h callbacks-------------------------------------

    function jump_to_next_marker(hObject, eventdata)
        % callback function for jumping to the next marker
        
        % get marker number
        sel_marker = str2double(get(e1h, 'String'));
        
        if strcmp(get(e1h, 'String'), '0') || strcmp(get(e1h, 'String'), '-1') % for zero or -1 value
            
            mlinf = minf; % every marker is allowed
            
        else % if there is a valid marker number
            
            mlinf = minf(minf(:, 1) == sel_marker, :); % select only chosen markers
            
        end
        
        % get data index of next marker
        next_marker_indi = min(mlinf(mlinf(:, 2) > Nstart, 2) ); 
        
        if ~isempty(next_marker_indi) % if there is a next marker
            if next_marker_indi < (Nsamp - NWin) % if it is not falling out of the last possible data window
                
                % adopt slider value to the next marker index
                set(s1h, 'Value', next_marker_indi);
                
                % plot selected data
                update_eeg_plot;
                
            end
        end
            
        
    end

    function jump_to_prev_marker(hObject, eventdata)
        % callback function for jumping to the previous marker
        
        % get marker number
        sel_marker = str2double(get(e1h, 'String'));
        
        if strcmp(get(e1h, 'String'), '0') || strcmp(get(e1h, 'String'), '-1') % for zero or -1 value
            
            mlinf = minf; % every marker is allowed
            
        else % if there is a valid marker number
            
            mlinf = minf(minf(:, 1) == sel_marker, :); % select only chosen markers
            
        end
        
        % get data index of previous marker
        prev_marker_indi = max(mlinf(mlinf(:, 2) < Nstart, 2));
        
        if ~isempty(prev_marker_indi) % if there is a previous marker
            if prev_marker_indi > 0 % if marker has a valid index number
                
                % adopt slider value to the previous marker index
                set(s1h, 'Value', prev_marker_indi);
                
                % plot selected data
                update_eeg_plot;
                
            end
        end
        
    end

    function select_all_cah(hObject, eventdata)
        % callback function for selecting all channels
        
        % read value of toggle button (either 0 or 1)
        b7h_value = get(b7h, 'Value');
        
        % set all checkboxes to toggle value
        set(cah, 'Value', b7h_value);
        
        % adopt channel zelection vector
        Channel_selection_vector = b7h_value .* ones(1, NCh);
        
        % toggle String value of the toggle button
        if b7h_value == 0 % if previous toggle state was on 'Unselect'
            set(b7h, 'String', 'S');
        else % if previous toggle state was on 'Select'
            set(b7h, 'String', 'U');
        end
        
    end

    function export_selection(hObject, eventdata)
        % callback function for exporting selected data sequences to the
        % MATLAB main workspace
        
        % get selection window indizes
        Win_x1_indi = round(Selected_Window_x1 .* NWin + Nstart - 1);
        Win_x2_indi = round(Selected_Window_x2 .* NWin + Nstart - 1);
        
        % export selected window data to base workspace
        assignin('base', 'eeg_export', ...
            dinf(Win_x1_indi:Win_x2_indi, Channel_selection_vector == 1));
        
        % find markers whithin the selection window
        marker_indi = find( (minf(:, 2) >= Win_x1_indi) & (minf(:, 2) <= Win_x2_indi ) );
        if ~isempty(marker_indi) % if there are markers whithin the selection window
            
            % adopt markers indexes relative to selection window size
            marker_win_indis = minf(marker_indi, 2) + 1 - Win_x1_indi;
            
            % export selected marker data to base workspace
            assignin('base', 'mark_export', [minf(marker_indi, 1), marker_win_indis]);
            
        end
        
    end

    function export_window(hObject, eventdata)
        % callback function for exporting selected th window (a1h) data to the
        % MATLAB main workspace
        
        % export window data to base workspace
        assignin('base', 'eeg_export', ...
            dinf(Nstart:(Nstart + NWin - 1), Channel_selection_vector == 1));
        
        % find markers whithin the axis window
        marker_indi = find( (minf(:, 2) >= Nstart) & (minf(:, 2) < (Nstart + NWin) ) );
        
        if ~isempty(marker_indi) % if there are markers whithin the axis window
            
            % adopt markers indexes relative to axis window size
            marker_win_indis = minf(marker_indi, 2) + 1 - Nstart;
            
             % export selected marker data to base workspace
            assignin('base', 'mark_export', [minf(marker_indi, 1), marker_win_indis]);
            
        end
        
    end

    function expand_window(hObject, eventdata)
        % callback function for expanding the selection window to the whole
        % axis a1h
        
        % get selection window indizes
        Win_x1_indi = round(Selected_Window_x1 .* NWin + Nstart - 1);
        Win_x2_indi = round(Selected_Window_x2 .* NWin + Nstart - 1);
        
        % adjust slider value to beginning of selection window
        set(s1h, 'Value', Win_x1_indi);
        
        % adop X_Scale to selected window
        X_Scale = (Win_x2_indi - Win_x1_indi) ./ NWin_init;
        
        % plot selected data
        update_eeg_plot;
        
    end

    function change_channel_selection(hObject, eventdata)
        % callback function for updating the channel selection checkboxes
        
        % read values of all channel checkboxes
        for n = 1:NCh
            Channel_selection_vector(n) = get(cah(n), 'Value');
        end
        
        % save results in Channel_selection_vector
        Channel_selection_vector = fliplr(Channel_selection_vector);
        
    end

    function inc_slider(hObject, eventdata)
        % callback function for updating plotted data according to new slider
        % position
        
        % read new slider value
        slider_value = get(s1h, 'Value');
        
        % make shure that slider value is not getting too large
        if slider_value < get(s1h, 'Max');
            set(s1h, 'Value', slider_value+1);
        end
        
        % plot selected data
        update_eeg_plot;
        
    end

    function dec_slider(hObject, eventdata)
        % callback function for updating plotted data according to new slider
        % position
        
        % read new slider value
        slider_value = get(s1h, 'Value');
        
        % make shure that slider value is not getting too small
        if slider_value > 1
            set(s1h, 'Value', slider_value-1);
        end
        
        % plot selected data
        update_eeg_plot;
        
    end

    function inc_x_scale(hObject, eventdata)
        % callback function for updating plotted data according to new slider
        % position
        
        % increase X_Scale value 
        X_Scale = X_Scale .* 1.5;
        
        % make shure that the new window size will be valid
        if ( (Nstart + NWin_init * X_Scale - 1) <= Nsamp ) && ...
             ( Nsamp - floor(NWin_init.*X_Scale) > 1 ) && ...
             ( NWin_init * X_Scale < Max_Win_Samples )
         
            % adopt Max-Value of the slider
            set(s1h, 'Max', Nsamp - floor(NWin_init.*X_Scale));
            
            % plot selected data
            update_eeg_plot;
        
        else % if new window size is not valid
            
            % restore old X_Scale
            X_Scale = X_Scale ./ 1.5;
            
        end
        
    end

    function dec_x_scale(hObject, eventdata)
        % callback function for updating plotted data according to new slider
        % position
        
        % decrease X_Scale value 
        X_Scale = X_Scale ./ 1.5;
        
        % adopt Max-Value of the slider
        set(s1h, 'Max', Nsamp - floor(NWin_init.*X_Scale));
        
        % plot selected data
        update_eeg_plot;
        
    end

    function adopt_x_scale(hObject, eventdata)
        % callback function for manual adjustment of x-scale
        
        % create matlab input dialog
        prompt = {'Enter X-Grid spacing either in ms: ', 'or in bins: '};
        name = 'X-Scale';
        numlines = 1;
        default_answer = {'200', ''};
        options.Resize = 'on';
        options.WindowStyle = 'modal';
        answer = inputdlg(prompt, name, numlines, default_answer, options);
        
        if ~isempty(answer) % if there was an answer to the dialog
            
            if ~isempty(answer{1}) % if user gave the X_Scale value in ms
                
                % adopt initial window size
                NWin_init = round( str2double(answer{1}) ./ 1000 .* fs .* 10 );
                
                % reset X_Scale
                X_Scale = 1;
                
                % plot selected data
                update_eeg_plot;
                
            else % if user gave the X_Scale value via number of indices
                
                % adopt initial window size
                NWin_init = str2double(answer{2}) .* 10;
                
                % reset X_Scale
                X_Scale = 1;
                
                % plot selected data
                update_eeg_plot;
                
            end
            
        end
        
    end

    function inc_y_scale(hObject, eventdata)
        % callback function for zooming along y-scale in axis a1h
        
        % increase Y_Scale
        Y_Scale = Y_Scale .* 1.5;
        
        % plot selected data
        update_eeg_plot;
        
    end

    function dec_y_scale(hObject, eventdata)
        % callback function for zooming along y-scale in axis a1h
        
        % decrease Y_Scale
        Y_Scale = Y_Scale ./ 1.5;
        
        % plot selected data
        update_eeg_plot;
        
    end

    function update_eeg_plot(hObject, eventdata)
        % slider callback function for plotting the actual data in axis a1h
        
        % clear figure (including child objects!)
        cla(a1h); Selected_Window_h = [];
        
        % restore initial settings
        plot(a1h, [zeros(1, NCh); ones(1, NCh)], [center; center], 'k-.')
        set(a1h, 'UIContextMenu', a1menu);
        
        % extract selected data values
        Nstart = round(get(s1h, 'Value')); % get start index from slider
        NWin = round(NWin_init .* X_Scale); % get number of samples in the window
        Win_indiz = Nstart : Nstart + NWin - 1; % calc data indices for the window
        channel_hight = 1 ./ (Y_Scale .* NCh); % compute maximum hight of each channel
        chy = zeros(NWin, NCh); % initialize data array
        for n = 1:NCh % for each channel
            chy(:, n) = dinf(Win_indiz, n).'; % extract data values to chy
            chy(:, n) = chy(:, n) ./ max_amp .* channel_hight + center(NCh - n + 1); % adopt channel mean and hight
        end
        
        % plot all channels
        h = plot(a1h, repmat(linspace(0, 1, NWin).', [1, NCh]), chy, 'b-');
        
        % set alternating color for eeg channels
        for n = 1:NCh % for each channel
            if mod(n, 2) % if channel number is even
                set(h(n), 'Color', [0 0 1]); % set color to pure blue
            else % if channel number is odd
                set(h(n), 'Color', [0 0.5 1]); % set color to light blue
            end
        end
        
        % adopt x-tick labels (window is divided into 9 grid positions along x-axis)
        X_tick_labels = round((0.1:0.1:0.9) .* NWin + Nstart - 1); % get indices for x-tick labels
        X_tick_label_time = round(1 ./ fs .* X_tick_labels .* 1000); % calc corresponding times in milli-seconds
        X_tick_labels_cell = cell(1, 9); % inittialize cell array for label strings
        for n = 1:9 % for each x-axis label
            X_tick_labels_cell{n} = int2str(X_tick_labels(n)); % convert x-tick indices to string
            set(sta(n), 'String', int2str(X_tick_label_time(n))); % set staitic text properties to the corresponding times in ms
        end
        set(a1h, 'XTickLabel', X_tick_labels_cell);
        
        % extract marker indices
        marker_indi = find( (minf(:, 2) >= min(Win_indiz)) & (minf(:, 2) < max(Win_indiz)) );
        
        if ~isempty(marker_indi) % if there are markers
            
            % get number of markers to be plotted
            marker_num = length(marker_indi); 
            
            % plot marker lines
            window_pos = (minf(marker_indi, 2) + 1 - Nstart) ./ NWin; % get marker position whithin the window
            plot(a1h, [window_pos, window_pos].', [zeros(marker_num, 1), ...
                ones(marker_num, 1)].', 'r-', 'LineWidth', 2); % plot vertical red line for each marker
            
            % plot marker labels
            Marker_names = cell(1, marker_num);
            for n = 1:marker_num % for all markers
                Marker_names{n} = int2str(minf(marker_indi(n), 1)); % get marker number and put it into a string
            end
            th = text(window_pos+0.01, 0.98.*ones(marker_num, 1), Marker_names); % plot marker numbers
            set(th, 'FontSize', 12, 'Edgecolor', 'red', 'FontWeight', 'bold', 'LineWidth', 2); % adopt Font properties
            
        end
        
        % plot mouse curser line on the edge of the axis window
        mouse_line_h = plot(a1h, [1 1], [0 1], 'm-');
        
    end

%% Support Functions

    function out = get_processing_data
        % function for getting the actually selected data samples from all
        % seleted channels. If there is no mouse-selection the whole window
        % data is given back.
        
        if strcmp(get(Selected_Window_h, 'Visible'), 'on') % is there a mouse slection?
            
            % get selection window indizes
            Win_x1_indi = round(Selected_Window_x1 .* NWin + Nstart - 1);
            Win_x2_indi = round(Selected_Window_x2 .* NWin + Nstart - 1);
            
            % extract selected window data to base workspace
            out = dinf(Win_x1_indi:Win_x2_indi, Channel_selection_vector == 1);
            
        else % if there is no mouse slection window?
            
            % extract whole axis window
            out = dinf(Nstart:(Nstart + NWin - 1), Channel_selection_vector == 1);
            
        end
        
    end

%% user defined functions

    function user_button_callback(hObject, eventdata)
        % user defined callback funktion for user button
        
        % get user selected data from data-browser window
        %selected_data = get_processing_data;
        
        disp('please insert your code here ...');
        
    end

end