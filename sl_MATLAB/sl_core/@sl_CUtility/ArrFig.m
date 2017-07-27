% ARRFIG arranges any open figures on screen
%   
%   ARRFIG('PropertyName', PropertyValue) sets the value of the specified 
%   property in order to arrange any open matlab figure in a particular way
%
%   Possible properties are:
%       'region'    ->      Specifies a region on screen, where figures
%                           should be arranged.
%                           Value can be 'fullscreen' or a 1 by 4 - matrix
%                           containing x- and y-coordinates (in pixels) and
%                           x- and y-dimension (in pixels as well). 
%                           If any of the numerical values is less than
%                           one and unequal zero, the respective value is
%                           threated as a percentage of the pertain screen
%                           property
%
%       'figmat'    ->      m by n - matrix that contains the information
%                           which figures to arrange and where to arrange
%                           on screen.
%                           In case the matrix is empty [], ARRFIG tries to
%                           squeeze all figures in a appropriate matrix.
%                           A zero as matrix value is a simple place
%                           holder.
%
%       'distance'  ->      That's the distance between each figure. The
%                           distance from each edge of any figure at the
%                           margin is half this value.
%
%       'monitor'   ->      Specifies the number (a scalar) of the monitor
%                           where the figures should be arranged
%
% Example:
%
% Let's say we have 5 figures 1 to 5. The screen resolution is 1280 x 1024.
% The command 
%
%       arrfig('region', [0 0.5 500 0.4], 'figmat', [1 1 3; 1 1 0; 5 4 4],
%       'distance', 0, 'monitor', 2);
%
% will arrange the figures in a rectangular region starting from [0, 512]
% to [500 922]. The origin of the screen coordinate system lies in the very
% upper left corner of the screen. The y-coordinate goes downward, x goes 
% to the right.
% arrfig divides the region into uniform sections. These sections are now
% combined into larger ones according to figmat. The particular figures are
% fit into these sections. That's all. In our case it should look like
% this:     
%           ----------------------------------------
%          |                                        |
%          |                                        |
%          |                                        |           
%          |                                        |           
%          |                                        |           
%           ---------------------                   |
%          |  figure 1   | f3    |                  |
%          |             |-------|    rest of       |
%          |             |       |    screen        |
%          |---------------------|                  |
%          | f5   | figure 4     |                  |
%           ---------------------                   |
%          |                                        |           
%           ----------------------------------------
% 
% The distance between the figures is 0. 
% 
% The figures are arranged on monitor 2. The origin of its coordinate
% systems lies in the very upper left corner as well. Just arrange your
% figures as you would do it on your main screen, ArrFig will do the rest.
%
% To arrange your figures on 2 screens independently, just use 2 
% ArrFig-instructions. This works on one screen as well.
%
%
% TODO: - alignment to left, right, upper and lower side of screen
%       - free choice of x- and y-dimensions of the figures
%       - specify aspect ratio
%       - specify maximum numbers of figures, that can be arranged in a
%         single row
%       - ...
%
%
% V1.0
%       basic version
%
% V1.1
%       added multi-screen capability (hopefully); has been tested on a 2
%       monitor system with identical resolution
%
% This script is still in development.
% any ideas, improvements, correction -> mail me: spamcubed@gmx.net
%
%
function ArrFig(varargin)

Handles = sort(get(0, 'Children'));
% ScreenSize = get(0, 'ScreenSize');
MonitorPositions = get(0, 'MonitorPosition')


fit2mat=0;
bFullScreen = 0;


%% check if there are any figures to arrange
if (isempty(Handles))
    error('There are no figures to arrange')
    return
end


%% analyze function parameters
ii = 0;
while ii<nargin

    ii = ii + 1;

    tmp = varargin{ii};
    if(ischar(tmp))
        switch lower(tmp)

            % region where figures should be arranged
            case 'region'
                Region = varargin{ii+1};

                if(ischar(Region))
                    if(strcmp(lower(Region), 'fullscreen'))
                        bFullScreen = 1;
                    else
                        error('"%s" ist kein gültiger Parameter für "Region"', Region);
                    end
                end

            % arrangement of figures is determined by matrix MatFig    
            case 'figmat'
                MatFig = varargin{ii+1};
                fit2mat=1;
                
            case 'distance'
                Distance = varargin{ii+1};
                
            case 'monitor'
                Monitor = varargin{ii+1};

            otherwise
                error('%s ist unbekannter Parameter', tmp);
                return;
        end

        ii=ii+1;

    else
        error('%s ist kein String', num2str(tmp));
        return
    end

end

ScreenSize = [1 1 diff(MonitorPositions(Monitor, [1,3]))+1 diff(MonitorPositions(Monitor, [2,4]))+1];

if (bFullScreen==1)
    Region = ScreenSize;
    bFullScreen = 0;
end



%% check if position and size of Region is absolute or relative to actuall
%% screen size
tmp = repmat(ScreenSize(3:4),1,2);
for ii = 1:4
    if ((Region(ii)<1) && Region(ii)~=0)
        Region(ii) = round(Region(ii)*tmp(ii));
    end
end


%% arrange figures according to matrix entries
if(fit2mat)

    % check if MatFig is empty
    if isempty(MatFig)

        % if so, try to squeeze all figures in a appropriate matrix
        n = ceil(sqrt(length(Handles)));
        m = ceil(length(Handles)/n);

        MatFig = reshape((1:n*m), m, n)';
        
        if ((n*m)<=2)
            MatFig = MatFig';
        end
    end

    MatFig = flipud(MatFig);
    SizeMat = size(MatFig);

    xsize = Region(3)/SizeMat(2);
    %ysize = 1/AspectRatio*xsize;
    ysize = Region(4)/SizeMat(1);

    for ii = 1:max(max(MatFig))

        [u,v] = find(MatFig==ii);

        u_start = min(u);
        u_end = max(u);

        v_start = min(v);
        v_end = max(v);

        if ~isempty([u_start u_end v_start v_end])

            % calculate position and size of figure ii, ...
            position = [Region(1) (ScreenSize(4)-Region(2)-Region(4)) 0 0];
            position = position + [(v_start-1)*xsize (u_start-1)*ysize ...
                (v_end-v_start+1)*xsize ...
                (u_end-u_start+1)*ysize];
            position = position + [5 5 -5 -80] + ....
                        [0.5*Distance 0.5*Distance -Distance -Distance];
      
                    
            if any(position(3:4)<0)
                error('Figures do not fit into region. Try to enlarge region or reduce number of figures.')
                return
            end
                    

            % ... arrange it and make it active
            if ~isempty(find(Handles==ii))
                set(ii, 'Position', position + [MonitorPositions(Monitor, 1:2)-[1 1] 0 0]);
                figure(ii);
            end
        end
    end     % end ii
end
   