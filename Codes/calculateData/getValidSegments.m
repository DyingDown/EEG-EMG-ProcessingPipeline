% function lats = getValidSegments(EEG, TL)
% 
%     % 初始化输出的有效片段索引
%     lats = [];
% 
%     % 读取数据长度
%     totalLength = size(EEG.data, 2); % EEG 数据的总时间点数量
% 
%     % 遍历时间点，检查每个起点是否满足条件
%     for i = 1:(totalLength - TL)
%         % 取当前时间段的数据
%         segment = EEG.data(:, i:i+TL-1);
% 
%         % 如果片段有效，记录其起点索引
%         lats(i, :) = segment;
%     end
% end

function lats = getValidSegments(EEG, TL)
    % 输入:
    % dEEG: 截取后的 EEG 数据 (pop_rmdat 已按 TL/Fs 截取)
    % TL:   每段数据的长度 (单位: 采样点数)

    % 初始化输出，读取通道数和数据总采样点
    [numChannels, totalPoints] = size(EEG.data);

    % 每段的采样点数已经通过调用方确保合理
    if TL > totalPoints
        error('Segment length exceeds the length of EEG data.');
    end

    % 确定片段数量 (无重叠片段)
    numSegments = floor(totalPoints / TL);

    % 初始化结果为三维数组: [通道数 x 每段采样点数 x 段数]
    lats = zeros(numChannels, TL, numSegments);

    % 按 TL 步长逐段提取
    for segIdx = 1:numSegments
        % 计算每段数据起止索引
        startIdx = (segIdx - 1) * TL + 1;
        endIdx = startIdx + TL - 1;

        % 截取当前段
        lats(:, :, segIdx) = dEEG.data(:, startIdx:endIdx);
    end
end

