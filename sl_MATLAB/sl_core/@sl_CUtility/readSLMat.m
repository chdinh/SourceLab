function p_outMat = readSLMat(p_sFilename,p_sType)
%READ Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        p_sType = 0;
    end

    if ~exist(p_sFilename,'file')
        error('%s does not exist.', p_sFilename);
        return;
    end
    
%     t_fileID = fopen(p_sFilename);
%     
%     tline = fgetl(t_fileID);
%     while ischar(tline)
%         disp(tline);
%         tline = fgetl(t_fileID);
%     end
% 
%     fclose(t_fileID);
    
    %ToDo This has to be changed - File format has to be a bin not a txt
    %file for sake of speed and saving memory
    
    t_sContent = fileread(p_sFilename);
    
    t_sContentSplitted = regexp(t_sContent, '\n', 'split');
    clear t_sContent;
    
    if p_sType
        t_type = regexp(t_sContentSplitted(1), ' : ', 'split');
        if ~strcmp(t_type{1,1}(1),'Type') || ~strcmp(t_type{1,1}(2),p_sType)
            error('File %s contains wrong formatted %s.', p_sFilename, p_sType);
            return;
        end
    end
    
    t_dim = regexp(t_sContentSplitted(2), ' : ', 'split');
    t_dim = regexp(t_dim{1,1}(2), 'x', 'split');

    m = str2double(t_dim{1,1}(1));
    n = str2double(t_dim{1,1}(2));

    p_outMat = zeros(m,n);

    for k = 1 : m
        line =  regexp(t_sContentSplitted(k+3), '#', 'split');
        line = str2double(line{1,1});
        line = line(1:n);
        p_outMat(k,:) = line;
    end
end

