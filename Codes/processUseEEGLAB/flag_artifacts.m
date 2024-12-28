function [EEG, stepFlags] =  flag_artifacts(EEG, parentFolder, setname, flagFile, stepFlags)
    global config;
    fprintf("Start removing artifacts for set %s...\n", setname);
    
    saveFolder = fullfile(parentFolder, "set", "afterArtifact");
    if ~exist(saveFolder, "dir")
        mkdir(saveFolder);
        fprintf("Created folder %s\n", saveFolder);
    end

    fprintf("After artifacts removel set's savePath = %s\n", saveFolder);
    

    EEG = pop_iclabel(EEG, 'default');

    fig = uifigure('Name', 'Artifact Flagging', 'Position', [100, 100, 600, 400]);
    
    % 使用Grid布局
    gridLayout = uigridlayout(fig, [10, 3]);  % 8行3列


    % 设置行和列的尺寸
    gridLayout.RowHeight = {'1.5x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};  % 每一行的高度都是相等的
    gridLayout.ColumnWidth = {'4x', '1x', '1x'};  % 列等宽

    % 添加提示文字
    textLabel = uilabel(gridLayout, 'Text', 'Select range for flagging component for rejection', ...
                    'FontSize', 25, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    textLabel.Layout.Row = 1;  % 让标签显示在第一行
    textLabel.Layout.Column = [1, 3];  % 跨越第一行的所有3列

    % 添加表头 min
    textLabelmin = uilabel(gridLayout, 'Text', 'MIN', 'HorizontalAlignment', 'center');
    textLabelmin.Layout.Row = 2;  % 让标签显示在第一行
    textLabelmin.Layout.Column = 2;  % 跨越第一行的所有3列

     % 添加表头 max
    textLabelmax = uilabel(gridLayout, 'Text', 'MAX', 'HorizontalAlignment', 'center');
    textLabelmax.Layout.Row = 2;  % 让标签显示在第一行
    textLabelmax.Layout.Column = 3;  % 跨越第一行的所有3列

    
    artifactTypes = fieldnames(config.artifacts);
    
    labelArray = gobjects(1, length(artifactTypes));
    minInputArray = gobjects(1, length(artifactTypes));
    maxInputArray = gobjects(1, length(artifactTypes));

    for i = 1:numel(artifactTypes)
        % 标签：伪影类型
        labelArray(i) = uilabel(gridLayout, 'Text', sprintf("Probability range for %s",artifactTypes{i}));
        labelArray(i).Layout.Row = i + 2;
        labelArray(i).Layout.Column = 1;
        
        % 下限输入框
        minInputArray(i) = uieditfield(gridLayout, 'numeric', 'Value', config.artifacts.(artifactTypes{i}).lower_limit);
        minInputArray(i).Layout.Row = i + 2;
        minInputArray(i).Layout.Column = 2;
        
        % 上限输入框
        maxInputArray(i) = uieditfield(gridLayout, 'numeric', 'Value', config.artifacts.(artifactTypes{i}).upper_limit);
        maxInputArray(i).Layout.Row = i + 2;
        maxInputArray(i).Layout.Column = 3;
    end
    
    % 添加一个确认按钮，点击时触发标记伪影
    btn = uibutton(gridLayout, 'Text', 'Flag Artifacts', ...
        'ButtonPushedFcn', @(btn, event) flagArtifacts());
    btn.Layout.Row = 10;
    btn.Layout.Column = 2;

    cancelBtn = uibutton(gridLayout, 'Text', 'Exit', ...
        'ButtonPushedFcn', @(btn, event) Exit());
    cancelBtn.Layout.Row = 10;
    cancelBtn.Layout.Column = 3;

    waitfor(fig);

    function flagArtifacts()
        EEG = pop_icflag(EEG, [minInputArray(1).Value maxInputArray(1).Value; ...
                               minInputArray(2).Value maxInputArray(2).Value; ...
                               minInputArray(3).Value maxInputArray(3).Value; ...
                               minInputArray(4).Value maxInputArray(4).Value; ...
                               minInputArray(5).Value maxInputArray(5).Value; ...
                               minInputArray(6).Value maxInputArray(6).Value; ...
                               minInputArray(7).Value maxInputArray(7).Value]);

    end
    
    function Exit()
        close(fig);
    end
    
    rejected_comps = find(EEG.reject.gcompreject > 0);
    
    disp("rejected comps");
    disp(rejected_comps);

    EEG = pop_subcomp(EEG, rejected_comps);
    EEG = eeg_checkset(EEG);

    pop_saveset(EEG, 'filename', [setname '.set'], 'filepath', char(saveFolder));


    EEG_a = EEG; 
    for i = 1:8
        EEG_a.data(i,:) = EEG_a.data(i,:)*0;
    end
    pop_eegplot( EEG_a, 1, 1, 1);
    
    stepFlags.flagArtifacts = true;
    save(flagFile, "stepFlags");
    disp("Artifacts removed.")
end