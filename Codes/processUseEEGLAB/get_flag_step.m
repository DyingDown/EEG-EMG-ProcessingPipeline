function stepFlags = get_flag_step(flagFile)
    folder = fileparts(flagFile);
    if ~exist(folder, "dir")
        mkdir(folder);
        fprintf("Created folder %s\n", folder);
    end

    % check if the flag file exists, if not, initialize an empty structure
    if exist(flagFile, 'file')
        load(flagFile, 'stepFlags');
    else
        % 初始化一个结构体，包含步骤标志和badChannels字段
        
        % 初始化每个步骤的标志为 false
        stepFlags.loadSet = false;           % 是否加载数据集
        stepFlags.interpolate = false;       % 是否执行插值操作
        stepFlags.runICA = false;            % 是否执行ICA操作
        stepFlags.flagArtifacts = false;    % 是否标记伪影
        
        % 初始化 badChannels 为一个空数组
        stepFlags.badChannels = [];          % 存储坏导电极的通道数组
    end
    
    % Save the updated flag structure back to the .mat file
    save(flagFile, 'stepFlags');
end
