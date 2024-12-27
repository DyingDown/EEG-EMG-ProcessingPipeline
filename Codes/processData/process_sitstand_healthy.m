clc
clear all

%{
    该文件用来对数据进行预处理
        - 加载数据到eeglab，其中包括电极位置信息，元数据，事件信息
        - 对数据进行滤波
        - ...未完待续
%}

eeglab;
% EEG.etc.eeglabvers = '2023.1'; % this tracks which version of EEGLAB is being used, you may ignore it
motion = 'sitstand';
base_dir = 'D:/Documents/Peng/EGG/Datasets';

% 加载subj1_raw_processed_s01、chanlocs、events_info并添加EMG通道标签

subj_id = 0;
subj_no = "subj4";

% 指定文件夹路径
folderPath = 'D:/Documents/Peng/EGG/Datasets/' + subj_no + '/filtered_dual'; 

saveFilePath = 'D:/Documents/Peng/EGG/Datasets/' +subj_no + '/set/beforeInterp';

if ~exist(saveFilePath, "dir")
    mkdir(saveFilePath)
    fprintf("Created the folder %s\n", saveFilePath)
end

% 获取文件夹中的所有文件和文件夹（包括隐藏文件）
fileList = dir(folderPath);

% 排除 '.' 和 '..' 文件夹
fileList = fileList(~ismember({fileList.name}, {'.', '..'}));

% 遍历文件列表
for k = 1:length(fileList)
    fileName = fileList(k).name;  % 获取文件或文件夹的名字
    filepath = fullfile(folderPath, fileName);  % 获取完整路径

    [~, filename, ~] = fileparts(fileName);
    
    % 加载滤波处理过后的数据
    % fname = strcat(subj_no,'_raw_processed_',session,'.txt');
    % txt_path = strcat(folderPath,'/',fname);
    fprintf("filepath: %s\n",filepath);

    % 加载通道位置文件
    locs_path = strcat(base_dir,'/','code_locs/24eegemg_sitstand_locs.ced');
    fprintf("locs_path: %s\n",locs_path);

    % 加载事件文件
    % events_fname = strcat(subj_no,'_',session,'_events_info.txt');

    [~, name, ext] = fileparts(fileName);
    name = extractBefore(name, "_raw_processed")
    eventFileName = name+"_events_info"+ext;
    events_path = fullfile(base_dir, subj_no, motion,'events_info',eventFileName);%不需要,'\',
    fprintf("events_path: %s\n",events_path);
    % file_name = strcat(subj_no,'_',session,'_beforeInterpol');
    
    if ~exist(locs_path, 'file')
        error("通道位置信息文件路径无效：%s", locs_path);
    end
    if ~exist(events_path, 'file')
        error('找不到事件文件: %s', events_path);
    end

    %{
        加载EEG数据
        dataformat: ascii # 导入TXT格式的数据
        nbchan: 0 # 初始通道数量，0表示自动检测
        data: txt_path # 数据的文件位置
        setname: filename # 给导入的数据集命名 
        srate: 1000 # 采样率
        pnts: 0 # 采样点数量，0表示自动检测
        xmin: 0 # 数据起始时间点
        chanlocs: locs_path # EEG 电极的标签和位置信息
    %}
    EEG = pop_importdata('dataformat','ascii','nbchan',0,'data',filepath,'setname',filename,'srate',1000,'pnts',0,'xmin',0,'chanlocs',locs_path);


    %  将前8个通道的属性修改为EMG， 原始数据里的前8列是EMG数据
    EEG=pop_chanedit(EEG, ...
        'changefield',{1,'type','EMG'}, ...
        'changefield',{2,'type','EMG'}, ...
        'changefield',{3,'type','EMG'}, ...
        'changefield',{4,'type','EMG'}, ...
        'changefield',{5,'type','EMG'}, ...
        'changefield',{6,'type','EMG'}, ...
        'changefield',{7,'type','EMG'}, ...
        'changefield',{8,'type','EMG'} ...
    );

    % 读取事件数据
    events_data = readtable(events_path, 'Delimiter', '\t', 'ReadVariableNames', false);
    
    % 获取数据列
    type = events_data{:, 1};     % 第一列：事件类型
    latency = events_data{:, 2};  % 第二列：延迟
    duration = events_data{:, 3}; % 第三列：持续时间
    
    % 创建 EEG 事件结构
    EEG.event = struct('type', [], 'latency', [], 'duration', []);
    for i = 1:height(events_data)
        EEG.event(i).type = char(type{i});       % 将类型强制转换为字符型
        EEG.event(i).latency = latency(i);       % 延迟
        EEG.event(i).duration = duration(i);     % 持续时间
    end

    % EEG = pop_importevent(EEG, 'event', events_path, 'fields', {'type', 'latency', 'duration'}, 'timeunit', NaN);


    % 检查和验证 EEG 数据集的完整性和一致性
    EEG = eeg_checkset( EEG );
    
    % 修改代码保存
    fprintf("class(filename)=%s, class(saveFilePath)=%s\n", class(filename), class(saveFilePath))
    EEG = pop_saveset(EEG, 'filename', [filename '.set'], 'filepath', char(saveFilePath));

    %保存为set
    % EEG = pop_saveset( EEG, 'filename',[filename '.set'],'filepath',saveFilePath);
end

%上面代码运行后需要clear工作区



% 对_beforeInterpol手动插值坏导,去除质量差的数据段-ManuRej;
% 跑ICA,记得选择通道类型EEG。-ICA;
% 用IClabel,剔除无用IC得到-preped;

