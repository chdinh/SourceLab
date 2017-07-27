function forwardEEG()
%
% forwardEEG() is a MATLAB GUI to calculate the surface potential maps of 
% up to 5 dipoles for a headmodel consisting of up to 4 concentric spheres.
%
% The number of shells as well as the shell radii and conductivities are 
% fully user customizable.
%
% An interactive dipole positioner allows the user to easily place the
% dipoles within the head model.
%
% A 3D view of the resulting surface potential map makes it possible to
% verify the potential distribution before exporting the simulation data to
% the MATLAB workspace.
%
% For the data export the user can choose one out of 4 different electrode 
% setups. If another setup is necessary, it can be easily defined in an
% electrode setup definition (.esd) file. For further information on this
% topic see the 'readme_ES.txt'.
%
% For the potential map calculation forwardEEG uses FIELDTRIP functions. So
% be sure that the FIELDTRIP toolbox is present on your machine as well as
% properly assigned in your MATLAB path variable (File -> Set Path...). The
% FIELDTRIP toolbox can be obtained from the <a href="http://fieldtrip.fcdonders.nl">FIELDTRIP homepage</a>
% (fieldtrip.fcdonders.nl)

%% Inits
FloatingCrosshair = [];
currMousePos = 0;
CrosshairAxes = 0;
numberOfShells = 4;
radii = [7.5 7.1 6.5 6.3];
conds = [0.33 0.0042 1 0.33];
numberOfDipoles = 1;
numberOfMovingDipoles = 0;
dipolePosition = zeros(5,3);
movingdipolePosition =zeros(5,3);
dipolePositionMov=[]; % Matrix with all dipole positions if moving dipoles are selected
movingsamples=[]; % vector with the number of moving dipole positions for each moving dipole
dipoleMoment = zeros(5,3);
movingdipoleMoment =zeros(5,3);
elec = [];
vol = [];
elecSetups = {};
elecSetup = [];
numsec = 36; % define the number of sections per 360 degrees
pl_potMap = 0;
CrosshairColors = {'g'  [1 0.5882 0] 'm' 'c' [0.5882 0.5882 0.3922]};
dipPosColors= [0,1,0; 1, 0.5882, 0; 1,0,1;0,1,1; 0.5582 0.5582 0.3922];
axlimit = 1.2*radii(1);
cElecSetups = {};
electrodeSignals=[]; % electrode signals
signal=[]; % dipole signals
lf=[]; % the leadfiel matrix
lfMov=[]; % the leadfield matrix if moving dipole(s) are selected
%lfMovTens=zeros(size(lfMov,1),numberOfDipoles*3,N); % leadfield tensor containing the time varying leadfield matrices if moving dipole(s) are selected
lfMovTens=[]; % leadfield tensor if moving dipoles are selected
pot=[]; % potential distribution
potMov=[]; % potential matrix if moving dipoles are selected
potMov_topoplot=[];
dipolePosMovTens=[];
f1h=0; % handles to submain GUI "EEG Data Browser"
f_decomp=0; % handles to submain GUI "EEG Decomposition Panel"

NLG=100; % nerve conduction velocity
N=500; % length of dipole signal
TFA_overlap='ActivityNOL'; % 'ActivityNOL'
SNRnoise=10;

% close all
% clc

%% Error messages
errInvRadius = 'Invalid shell radius! Enter valid shell radii which suffice 0<R1<R2<R3!';
errInvdipolePosition = 'Invalid dipole position! Position has to be within the head model!';
errInvdipoleMoment = 'Invalid dipole moment! Enter a valid dipole moment!';
errInvOutputVarName = 'The output variable name is not valid! Choose a valid one!';
errStartEndPosMovDipNotDiff = 'The start and end position of a moving dipole has to be different!';
errNoDipoleSignalSelected= 'Signals for all dipoles have to be selected!';


%% create UI elements

% =========================================================================
% create host figure
% =========================================================================
f_main = figure(...
    'Name', 'Forward EEG Simulator v2.0', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'Position', [100 100 1550 900], ...
    'Units', 'normalized', ...
    'NumberTitle', 'off', ...
    'Pointer', 'arrow', ... 
    'Resize', 'off', ...
    'Visible', 'off', ...
    'WindowButtonMotionFcn', {@mouse_move}, ...
    'WindowButtonDownFcn', {@button_down}, ...
    'WindowKeyPressFcn', {@button_down},...
    'Renderer','OpenGL');

% =========================================================================
% create viewer panel and elements
% =========================================================================

% panel -------------------------------------------------------------------
p_viewer = uipanel(...
    'Parent', f_main, ...
    'Title', 'Viewer', ...
    'Position', [0.01 0.01 0.57 0.98]);
% -------------------------------------------------------------------------

% dipole positioning panel ------------------------------------------------
p_sourceloc = uipanel(...
    'Parent', p_viewer, ...
    'Title', 'Interactive Dipole Positioner (Use ''1...5'' resp. "6...8" keys to place dipoles resp. moving dipoles 1...3. Use left mouse button to place dipole 1)', ...
    'Position', [0.02 0.6 0.96 0.38]);

% right view axes
a_sourceloc(1) = axes(...
    'Parent', p_sourceloc, ...
    'NextPlot', 'add', ...
    'Position', [0.065 0.17 0.26 0.7], ...
    'XLim', [-axlimit axlimit], ...
    'XLimMode', 'manual', ...
    'YLim', [-axlimit axlimit], ...
    'YLimMode', 'manual', ...
    'PlotBoxAspectRatio', [1 1 1], ...
    'PlotBoxAspectRatioMode', 'manual', ...
    'DrawMode', 'fast');
title('right view');
xlabel('x');
ylabel('z');

% top view axes
a_sourceloc(2)  = axes(...
    'Parent', p_sourceloc, ...
    'NextPlot', 'add', ...
    'Position', [0.3875 0.17 0.26 0.7], ...
    'XDir', 'reverse', ...
    'XLim', [-axlimit axlimit], ...
    'XLimMode', 'manual', ...
    'YLim', [-axlimit axlimit], ...
    'YLimMode', 'manual', ...
    'PlotBoxAspectRatio', [1 1 1], ...
    'PlotBoxAspectRatioMode', 'manual', ...
    'DrawMode', 'fast');
title('top view');
xlabel('y');
ylabel('x');

% front view axes
a_sourceloc(3)  = axes(...
    'Parent', p_sourceloc, ...
    'NextPlot', 'add', ...
    'Position', [0.715 0.17 0.26 0.7], ...
    'XLim', [-axlimit axlimit], ...
    'XLimMode', 'manual', ...
    'YLim', [-axlimit axlimit], ...
    'YLimMode', 'manual', ...
    'PlotBoxAspectRatio', [1 1 1], ...
    'PlotBoxAspectRatioMode', 'manual', ...
    'DrawMode', 'fast');
title('front view');
xlabel('y');
ylabel('z');

% context menu elements (available via right click in the axis a_sourcelog())
m_sourceloc = uicontextmenu('Parent', f_main);
h_m1 = uimenu(m_sourceloc, 'Label', 'Open in new window...', 'Callback', {@save_dipole_positioner_viewer});
%h_m2 = uimenu(h_ctm1, 'Label', 'Export all data', 'Callback', {@export_data});

% floating crosshair (crosshair that follows the mouse)
FloatingCrosshair(1) = plot(...
    a_sourceloc(1), ...
    [-axlimit axlimit], ...
    [0 0], ...
    'k-', ...
    'Visible', 'off');
FloatingCrosshair(2) = plot(...
    a_sourceloc(1), ...
    [0 0], ...
    [-axlimit axlimit], ...
    'k-', ...
    'Visible', 'off');

% static dipole crosshairs (crosshairs that indicate dipole positions)
CHvisibility = 'on';
for j=1:5
    for i=1:3
        Crosshair(i,j) = plot(...
            a_sourceloc(i), 0, 0, ...
            'Marker', '+', ...
            'LineStyle', 'none', ...
            'MarkerEdgeColor', CrosshairColors{j}, ...
            'Visible', CHvisibility, ...
            'MarkerSize', 9);
    end
    if (j == numberOfDipoles)
        CHvisibility = 'off';
    end
end

% create marker for end position of moving dipoles
%markerMov = 

% moving dipole crosshairs (crosshairs that indicate end position of moving
% dipoles)
CHMvisibility = 'off';
for j=1:3
%    if (j == (numberOfMovingDipoles))
%         CHMvisibility = 'off';
    for i=1:3
        movingCrosshair(i,j) = plot(...
            a_sourceloc(i), 0, 0,...
            'Marker', '*',...
            'LineStyle', 'none',...
            'MarkerEdgeColor', CrosshairColors{j}, ...
            'Visible', CHMvisibility, ...
            'MarkerSize', 9);
    end
     
end
% -------------------------------------------------------------------------

% 3D potential and electrode panel ----------------------------------------
p_3Dview = uipanel(...
    'Parent', p_viewer, ...
    'Title', '3D Potential Map and Electrode View', ...
    'Position', [0.02 0.02 0.58 0.56]);

% 3D potential and electrode plot axes
a_3Dview = axes(...
    'Parent', p_3Dview, ...
    'OuterPosition', [0.0 0.0 1 1], ...
    'XLim', [-axlimit axlimit], ...
    'XLimMode', 'manual', ...
    'YLim', [-axlimit axlimit], ...
    'YLimMode', 'manual', ...
    'ZLim', [-axlimit axlimit], ...
    'ZLimMode', 'manual', ...
    'PlotBoxAspectRatio', [1 1 1], ...
    'PlotBoxAspectRatioMode', 'manual', ...
    'DrawMode', 'fast', ...
    'NextPlot', 'add');

% 3D electrode plot
pl_elecSetup = plot3(...
    a_3Dview, ...
    0, ...
    0, ...
    0, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', 'y', ...
    'MarkerEdgeColor', 'k', ...
    'Visible', 'off');

% 3D potential map plot
pl_potMap = surf(...
    a_3Dview, ...
    sphere(10), ...
    'Visible', 'off');

shading(a_3Dview, 'interp'); % set shading to 'interp' for a nice surface

% 3D nose plot (for indicating directions)
pl_nose = patch(...
    [0 0 1], ...
    [1 0 0], ...
    [0 1 0], ...
    zeros(3,1), ...
    'Parent', a_3Dview, ...
    'Visible', 'off');

% % 3D dipole plot (for indicating the dipole position)
% pl_dipolePos = plot3(...
%     a_3Dview,...
%     0,...
%     0,...
%     0,...
%     'LineStyle', 'none', ...
%     'Marker', 'o', ...
%     'MarkerSize', 4, ...
%     'MarkerFaceColor', 'k', ...
%     'MarkerEdgeColor', 'k', ...
%     'Visible', 'Off');

%3D dipole plot (for indicating the dipole position)

%define starting positions
pl_dipolePos = scatter3(...
    a_3Dview,...
    0,...
    0,...
    0,...
    15,...
    'filled',...
    'CData',[1 1 1],...
    'Marker', 'o', ...
    'Visible', 'Off');

% 3D plot settings
set(a_3Dview, 'View', [37.5 30]);
xlabel(a_3Dview, 'x')
ylabel(a_3Dview, 'y')
zlabel(a_3Dview, 'z')
axis(a_3Dview, 'equal')
rotate3d off
rotate_handle = rotate3d(a_3Dview);
% -------------------------------------------------------------------------

% View Control subpanel ---------------------------------------------------
p_viewControl = uipanel(...
    'Parent', p_viewer, ...
    'Title', 'View Control', ...
    'Position', [0.62 0.28 0.36 0.3]);

% View Control buttons
pb_rightView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Right View', ...
    'Units', 'normalized', ...
    'Position', [0.05 0.54 0.266 0.18], ...
    'Callback', {@change3DView});

pb_leftView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Left View', ...
    'Units', 'normalized', ...
    'Position', [0.05 0.77 0.266 0.18], ...
    'Callback', {@change3DView});

pb_topView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Top View', ...
    'Units', 'normalized', ...
    'Position', [0.366 0.54 0.266 0.18], ...
    'Callback', {@change3DView});

pb_bottomView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Bottom View', ...
    'Units', 'normalized', ...
    'Position', [0.366 0.77 0.266 0.18], ...
    'Callback', {@change3DView});

pb_frontView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Front View', ...
    'Units', 'normalized', ...
    'Position', [0.683 0.54 0.266 0.18], ...
    'Callback', {@change3DView});

pb_backView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Back View', ...
    'Units', 'normalized', ...
    'Position', [0.683 0.77 0.266 0.18], ...
    'Callback', {@change3DView});

pb_defaultView = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Default View', ...
    'Units', 'normalized', ...
    'Position', [0.05 0.29 0.266 0.18], ...
    'Callback', {@change3DView});

pb_potentialCourse = uicontrol(...
    'Parent', p_viewControl, ...
    'Style', 'pushbutton', ...
    'String', 'Potential course', ...
    'Units', 'normalized', ...
    'Enable', 'Off',...
    'Position', [0.366 0.29 0.582 0.18], ...
    'Callback', {@showPotentialCourse});

% radio button group "Show dipole position" 
rbg_showDipolePosition = uibuttongroup(...
    'Parent',p_viewControl,...
    'Units', 'normalized',...
    'Position', [0.275 0.04 0.6 0.2],...
    'Title', 'Show Dipole Position',...
    'BorderType', 'none');
    
uicontrol('Style', 'Radio',...
    'String', 'No',...
    'Units', 'normalized',...
    'Position', [0.12 0.1 0.3 0.5],...
    'Parent', rbg_showDipolePosition);

uicontrol('Style', 'Radio',...
    'String', 'Yes',...
    'Units', 'normalized',...
    'Position', [0.42 0.1 0.3 0.5],...
    'Parent', rbg_showDipolePosition);
 
set(rbg_showDipolePosition,'SelectionChangeFcn',{@showDipolePosition});

% Electrode setup panel -------------------------------------------------------
p_exportMenu = uipanel(...
    'Parent', p_viewer, ...
    'Title', 'Electrode Setup', ...
    'Position', [0.62 0.02 0.36 0.24]);

