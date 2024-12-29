function [EEG, stepFlags] = run_ICA(EEG, parentFolder, setname, flagFile, stepFlags)
    fprintf("Starting ICA for set %s...\n", setname);
    saveFolder = fullfile(parentFolder, "set", "afterICA");
    if ~exist(saveFolder, "dir")
        mkdir(saveFolder);
        fprintf("Created folder %s\n", saveFolder);
    end

    fprintf("ICA set savePath = %s\n", saveFolder);
    

    % 获取类型为 'EEG' 的通道索引
    channelIndices = find(strcmp({EEG.chanlocs.type}, 'EEG'));
    
    % 验证是否找到通道
    if isempty(channelIndices)
        error('No channels of type EEG found.');
    end
    

    EEG_chans = 9:24;

    % 使用找到的通道索引选择
    % EEG_ICAed = pop_select(EEG, 'channel', channelIndices);
    restLen = 16 - length(stepFlags.badChannels);
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'on', 'chanind', EEG_chans,'pca', restLen);


    EEG = pop_saveset( EEG, 'filename',[setname  '.set'],'filepath', char(saveFolder)); %保存数据
    % EEG = pop_saveset( EEG, 'filename',[setname  '.set'],'filepath', char(saveFolder)); %保存数据

    % pop_eegplot( EEG, 1, 1, 1);


    stepFlags.runICA = true;
    save(flagFile, "stepFlags");
    disp("ICA finished and labled.")

    % flag_artifacts(EEG, parentFolder, setname, flagFile, stepFlags);
end