% EMG影响观看时。
EEG_a = EEG; 
for i = 1:8
    EEG_a.data(i,:) = EEG_a.data(i,:)*0;
end
pop_eegplot( EEG_a, 1, 1, 1); 


% zhikanC3。
EEG_a = EEG;
for i = 1:22
    if i == 10
        continue;
    end
    EEG_a.data(i,:) = EEG_a.data(i,:)*0;
end
pop_eegplot( EEG_a, 1, 1, 1); 





% %单看EMG    
% EEG_b = EEG;
% for i = 9:24
%     EEG_b.data(i,:) = EEG_b.data(i,:)*0;
% end
% pop_eegplot( EEG_b, 1, 1, 1); 


%错误实例
%{

% 生成epochs
EEG_a = pop_epoch( EEG, {  'a'  }, [0         5.4], 'newname', 'subj1_s01_interpol epochs_a', 'epochinfo', 'yes');
EEG_b = pop_epoch( EEG, {  'b'  }, [0         3], 'newname', 'subj1_s01_interpol epochs_b', 'epochinfo', 'yes');
pop_eegplot( EEG_a, 1, 1, 1);

%%% 剔除坏段-有需要运行
to_delete = false(1, EEG.trials);  % 全部初始化为false
to_delete([1]) = true;  % 设置要删除的epoch的索引为true
% 使用pop_select函数删除指定索引的epoch
EEG_a = pop_select(EEG_a, 'notrial', to_delete);
pop_eegplot( EEG_a, 1, 1, 1);

file_path={'D:\EEG\外骨骼项目\data_rename\subj1\sitstand' 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\epoch'};
file_name = 'subj1_s01_a';
EEG_a = pop_saveset( EEG_a, 'filename',[file_name '_Epo.set'],'filepath',file_path{2});


%%% b %%%
pop_eegplot( EEG_b, 1, 1, 1);

%%% 剔除坏段-有需要运行
to_delete = false(1, EEG.trials);  
to_delete([]) = true;  
EEG_b = pop_select(EEG_b, 'notrial', to_delete);
pop_eegplot( EEG_b, 1, 1, 1);

file_path={'D:\EEG\外骨骼项目\data_rename\subj1\sitstand' 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\epoch'};
file_name = 'subj1_s01_b';
EEG_b = pop_saveset( EEG_b, 'filename',[file_name '_Epo.set'],'filepath',file_path{2});

}%

% runICA
file_name = 'subj1_s01_a';
file_path={'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\epoch' 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\ICA'};
EEG = pop_loadset('filename',[file_name  '_Epo.set'],'filepath',file_path{1});%导入.set数据

EEG = pop_select(EEG, 'channel', 'EEG');
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',14);%因为插值两个坏导
EEG = pop_iclabel(EEG, 'default');
EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %保存数据

%剔除IC
EEG = pop_iclabel(EEG, 'default');
EEG = pop_subcomp( EEG, [4  7  8  9], 0);
EEG.setname='subj1_s01_a_preped';
%有问题。
EEG = eeg_checkset( EEG );
file_path = 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\preped'
EEG = pop_saveset( EEG, 'filename',[file_name  '_preped.set'],'filepath',file_path); %保存数据












%{
file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\ICA'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');%runICA
    EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %保存数据
end
%}






%{
file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\EDF' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set'};
for i=1:6%需要修改
    file_name=[num2str(i)];
    EEG = pop_biosig(strcat(file_path{1},'\',[file_name '.edf']) );
    EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'lookup','E:\\MATLAB工具包\\eeglab12_0_2_6b\\plugins\\dipfit2.2\\standard_BESA\\standard-10-5-cap385.elp');
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'nochannel',{'HEO' 'VEO' 'Trigger' 'CB1' 'CB2'});
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 1, 1650, true, [], 1);%按照之前的参数滤波
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 40, 166, 0, [], 1);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',file_path{2});
    EEG = eeg_checkset( EEG );
end

%手动去坏段，插值坏导

%跑ica

file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\ICA'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');%runICA
    EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %保存数据
end






%转参考
file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\ICA' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\REF'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '_ICA.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );%全脑平均参考
    EEG = pop_saveset( EEG, 'filename',[file_name  '_REF.set'],'filepath',file_path{2}); %保存数据
end





%分段

file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\REF' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\epoch'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '_REF.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_epoch( EEG, {  '2'  }, [-0.2         0.8], 'newname', 'EDF file resampled epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-200    0]);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[file_name  '_EPOCH.set'],'filepath',file_path{2}); %保存数据
end


%}


































%{
file_path={'D:\\EEG\\外骨骼项目\\data_rename' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set'};
i = 1;
k = 1;
subj_num =[num2str(i)];
session = [num2str(k)];
file_name = strcat('s0',session);
txt_path = strcat(file_path{1},'\','subj',subj_num,'\sitstand\',[file_name '.txt']);
EEG = pop_importdata('dataformat','ascii','nbchan',0,'data',txt_path,'setname','test_history','srate',1000,'pnts',0,'xmin',0,'chanlocs','D:\\EEG\\外骨骼项目\\data_rename\\code_locs\\32eegemg_sitstand_locs.ced');
%给EMG通道添加标签
EEG=pop_chanedit(EEG, 'changefield',{1,'type','EMG'},'changefield',{2,'type','EMG'},'changefield',{3,'type','EMG'},'changefield',{4,'type','EMG'},'changefield',{5,'type','EMG'},'changefield',{6,'type','EMG'},'changefield',{7,'type','EMG'},'changefield',{8,'type','EMG'});
%}

    
%}

