% 模拟数据 (使用真实数据时替换以下)
fs = 1000;          % 采样率（Hz）
t = 0:1/fs:3;       % 3秒数据时间轴

subj_no = "subj4";
eventType = 'a';
% 加载 .mat 数据
% taData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_TA.mat');
% plData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_PL.mat');
% rfData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_RF.mat');
% rfData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_RF.mat');
% rfData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_RF.mat');
% rfData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_RF.mat');
% rfData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj0/4_afterICA_dir_a_CMCvalues_RF.mat');

% data = load('D:\Documents\Peng\zhengda\CMCresult_lowerLimb\CMCvalues\subj1_s01_preped_dir_a_CMCvalues(MG&RF).mat');


channels =  {};
results = {};

folderPath = 'D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/'+subj_no;

% folderPath = 'D:\Documents\Peng\zhengda\CMCresult_lowerLimb\CMCvalues';

% 获取文件夹中的所有文件和文件夹（包括隐藏文件）
fileList = dir(folderPath);

% 排除 '.' 和 '..' 文件夹
fileList = fileList(~ismember({fileList.name}, {'.', '..'}));

dataLen = 0;
% 遍历文件列表
for k = 1:length(fileList)

    fileName = fileList(k).name;  % 获取文件或文件夹的名字
    filepath = fullfile(folderPath, fileName);  % 获取完整路径
    
    disp(fileName(1))
    disp(fileName)
    disp(filepath)
    if fileName(1) ~= eventType
        fprintf("continue\n")
        continue;
    end
    
    disp(k)

    [~, varName, ~] = fileparts(fileName);
    parts = split(varName, '_');
    EMG_label = parts{end};

    channels = [channels, strcat(EMG_label, '-C3'), strcat(EMG_label, '-C4')];
    % channels = [channels, ];

    data = load(filepath);
    dataLen = size(data.wcohere_C3, 2);

    results = [results, data.wcohere_C3, data.wcohere_C4];
end

disp(results)

% 小波频率范围
freq_range = 1:0.5:50;  % 可以根据需求调整频率范围
% 假设 wcohere_MGvsC3 是计算好的小波相干值矩阵，time 和 freq 是时间和频率轴
% wcohere_MGvsC3, wcohere_RFvsC3, 等等

% 2. 设置绘图参数
% channels = {'MG-C3', 'MG-C4', 'RF-C3', 'RF-C4'}; % 替换为你的肌肉-脑区名称
% results = {data.wcohere_MGvsC3, data.wcohere_MGvsC4, data.wcohere_RFvsC3, data.wcohere_RFvsC4}; % 数据按顺序
freq = 1:50; % 频率范围 (Hz)，调整到你的范围
time = linspace(0, 3000, dataLen); % 时间 (ms)

% 3. 创建子图
figure;
for i = 1:length(results)
    % subplot(length(results), 1, i);
    nexttile
    imagesc(time, freq, results{i});
    axis xy; % 确保频率轴是正序
    colormap('jet'); % 设置颜色
    colorbar; % 显示颜色条
    caxis([0, 0.4]); % 限定颜色范围，根据数据调整
    title(channels{i}, 'Interpreter', 'none');
    xlabel('Time (ms)');
    ylabel('Frequency (Hz)');
end

% 4. 添加整体图标题
sgtitle(['线性脑肌耦合 小波相干分析结果  (C3/C4)  王之一-20240821第二次-2024-08-21-16-39-05.309000 事件'  eventType]);


% % 图像参数设置
% figure;
% for i = 1:num_muscles
%     for j = 1:num_channels
%         % 计算EEG/EMG时频图
%         [wt, f] = customMorletCWT(emg_data(i, :), fs, freq_range);  % EMG的小波变换
%         subplot(num_muscles, num_channels, (i-1)*num_channels + j); % 子图
%         imagesc(t, f, abs(wt));  % 绘制小波图
%         set(gca, 'YDir', 'normal');  % Y轴正方向向上
%         colorbar;  % 颜色条
%         caxis([0, 0.4]);  % 设置颜色范围（按你的需要调整）
% 
%         % 添加标题与标签
%         if i == 1
%             title(sprintf('%s-%s', muscle_names{i}, eeg_channels{j})); % 每列标题
%         end
%         if j == 1
%             ylabel(sprintf('%s', muscle_names{i}));  % 每行标签
%         end
%         if i == num_muscles
%             xlabel('Time (s)');  % 只在最后一行设置时间标签
%         end
%     end
% end
% 
% % 总标题
% sgtitle('脑肌耦合时频域结果（小波变换）');

% function [wt, f] = customMorletCWT(signal, fs, freq_range)
%     % 自定义 Morlet 母小波并实现小波变换
%     scales = fs ./ freq_range; % 根据频率范围设置小波尺度
%     f = freq_range;            % 输出频率向量
%     wt = zeros(length(scales), length(signal)); % 初始化小波系数
% 
%     for idx = 1:length(scales)
%         scale = scales(idx);
%         % 检查 `scale` 的合法性，并生成时间窗口
%         t = -4*scale:1/fs:4*scale; % 时间窗口长度
%         fc = 1; % 母小波中心频率
%         morlet_wavelet = (pi^(-0.25)) * exp(-t.^2/(2*scale^2)) .* exp(1i*2*pi*fc*t);
% 
%         % 对信号执行卷积
%         wt(idx, :) = conv(signal, morlet_wavelet, 'same');
%     end
% end
