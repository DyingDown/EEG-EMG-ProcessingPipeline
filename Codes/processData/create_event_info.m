function create_event_info(filepath, TL_a, TL_b, startPoints)
    % create_event_info create file for events
    %
    % Inputs
    %   filepath        - (string) path of original data file
    %   TL_a        - (int) length of event a
    %   TL_b        - (int) length of event b
    %   startPoints - (array) start points
    

    [filefolder, filename, ~] = fileparts(filepath);

    fprintf("Start creating events info for file %s\n", filename);

    eventFolder = getParentSibling(filepath, "events_info")

    eventFilepath = fullfile(eventFolder, filename + ".txt");


    len = length(startPoints); 
    

    eventInfo = cell(len * 2, 3); % 事件信息的储存矩阵

    start = 1;
    for j = 1:len*2 
        if mod(j, 2) == 1
            eventType = 'a'; % a类事件
            period = TL_a; % a类周期
        else
            eventType = 'b'; % b类事件
            period = TL_b; % b类周期
        end
        eventInfo{j, 1} = eventType;
        eventInfo{j, 2} = start;
        eventInfo{j, 3} = period;
        start = start + period; % 更新起始点
    end
    
    disp(eventInfo);

    fid = fopen(eventFilepath, 'w'); % 打开文件
    
    for j = 1:len*2
        fprintf(fid, '%s\t%d\t%d\n', eventInfo{j, :}); % 写入事件信息，注意顺序
    end

    fclose(fid); % 关闭文件
    fprintf("Successfullly created event info file for %s at %s\n", filename, eventFilepath)
end