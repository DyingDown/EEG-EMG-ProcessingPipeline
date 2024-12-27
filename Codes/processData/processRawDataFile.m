function processRawDataFile(filepath, isPeakPoint)
    fprintf("Loading data from %s\n", filepath);
    fid = fopen(filepath);
    if fid == -1
        error('无法打开文件：%s', filepath);
    end

    [~, ~, ext] = fileparts(filepath);
    if ~strcmp(ext, "txt")
        disp("This file is not a txt source file");
    end

    % 不包含时间戳的数据格式
    % datafile = textscan(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', 'CommentStyle', '#');
    datafile = textscan(fid, repmat('%f', 1, 32), 'Delimiter', '\t', 'CommentStyle', '#');
    
    fclose(fid);

    fprintf("Parting and filtering Data\n")
    % 拆分EMG数据和EGG数据
    EMGData = [datafile{1:8}]; 
    EEGData = [datafile{17:32}];
    [EMGData, EEGData] = filterData(EMGData, EEGData);
    
    [TL_a, TL_b, startPoints, isDeleted] = modifyStartPoints(EMGData, EEGData, isPeakPoint, filepath);

    if isDeleted == false
        create_event_info(filepath, TL_a, TL_b, startPoints);
    
    
        [cutEMG, cutEEG] = cutData(EMGData, EMGData, filepath, TL_a, TL_b, startPoints, isPeakPoint);
        saveCuttedData([cutEMG, cutEEG]', filepath);
    end
end


function [EMGData, EEGData] = filterData(EMGData, EEGData)
    %{
        滤波处理，这部分代码可以在图表展示时启用，方便查看分段结果；在保存结果到文件时注释，这样保存的结果是原始未滤波数据
    
        陷波滤波: 消除 50Hz 工频干扰及其倍频干扰（常见于电生理数据采集时的电力噪声）。
        带通滤波:
            EMG 信号滤波到 20-150Hz 范围，保留肌电数据的主要频段。
            EEG 信号滤波到 1-49Hz，保留脑电数据的主要频段。
    %}
    
    fs=1000; % 采样频率
    for j=1:9   % 工频滤波 消除50Hz工频干扰及其倍频干扰
        [b,a]=butter(2, [2*(50*j-1)/fs,2*(50*j+1)/fs], "stop");
        EMGData=filter(b,a,EMGData);
        EEGData=filter(b,a,EEGData);
    end
    
    %EMGData = abs(EMGData); %整流，可调整是否需要整流
    [b,a]=butter(4, [2*20/fs,2*150/fs],"bandpass"); %EMG 20-150Hz带通
    EMGData=filter(b,a,EMGData);
    [b,a]=butter(4, [2*1/fs,2*49/fs],"bandpass"); %EEG 1-49Hz带通
    EEGData=filter(b,a,EEGData);
end

function [TL_a, TL_b, startPoints, isDeleted] = modifyStartPoints(EMGData, EEGData, isPeakPoint, filepath)
    % modifyStartPoints Adjustify the start points mannually with plot
    %
    % Inputs
    %   EMGData     - (double array)
    %   EEGData     - (double array)
    %   isPeakPoint - (bool) 打点位置是不是在峰值上
    %   filepath    - (string) 数据源文件路径
    %
    % Author: o_oyao
    % Date: 2024-MM-DD

    % 如何之前有默认的打点数据或者TL_a TL_b，则使用之前的
    [filefolder, filename, ext] = fileparts(filepath);
    fprintf("filename=%s\n", filename);


    mataInfoPath = fullfile(fileparts(filefolder) + "/meta_info/", filename + ".mat");
    bannedEMGList = [];
    bannedEEGList = [];
    % 检查文件是否存在
    % disp(mataInfoPath)
    % disp(exist(mataInfoPath, "file"))
    if exist(mataInfoPath, "file") == 2
        try
            % 尝试加载 .mat 文件
            metaInfo = load(mataInfoPath);
            startPoints = metaInfo.startPoints;
            TL_a = metaInfo.TL_a;
            TL_b = metaInfo.TL_b;
            bannedEMGList = [bannedEMGList, metaInfo.bannedEMGList];
            bannedEEGList = [bannedEEGList metaInfo.bannedEEGList];
            fprintf("found meta info file %s\n", mataInfoPath)
        catch ME
            % 如果发生错误, 捕获并显示错误信息
            disp(['加载文件时发生错误: ', ME.message]);
        end
    else
        % 如果文件不存在
        disp("没有指定默认AB事件时长和打点信息，将采取系统默认时长3s和源数据打点信息")
        % 获取打点信息
        startPoints = extract_startPoints(filepath);
    
        disp(startPoints)
    
        TL_a = 3000; % milliseconds 默认的
        TL_b = 3000;
    end
    
    plotData(EMGData, EEGData, filename, TL_a, TL_b, startPoints, true, false, bannedEMGList, bannedEEGList);

    [TL_a, TL_b, startPoints, bannedEMGList, bannedEEGList, isDeleted] = inputVariables(EMGData, EEGData, TL_a, TL_b, startPoints, filepath, isPeakPoint, bannedEMGList, bannedEEGList);
    
end


function [TL_a, TL_b, startPoints, bannedEMGList, bannedEEGList, isDeleted] = inputVariables(EMGData, EEGData, TL_a, TL_b, startPoints, filepath, isPeakPoint, bannedEMGList, bannedEEGList)
    % inputVariables input the TL_a, TL_b
    %
    % Inputs
    %   TL_a         - (int) default TL_a
    %   TL_b         - (int) default TL_b
    %   startPoints  - (array) default startPoints
    %

    isDeleted = false;

    [filefolder, filename, ext] = fileparts(filepath);
    
    fig = uifigure('Name', 'Meta Info Input');
    
    grid = uigridlayout(fig, [5, 3]);  % 5行6列的网格布局
    grid.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit'};  % 每行高度自动调整
    grid.ColumnWidth = {'1x', '1x', '1x'};                % 3列等宽
    
    % 创建输入字段标签和字段
    % 输入TL_a
    uilabel(grid, 'Text', 'TL_a:', 'HorizontalAlignment', 'right');
    a_input = uieditfield(grid, 'numeric', 'Value', TL_a);
    a_input.Layout.Column = [2, 3];  % 跨两列（中间和右侧）

    % 输入TL_b
    % 输入TL_a
    uilabel(grid, 'Text', 'TL_b:', 'HorizontalAlignment', 'right');
    b_input = uieditfield(grid, 'numeric', 'Value', TL_b);
    b_input.Layout.Column = [2, 3];  % 跨两列（中间和右侧）
    
    
     % 输入打点
    uilabel(grid, 'Text', 'Start points(comma separated):', 'HorizontalAlignment', 'right');
    startPoints_input = uieditfield(grid, 'text');
    startPoints_input.Layout.Column = [2,3];      % 跨两列
    startPoints_input.Value = strjoin(arrayfun(@num2str, startPoints, 'UniformOutput', false), ', '); % 将数组转换成逗号分隔的字符串
    
     % 输入不看EMG通道
    uilabel(grid, 'Text', 'Banned EMG List(comma separated):', 'HorizontalAlignment', 'right');
    bannedEMGList_input = uieditfield(grid, 'text');
    bannedEMGList_input.Layout.Column = [2,3];      % 跨两列
    bannedEMGList_input.Value = strjoin(arrayfun(@num2str, bannedEMGList, 'UniformOutput', false), ', '); % 将数组转换成逗号分隔的字符串
    
     % 不看EEG通道
    uilabel(grid, 'Text', 'Banned EEG List(comma separated):', 'HorizontalAlignment', 'right');
    bannedEEGList_input = uieditfield(grid, 'text');
    bannedEEGList_input.Layout.Column = [2,3];      % 跨两列
    bannedEEGList_input.Value = strjoin(arrayfun(@num2str, bannedEEGList, 'UniformOutput', false), ', '); % 将数组转换成逗号分隔的字符串

    % 创建按钮：提交并更新图形
    submit_button = uibutton(grid, 'Text', 'Save & Update figure', 'ButtonPushedFcn', @(btn, event) update_variables_and_plot());
    % do not show some channel on the figure
    updatetBanned = uibutton(grid, 'Text', 'Update Banned Channel', 'ButtonPushedFcn', @(btn, event) updateBannedChann());
    % view cutted waves
    view_cutted_button = uibutton(grid, 'Text', 'View Cutted Figure', 'ButtonPushedFcn', @(btn, event) view_cutted());

    % 创建按钮：关闭表单和图形窗口
    close_button = uibutton(grid, 'Text', 'Close', 'BackgroundColor', '#2b75a6' ,'ButtonPushedFcn', @(btn, event) close_window());
    % discard this file
    finished_button = uibutton(grid, 'Text', 'Mark Finish Permenantly', 'BackgroundColor', '#77ac30', 'ButtonPushedFcn', @(btn, event) move_file('permentanly mark file ' + filename + ' as finished and will never show up again', "finished"));

    discard_button = uibutton(grid, 'Text', 'Discard this file', 'BackgroundColor', '#c42b1c', 'ButtonPushedFcn', @(btn, event) delete_file());
    
    submit_button.Layout.Column = 1;  % 占第1列
    updatetBanned.Layout.Column = 2;  % 跨3列
    view_cutted_button.Layout.Column = 3;
    close_button.Layout.Column = 1;   % 占第2列
    finished_button.Layout.Column = 2;
    discard_button.Layout.Column = 3;

    waitfor(fig); 

    % 更新变量并绘制图形的回调函数
    function update_variables_and_plot()
        % 从输入框获取变量
        TL_a = a_input.Value;  % 获取 a 的值
        TL_b = b_input.Value;  % 获取 b 的值
        startPointsStr = startPoints_input.Value;  % 获取数组字符串值
        startPoints = str2num(startPointsStr);  % 将字符串转换为数字数组
        bannedEEGList = str2num(bannedEEGList_input.Value);
        bannedEMGList = str2num(bannedEMGList_input.Value);
        
        
        % 获取上一层目录
        parentfolder = fileparts(filefolder);
        newFolder = fullfile(parentfolder, "meta_info");
        if ~exist(newFolder, "dir")
            mkdir(newFolder)
            fprintf("Created a new folder %s\n", newFolder);
        end

        % 重绘图
        waveFig = plotData(EMGData, EEGData, filename, TL_a, TL_b, startPoints, isPeakPoint, true, bannedEMGList, bannedEEGList);
        % 保存变量
        metaInfoPath = fullfile(newFolder, filename + ".mat");
        save(metaInfoPath, 'TL_a', 'TL_b', 'startPoints', 'bannedEEGList', 'bannedEMGList');
        fprintf("Saved meta info for %s at %s\n", filename, metaInfoPath);
    end

    % 关闭窗口的回调函数
    function close_window()
        % 关闭图形窗口
        close(fig);
    end

    function updateBannedChann()
        plotData(EMGData, EEGData, filename, a_input.Value, b_input.Value, startPoints, isPeakPoint, true, str2num(bannedEMGList_input.Value), str2num(bannedEEGList_input.Value));
    end

    function move_file(confirmMessage, folderName)
        % 弹出确认对话框
        choice = uiconfirm(fig, ...
            'This action will' + confirmMessage  + '. Are you sure to do that?', ...
            'Confirm Action', ...
            'Options', {'Continue', 'Cancel'}, ...
            'DefaultOption', 2, ...
            'CancelOption', 2);
    
        % 判断用户选择
        if strcmp(choice, 'Continue')
            % 如果用户点击“确定”，继续执行操作

            destinateFolder = getParentSibling(filepath, folderName);
            destinateFilepath = fullfile(destinateFolder, filename + ext);
            fprintf("Destinated moving Folder = %s\n", destinateFilepath);
            movefile(filepath, destinateFilepath);
            fprintf('%s moved to %s\n', filepath, destinateFilepath);

            % close it's figure
            waveFig = findall(0, 'Name', ['Window ' char(filename)], 'Type', 'figure');
            close(waveFig);  % 关闭已打开的图形窗口
            close(fig);

        else
            % 如果用户点击“取消”，中止操作
            disp('Moving cancelled.');
            % 返回
            return;
        end

    end

    function view_cutted()
        TL_a = a_input.Value;  % 获取 a 的值
        TL_b = b_input.Value;  % 获取 b 的值
        startPointsStr = startPoints_input.Value;  % 获取数组字符串值
        startPoints = str2num(startPointsStr);  % 将字符串转换为数字数组
        bannedEEGList = str2num(bannedEEGList_input.Value);
        bannedEMGList = str2num(bannedEMGList_input.Value);
        [cutEMGData, cutEEGData] = cutData(EMGData, EEGData, filepath, TL_a, TL_b, startPoints, isPeakPoint);
        start = 1;
        marks = [];
        for i = 1:length(startPoints)
            marks = [marks start];
            if mod(i, 2) == 1
                start = start+TL_a;
            else
                start = start + TL_b;
            end
        end

        plotData(cutEMGData, cutEEGData, filename, TL_a, TL_b, ...
            marks, false, true, bannedEMGList, bannedEEGList);
    end

    function delete_file()
        move_file('remove file ' + filename + ' from original data files', "discard")
        isDeleted = true;
    end
end
 
function [newEMGData, newEEGData] = cutData(EMGData, EEGData, filepath, TL_a, TL_b, startPoints, isPeak)
    fprintf("Start cutting the Data in to pieces and combine together.\n")
    %% 结果保存-分段且过滤

    save_idx = [];

    if isPeak == true
        for j = 1:length(startPoints)    
            if mod(j, 2) == 1
                save_idx = [save_idx (startPoints(j)-TL_a/2):(startPoints(j)+TL_a/2)];
            else
                save_idx = [save_idx (startPoints(j)-TL_b/2):(startPoints(j)+TL_b/2)];
            end
        end
    else
        for j = 1:length(startPoints)    
            if mod(j, 2) == 1
                save_idx = [save_idx startPoints(j):(startPoints(j)+TL_a)];
            else
                save_idx = [save_idx startPoints(j):(startPoints(j)+TL_b)];
            end
        end
    end

    newEMGData = EMGData(save_idx,:);
    newEEGData = EEGData(save_idx,:);
end

function saveCuttedData(combineddata, filepath) 
    [~, nameWithoutExtension, ext] = fileparts(filepath);

    processedDataFolderPath = getParentSibling(filepath, "filtered");
    fprintf("processedDataFolderPath=%s\n", processedDataFolderPath);

    saveFilePath = fullfile(processedDataFolderPath, nameWithoutExtension + "_raw_processed"+ ext);
    fid = fopen(saveFilePath, 'w');
    if fid == -1
        error('无法打开文件：%s', fullpath);
    end
    fprintf(fid, '%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\r\n', combineddata);
    fclose(fid);
    fprintf("Processed Data saved succesfully at %s\n", saveFilePath)
end