% Electrode setup dropdown menu
% t_elecSetup = uicontrol(...
%     'Parent', p_exportMenu, ...
%     'Style', 'text', ...
%     'Units', 'normalized', ...
%     'HorizontalAlignment', 'left', ...
%     'String', 'Electrode Setup:', ...
%     'Position', [0.05 0.9 0.9 0.05]);

dd_elecSetup = uicontrol(...
    'Parent', p_exportMenu, ...
    'Style', 'popup',...
    'Units', 'normalized', ...
    'Position', [0.05 0.845 0.9 0.05], ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @updateElecSetup);


% Reload Electrode Setups button
pb_reloadElecSetups = uicontrol(...
    'Parent', p_exportMenu, ...
    'Style', 'pushbutton', ...
    'String', 'Reload Electrode Setups', ...
    'Units', 'normalized', ...
    'Position', [0.05 0.47 0.9 0.2], ...
    'Enable', 'on', ...
    'Callback', {@reloadElecSetups});
    
%reloadElecSetups(); % initially load electrode setups to fill dropdown

% warning panel and text
p_vcNotUp2Date = uipanel(...
    'Parent', p_exportMenu, ...
    'Position', [0.05 0.07 0.9 0.3]);

t_pmNotUp2Date = uicontrol(...
    'Parent', p_vcNotUp2Date, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'Visible', 'on', ...
    'String', {'Potential map and/or electrode signals is/are not up to date!'}, ...
    'Position', [0.05 0.05 0.9 0.8], ...
    'ForegroundColor', 'r');

% -------------------------------------------------------------------------

% =========================================================================
% create model settings panel and elements
% =========================================================================

% panel -------------------------------------------------------------------
p_modelsettings = uipanel(...
    'Parent', f_main, ...
    'Title', 'Model Settings', ...
    'Position', [0.59 0.01 0.25 0.38]);

% number of shells dropdown menu
t_numberOfShells = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Number of concentric shells:', ...
    'Position', [0.05 0.89 0.65 0.05]);

dd_numberOfShells = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'popup',...
    'Units', 'normalized', ...
    'String', '1|2|3|4',...
    'Value', 4, ...
    'Position', [0.7 0.9 0.25 0.05], ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @setNumberOfShells);
    
% shell properties static texts
t_shellprops = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Shell properties (1 = outermost):', ...
    'Position', [0.05 0.74 0.9 0.05]);

t_shellnumber = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Shell No.', ...
    'Position', [0.05 0.66 0.2 0.05]);

t_shellradii = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Radius (in cm)', ...
    'Position', [0.25 0.66 0.3 0.05]);
    
t_shellconds = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Conductivity (in S/m)', ...
    'Position', [0.625 0.66 0.325 0.05]);

% basic position and size data for static shell property texts
lefttextoffset = 0.05;
lowertextoffset = 0.58;
texthight = 0.06;
textwidth = 0.2;
textdist = 0.08;

% basic position and size data for shell property edits
lefteditoffset = 0.25;
lowereditoffset = 0.585;
edithight = 0.06;
editwidth = 0.325;
editdisth = 0.375;
editdistv = 0.08;

% create shell property texts and edits in a loop
for i=1:4
    t_shellprops(i) = uicontrol(...
        'Parent', p_modelsettings, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', sprintf('Shell %i:', i), ...
        'Position', [lefttextoffset (lowertextoffset - (i-1)*textdist) textwidth texthight]);
    
    e_shellradius(i) = uicontrol(...
        'Parent', p_modelsettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', num2str(radii(i)), ...
        'Position', [lefteditoffset (lowereditoffset - (i-1)*editdistv) editwidth edithight], ...
        'BackgroundColor', [1 1 1], ...
        'UserData', i, ...
        'Callback', {@checkRadius});
    
    e_shellconds(i) = uicontrol(...
        'Parent', p_modelsettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', num2str(conds(i)), ...
        'Position', [(lefteditoffset + editdisth) (lowereditoffset - (i-1)*editdistv) editwidth edithight], ...
        'BackgroundColor', [1 1 1], ...
        'UserData', i, ...
        'Callback', {@checkCond});
end

% Create Volume Conductor button
pb_createVolumeConductor = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'pushbutton', ...
    'String', 'Create Volume Conductor', ...
    'Units', 'normalized', ...
    'Position', [0.05 0.05 0.9 0.1], ...
    'Callback', {@createVolumeConductor});

pb_resetVolumeConductor = uicontrol(...
    'Parent', p_modelsettings, ...
    'Style', 'pushbutton', ...
    'String', 'Reset Volume Conductor to Default', ...
    'Units', 'normalized', ...
    'Position', [0.05 0.2 0.9 0.1], ...
    'Callback', {@resetVolumeConductor});

% =========================================================================
% create source settings panel and elements
% =========================================================================

% panel -------------------------------------------------------------------
p_sourcesettings = uipanel(...
    'Parent', f_main, ...
    'Title', 'Source Settings', ...
    'Position', [0.59 0.41 0.40 0.58]);
% -------------------------------------------------------------------------

% number of dipoles dropdown menu
t_numberOfDipoles = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Number of dipoles:', ...
    'Position', [0.03 0.89 0.5 0.05]);

dd_numberOfDipoles = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'popup',...
    'Units', 'normalized', ...
    'String', '1|2|3|4|5',...
    'Value', numberOfDipoles, ...
    'Position', [0.23 0.9 0.15 0.05], ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @setNumberOfDipoles);

t_numberOfMovingDipoles = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Number of moving dipoles:', ...
    'Position', [0.45 0.89 0.5 0.05]);

dd_numberOfMovingDipoles = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'popup',...
    'Units', 'normalized', ...
    'String', '0|1|2|3',...
    'Value', numberOfMovingDipoles+1,...
    'Position', [0.75 0.9 0.15 0.05], ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @setNumberOfMovingDipoles);

% basic position and size data for static dipole property texts
lefttextoffset = 0.03;
lowertextoffset = 0.775;
texthight = 0.04;
textwidth = 0.5;
textdist = 0.05;

% basic position and size data for dipole property edits
lefteditoffset = 0.225;
lowereditoffset = 0.79;
edithight = 0.04;
editwidth = 0.08;
editdisth = 0.1;
editdistv = 0.05;
lefteditmovingoffset = 0.53; % basic position data for moving dipole property edits
%lowereditsignaloffset = 0.25; % basic position for signal property edits
textdistsignal = 0.03; % basis text distinction between pop up menus for signal selection
lowertextsignaloffset = 0.27; % basic position for signal property edits
signaleditdist = 0.03; % basis distinction between two signal pop up menus

% column header static texts
t_dipolex = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'center', ...
    'String', 'x', ...
    'Position', [lefteditoffset-0.01 (lowertextoffset + 0.06) editwidth texthight]);

t_dipoley = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'center', ...
    'String', 'y', ...
    'Position', [(lefteditoffset-0.01 + editdisth) (lowertextoffset + 0.06) editwidth texthight]);

t_dipolez = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'center', ...
    'String', 'z', ...
    'Position', [(lefteditoffset-0.01 + 2*editdisth) (lowertextoffset + 0.06) editwidth texthight]);

t_movingdipolex = uibutton(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'center', ...
    'String', 'x_{end}', ...
    'interpreter', 'tex',...
    'Position', [lefteditmovingoffset-0.01 (lowertextoffset + 0.06) editwidth texthight]);

t_movingdipoley = uibutton(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'center', ...
    'String', 'y_{end}', ...
    'interpreter', 'tex',...
    'Position', [(lefteditmovingoffset-0.01 + editdisth) (lowertextoffset + 0.06) editwidth texthight]);

t_dipolemovingz = uibutton(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'center', ...
    'String', 'z_{end}', ...
    'interpreter','tex',...
    'Position', [(lefteditmovingoffset-0.01 + 2*editdisth) (lowertextoffset + 0.06) editwidth texthight]);

% t_signal = uicontrol(...
%     'Parent', p_sourcesettings, ...
%     'Style', 'text', ...
%     'Units', 'normalized', ...
%     'HorizontalAlignment', 'center', ...
%     'String', 'signal', ...
%     'Position', [(lefteditsignaloffset-0.01 + 2.5*editdisth) (lowertextoffset + 0.06) editwidth texthight]);

% create dipole property static texts and edits for static and moving 
% dipoles and pop up menues for selecting the signals in a loop
for i = 1:5
    % dipole i position row header
    t_dipolePosition(i) = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', sprintf('Dipole %i position:', i), ...
    'Position', [lefttextoffset (lowertextoffset - 2*(i-1)*textdist) textwidth texthight]);
    
    % dipole i moment row header
    t_dipoleMoment(i) = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', sprintf('Dipole %i moment:', i), ...
    'Position', [lefttextoffset (lowertextoffset - (2*(i-1)+1)*textdist) textwidth texthight]);

    % dipole i moment row header
    t_dipoleSignal(i) = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', sprintf('Dipole %i signal:', i), ...
    'Position', [lefttextoffset (lowertextsignaloffset - (2*(i-1))*textdistsignal) textwidth texthight]);
    
    % create dipole i position edit fields in a loop (two for loops for
    % position and moment are used because of the tabulator sequence)
    for j = 1:3
        e_dipolePosition(i,j) = uicontrol(...
        'Parent', p_sourcesettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', '0', ...
        'Enable', 'on', ...
        'Position', [(lefteditoffset + (j-1)*editdisth) (lowereditoffset - 2*(i-1)*editdistv) editwidth edithight], ...
        'BackgroundColor', CrosshairColors{i}, ...
        'UserData', [i j], ...
        'Callback', {@refreshCrosshairs});
    end
    
    % create dipole i moment edit fields in a loop (two for loops for
    % position and moment are used because of the tabulator sequence)
    for j = 1:3
        e_dipoleMoment(i,j) = uicontrol(...
        'Parent', p_sourcesettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', '0', ...
        'Enable', 'on', ...
        'Position', [(lefteditoffset + (j-1)*editdisth) (lowereditoffset - (2*(i-1)+1)*editdistv) editwidth edithight], ...
        'BackgroundColor', CrosshairColors{i}, ...
        'UserData', [i j], ...
        'Callback', {@checkdipoleMoment});
    end
    
    if i<=3
    % create moving dipole i=1:3 position edit fields in a loop (two for loops for
    % position and moment are used because of the tabulator sequence)
    for j = 1:3
        e_movingdipolePosition(i,j) = uicontrol(...
        'Parent', p_sourcesettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', '0', ...
        'Enable', 'on', ...
        'Position', [(lefteditmovingoffset + (j-1)*editdisth) (lowereditoffset - 2*(i-1)*editdistv) editwidth edithight], ...
        'BackgroundColor', CrosshairColors{i}, ...
        'UserData', [i j], ...
        'Callback', {@refreshMovingCrosshairs});
    end
    % create moving dipole i=1:3 moment edit fields in a loop (two for loops for
    % position and moment are used because of the tabulator sequence)
    for j = 1:3
        e_movingdipoleMoment(i,j) = uicontrol(...
        'Parent', p_sourcesettings, ...
        'Style', 'edit', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'String', '0', ...
        'Enable', 'on', ...
        'Position', [(lefteditmovingoffset + (j-1)*editdisth) (lowereditoffset - (2*(i-1)+1)*editdistv) editwidth edithight], ...
        'BackgroundColor', CrosshairColors{i}, ...
        'UserData', [i j], ...
        'Callback', {@checkmovingdipoleMoment});
    end
    end
    % create signal edit fields in a loop
    dd_signal(i) = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'popup',...
    'Units', 'normalized', ...
    'String', 'none|alpha-band sinus wave|beta-band sinus wave|ts-alpha-band sinus wave|ts-beta-band sinus wave|gamma-band sinus wave|evoked potential|sleep spindles|wave|spikes|spike wave complex|eye blink|polyspikes|rectangle|paraboloid|triangle|sinus period|gauss|rect|time-shifted spike|sawtooth|gauss noise',...
    'Enable', 'on',...
    'Position', [(lefteditoffset) (lowertextsignaloffset - ((2*(i-1)+0.01)*signaleditdist)+0.01) 0.28 (edithight)], ...
    'BackgroundColor', [1 1 1], ...
    'Callback', @setSignal);
end

set(e_dipoleMoment, 'Enable', 'off'); % disable all dipole moment edits
set(e_dipoleMoment(:,1:numberOfDipoles), 'Enable', 'off'); % enable dipole moment edits for dipoles 1:numberOfDipoles
set(e_dipolePosition, 'Enable', 'off'); % disable all dipole position edits
set(e_dipolePosition(:,1:numberOfDipoles), 'Enable', 'off'); % enable dipole position edits for dipoles 1:numberOfDipoles
set(e_movingdipoleMoment, 'Enable', 'off'); % disable all moving dipole moment edits
set(e_movingdipolePosition, 'Enable', 'off'); % disable all moving dipole position edits


% Calculate Potentials button
pb_calculatePotentials = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'pushbutton', ...
    'String', 'Calculate Potentials', ...
    'Units', 'normalized', ...
    'Position', [0.55 0.24 0.4 0.075], ...
    'Callback', {@calculatePotentials});

% Calculate Electrode Signals button
pb_calculateElectrodeSignals = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'pushbutton', ...
    'String', 'Calculate Electrode Signals', ...
    'Enable', 'off',...
    'Units', 'normalized', ...
    'Position', [0.55 0.14 0.4 0.075], ...
    'Callback', {@calculateElectrodeSignals});

% Show Electrode Signals button
pb_showElectrodeSignals = uicontrol(...
    'Parent', p_sourcesettings, ...
    'Style', 'pushbutton', ...
    'String', 'Show Electrode Signals', ...
    'Enable', 'off',...
    'Units', 'normalized', ...
    'Position', [0.55 0.04 0.4 0.075], ...
    'Callback', {@showElectrodeSignals});

