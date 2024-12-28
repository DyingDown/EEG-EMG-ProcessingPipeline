% 崔强-20240329第三次_raw_processed.txt

filepath = 'D:\Documents\Peng\EEG\Datasets\subj5\filtered\崔强-20240329第三次_raw_processed.txt';
% filepath = 'D:\Documents\Peng\EEG\datas\subj4\filtered_dual\王之一-20240814第三次-2024-08-14-16-34-04.855000_raw_processed.txt';
fid = fopen(filepath);
if fid == -1
    error('无法打开文件：%s', filepath);
end

[~, ~, ext] = fileparts(filepath);
if ~strcmp(ext, "txt")
    disp("This file is not a txt source file");
end

% 不包含时间戳的数据格式
datafile = textscan(fid, repmat('%f', 1, 24), 'Delimiter', '\t', 'CommentStyle', '#');

metaInfo = load("D:\Documents\Peng\EEG\Datasets\subj5\meta_info\崔强-20240329第三次.mat");

% 拆分EMG数据和EGG数据
EMGData = [datafile{1:8}]; 
EEGData = [datafile{9:24}];

% plotData(EMGData, EEGData, "崔强-王之一-20240814第三次-2024-08-14-16-34-04.855000_raw_processed", 3000, 3000, [], true, true, [], [])
plotData(EMGData, EEGData, "崔强-王之一-20240814第三次-2024-08-14-16-34-04.855000_raw_processed", 3000, 2500, [], true, true, [], [])