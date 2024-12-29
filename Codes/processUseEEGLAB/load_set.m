function [EEG, stepFlags] = load_set(baseDataFolder, fullPath, filepath, fileName, flagPath, stepFlags)
    fprintf("Start loading set %s\n", fileName);

    [folder, filename, ~] = fileparts(fileName);

    
    saveFilePath = fullfile(fullPath, "set/beforeInterp");
    
    if ~exist(saveFilePath, "dir")
        mkdir(saveFilePath)
    end

    
    % 加载滤波处理过后的数据
    % fname = strcat(subj_no,'_raw_processed_',session,'.txt');
    % txt_path = strcat(folderPath,'/',fname);
    fprintf("filepath: %s\n",filepath);

    % 加载通道位置文件
    locs_path = strcat(baseDataFolder,'/','code_locs/24eegemg_sitstand_locs.ced');
    fprintf("locs_path: %s\n",locs_path);

    % 加载事件文件
    % events_fname = strcat(subj_no,'_',session,'_events_info.txt');

    [~, name, ext] = fileparts(fileName);
    eventFileName = extractBefore(name, "_raw_processed");
    disp(eventFileName)
    events_path = fullfile(fullPath,'events_info',[eventFileName ext]);%不需要,'\',
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
    EEG = pop_importdata('dataformat','ascii','nbchan',0,'data',filepath,'setname',eventFileName,'srate',1000,'pnts',0,'xmin',0,'chanlocs',locs_path);


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
    disp(events_data)
    
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
    fprintf("filename=%s, saveFilePath=%s\n",eventFileName, saveFilePath)
    EEG = pop_saveset(EEG, 'filename', [eventFileName '.set'], 'filepath', char(saveFilePath));

    fprintf("%s.set generated.\n", eventFileName);
    EEG = pop_loadset('filename', [eventFileName '.set'], 'filepath', char(saveFilePath)); 

    stepFlags.loadSet = true;
    save(flagPath, "stepFlags");

    % pop_eegplot( EEG, 1, 1, 1); 

    stepFlags.loadSet = true;
    save(flagPath, "stepFlags");
    disp("Marked load set as done");

    % figure;
    % topoplot([], EEG.chanlocs, 'electrodes', 'labels');
end