% Additive noise radio buttons
rbg_additiveNoise = uibuttongroup(...
    'Parent',p_sourcesettings,...
    'Units', 'normalized',...
    'Position', [0.55 0.34 0.4 0.17],...
    'Title', 'Additive Noise',...
    'BorderType', 'etchedin');%,...
    %'SelectionChangeFcn','{@additiveNoise}');
%'Title', ({'Additive' ' Noise'}),...

rb_whiteNoise = uicontrol('Style', 'Radio',...
    'String', 'White Noise',...
    'Units', 'normalized',...
    'Position', [0.1 0.5 0.6 0.4],...
    'Parent', rbg_additiveNoise);

rb_backgroundEEG = uicontrol('Style', 'Radio',...
    'String', 'Background EEG',...
    'Units', 'normalized',...
    'Position', [0.1 0.1 0.6 0.4],...
    'Parent', rbg_additiveNoise);

set(rbg_additiveNoise,'SelectionChangeFcn',{@additiveNoise});

t_SNRnoise = uicontrol(...
    'Parent', rbg_additiveNoise, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'SNR:', ...
    'Position', [0.75 0.4 0.2 0.4]);

e_SNRnoise = uicontrol(...
    'Parent', rbg_additiveNoise, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'String', SNRnoise, ...
    'Position', [0.75 0.2 0.2 0.3],...
    'Enable','On',...
    'Callback', {@addSNRnoise});

% warning panel and texts
% p_vcNotUp2Date = uipanel(...
%     'Parent', p_sourcesettings, ...
%     'BorderType', 'etchedin',...
%     'Position', [0.55 0.34 0.4 0.17]);

t_vcNotUp2Date = uicontrol(...
    'Parent', p_vcNotUp2Date, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'Visible', 'off', ...
    'String', {'Volume Conductor is not up to date!', 'Press "Create Volume Conductor" to refresh the model!'}, ...
    'Position', [0.05 0.05 0.9 0.8], ...
    'ForegroundColor', 'r');

t_dipoleMomentZero = uicontrol(...
    'Parent', p_vcNotUp2Date, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'Visible', 'off', ...
    'String', {'WARNING! No non-zero dipole moment specified.', 'Calculation will result in zero potential map.'}, ...
    'Position', [0.05 0.05 0.9 0.8], ...
    'ForegroundColor', 'r');

% =========================================================================
% create decomposition panel and elements
% =========================================================================

% panel -------------------------------------------------------------------
p_decomposition = uipanel(...
    'Parent', f_main, ...
    'Title', 'Decomposition', ...
    'Position', [0.85 0.19 0.14 0.2]);

p_EEGDecompDescription = uipanel(...
    'Parent', p_decomposition,...
    'BorderType', 'etchedin',...
    'Position',[0.07 0.5 0.86 0.4]);

pb_showEEGDecompositionPanel=uibutton(...
    'Parent', p_EEGDecompDescription, ...
    'Style', 'text', ...
    'String', 'Link to various \newline decomposition methods', ...
    'HorizontalAlignment','center',...
    'Interpreter', 'tex',...
    'Units', 'normalized', ...
    'Enable', 'On',...
    'Position', [0.05 0.05 0.95 0.95]);
     
pb_showEEGDecompositionPanel=uicontrol(...
    'Parent', p_decomposition, ...
    'Style', 'pushbutton', ...
    'String', 'EEG Decomposition Panel', ...
    'HorizontalAlignment','center',...
    'Units', 'normalized', ...
    'Enable', 'Off',...
    'Position', [0.07 0.1 0.86 0.3], ...
    'Callback', {@showEEGDecompositionPanel});
    %'Interpreter', 'tex',...
% =========================================================================
% create export data panel and elements
% =========================================================================

p_exportData = uipanel(...
    'Parent', f_main, ...
    'Title', 'Export Data', ...
    'Position', [0.85 0.01 0.14 0.17]);

% Output variable name edit field
t_outputVarName = uicontrol(...
    'Parent', p_exportData, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'Output Variable Name:', ...
    'Position', [0.07 0.72 0.86 0.15]);

e_outputVarName = uicontrol(...
    'Parent', p_exportData, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'String', 'output', ...
    'Enable', 'off', ...
    'Position', [0.07 0.51 0.86 0.2], ...
    'BackgroundColor', [1 1 1]);

% Export Electrode Data to Workspace button
pb_exportElecDataToWorkspace = uicontrol(...
    'Parent', p_exportData, ...
    'Style', 'pushbutton', ...
    'String', 'Export Data to Workspace', ...
    'Units', 'normalized', ...
    'Position', [0.07 0.12 0.86 0.24], ...
    'Enable', 'off', ...
    'Callback', {@exportElecDataToWorkspace});


% -------------------------------------------------------------------------

% call some functions for initialization
reloadElecSetups(); % initially load electrode setups to fill dropdown
setNumberOfShells(); % initialize numberOfShells and set enable status of shell property edits
setNumberOfDipoles(); % initialize numberOfDipoles and set enable status of dipole property edits
createVolumeConductor(); % create a volume conductor model with default radii and conductivities
set(f_main, 'Visible', 'on'); % finally set the visibility property of the main window to 'on'

% set UI context menues
set(a_sourceloc(1),'UIContextMenu',m_sourceloc);
set(a_sourceloc(2),'UIContextMenu',m_sourceloc);
set(a_sourceloc(3),'UIContextMenu',m_sourceloc);

%% Main Window callback functions


function button_down(hObject, eventdata)
% callback function button_down(hObject, eventdata) is called on a left 
% mouse button down event or on a key press event while mouse cursor is 
% within the main window. 
% If the cursor is within one of the interactive dipole positioner axes, 
% dipole position crosshairs are being adapted in all positioner axes as 
% well as the dipole position edit fields and the global dipole position 
% matrix 'dipolePosition'.

    % check whether the cursor is within any positioner axes. 
    % 'currMousePos' is empty otherwise (see mouse_move function below)
    if isempty(currMousePos)
        return;
    end
    
    % check whether a key press event (-> ~isempty(eventdata)=0) or a left
    % mouse button down event (-> ~isempty(eventdata)=1) called the 
    % callback and set dipnum to the number of dipole to adapt.
    if ~isempty(eventdata)
    % if a key press event was calling... 
        dipnum = str2num(eventdata.Character); % ...set 'dipnum'...
        if (isempty(dipnum))
        % ...and firstly check if dipnum is empty (which might is
        % possible when e.g. 'Alt' key has been pressed).
            return;
        end
        if (~isnumeric(dipnum) || ((dipnum > numberOfDipoles) && (dipnum < 6))...
            || ((dipnum > (numberOfMovingDipoles +3)) && (dipnum > 8)) || dipnum < 1)
        % Further check if a valid key ('1'...'numberOfDipoles') has been
        % pressed.
            return;
        end
    else
    % if a left mouse button down event called the callback, set 'dipnum'
    % to 1.
        dipnum = 1;        
    end
    
    if (CrosshairAxes == a_sourceloc(1))
    % if current axes is the 'Right View' axes, adapt x- and z-component of
    % the position data of the appropriate dipole...
    if dipnum < 6
        dipolePosition(dipnum,1) = currMousePos(1);
        dipolePosition(dipnum,3) = currMousePos(2); % ... in matrix 'dipolePosition'...
        set(e_dipolePosition(dipnum,1), 'String', num2str(round2(currMousePos(1),1e-4)));
        set(e_dipolePosition(dipnum,3), 'String', num2str(round2(currMousePos(2),1e-4))); % ... and in the accordant edit field...
        refreshCrosshairs(e_dipolePosition(dipnum,1)); % ... and finally refresh the dipole position crosshairs.
    else
        movingdipolePosition(dipnum-5,1) = currMousePos(1);
        movingdipolePosition(dipnum-5,3) = currMousePos(2); % ... in matrix 'dipolePosition'...
        set(e_movingdipolePosition(dipnum-5,1), 'String', num2str(round2(currMousePos(1),1e-4)));
        set(e_movingdipolePosition(dipnum-5,3), 'String', num2str(round2(currMousePos(2),1e-4))); % ... and in the accordant edit field...
        refreshMovingCrosshairs(e_movingdipolePosition(dipnum-5,1)); % ... and finally refresh the dipole position crosshairs.  
    end
    elseif (CrosshairAxes == a_sourceloc(2))
    % the same as above but for the 'Top View' axes and for the the x- and
    % y-component.
    if dipnum < 6
        dipolePosition(dipnum,2) = currMousePos(1);
        dipolePosition(dipnum,1) = currMousePos(2);
        set(e_dipolePosition(dipnum,2), 'String', num2str(round2(currMousePos(1),1e-4)));
        set(e_dipolePosition(dipnum,1), 'String', num2str(round2(currMousePos(2),1e-4)));
        refreshCrosshairs(e_dipolePosition(dipnum,1));
    else
        movingdipolePosition(dipnum-5,2) = currMousePos(1);
        movingdipolePosition(dipnum-5,1) = currMousePos(2); % ... in matrix 'dipolePosition'...
        set(e_movingdipolePosition(dipnum-5,2), 'String', num2str(round2(currMousePos(1),1e-4)));
        set(e_movingdipolePosition(dipnum-5,1), 'String', num2str(round2(currMousePos(2),1e-4))); % ... and in the accordant edit field...
        refreshMovingCrosshairs(e_movingdipolePosition(dipnum-5,1)); % ... and finally refresh the dipole position crosshairs.  
    end
    elseif (CrosshairAxes == a_sourceloc(3))
    % the same as above but for the 'Front View' axes and for the the y- 
    % and z-component.
    if dipnum < 6
        dipolePosition(dipnum,2) = currMousePos(1);
        dipolePosition(dipnum,3) = currMousePos(2);
        set(e_dipolePosition(dipnum,2), 'String', num2str(round2(currMousePos(1),1e-4)));
        set(e_dipolePosition(dipnum,3), 'String', num2str(round2(currMousePos(2),1e-4)));
        refreshCrosshairs(e_dipolePosition(dipnum,1));
    else
       movingdipolePosition(dipnum-5,2) = currMousePos(1);
        movingdipolePosition(dipnum-5,3) = currMousePos(2); % ... in matrix 'dipolePosition'...
        set(e_movingdipolePosition(dipnum-5,2), 'String', num2str(round2(currMousePos(1),1e-4)));
        set(e_movingdipolePosition(dipnum-5,3), 'String', num2str(round2(currMousePos(2),1e-4))); % ... and in the accordant edit field...
        refreshMovingCrosshairs(e_movingdipolePosition(dipnum-5,1)); % ... and finally refresh the dipole position crosshairs.   
    end
    end   
end

function mouse_move(hObject, eventdata)
% callback function mouse_move(hObject, eventdata) is called on a mouse 
% move event within the main window.
% Shows a floating crosshair if the cursor is within positioner axes,
% enables the rotate3D function if the cursor is within the 3D view axes.
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !! Might be a 'dirty' possibility to do this. I guess there is better, !!
% !! more performant way to do this, but it works for the moment!        !! 
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    % First of all get the cursor position with respect to the particular
    % axes.
    viewer3DMousePos = get(a_3Dview, 'CurrentPoint');
    viewer3DMousePos = viewer3DMousePos(1,1:3);
    SaggitalMousePos = get(a_sourceloc(1),'CurrentPoint');
    SaggitalMousePos = SaggitalMousePos(1,1:2);
    CoronalMousePos = get(a_sourceloc(2),'CurrentPoint');
    CoronalMousePos = CoronalMousePos(1,1:2);
    FrontalMousePos = get(a_sourceloc(3),'CurrentPoint');
    FrontalMousePos = FrontalMousePos(1,1:2);
    
    
    
    if (norm(SaggitalMousePos) <= max(get(a_sourceloc(1), 'XLim'))/1.2)
        CrosshairAxes = a_sourceloc(1);
        currMousePos = SaggitalMousePos;
    elseif (norm(CoronalMousePos) <= max(get(a_sourceloc(2), 'XLim'))/1.2)
        CrosshairAxes = a_sourceloc(2);
        currMousePos = CoronalMousePos;
    elseif (norm(FrontalMousePos) <= max(get(a_sourceloc(3), 'XLim'))/1.2)
        CrosshairAxes = a_sourceloc(3);
        currMousePos = FrontalMousePos;
    else
        CrosshairAxes = [];
        currMousePos = [];
    end

    if ~isempty(CrosshairAxes)
        set(FloatingCrosshair(1), 'YData', [currMousePos(2) currMousePos(2)]);
        set(FloatingCrosshair(2), 'XData', [currMousePos(1) currMousePos(1)]);
        set(FloatingCrosshair, 'Parent', CrosshairAxes);
        set(FloatingCrosshair, 'Visible', 'on');
        set(f_main, 'Pointer', 'custom', 'PointerShapeCData', NaN*ones(16))
    else
        set(FloatingCrosshair, 'Visible', 'off');
        set(f_main, 'Pointer', 'arrow')
        % check whether the cursor is within the 3D view axes.
        if (... 
                viewer3DMousePos(1) <= max(get(a_3Dview, 'XLim')) && ...
                viewer3DMousePos(1) >= min(get(a_3Dview, 'XLim')) && ...
                viewer3DMousePos(2) <= max(get(a_3Dview, 'YLim')) && ...
                viewer3DMousePos(2) >= min(get(a_3Dview, 'YLim')) && ...
                viewer3DMousePos(3) <= max(get(a_3Dview, 'ZLim')) && ...
                viewer3DMousePos(3) >= min(get(a_3Dview, 'ZLim')))
            if strcmp(get(rotate_handle, 'Enable'), 'off')
            % If so and rotate3D is 'off'...
                set(rotate_handle, 'Enable', 'on'); % ...turn it 'on'
            end
        else
        % otherwise...
            if (strcmp(get(rotate_handle, 'Enable'), 'on'))
            % ...if rotate3D is enabeld 
                set(rotate_handle, 'Enable', 'off'); % ...turn it 'off'
            end
        end
    end  
end

function createVolumeConductor(hObject, eventdata)
% callback function that is called on click on "Create Volume
% Conductor" button

