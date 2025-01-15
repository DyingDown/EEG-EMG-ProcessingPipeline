function plotCohAvg() 
    global config;
    % 设置默认文件夹路径
    defaultFolderPath = config.avgDatasFolder; % 默认路径，根据需要修改

    % 如果默认路径不存在，设置为空路径
    if ~isfolder(defaultFolderPath)
        defaultFolderPath = pwd; % 使用当前路径
    end

    % 创建选择文件夹窗口
    selectedFolder = uigetdir(defaultFolderPath, '请选择一个文件夹');

    % 如果用户点击取消，结束函数
    if isequal(selectedFolder, 0)
        disp('用户取消选择');
        return;
    end

    % 显示所选文件夹路径
    fprintf('所选文件夹路径为：%s\n', selectedFolder);

    % % 获取文件目录
    % files = dir(selectedFolder);
    destinatedFolder = fullfile(selectedFolder, "avg");
    if ~exist(destinatedFolder)
        mkdir(destinatedFolder)
    end

    % 小波频率范围与时间轴设置
    freq_range = 1:0.5:50; % 调整频率范围
    freq = 1:50; % 频率 (Hz)
    time = linspace(0, 3000, 1000); % 时间 (ms)

    destinatedFilepath = fullfile(destinatedFolder, "avg.mat");

    
    resultFile = computeAvg(selectedFolder, destinatedFilepath);
   
    [desFolder, ~, ~] = fileparts(resultFile);

    plot_cmc_cohere(resultFile, desFolder, time, freq_range);
end