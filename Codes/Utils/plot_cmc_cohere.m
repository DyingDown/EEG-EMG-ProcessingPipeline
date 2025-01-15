function plot_cmc_cohere(matFilePath, outputPath, time, freq_range, eventType)

    if nargin < 5
        eventType = ''; % 如果没有传入 param2，则使用默认值
    end
    data = load(matFilePath);
    [~, matFileName, ~] = fileparts(matFilePath); % 文件名不含路径和扩展名
    
    % 提取数据：查找以 'wcohere_C3_' 或 'wcohere_C4_' 开头的变量
    results = {};
    channels = {};
    labels = fieldnames(data.results);
    for i = 1:length(labels)
        disp(labels)
        if startsWith(labels{i}, 'wcohere_C3_') || startsWith(labels{i}, 'wcohere_C4_')
            disp("found start with wcohere_c3_c4")
            results{end+1} = data.results.(labels{i});
            channelName = strrep(labels{i}, 'wcohere_', ''); % 去除 'wcohere_' 前缀
            channelName = strrep(channelName, '_', ' - '); % 替换下划线为 ' - '
            channels{end+1} = channelName;
        end
    end
    disp("result length:")
    disp(length(results));
    disp(channels)

    % 创建图像
    figure;
    t = tiledlayout(4, 4); % 4 行 4 列的布局，保证每个数据项按顺序展示
    for i = 1:length(results)
        nexttile; % 自动按顺序排列
        imagesc(time, freq_range, results{i});
        axis xy; % 确保频率轴正序
        colormap('jet');
        colorbar;
        caxis([0, 0.4]); % 根据数据调整颜色范围
        title(channels{i}, 'Interpreter', 'none');
        xlabel('Time (ms)');
        ylabel('Frequency (Hz)');
    end

    set(gcf, 'Position', [100, 100, 2300, 1000]); % 设置图像大小，适合 4x4 图布局

    % 总标题：获取文件名前缀并生成整体标题
    splitName = split(matFileName, '_');
    prefix = splitName{1}; % 获取文件名前缀
    overallTitle = sprintf('线性脑肌耦合 小波相干分析结果 (C3&C4) %s', prefix);
    sgtitle(overallTitle, 'Interpreter', 'none');

    % 保存图像
    outputFileName = sprintf('%s_%s_CMC(C3&C4).png', prefix, eventType);
    saveas(gcf, fullfile(outputPath, outputFileName));
    close; % 关闭当前图像
end