% reflect vector radii, so that is is ascendet
%radii=fliplr(radii);

    if ~issorted(radii(numberOfShells:-1:1))
    % if the radii 1...'numberOfShells' are not ascendet...
        errordlg(errInvRadius); % ...show an error message...
        return; %... and return
    end
    
    % make 3D plots invisible before volume conduction model update
    set(pl_potMap, 'Visible', 'off');
    set(pl_nose, 'Visible', 'off');
    set(pl_elecSetup, 'Visible', 'off');
    
    % 'park' crosshair handles in the 3Dview axes to prevent them from 
    % being deleted when clearing sourceloc axes    
    set(FloatingCrosshair, 'Parent', a_3Dview);
    set(Crosshair, 'Parent', a_3Dview);
    set(movingCrosshair, 'Parent', a_3Dview);
    
    % delete previous shells in the sourceloc axes
    for i=1:3
        cla(a_sourceloc(i));
    end
        
    % put crosshair handles back to the sourceloc axes (seems to be not
    % possible to do this without a loop like above)
    for i=1:3
        set(Crosshair(i,:), 'Parent', a_sourceloc(i));
        set(movingCrosshair(i,:), 'Parent', a_sourceloc(i));
    end
    set(FloatingCrosshair, 'Parent', a_sourceloc(1));
    
    refreshAxesLimits();
    
    % paint the circles according to the new model settings
    for i = numberOfShells:-1:1
        for j = 1:3
            axes(a_sourceloc(j));
            mycircle(0,0,radii(i));
        end
    end
    
    % plot noses for orientation in every sourceloc axes
    plot(a_sourceloc(1), ...
        radii(1)*[0.98 1.15 0.98], ...
        radii(1)*[0.15 -0.15 -0.15], ...
        '-k');
    plot(a_sourceloc(2), ...
        radii(1)*[-0.15 0 0.15], ...
        radii(1)*[0.98 1.15 0.98], ...
        '-k', ...
        [0 0], ...
        radii(1)*[1 1.15], '-k');
    plot(a_sourceloc(3), ...
        radii(1)*[-0.15 0.15 0 -0.15], ...
        radii(1)*[-0.15 -0.15 0.15 -0.15], ...
        '-k', [0 0], ...
        radii(1)*[0.15 -0.15], ...
        '-k');
        
    % construct a volume conduction model of the head consisting of
    % 'numberOfShells' concentric spheres with specified radii and
    % conductivities.
    vol.o = [0 0 0]; % origin at [0 0 0]
    vol.r = radii(1:numberOfShells); % FIELDTRIP functions need the radii...
    vol.c = conds(1:numberOfShells); % ...as well as the conductivities starting with the outermost shell.
    vol.type = 'concentric'; % setting the model type to multiple concentric spheres (important for FIELDTRIP)
    
    % create a set of electrodes, equally distributed on a sphere
    el = linspace(-pi./2, pi./2, numsec/2 + 1);
    az = linspace(-pi, pi, numsec + 1);
    az(end) = az(1);
    [az, el] = meshgrid(az, el);
    [X,Y,Z] = sph2cart(az, el, radii(1)*ones(numsec/2 + 1, numsec + 1));
    elec.pnt = [reshape(X,numel(X),1), reshape(Y,numel(Y),1), reshape(Z,numel(Z),1)];
    
    % FIELDTRIP needs electrode labels so here we create strings of
    % ascending integers. They won't appear anywhere.
    for i=1:size(elec.pnt,1)
       elec.label{i} = sprintf('%03d', i);
    end
    
    % disable the warning text that the volume conductor is not up to date
    showWarningCalcPot('off');
    % disable 'Create Volume Condutor' button
    set(pb_createVolumeConductor, 'Enable', 'off');
    % check if there are non-zero dipole moments. If not, show a warning!
    checkZerodipoleMoment()
end

%% calculatePotentials
function calculatePotentials(hObject, eventdata)
% callback function that is called on button "Calculate Potentials" click.
% Calculates the potentials at given electrode positions

