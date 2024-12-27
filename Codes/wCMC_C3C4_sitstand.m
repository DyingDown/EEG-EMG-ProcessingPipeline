Fs = 1000;
% TL = 5200*Fs/1000;%P4、P5
TL = 3000*Fs/1000;%P4、P5
subj_no = "subj4";
%分运动方向、EEG频带分析
% dirs = ['b', 'c', 'd', 'e', 'f', 'g', 'h'];

tic;

dirs = ['b'];
filename = erase(EEG.filename, '.set');
for idx = 1:length(dirs)
    dEEG = pop_rmdat(EEG, {dirs(idx)}, [0, TL/Fs],0);   %选取特定方向的动作段
    dEEG.setname = filename + "_dir_"+dirs(idx);
    aEEG = dEEG;
end

% 各肌电通道定义
EMG_chs = [1, 2, 3, 4, 5, 6, 7, 8]; % 分别为 TA, PL, MG, LG, RF, VM, LBF, SEM
EMG_labels = {'TA', 'PL', 'MG', 'LG', 'RF', 'VM', 'LBF', 'SEM'};

% EEG通道定义
EEG1ch = 12;%C3
EEG2ch = 16;%C4

% lats = getValidSegments(aEEG, TL); 
% N = length(lats); 

[~, totalPoints] = size(aEEG.data);
N = floor(totalPoints / TL);
fprintf("N=%d, totalPoints = ", N, totalPoints);

% 初始化存储变量
C3 = zeros(TL, N);
C4 = zeros(TL, N);

for j = 1:length(EMG_labels)
    eval([EMG_labels{j}, '= zeros(TL, N);']);
end

idx = 1;

% 数据分段提取
for i = 1:N
    % idx = lats(i);
    try
        % 提取EMG信号
        for j = 1:length(EMG_chs)
            eval([EMG_labels{j}, '(:,i) = aEEG.data(EMG_chs(j),idx:idx+TL-1)'';']);
        end
        % 提取EEG信号
        C3(:, i) = aEEG.data(EEG1ch, idx:idx+TL-1)';
        C4(:, i) = aEEG.data(EEG2ch, idx:idx+TL-1)';
    catch
        N = N - 1;
    end
    idx = idx + TL;
end


% 分批次计算并保存
for j = 1:length(EMG_labels)
    label = EMG_labels{j};
    
    fprintf("Start processing %s C3\n", label);
    [wcohere_C3, ~, ~] = calcCMC(C3, eval(label), N, TL, Fs);
    fprintf("Finished %s C3\n", label);


    elapsedTime = toc;  % 获取已运行的秒数

    % 计算分钟和秒数
    minutes = floor(elapsedTime / 60);  % 获取完整的分钟
    seconds = round(mod(elapsedTime, 60));  % 获取剩余的秒数
    % 输出格式为：几分钟几秒
    fprintf('已运行时间：%d分钟 %d秒\n', minutes, seconds);
    
    fprintf("Start processing %s C4\n", label);
    [wcohere_C4, ~, ~] = calcCMC(C4, eval(label), N, TL, Fs);


    elapsedTime = toc;  % 获取已运行的秒数

    % 计算分钟和秒数
    minutes = floor(elapsedTime / 60);  % 获取完整的分钟
    seconds = round(mod(elapsedTime, 60));  % 获取剩余的秒数
    fprintf("Finished %s C4\n", label);
    
    % 输出格式为：几分钟几秒
    fprintf('已运行时间：%d分钟 %d秒\n', minutes, seconds);

    % 分别保存C3和C4的结果
    save_folder = "D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/" + subj_no;
    if ~exist(save_folder, "dir")
        mkdir(save_folder)
    end

    save_path = save_folder + "/" + dirs(1)+ "_" + aEEG.setname + "_CMCvalues_" + label + ".mat";
    save(save_path, 'wcohere_C3', 'wcohere_C4');
    
    fprintf("Saved results for %s\n", label);
       
end