T_start=[0, 0, 0, 0, 0]; % start samples of dipoles

    % check for valid dipole positions first
    if ~checkdipolePosition()
    % if invalid dipole positions were found...
        errordlg(errInvdipolePosition); % ... show an error message...
        return; % ...and return
    end
    
    % compute the leadfield for given dipole positions (start position)
    dipolePosition_Start=dipolePosition(1:numberOfDipoles,:);
    dipoleMoment_Start=dipoleMoment(1:numberOfDipoles,:);
    numberOfDipoles_Start=numberOfDipoles;
    for i=1:numberOfDipoles
        if T_start(i) ~= 0
            dipolePosition_Start(i,:)=[];
            dipoleMoment_Start(i,:)=[];
            numberOfDipoles_Start=numberOfDipoles_Start-1;
        end
    end
    lf = ft_compute_leadfield(dipolePosition_Start, elec, vol);
    %lf_topoplot=ft_compute_leadfield(dipolePosition_Start, elecSetup, vol, 0);
    % compute the potential distribution for the dipoles with given moments
    pot = lf * reshape(dipoleMoment_Start',3*numberOfDipoles_Start,1);
    %pot_topoplot= lf_topoplot * reshape(dipoleMoment_Start',3*numberOfDipoles_Start,1);
   
    % calculate time varying potentials if moving dipoles are selected
if numberOfMovingDipoles ~=0
    
    if checkStartEndPos()==0; % if the start and end positions of the moving dipoles are not different...
    errordlg(errStartEndPosMovDipNotDiff); % ... show an error message...
    return; % ...and return
    end
    
        numberOfDipoles=get(dd_numberOfDipoles, 'Value'); % get the current number of dipoles
numberOfMovingDipoles=get(dd_numberOfMovingDipoles,'Value')-1;
      dipolePositionMov=dipolePosition(1:numberOfDipoles,:);
      dipolePositionMovPol=[];
      dipoleMomentMovPol=[];
dipoleMomentMov=dipoleMoment(1:numberOfDipoles,:);
numberOfDipolesMov=numberOfDipoles;
signalMovPot=[];
movingsamples=zeros(1,numberOfMovingDipoles);
%N=1000;
NLG=100; % nerve conduction velocity in cm/s
fs=1000; % should be high enough so that animation will run smoothly
movingsamplesmax=floor(max(max(abs(dipolePosition(1:numberOfMovingDipoles,:)-movingdipolePosition(1:numberOfMovingDipoles,:)))))./NLG.*fs;

    % calculate the moving dipole positions
    for i=1:numberOfMovingDipoles
    movingsamples(1,i)=floor((max(abs(dipolePosition(i,:)-movingdipolePosition(i,:))))./NLG.*fs);
    %dipoledistance=dipolePosition(i,:)-movingdipolePosition(i,:);
    % expansion of the dipolePosition matrix
%     % dipole moves linearly
%     dipolePositionMov=vertcat(dipolePositionMov,(repmat(dipolePosition(i,:)',1,movingsamples(1,i))- (dipoledistance'*linspace(0,1,movingsamples(1,i))))');
    

    [a_s,e_s,r_s]=cart2sph(dipolePosition(i,1),dipolePosition(i,2),dipolePosition(i,3));
    [a_e,e_e,r_e]=cart2sph(movingdipolePosition(i,1),movingdipolePosition(i,2),movingdipolePosition(i,3));
    %dipolePolDis=abs([a_s,e_s,r_s]-[a_e,e_e,r_e]);
    %dipolePolDis=[e_e,a_e,r_e]-[e_s,a_s,r_s];
    dipolePolDis=[a_e,e_e,r_e]-[a_s,e_s,r_s];
    % if the radius of the start and end position is equal dipole moves on
    % a sphere relativ to the head surface ...
    %if dipolePolDis(1,3) == 0
    dipolePositionMovPol=vertcat(dipolePositionMovPol,(repmat([a_s,e_s,r_s]',1,movingsamples(1,i))+(dipolePolDis'*linspace(0,1,movingsamples(1,i))))');
    [cart1,cart2,cart3]=sph2cart(dipolePositionMovPol(:,1),dipolePositionMovPol(:,2),dipolePositionMovPol(:,3));
    dipolePositionMov=vertcat(dipolePositionMov,[cart1,cart2,cart3]);
%     % ... else dipole moves linearly
%     else
%     dipolePositionMov=vertcat(dipolePositionMov,(repmat(dipolePosition(i,:)',1,movingsamples(1,i))- (dipoledistance'*linspace(0,1,movingsamples(1,i))))');
%     end
    % expansion of the dipole signals
    signalpos=[zeros(1,movingsamplesmax) 1 zeros(1,movingsamplesmax-1)];
    signalpos=[1 zeros(1,N-1)];
    signalmovpot=zeros(movingsamples(1,i),N);
    for n=0:movingsamples(1,i)-1
        %h1=signalmovpot(n+1,:);
        %h2=circshift(signalpos',T_start(1,i+numberOfDipoles-numberOfMovingDipoles)+n)';%(1,movingsamplesmax+1-n:2*movingsamplesmax-n);
        signalmovpot(n+1,:)=circshift(signalpos',T_start(1,i+numberOfDipoles-numberOfMovingDipoles)+n)';%signalpos(1,movingsamplesmax+1-n:2*movingsamplesmax-n);
    end
    signalMovPot=[signalMovPot;signalmovpot];
    % expansion of the dipole moment matrix
    %dipoleMomentMov=[dipoleMomentMov;repmat(dipoleMoment(i,:),movingsamples(1,i),1)];
    % moment moves on a sphere relativ to the head surface
    [a_s,e_s,r_s]=cart2sph(dipoleMoment(i,1),dipoleMoment(i,2),dipoleMoment(i,3));
    [a_e,e_e,r_e]=cart2sph(movingdipoleMoment(i,1),movingdipoleMoment(i,2),movingdipoleMoment(i,3));
    dipolePolDis=[a_e,e_e,r_e]-[a_s,e_s,r_s];
    dipoleMomentMovPol=vertcat(dipoleMomentMovPol,(repmat([a_s,e_s,r_s]',1,movingsamples(1,i))+(dipolePolDis'*linspace(0,1,movingsamples(1,i))))');
    [cart1,cart2,cart3]=sph2cart(dipoleMomentMovPol(:,1),dipoleMomentMovPol(:,2),dipoleMomentMovPol(:,3));
    dipoleMomentMov=vertcat(dipoleMomentMov,[cart1,cart2,cart3]);
    
    % expand numberOfDipolesMov
    numberOfDipolesMov=numberOfDipolesMov+movingsamples(1,i)-1;
    dipolePositionMovPol=[];
     dipoleMomentMovPol=[];
    end % i=1:numberOfMovingDipoles
dipolePositionMov(1:numberOfMovingDipoles,:)=[];
dipolePositionMov=circshift(dipolePositionMov,-(numberOfDipoles-numberOfMovingDipoles));
%signal(1:numberOfMovingDipoles,:)=[];
dipoleMomentMov(1:numberOfMovingDipoles,:)=[];

signalMovPot=[zeros(numberOfDipoles-numberOfMovingDipoles,N);signalMovPot];
for i=1:numberOfDipoles-numberOfMovingDipoles
    signalMovPot(i,T_start(1,i)+1:end)=ones(1,N-T_start(1,i));
end
signalMovPot=circshift(signalMovPot,-(numberOfDipoles-numberOfMovingDipoles));
% compute the leadfield for given dipole and electrode positions
lfMov = ft_compute_leadfield(dipolePositionMov(1:numberOfDipolesMov,:), elec, vol);

% % if electrode setup is chosen, compute leadfield for that particular
% % electrode setup
% if dd_elecSetup>1
%     lfMov_topoplot =ft_compute_leadfield(dipolePositionMov(1:numberOfDipolesMov,:), elecSetup, vol, 1);
% end
    
% replicate the signal matrix
signaltomoment=zeros(3*numberOfDipolesMov,size(signalMovPot,2));
for i=1:numberOfDipolesMov
    %signalMovPot(i,:)=circshift(signalMovPot(i,:)',T_start(i))';
    signaltomoment(i+(i-1)*2:i*3,:)=repmat(signalMovPot(i,:),3,1);
end

%compute the potentials for given moving dipole positions and dipole
%moments
potMov=lfMov*(repmat(reshape(dipoleMomentMov',3*numberOfDipolesMov,1),1,size(signalMovPot,2)).*signaltomoment);

%potMov_topoplot=lfMov_topoplot*(repmat(reshape(dipoleMomentMov',3*numberOfDipolesMov,1),1,size(signalMovPot,2)).*signaltomoment);
%potMov(:,1:min(T_start(1,1:numberOfDipoles)))=repmat(potMov(:,min(T_start(1,1:numberOfDipoles))+1),1,min(T_start(1,1:numberOfDipoles)));
%end_mov=zeros(size(potMov,1),1);
%end_mov_pos=find(ismember(potMov,end_mov));
%c_num=find(all(repmat(end_mov,1,size(potMov,2))==potMov));
%potMov(:,end_mov_pos(1,1):end)=repmat(potMov(:,end_mov_pos(1,1)-1),1,N-end_mov_pos(1,1));
%potMov_topoplot=[potMov_topoplot repmat(potMov_topoplot(:,movingsamplesmax),1,N-movingsamplesmax)];
% end_mov=zeros(size(potMov,1),1);
% c_num=find(all(repmat(end_mov,1,size(potMov,2))==potMov));
% for n=1:size(potMov,2)
% if any(c_num(:) == n)
%     potMov(:,n)=potMov(:,n-1);
% end
% end

% else
% N=500;
% potMov_topoplot=repmat(pot_topoplot,1,N);

end


% for using the 'surf' command, vectors have to be reshaped to
    % matrices. See 'surf' help for details.
    x = reshape(elec.pnt(:,1),[numsec/2 + 1, numsec + 1]);
    y = reshape(elec.pnt(:,2),[numsec/2 + 1, numsec + 1]);
    z = reshape(elec.pnt(:,3),[numsec/2 + 1, numsec + 1]);
    pot = reshape(pot,[numsec/2 + 1, numsec + 1]);
    
    % adjust the data in the potential map handle
    set(pl_potMap, ... 
        'XData', x, ...
        'YData', y, ...
        'ZData', z, ...
        'CData', pot, ...
        'Parent', a_3Dview, ...
        'Visible', 'on');
    
    caxis(a_3Dview, [min(min(pot)) max(max(pot))]); % refresh the colormap
    %shading(a_3Dview, 'interp'); % set shading to 'interp' for a nice surface
    
    % refresh the nose in the 3D view
    set(pl_nose, ...
        'XData', radii(1).*[0.9 1.15 0.98; 0.9 1.15 0.98; 0.9 1.15 0.9]', ...
        'YData', radii(1).*[-0.15 0 0; 0.15 0 0; -0.15 0 0.15]', ...
        'ZData', radii(1).*[-0.15 -0.15 0.15; -0.15 -0.15 0.15; -0.15 -0.15 -0.15]', ...
        'CData', zeros(3,3), ...
        'FaceColor', 'w', ...
        'EdgeColor', 'k', ...
        'Visible', 'on');
    
    axis(a_3Dview, 'equal'); % adjust 3D view axis...
    set(a_3Dview, 'View', [37.5 30]); % ... and angle
    refreshAxesLimits();
    
     colorbar('peer', a_3Dview); % show colorbar
    
    showWarningExport('off'); % disable warning that potential map is not up to date
    
    % adjust the dipole position data
    set(pl_dipolePos,...
        'XData', dipolePosition(1:numberOfDipoles,1),...
        'YData', dipolePosition(1:numberOfDipoles,2),...
        'ZData', dipolePosition(1:numberOfDipoles,3),...
        'Visible','On',...
        'CData', dipPosColors(1:numberOfDipoles,:));%
       
    %refreshdata(pl_dipolePos);
   

% enable/disable the push button to start the animation
 if numberOfMovingDipoles ~=0
    
set(pb_potentialCourse, 'Enable', 'on');
else
set(pb_potentialCourse, 'Enable', 'Off');  
 end  

end


function setSignal(hObject, eventdata)
% callback function that is called on choosing a signal from at least one
% pop up menu 'Dipole i signal' 


for i=1:get(dd_numberOfDipoles, 'Value');
        signalSetup(i,1)=get(dd_signal(i), 'Value');
end
   
if (get(dd_elecSetup, 'Value') == 1 ) || (length(find(signalSetup-1))~=numberOfDipoles)
    set(pb_calculateElectrodeSignals, 'Enable', 'off');
    showWarningExport('off');
    set(t_pmNotUp2Date, 'Visible','On');
else
    set(pb_calculateElectrodeSignals, 'Enable', 'on');
    showWarningExport('on');
    set(t_pmNotUp2Date, 'Visible','Off');
end

end


function calculateElectrodeSignals(hObject, eventdata)
% callback function that is called on button "Calculate Electrode Signals"
% click
% Calculates the electrode signals depending on the signals and the choosen
% electrode setup

% disable "Show electrode signals" button
%set(pb_showElectrodeSignals, 'Enable', 'Off');

T_start=[0, 0, 0, 0, 0]; % start samples of dipoles

signal=[];
elecSetupNumber=get(dd_elecSetup, 'Value'); % get the current electrode setup number
numberOfDipoles=get(dd_numberOfDipoles, 'Value'); % get the current number of dipoles
numberOfMovingDipoles=get(dd_numberOfMovingDipoles,'Value')-1;

for i=1:numberOfDipoles
    signalSetup=get(dd_signal(i), 'Value');
% show warning if not for every dipole a signal is selected
if signalSetup == 1
    errordlg(errNoDipoleSignalSelected);
    return
end    
    [signal(i,:),fs,N]=generateSignals(signalSetup); % generating the signals for each dipole
end
%electrodeSignalsMov=zeros(size(elecSetup.pnt,1),N);
electrodeSignals=zeros(size(elecSetup.pnt,1),N);
if numberOfMovingDipoles ~= 0

    if checkStartEndPos()==0; % if the start and end positions of the moving dipoles are not different...
    errordlg(errStartEndPosMovDipNotDiff); % ... show an error message...
    return; % ...and return
    end

    dipolePositionMov=dipolePosition(1:numberOfDipoles,:);
    dipolePositionMovPol=[];
    dipoleMomentMovPol=[];
    dipoleMomentMov=dipoleMoment(1:numberOfDipoles,:);
    numberOfDipolesMov=numberOfDipoles;
    %signalMov=signal;
    movingsamples=zeros(1,numberOfMovingDipoles);
    NLG=100; % nerve conduction velocity in cm/s

    % calculate the moving dipole positions
    for i=1:numberOfMovingDipoles
    movingsamples(1,i)=floor((max(abs(dipolePosition(i,:)-movingdipolePosition(i,:))))./NLG.*fs);
   
        % expansion of the dipolePosition matrix
    %     % dipole moves linearly
    %      dipoledistance=dipolePosition(i,:)-movingdipolePosition(i,:);
    %     dipolePositionMov=vertcat(dipolePositionMov,(repmat(dipolePosition(i,:)',1,movingsamples(1,i))- (dipoledistance'*linspace(0,1,movingsamples(1,i))))');
        % dipole moves on a sphere relativ to the head surface
    [a_s,e_s,r_s]=cart2sph(dipolePosition(i,1),dipolePosition(i,2),dipolePosition(i,3));
    [a_e,e_e,r_e]=cart2sph(movingdipolePosition(i,1),movingdipolePosition(i,2),movingdipolePosition(i,3));
    dipolePolDis=[a_e,e_e,r_e]-[a_s,e_s,r_s];
    dipolePositionMovPol=vertcat(dipolePositionMovPol,(repmat([a_s,e_s,r_s]',1,movingsamples(1,i))+(dipolePolDis'*linspace(0,1,movingsamples(1,i))))');
    [cart1,cart2,cart3]=sph2cart(dipolePositionMovPol(:,1),dipolePositionMovPol(:,2),dipolePositionMovPol(:,3));
    dipolePositionMov=vertcat(dipolePositionMov,[cart1,cart2,cart3]);
    
    %     % expansion of the dipole signals
    %     signalhelp=[zeros(1,size(signal,2)) signal(i,:)];
    %     signalmov=zeros(movingsamples(1,i),N);
    %     %samplesMov=floor((fs.*dipoledistance./NLG)./samplingPoints);
    %     samplesMov=1; % number of samples to move dipole signal
    %     for n=0:movingsamples(1,i)-1
    %         signalmov(n+1,:)=signalhelp(1,N+1-samplesMov*n:2*N-samplesMov*n);
    %     end
    %     signalMov=[signalMov;signalmov];
    
    % expansion of the dipole moment matrix
    %dipoleMomentMov=[dipoleMomentMov;repmat(dipoleMoment(i,:),movingsamples(1,i),1)];
    %dipoleMomentDistance=dipoleMoment(i,:)-movingdipoleMoment(i,:);
    %dipoleMomentMov=vertcat(dipoleMomentMov,(repmat(dipoleMoment(i,:)',1,movingsamples(1,i))- (dipoleMomentDistance'*linspace(0,1,movingsamples(1,i))))');
    
    % moment moves on a sphere relativ to the head surface
    [a_s,e_s,r_s]=cart2sph(dipoleMoment(i,1),dipoleMoment(i,2),dipoleMoment(i,3));
    [a_e,e_e,r_e]=cart2sph(movingdipoleMoment(i,1),movingdipoleMoment(i,2),movingdipoleMoment(i,3));
    dipolePolDis=[a_e,e_e,r_e]-[a_s,e_s,r_s];
    dipoleMomentMovPol=vertcat(dipoleMomentMovPol,(repmat([a_s,e_s,r_s]',1,movingsamples(1,i))+(dipolePolDis'*linspace(0,1,movingsamples(1,i))))');
    [cart1,cart2,cart3]=sph2cart(dipoleMomentMovPol(:,1),dipoleMomentMovPol(:,2),dipoleMomentMovPol(:,3));
    dipoleMomentMov=vertcat(dipoleMomentMov,[cart1,cart2,cart3]);
    
    
    % expand numberOfDipolesMov
     numberOfDipolesMov=numberOfDipolesMov+movingsamples(1,i)-1;
     dipolePositionMovPol=[];
     dipoleMomentMovPol=[];
    end % i=1:numberOfMovingDipoles
    dipolePositionMov(1:numberOfMovingDipoles,:)=[];
    dipolePositionMov=circshift(dipolePositionMov,-(numberOfDipoles-numberOfMovingDipoles));
    %signal(1:numberOfMovingDipoles,:)=[];
    dipoleMomentMov(1:numberOfMovingDipoles,:)=[];
    % reshape dipoleMomentMov, so that moving dipoles are in the first entries
    if numberOfDipoles-numberOfMovingDipoles ~= 0
    dipoleMomentMov=[dipoleMomentMov(numberOfDipoles-numberOfMovingDipoles+1:end,:); dipoleMomentMov(1:numberOfDipoles-numberOfMovingDipoles,:)];
    end

    % compute the leadfield for given dipole and electrode positions
    lfMov = ft_compute_leadfield(dipolePositionMov(1:numberOfDipolesMov,:), elecSetup, vol);

    % reshape and expand the leadfield matrix for moving dipole(s) 
    movingsamplesTens=[0 movingsamples];
    lfMovTens=zeros(size(elecSetup.pnt,1),numberOfDipoles*3,N);

    % if numberOfDipoles ~= numberOfMovingDipoles % if there are static dipoles
    % lfMovTens(:,numberOfMovingDipoles*3+1:numberOfDipoles*3,:)=repmat(lfMov(:,1:(numberOfDipoles-numberOfMovingDipoles)*3)+1,[1,1,N]);
    % end
    % for i=1:numberOfMovingDipoles
    %   lfMovTens(:,2*i+i-2:3*i,1:movingsamplesTens(1,i+1))=reshape(reshape(lfMov(:,(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesTens(1,1:i)))*3+1:(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesTens(1,1:i+1)))*3),size(elecSetup.pnt,1)*movingsamples(1,i)*3,1),[size(elecSetup.pnt,1),3,movingsamples(1,i)]);
    %   lfMovTens(:,2*i+i-2:3*i,movingsamplesTens(1,i+1)+1:end)=repmat(lfMovTens(:,2*i+i-2:3*i,movingsamplesTens(1,i+1)),[1,1,N-movingsamples(1,i)]);
    % end
    if numberOfDipoles ~= numberOfMovingDipoles % if there are static dipoles

    for i=1:numberOfDipoles-numberOfMovingDipoles

    lfMovTens(:,numberOfMovingDipoles*3+1+(i-1)*3:numberOfMovingDipoles*3+i*3,T_start(1,i+numberOfDipoles-numberOfMovingDipoles)+1:end)=repmat(lfMov(:,sum(movingsamplesTens)*3+1:end),[1,1,N-T_start(1,i+numberOfDipoles-numberOfMovingDipoles)]);
    end
    end

    for i=1:numberOfMovingDipoles
    
        lfMovTens(:,1+(i-1)*3:i*3,1+T_start(1,i):movingsamplesTens(1,i+1)+T_start(1,i))=reshape(reshape(lfMov(:,(sum(movingsamplesTens(1,1:i)))*3+1:(sum(movingsamplesTens(1,1:i+1)))*3),size(elecSetup.pnt,1)*movingsamples(1,i)*3,1),[size(elecSetup.pnt,1),3,movingsamples(1,i)]);
        lfMovTens(:,1+(i-1)*3:i*3,movingsamplesTens(1,i+1)+1+T_start(1,i):end)=repmat(lfMovTens(:,2*i+i-2:3*i,movingsamplesTens(1,i+1)+T_start(1,i)),[1,1,N-movingsamples(1,i)-T_start(1,i)]);

    %   lfMovTens(:,2*i+i-2:3*i,1:movingsamplesTens(1,i+1))=reshape(reshape(lfMov(:,(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesTens(1,1:i)))*3+1:(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesTens(1,1:i+1)))*3),size(elecSetup.pnt,1)*movingsamples(1,i)*3,1),[size(elecSetup.pnt,1),3,movingsamples(1,i)]);
    %   lfMovTens(:,2*i+i-2:3*i,movingsamplesTens(1,i+1)+1:end)=repmat(lfMovTens(:,2*i+i-2:3*i,movingsamplesTens(1,i+1)),[1,1,N-movingsamples(1,i)]);
    end

    % replicate the signal matrix
    signaltomoment=zeros(3*numberOfDipoles,size(signal,2));
    for i=1:numberOfDipoles
        signal(i,:)=circshift(signal(i,:)',T_start(i))';
        signaltomoment(i+(i-1)*2:i*3,:)=repmat(signal(i,:),3,1);
    end

    % expand the dipole moment matrix
    dipoleMomentMov=dipoleMomentMov';
    dipoleMomentMat=zeros(numberOfDipoles*3,N);
    for i=1:numberOfDipoles
        if i<=numberOfMovingDipoles

        
    %        
    % % dipole vanishes after finishing moving distance
            % dipoleMomentMat(1+(i-1)*3:i*3,:)=[dipoleMomentMov(:,sum(movingsamplesTens(1,1:i))+1:sum(movingsamplesTens(1,1:i+1))) zeros(3,N-movingsamples(1,i))];

    % dipole moment decays with the Euler function after dipole has finished
    % moving

        % for one moving dipole
     %dipoleMomentMat(1+(i-1)*3:i*3,:)=[dipoleMomentMov(1+(i-1)*3:i*3,:) repmat(dipoleMomentMov(:,sum(movingsamples(1,1:i))),1,N-movingsamples(1,i))]; 
        % for several moving dipoles

     dipoleMomentMat(1+(i-1)*3:i*3,T_start(1,i)+1:end)=[dipoleMomentMov(:,sum(movingsamplesTens(:,1:i))+1:sum(movingsamplesTens(:,1:i+1))) repmat(dipoleMomentMov(:,sum(movingsamples(1,1:i))),1,N-movingsamples(1,i)-T_start(1,i))];
      %dipoleMomentMat(1+(i-1)*3:i*3,:)=[dipoleMomentMov(:,sum(movingsamplesTens(:,1:i))+1+numberOfDipoles-numberOfMovingDipoles:sum(movingsamplesTens(:,1:i+1))+numberOfDipoles-numberOfMovingDipoles) repmat(movingdipoleMoment(i,:)',1,N-movingsamples(1,i))];

         t_e=linspace(0,N-movingsamples(i)-T_start(1,i),N-movingsamples(i)-T_start(1,i));
         e_decay=repmat(exp(-0.01*t_e),3,1);
         %e_decay=repmat(exp(-0*t_e),3,1);
         dipoleMomentMat(i+(i-1)*2:i*3,movingsamples(i)+T_start(1,i)+1:end)=dipoleMomentMat(i+(i-1)*2:i*3,movingsamples(i)+T_start(1,i)+1:end).*e_decay;
       % dipole vanishes after movement has finished
      % dipoleMomentMat(i+(i-1)*2:i*3,movingsamples(i)+T_start(1,i)+1:end)=dipoleMomentMat(i+(i-1)*2:i*3,movingsamples(i)+T_start(1,i)+1:end).*0;
      % dipole sends last moments after finishing moving distance
             %dipoleMomentMat(1+(i-1)*3:i*3,:)=[dipoleMomentMov(1+(i-1)*3:i*3,:) repmat(dipoleMomentMov(:,movingsamples(1,i)),1,N-movingsamples(1,i))];

    else
                dipoleMomentMat(1+(i-1)*3:i*3,T_start(1,i)+1:end)=repmat(dipoleMoment(i,:)',1,N-T_start(1,i));
    end
end


%compute the electrode signals for given dipole moments and given signals
for n=1:N
    electrodeSignals(:,n)=lfMovTens(:,:,n)*(dipoleMomentMat(:,n).*signaltomoment(:,n));

end

% add noise
electrodeSignals = [];
sl_include_core;
    fs=1000;
    

else % for if numberOfMovingDipoles ~=0, only static dipoles are selected

% compute the leadfield for given dipole and electrode positions
lf = ft_compute_leadfield(dipolePosition(1:numberOfDipoles,:), elecSetup, vol);

% replicate the signal matrix
signaltomoment=zeros(3*numberOfDipoles,size(signal,2));
for i=1:numberOfDipoles
    signal(i,:)=circshift(signal(i,:)',T_start(1,i))';
    signaltomoment(i+(i-1)*2:i*3,:)=repmat(signal(i,:),3,1);
end

%compute the electrode signals for given dipole moments and given signals
electrodeSignals=lf*(repmat(reshape(dipoleMoment(1:numberOfDipoles,:)',3*numberOfDipoles,1),1,size(signal,2)).*signaltomoment);

    % add noise
    sl_include_core;
    fs=1000;
    %% Forward Solution
    t_ForwardSolution = sl_CForwardSolution('ToolBox_SourceLab/sl_MATLAB/Data/EEG/Sample/sample_audvis-ave-oct-6-fwd.fif');
    %%
    t_ForwardSolution.import_ft_ForwardSolution(lf,elecSetup, dipolePosition(1:numberOfDipoles,:));
    
    t_Simulator = sl_CSimulator(t_ForwardSolution, fs);
    
    for i=1:numberOfDipoles
    t_Simulator.SourceActivation.addActivation(i, signal(i,:),'nn',dipoleMoment(i,:));%, [1 0 0; 0 1 0]);
    end
           
        if get(rb_whiteNoise, 'Value')
           noise_mode=1;
        else 
            noise_mode=2;
        end
        t_Simulator.simulate('mode',noise_mode,'snr',SNRnoise);
        electrodeSignals=t_Simulator.data;

end % if numberOfMovingDipoles ~=0

    set(pb_showElectrodeSignals, 'Enable', 'on'); % enables the 'Show Electrode Signals' button
    set(pb_showEEGDecompositionPanel, 'Enable', 'on'); % enables the " Show EEG Decomposition panel" puchbutton
    showWarningExport('Off');

end

function showElectrodeSignals(hObject,eventdata,handles)
% callback function that is called on button 'Show Electrode Signals' click
% opens a figure to show the electrode signals
% marker data has to be selected

if ishandle(f1h)&& (f1h ~=0) 
    close(f1h)
end

f1h=show_electrode_signals(electrodeSignals',elecSetup.label);
guidata(hObject,f1h);

end


function setNumberOfShells(hObject, eventdata, radii, conds)
% callback function that is called on popup selection to enable/disable 
% radii and conductivity edit fields

    numberOfShells = get(dd_numberOfShells, 'Value'); % update 'numberOfShells'
    
    switch numberOfShells
        case 1
            radii = [7.5];
            conds = [0.33 0 0 0];
        case 2
            radii = [7.5 6.5];
            conds = [0.0042 0.33 0 0];
        case 3
            radii = [7.5 7.1 6.5];
            conds = [0.33 0.0042 0.33 0];
        case 4
            radii = [7.5 7.1 6.5 6.3];
            conds = [0.33 0.0042 1 0.33];
    end
    
    set(e_shellradius, 'Enable', 'off'); % disable all radii...
    set(e_shellconds, 'Enable', 'off'); % ...and conductivity edit fields
        
    set(e_shellradius(1:numberOfShells), 'Enable', 'on'); % enable radii...
    set(e_shellconds(1:numberOfShells), 'Enable', 'on'); % ...and conductivity edits '1:numberOfShells'
    
    % set the radii and conductivity values
    for i=1:numberOfShells
        set(e_shellradius(i),'String', num2str(radii(i)));
        set(e_shellconds(i), 'String', num2str(conds(i)));
    end
    
    % dirty workaround for the dropdown to get rid of the focus to prevent
    % the value to be adjusted when pressing number keys to locate dipoles.
    set(dd_numberOfShells, 'Enable', 'off');
    drawnow;
    set(dd_numberOfShells, 'Enable', 'on');
    
    % enable warnings
    showWarningExport('on')
    showWarningCalcPot('on')
end


function setNumberOfDipoles(hObject, eventdata)
% callback function that is called on popup selection to enable/disable 
% dipole edit fields

    numberOfDipoles = get(dd_numberOfDipoles, 'Value'); % update 'numberOfDipoles'
    
    set(Crosshair, 'Visible', 'off'); % disable all dipole crosshairs
    set(Crosshair(:,1:numberOfDipoles), 'Visible', 'on'); % enable dipole crosshairs '1:numberOfDipoles'
    
    set(e_dipolePosition, 'Enable', 'off'); % disable all dipole position edits
    set(e_dipoleMoment, 'Enable', 'off'); % disable all dipole moment edits
    set(dd_signal, 'Enable', 'off'); % disable all signal pop up menues
    
    set(e_dipolePosition(1:numberOfDipoles,:), 'Enable', 'on'); % enable dipole position edits '1:numberOfDipoles'
    set(e_dipoleMoment(1:numberOfDipoles,:), 'Enable', 'on'); % enable dipole moment edits '1:numberOfDipoles'
    set(dd_signal(1:numberOfDipoles), 'Enable', 'on'); % enable signal pop up menues '1:numberOfDipoles'
    
    % dirty workaround for the dropdown to get rid of the focus to prevent
    % the value to be adjusted when pressing number keys to locate dipoles.
    set(dd_numberOfDipoles, 'Enable', 'off');
    drawnow;
    set(dd_numberOfDipoles, 'Enable', 'on');

    showWarningExport('on')
    checkZerodipoleMoment()
end

function setNumberOfMovingDipoles(hObject,eventdata)
% callback function which is called on choosing a number of moving dipoles
% from the pop up menu 'Number Of Moving Dipoles'

numberOfMovingDipoles = (get(dd_numberOfMovingDipoles, 'Value'));

set(movingCrosshair, 'Visible', 'off'); % disable all dipole crosshairs
set(movingCrosshair(:,1:numberOfMovingDipoles-1), 'Visible', 'on'); % enable dipole crosshairs '1:numberOfDipoles'

% Disable all edit fields
    set(e_movingdipolePosition, 'Enable', 'off');
    set(e_movingdipoleMoment, 'Enable', 'off');

if (numberOfMovingDipoles ~= 1)
% Enable the position and moment edit fields for the choosen number of
% moving dipoles
    set(e_movingdipolePosition(1:numberOfMovingDipoles-1,:), 'Enable', 'on');
    set(e_movingdipoleMoment(1:numberOfMovingDipoles-1,:), 'Enable', 'on');
end

% dirty workaround for the dropdown to get rid of the focus to prevent
    % the value to be adjusted when pressing number keys to locate dipoles.
    set(dd_numberOfMovingDipoles, 'Enable', 'off');
    drawnow;
    set(dd_numberOfMovingDipoles, 'Enable', 'on');
% %enable movingCrosshairs
% set(movingCrosshair, 'Visible', 'on');

% enable warning that potential map (and electrode signals) is (are) not up to date
    for i=1:numberOfDipoles
        signalSetup(i,1)=get(dd_signal(i), 'Value');
    end
   
    if (get(dd_elecSetup, 'Value') == 1 ) || (length(find(signalSetup-1))~=numberOfDipoles)
    % electrode signals can not be calculated
    showWarningExport('on')
    else
    % electrode signals can be calculated
    showWarningExport('on');
    end
end

function additiveNoise(hObject,eventdata)
    % callback function executed when the selected radio button changes
    % enables the warning, that electrode signals are not up to date, if
    % electrode signals have been calulcated previously
    if ~isempty(electrodeSignals)
    
     set(t_pmNotUp2Date, 'Visible', 'On');
    end
end

function addSNRnoise (hObject,eventdata)
     % callback function executed when the edit field to select the SNR
     % is changed
        SNRnoise = str2double(get(e_SNRnoise,'String'));
end

function refreshCrosshairs(hObject, eventdata)
    % callback function which is called on leaving a dipole position edit
    % field
    
    component = get(hObject, 'UserData'); % get the component (x, y, z) which is stored (as 1, 2, 3) in the UserData field of the calling edit field
    
    checkDipolePositionComponent(hObject, component); % check whether the value is valid
    
    % adjust crosshair position
    set(Crosshair(1,component(1)), ...
        'XData', dipolePosition(component(1),1), ...
        'YData', dipolePosition(component(1),3));
    
    set(Crosshair(2,component(1)), ...
        'XData', dipolePosition(component(1),2), ...
        'YData', dipolePosition(component(1),1));
    
    set(Crosshair(3,component(1)), ...
        'XData', dipolePosition(component(1),2), ...
        'YData', dipolePosition(component(1),3));
    
end

function refreshMovingCrosshairs(hObject, eventdata)
    % callback function which is called on leaving a moving dipole position
    % edit field
    component = get(hObject, 'UserData'); % get the component (x, y, z) which is stored (as 1, 2, 3) in the UserData field of the calling edit field
    
    checkMovingDipolePositionComponent(hObject, component); % check whether the value is valid
    
    % adjust crosshair position
    set(movingCrosshair(1,component(1)), ...
        'XData', movingdipolePosition(component(1),1), ...
        'YData', movingdipolePosition(component(1),3));
    
    set(movingCrosshair(2,component(1)), ...
        'XData', movingdipolePosition(component(1),2), ...
        'YData', movingdipolePosition(component(1),1));
    
    set(movingCrosshair(3,component(1)), ...
        'XData', movingdipolePosition(component(1),2), ...
        'YData', movingdipolePosition(component(1),3));
end

function refreshdipoleMoment(hObject, eventdata)
    if ~checkdipoleMoment()
        set(e_dipoleMoment(1,1), 'String', num2str(dipoleMoment(1,1)));
        set(e_dipoleMoment(1,2), 'String', num2str(dipoleMoment(1,2)));
        set(e_dipoleMoment(1,3), 'String', num2str(dipoleMoment(1,3)));
        errordlg(errInvdipoleMoment)
    end
end

function change3DView(hObject, eventdata)
    % callback function which is called on a view control button. Nothing
    % more to comment here. Easy to understand.
    if (hObject == pb_rightView)
        set(a_3Dview, 'View', [0 0]);
    elseif (hObject == pb_leftView)
        set(a_3Dview, 'View', [180 0]);
    elseif (hObject == pb_topView)
        set(a_3Dview, 'View', [-90 90]);
    elseif (hObject == pb_bottomView)
        set(a_3Dview, 'View', [90 -90]);
    elseif (hObject == pb_frontView)
        set(a_3Dview, 'View', [90 0]);
    elseif (hObject == pb_backView)
        set(a_3Dview, 'View', [-90 0]);
    elseif (hObject == pb_defaultView)
        set(a_3Dview, 'View', [37.5 30]);
    end
end

function showDipolePosition(hObject,eventdata,handles)
 % callback function which is called on changing the radio button group "Show Dipole Position"   
 switch get(get(hObject,'SelectedObject'),'String')
     case 'No'
         %set(a_sourceloc,'HandleVisibility','Off');
        set(pl_potMap,'FaceAlpha',1); 
        %set(pl_potMap,'Visible','On','Parent',a_3Dview); 
     case 'Yes'
         %set(a_sourceloc,'HandleVisibility','Off');
        set(pl_potMap,'FaceAlpha',0.2);
        %set(pl_potMap,'Visible','Off','Parent',a_3Dview); 
 end
end

function showPotentialCourse(hObject,eventdata)
    % callback function which is called on the potential course button.
    % Shows the potential course if moving dipoles are selected
    
    % reshape the dipole position moving matrix to a tensor
    movingsamplesPC=[0 movingsamples];
    dipolePosMovTens=zeros(N,3,numberOfDipoles);
    if numberOfDipoles-numberOfMovingDipoles ~= 0 % if static dipoles are selected
        h1=dipolePosMovTens(:,:,numberOfMovingDipoles+1:numberOfDipoles);
%        h2=permute(repmat(dipolePositionMov(1:numberOfDipoles-numberOfMovingDipoles,:),[1,1,max(movingsamplesPC)]),[3,2,1]);
       h3=permute(repmat(dipolePositionMov(end-(numberOfDipoles-numberOfMovingDipoles-1):end,:),[1,1,N]),[3,2,1]);
       
    dipolePosMovTens(:,:,numberOfMovingDipoles+1:numberOfDipoles)=permute(repmat(dipolePositionMov(end-(numberOfDipoles-numberOfMovingDipoles-1):end,:),[1,1,N]),[3,2,1]);
    end
    for i=1:numberOfMovingDipoles
        %help1=dipolePosMovTens(:,:,numberOfMovingDipoles-numberOfDipoles+i);
%         h2=numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i))+1;
%         h3=dipolePositionMov(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i))+1:numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1)),:);
%         x=numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i))+1;
%         y=numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1));
%          h1=dipolePositionMov(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i))+1:numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1)),:);
%          h5=dipolePositionMov(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1)),:);
%          h4=repmat(dipolePositionMov(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1)),:),max(movingsamplesPC)-movingsamplesPC(1,i+1),1);
%         %help2=[dipolePositionMov(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i))+1:numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1)),:) repmat(dipolePositionMov(numberOfDipoles-numberOfMovingDipoles+sum(movingsamplesPC(1,1:i+1),:)),max(movingsamplesPC)-movingsamplesPC(1,i+1),1)];
%      help2=[h1; h4];
        dipolePosMovTens(:,:,i)=[dipolePositionMov(sum(movingsamplesPC(1,1:i))+1:sum(movingsamplesPC(1,1:i+1)),:); repmat(dipolePositionMov(sum(movingsamplesPC(1,1:i+1)),:),N-movingsamplesPC(1,i+1),1)];
    end
    
    % surf the potential distributions for each sample  
    for i=1:size(potMov,2)
        % reshape the potential vector
        x = reshape(elec.pnt(:,1),[numsec/2 + 1, numsec + 1]);
        y = reshape(elec.pnt(:,2),[numsec/2 + 1, numsec + 1]);
        z = reshape(elec.pnt(:,3),[numsec/2 + 1, numsec + 1]);
        potMovShow = reshape(potMov(:,i),[numsec/2 + 1, numsec + 1]);
    
    % adjust the data in the potential map handle
    set(pl_potMap, ... 
        'XData', x, ...
        'YData', y, ...
        'ZData', z, ...
        'CData', potMovShow, ...
        'Parent', a_3Dview, ...
        'Visible', 'on');
    
    % adjust the dipole position
    set(pl_dipolePos,...
        'XData',dipolePosMovTens(i,1,:),...
        'YData',dipolePosMovTens(i,2,:),...
        'ZData',dipolePosMovTens(i,3,:),...
        'CData', dipPosColors(1:numberOfDipoles,:));
        
    drawnow
    end
   
    % at the end of the animation the potential distribution of the
    % starting position ...
    x = reshape(elec.pnt(:,1),[numsec/2 + 1, numsec + 1]);
    y = reshape(elec.pnt(:,2),[numsec/2 + 1, numsec + 1]);
    z = reshape(elec.pnt(:,3),[numsec/2 + 1, numsec + 1]);
    pot = reshape(pot,[numsec/2 + 1, numsec + 1]);
    set(pl_potMap, ... 
        'XData', x, ...
        'YData', y, ...
        'ZData', z, ...
        'CData', pot, ...
        'Parent', a_3Dview, ...
        'Visible', 'on');
    % ... and the dipole at the starting position is shown
    set(pl_dipolePos,...
        'XData', dipolePosition(1:numberOfDipoles,1),...
        'YData', dipolePosition(1:numberOfDipoles,2),...
        'ZData', dipolePosition(1:numberOfDipoles,3),...
        'CData', dipPosColors(1:numberOfDipoles,:));     
end


function checkRadius(hObject, eventdata)
    % callback function that is called on leaving a radius edit field
    
    radius = str2num(get(hObject, 'String')); % get the content of the edit field and convert it to a number
    shellnumber = get(hObject, 'UserData'); % the shell number is stored in the UserData field
    
    if(isempty(get(hObject, 'String')))
        set(hObject, 'String', num2str(radii(shellnumber)));
        return;
    end
    
    % check if the content is a valid number, otherwise reset the content 
    % of the edit field and return
    if(~isreal(radius(1)) || numel(radius) ~= 1 || ~isnumeric(radius(1)) || radius <= 0)
        set(hObject, 'String', num2str(radii(shellnumber)));
        return;
    end
    
    % if radius is valid then adjust the global 'radii' variable
    radii(shellnumber) = radius;
    
    % enable warnings
    showWarningCalcPot('on');
    showWarningExport('on');
    
end


function checkDipolePositionComponent(hObject, component)
% check content of edit field with handle hObject for to be a valid single 
% dipole position component
    
    pos = str2num(get(hObject, 'String')); % get the content of the edit field
    
    if(numel(pos) ~=1)
    % if it is not a vector or matrix
        if(isempty(get(hObject, 'String')))
        % if it is empty
            set(hObject, 'String', '0'); % set the edit field...
            dipolePosition(component(1), component(2)) = 0; % ...and the 'dipolePosition' element to zero
            showWarningExport('on')
        else
            set(hObject, 'String', num2str(dipolePosition(component(1), component(2))));
        end
        return;
    end
    
    if(~isreal(pos) || ~isnumeric(pos))
    % if it is not a real number...
        set(hObject, 'String', num2str(dipolePosition(component(1), component(2)))); % set the edit field to the last valid value
        return;
    elseif (pos > radii(1))
    % if the position component is larger then the outer sphere radius...
        set(hObject, 'String', num2str(radii(1))); % ...set edit field...
        dipolePosition(component(1), component(2)) = radii(1); % ...and the 'dipolePosition' element to the outer sphere radius
        showWarningExport('on')
        return;
    end
    
    % Otherwise, if the entry is correct, adjust 'dipolePosition' component
    dipolePosition(component(1), component(2)) = pos;

    showWarningExport('on')
end

function checkMovingDipolePositionComponent(hObject, component)
% check content of edit field with handle hObject for to be a valid single 
% dipole position component
    
    pos = str2num(get(hObject, 'String')); % get the content of the edit field
    
    if(numel(pos) ~=1)
    % if it is not a vector or matrix
        if(isempty(get(hObject, 'String')))
        % if it is empty
            set(hObject, 'String', '0'); % set the edit field...
            movingdipolePosition(component(1), component(2)) = 0; % ...and the 'dipolePosition' element to zero
            showWarningExport('on')
        else
            set(hObject, 'String', num2str(movingdipolePosition(component(1), component(2))));
        end
        return;
    end
    
    if(~isreal(pos) || ~isnumeric(pos))
    % if it is not a real number...
        set(hObject, 'String', num2str(movingdipolePosition(component(1), component(2)))); % set the edit field to the last valid value
        return;
    elseif (pos > radii(1))
    % if the position component is larger then the outer sphere radius...
        set(hObject, 'String', num2str(radii(1))); % ...set edit field...
        movingdipolePosition(component(1), component(2)) = radii(1); % ...and the 'dipolePosition' element to the outer sphere radius
        showWarningExport('on')
        return;
    end
    
    % Otherwise, if the entry is correct, adjust 'dipolePosition' component
    movingdipolePosition(component(1), component(2)) = pos;

    showWarningExport('on')
end
        

function validdipolePosition = checkdipolePosition()
% check for valid dipole poistion. A valid dipole position is within
% the head model.

    validdipolePosition = 0; % suppose invalid dipole positions
    
    for i = 1:numberOfDipoles
        if (norm(dipolePosition(i,:)) > radii(numberOfShells))
            return;
        end       
    end
    
    validdipolePosition = 1;
end

function validStartEndPos = checkStartEndPos()
% check if start and end position of the moving dipoles are different, if
% not display warning

validStartEndPos =1; % assume that the start and end positions are different for all moving dipoles
for i=1:numberOfMovingDipoles-1
   
if (dipolePosition(i,:)-movingdipolePosition(i,:))==zeros(1,3);
    validStartEndPos =0; 
end
end
end

function checkdipoleMoment(hObject, eventdata)
% callback function which is called when leaving a dipole moment edit
% field. Check for valid dipole moment component. A valid dipole moment is
% a real scalar number.

    mom = str2num(get(hObject, 'String'));
    component = get(hObject, 'UserData');
    
    if(numel(mom) ~= 1)
        if(isempty(mom))
            set(hObject, 'String', '0');
            dipoleMoment(component(1), component(2)) = 0;
        else
            set(hObject, 'String', num2str(dipoleMoment(component(1), component(2))));
        end
        checkZerodipoleMoment();
        return;
    end
        
    if(~isreal(mom)) || ~isnumeric(mom)
        set(hObject, 'String', num2str(dipoleMoment(component(1), component(2))));
        checkZerodipoleMoment();
        return;
    end
    
    dipoleMoment(component(1), component(2)) = mom;
    showWarningExport('on')
    checkZerodipoleMoment();
end

function checkmovingdipoleMoment(hObject,eventdata)
% callback function which is called when leaving a moving dipole moment edit
% field. Check for valid dipole moment component. A valid dipole moment is
% a real scalar number. 
mom = str2num(get(hObject, 'String'));
    component = get(hObject, 'UserData');
    
    if(numel(mom) ~= 1)
        if(isempty(mom))
            set(hObject, 'String', '0');
            movingdipoleMoment(component(1), component(2)) = 0;
        else
            set(hObject, 'String', num2str(movingdipoleMoment(component(1), component(2))));
        end
        checkZerodipoleMoment();
        return;
    end
        
    if(~isreal(mom)) || ~isnumeric(mom)
        set(hObject, 'String', num2str(movingdipoleMoment(component(1), component(2))));
        checkZerodipoleMoment();
        return;
    end
    
    movingdipoleMoment(component(1), component(2)) = mom;
    showWarningExport('on')
    checkZerodipoleMoment();

end

function checkZerodipoleMoment()
% checks if there is at least one non-zero dipole moment. If not, a warning
% is displayed
    if (norm(dipoleMoment(1:numberOfDipoles,:)) == 0)
        showWarningDipoleMoment('on');
    else
        showWarningDipoleMoment('off');
    end
end


function checkCond(hObject, eventdata)
% callback function that is called on leaving a shell conductivity edit
% field. If an invalid input was found, the value is reset to the last
% valid value.
    cond = str2num(get(hObject, 'String'));
    shellnumber = get(hObject, 'UserData');
    if(isempty(str2num(get(hObject, 'String'))))
        set(hObject, 'String', num2str(conds(shellnumber)));
        return;
    end
    
    if(numel(cond) ~= 1)
        set(hObject, 'String', num2str(conds(shellnumber)));
        return;
    end
    
    if(~isreal(cond) || ~isnumeric(cond) || cond <= 0)
        set(hObject, 'String', num2str(conds(shellnumber)));
        return;
    end
    
    conds(shellnumber) = cond;
    showWarningCalcPot('on');
    showWarningExport('on')
end

function save_dipole_positioner_viewer(hObject,eventdata)
    % callback function that, creates temporary figure and copies axes
        % for saving single axes as graphics
        
        % get current axes handle
        h_axsTmp = gca;
        
        % create figure
        h_figTmp = figure;
        
        % set position properties
        set(h_axsTmp,'Units','Pixels');
        posTmp = get(h_axsTmp,'OuterPosition');
        set(h_figTmp,'Position',[50 50 posTmp(3) posTmp(4)])
        
        % copy axes
        h_cpy = copyobj(h_axsTmp,h_figTmp);
        
        % set position properties
        set(h_cpy,'OuterPosition',[0 0 posTmp(3) posTmp(4)]);
        set(h_cpy,'Units','normalized');
end


function refreshAxesLimits()
% refreshAxesLimits() adjusts the axes limits of all sourceloc axes as well
% as the 3D view axes such that the volume conduction model fits in them.
    axlimit = 1.2*radii(1);
    for i=1:3
        set(a_sourceloc(i), ...
            'XLim', [-axlimit axlimit], ...
            'YLim', [-axlimit axlimit]);
    end
    set(a_3Dview, ...
        'XLim', [-axlimit axlimit], ...
        'YLim', [-axlimit axlimit], ...
        'ZLim', [-axlimit axlimit]);
    
    set(FloatingCrosshair(1), 'XData', [-axlimit axlimit]);
    set(FloatingCrosshair(2), 'YData', [-axlimit axlimit]);
end


function resetVolumeConductor(hObject, eventdata)
% callback function of "Reset Volume Conductor" button. Resets the volume
% conduction model to the default number of shells with default radii and
% conductivities.
    set(dd_numberOfShells, 'Value', 4);
    radii = [7.5 7.1 6.5 6.3];
    conds = [0.33 0.0042 1 0.33];
    setNumberOfShells();
    for i = 1:4
        set(e_shellradius(i), 'String', num2str(radii(i)));
        set(e_shellconds(i), 'String', num2str(conds(i)));
        set(dd_numberOfShells, 'Value', 4);
    end
    
    createVolumeConductor();
end


function showWarningCalcPot(status)
% showWarningCalcPot(status) enables the warning text that the volume 
% conductor is not up to date if status = 'on' and disables the warning if
% status = 'off'. Additionally, some GUI elements are disabled or enabled.
    if(strcmp(status, 'on'))
        set(t_vcNotUp2Date, 'Visible', 'on');
        set(pb_calculatePotentials, 'Enable', 'off');
        set(pb_calculateElectrodeSignals, 'Enable', 'Off');
        set(pb_showElectrodeSignals, 'Enable', 'Off'); 
        set(pb_createVolumeConductor, 'Enable', 'on');
        set(t_dipoleMomentZero, 'Visible', 'off');
    else
        set(t_vcNotUp2Date, 'Visible', 'off');
        set(pb_calculatePotentials, 'Enable', 'on');
        for i=1:get(dd_numberOfDipoles, 'Value');
        signalSetup(i,1)=get(dd_signal(i), 'Value');
        end
        if (get(dd_elecSetup, 'Value') ~= 1 ) || (length(find(signalSetup-1)) == numberOfDipoles)
        set(pb_calculateElectrodeSignals, 'Enable', 'On');
        end
        set(pb_createVolumeConductor, 'Enable', 'off');
        if(norm(dipoleMoment) == 0)
            set(t_dipoleMomentZero, 'Visible', 'on');
        end
        
    end
end


function showWarningExport(status)
% showWarningExport(status) enables the warning text that the potential 
% map is not up to date if status = 'on' and disables the warning if
% status = 'off'

    set(t_pmNotUp2Date, 'Visible', status);
    updateElecSetup();
    if(strcmp(status, 'on'))
        set(pb_exportElecDataToWorkspace, 'Enable', 'off');
        
    else
        
    end    
end


function showWarningDipoleMoment(status)
% showWarningDipoleMoment(status) enables the warning text that no non-zero
% dipole moment is specified if status = 'on' and the volume conductor not 
% up to date warning is not currently active and disables the warning if
% status = 'off'

    if (strcmp(status, 'on') && strcmp(get(t_vcNotUp2Date, 'Visible'), 'off'))
        set(t_dipoleMomentZero, 'Visible', 'on');
    else
        set(t_dipoleMomentZero, 'Visible', 'off');
    end
end

function exportElecDataToWorkspace(hObject, eventdata)
% callback function of "Export Electrode Data to Workspace" button. Creates
% a struct in the MATLAB 'base' workspace containing many data about the
% current potential map. For details see below.

    outputVarName = get(e_outputVarName, 'String'); % get name of output variable
    
    % chek whether the variable name is valid, ...
    if ~isvarname(outputVarName)
        errordlg(errInvOutputVarName) % ...otherwise show an error message...
        return; % ...and return
    end
    
    % compute the leadfield for given dipole and electrode positions
    lf = ft_compute_leadfield(dipolePosition(1:numberOfDipoles,:), elecSetup, vol);
    
    % compute the potential distribution for given dipoles at electrode
    % positions
    pot = lf * reshape(dipoleMoment(1:numberOfDipoles,:)',3*numberOfDipoles,1);
    
    % create a temporary output struct containing...
    tempout.ElectrodeSetup = cElecSetups{get(dd_elecSetup, 'Value')}; % ...electrode setup name, ...
    tempout.ElectrodeLabels = elecSetup.label; % ...electrode labels, ...
    tempout.ElectrodePoints = elecSetup.pnt; % ...electrode positions, ...
    tempout.ElectrodePotentials = pot; % ...electrode potentials, ...
    tempout.dipolePositions = dipolePosition(1:numberOfDipoles,:); % ...dipole positions, ...
    tempout.dipoleMoments = dipoleMoment(1:numberOfDipoles,:); % ...dipole moments, ...
    tempout.ShellRadii = radii(1:numberOfShells); % ...shell radii, ...
    tempout.ShellConductivities = conds(1:numberOfShells); % ...shell conductivities, ...
    % if electrode signals are computed
    if ~isempty(electrodeSignals);
    tempout.DipoleSignals=signal; % signal matrix containing the dipole signals, ...
    tempout.ElectrodeSignals=electrodeSignals; % ...electrode signals, ...
    end
    % if moving dipoles are selected
    if numberOfMovingDipoles ~= 0
    tempout.movingdipolePositions= movingdipolePosition(1:numberOfMovingDipoles,:); % end positions of moving dipoles
    tempout.movingdipoleMoments=movingdipoleMoment(1:numberOfMovingDipoles,:); % end moments of moving dipoles
    tempout.LeadfieldTensor=lfMovTens; % the leadfield tensor
    %tempout.potMov_topoplot=potMov_topoplot; % tensor containing the potentials over time of moving dipoles
    tempout.movDipPos=dipolePosMovTens; % tensor with the dipole positions during the moving
    else
    tempout.LeadfieldMatrix = lf; % the leadfield matrix, ... 
    %tempout.potMov_topoplot=potMov_topoplot;
    end
    
    % assign this struct in MATLAB 'base' workspace
    assignin('base', outputVarName, tempout);
end

function updateElecSetup(hObject, eventdata)
% callback function of electrode setup dropdown menu. Refreshes the 
% electrode positions in global variables and in the 3D view. 

    elecSetupNumber = get(dd_elecSetup, 'Value'); % get selected electrode setup number
    
    if (elecSetupNumber == 1)
    % if 'No Electrodes' is selected...
        set(pl_elecSetup, 'Visible', 'off'); % ...disable electrode plot,
        set(pb_exportElecDataToWorkspace, 'Enable', 'off'); % ...disable export button and
        set(e_outputVarName, 'Enable', 'off'); % ...disable output variable name edit
        set(pb_calculateElectrodeSignals, 'Enable', 'off'); % disable the 'Calculate Electrode Signals' button in the source
        set(pb_showElectrodeSignals, 'Enable', 'off'); % disable the "Show Electrode Signals" button
        % setting panel
    else
    % otherwise (if a valid electrode setup was selected...
        elecTemp = importdata(elecSetups(elecSetupNumber-1).filename); % ...get electrode positions from file, ...
        elecSetup.pnt = radii(1)*elecTemp.data; % ...multiply them by the outer shell radius and assign them to elecSetup.pnt, ...
        elecSetup.label = elecTemp.textdata(2:end); %. ...assign electrode labels and
        elecSetup.description = elecTemp.textdata(1); % ...get the electrode setup description for dropdown menu and data export
        
        % refresh electrode positions in 3D view an make it visible
        set(pl_elecSetup, ...
            'XData', elecSetup.pnt(:,1), ...
            'YData', elecSetup.pnt(:,2), ...
            'ZData', elecSetup.pnt(:,3), ...
            'Visible', 'on');
        
        % check if the potential map not up to date warning is active,
        % otherwise enable export push button and output variable edit.
        if(strcmp(get(t_pmNotUp2Date, 'Visible'), 'off'))
            set(pb_exportElecDataToWorkspace, 'Enable', 'on');
            set(e_outputVarName, 'Enable', 'on');
        end
        
        % enable the 'Calculate Electrode Signals' button in the source
        % setting panel if a signal is choosen accordingly
        signalSetup=get(dd_signal(1), 'Value');
        if (signalSetup ~= 1) 
           set(pb_calculateElectrodeSignals, 'Enable', 'on');
        else
           set(pb_calculateElectrodeSignals, 'Enable', 'off'); 
        end
    end
end

function reloadElecSetups(hObject, eventdata)
% callback function of "Reload Electrode Setups" button. Looks for
% electrode setup definition (.esd) files in the program directory and
% according to this refreshes the dropdown menu

    d = ls; % get the current directory content
    files = {}; % create an empty cell array
    
    % fill the 'files' cell array with filenames from directory
    for(i=3:size(d,1))
    % start with i=3 because first two directory entries are '.' and '..'
        files{i-2} = deblank(d(i,:)); % remove blanks and write filenames to 'files'
    end
    
    elecSetups = []; % clear elecSetups
    filecount = 1; % reset index counter
    
    % find '.esd' files end write their filenames and descriptions read
    % from file in elecSetups
    for(i=1:numel(files))
    % for every file found in the upper loop...
        if(strcmp(files{i}(end-3:end), '.esd'))
        % check whether it is an '.esd' file
            elecSetups(filecount).filename = files{i}; % write filename to elecSetups, ...
            I = importdata(elecSetups(filecount).filename, '\t', 1); % get all the data out of the file...
            
            % and write only the first line of file to the description 
            % field of elecSetups. There is a better way to do this without 
            % getting ALL the data out of the file but only the first line.
            elecSetups(filecount).description = I.textdata{1};
            
            filecount = filecount + 1; % increment index counter
        end
    end
    
    cElecSetups = {'No Electrodes'}; % initialize a cell array with the default entry 'No Electrodes'
    
    % fill the cell array with electrode setup descriptions
    for i=1:numel(elecSetups)
        cElecSetups=[cElecSetups;elecSetups(i).description];
    end
    
    set(dd_elecSetup, 'String', cElecSetups); % assign the cell array to the dropdown menu, ...
    set(dd_elecSetup, 'Value', 1); % ...select 'No Electrodes'...
    set(dd_elecSetup, 'Enable', 'on'); % ...and eneable it
    
    updateElecSetup(); % update the electrode 3D view after selecting 'No Electrodes'
end

function showEEGDecompositionPanel(hObject,eventdata)
% callback function that opens the EEG decomposition panel
if ishandle(f_decomp)&& (f_decomp ~=0) 
    close(f_decomp)
end

% save electrode data to appropriate file

if get(dd_elecSetup,'Value')==5
    ES='1010'; 
elseif get(dd_elecSetup,'Value')==7
    ES='SyntheticElec'; 
elseif get(dd_elecSetup,'Value')==8
    ES='SyntheticElec(25channels)'; 
end
sig=repmat({''},1,numberOfDipoles);
for i=1:numberOfDipoles
    sv=get(dd_signal(i),'Value');
    %sig(i)='';
    if sv==2; sig(i)=cellstr('alpha-band'); 
        elseif   sv==3; sig(i)=cellstr('beta-band');
            elseif   sv==4; sig(i)=cellstr('ts-alpha-band');
                 elseif   sv==5; sig(i)=cellstr('ts-beta-band');
        elseif   sv==7; sig(i)=cellstr('EP');
            elseif   sv==8; sig(i)=cellstr('sleepspindles');
        elseif   sv==9; sig(i)=cellstr('wave');
            elseif sv==10; sig(i)=cellstr('spike');
                 elseif   sv==11; sig(i)=cellstr('spikewave');
                 elseif   sv==12; sig(i)=cellstr('eyeblink');
    elseif sv==13; sig(i)=cellstr('polyspikes');    
    elseif sv==15; sig(i)=cellstr('paraboloid');
        elseif sv==17; sig(i)=cellstr('singauss');
            elseif sv==18; sig(i)=cellstr('gauss');
                elseif sv==19; sig(i)=cellstr('rect');
                    elseif sv==20; sig(i)=cellstr('ts-spike');
                        elseif sv==22; sig(i)=cellstr('gaussnoise');
    
        
    end
end
if numberOfDipoles==1
    folder_dip='1Dipole';
elseif numberOfDipoles==2
    folder_dip='2Dipoles';
end
if (numberOfDipoles-numberOfMovingDipoles) == 0 % if no static dipoles are selected
f_nD='';
else
    f_nD=['_',int2str(numberOfDipoles-numberOfMovingDipoles),'D'];
end
if numberOfMovingDipoles==0 % if no moving dipoles are selected
    f_nMD='';
else
    f_nMD=['_',int2str(numberOfMovingDipoles),'MD'];
end
if strcmp(get(get(rbg_additiveNoise, 'SelectedObject'),'String'),'Yes') % if noise is added to electrode signals
 noise='_noise';   
else
    noise='';
end
if size(sig,2)==1
elecSig_FileName=sprintf('ED_%s%s%s_%s%s',ES,f_nD,f_nMD,sig{1},noise);
elseif size(sig,2)==2
 elecSig_FileName=sprintf('ED_%s%s%s_%s_%s%s',ES,f_nD,f_nMD,sig{1},sig{2},noise);
end
% create a temporary output struct containing...
% compute the leadfield for given dipole and electrode positions
    lf = ft_compute_leadfield(dipolePosition(1:numberOfDipoles,:), elecSetup, vol);
    % compute the potential distribution for given dipoles at electrode
    % positions
    pot = lf * reshape(dipoleMoment(1:numberOfDipoles,:)',3*numberOfDipoles,1);
    ElecSig.ElectrodeSetup = cElecSetups{get(dd_elecSetup, 'Value')}; % ...electrode setup name, ...
    ElecSig.ElectrodeLabels = elecSetup.label; % ...electrode labels, ...
    ElecSig.ElectrodePoints = elecSetup.pnt; % ...electrode positions, ...
    ElecSig.ElectrodePotentials = pot; % ...electrode potentials, ...
    ElecSig.dipolePositions = dipolePosition(1:numberOfDipoles,:); % ...dipole positions, ...
    ElecSig.dipoleMoments = dipoleMoment(1:numberOfDipoles,:); % ...dipole moments, ...
   ElecSig.ShellRadii = radii(1:numberOfShells); % ...shell radii, ...
    ElecSig.ShellConductivities = conds(1:numberOfShells); % ...shell conductivities, ...
    % if electrode signals are computed
    if ~isempty(electrodeSignals);
    ElecSig.DipoleSignals=signal; % signal matrix containing the dipole signals, ...
    ElecSig.ElectrodeSignals=electrodeSignals; % ...electrode signals, ...
    end
    % if moving dipoles are selected
    if numberOfMovingDipoles ~= 0
    ElecSig.movingdipolePositions= movingdipolePosition(1:numberOfMovingDipoles,:); % end positions of moving dipoles
    ElecSig.movingdipoleMoments=movingdipoleMoment(1:numberOfMovingDipoles,:); % end moments of moving dipoles
    ElecSig.LeadfieldTensor=lfMovTens; % the leadfield tensor
    %tempout.potMov_topoplot=potMov_topoplot; % tensor containing the potentials over time of moving dipoles
    ElecSig.movDipPos=dipolePosMovTens; % tensor with the dipole positions during the moving
    else
    ElecSig.LeadfieldMatrix = lf; % the leadfield matrix, ... 
    %tempout.potMov_topoplot=potMov_topoplot;
    end
    %save(['EEGDecompFunctions\ElectrodeSignals\',folder_dip,'\',TFA_overla
    %p,'\',elecSig_FileName,'.mat'],'ElecSig');
    WorkingFolder='SyntheticElectrodeSetup';
    save(['EEGDecompFunctions\Results\',WorkingFolder,'\ElectrodeSignals\',elecSig_FileName,'.mat'],'ElecSig');
    
   f_decomp = EEGdecomposition(elecSig_FileName);
   guidata(hObject,f_decomp);
end

end

