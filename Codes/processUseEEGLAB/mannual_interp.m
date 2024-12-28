function [EEG_interp, stepFlags] = mannual_interp(EEG, flagPath, stepFlags)
    % mannual_interp EEG
    %
    % Inputs
    %   EEG         - (struct) original loaded set
    %   flagPath    - (string) full path of flag file
    %   stepFlags   - (struct) flags struct
    % 

    fprintf("Start mannual interpolation for set %s...\n", EEG.setname);

    eegFilename = EEG.filename;
    eegFilepath = EEG.filepath;

    saveFolder = getSiblingFolder(eegFilepath, "afterInterp");    
    
    fig = uifigure('Name', 'Select Bad Channels');
    
    gridLayout = uigridlayout(fig, [5, 8]);  % 5行6列的网格布局    
    % 设置行和列的尺寸
    gridLayout.RowHeight = {'2x', '1x', '1x', '0.5x', '1.5x'};  % 每一行的高度都是相等的
    gridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};  % 列等宽
    
    % 添加提示文字
    textLabel = uilabel(gridLayout, 'Text', 'Select the bad channels', ...
                    'FontSize', 25, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % 将标签设置为跨越整行（两列）
    textLabel.Layout.Row = 1;  % 让标签显示在第一行
    textLabel.Layout.Column = [1, 8];  % 跨越第一行的所有6列
    
    
    % 为每个EEG通道生成选择按钮（16个按钮）
    % 获取通道名称
    eegChannelNames = {EEG.chanlocs(9:end).labels}; % 假设 EEG 数据中后面 16 个通道是 EEG 通道
    numChannels = numel(eegChannelNames);
    finnalBadChans = [];
    
    % 按钮数组
    buttonArray = gobjects(1, numChannels);  % 存储16个EEG通道选择按钮的句柄
    selectedChannels = false(1, numChannels);  % 标记通道是否被选中
    
    % 创建按钮
    buttonArray = gobjects(1, numChannels); % 初始化按钮数组
    for i = 1:numChannels
        buttonArray(i) = uibutton(gridLayout, ...
            'Text', eegChannelNames{i}, ... % 使用通道名称
            'ButtonPushedFcn', @(btn, event) toggleChannelSelection(i)); % 绑定通道选择回调函数
        % 设置 Layout 属性
        buttonArray(i).Layout.Row = ceil(i / 8) + 1; % 按钮分布在第 2 到第 5 行
        buttonArray(i).Layout.Column = mod(i-1, 8) + 1; % 每行最多显示 6 个按钮
        defaultButtonColor = buttonArray(i).BackgroundColor;
    end
    
    % 操作按钮（位于下方一行）
    % 插值操作按钮
    interpolateButton = uibutton(gridLayout, 'Text', sprintf('Interp Sel Chann'), 'BackgroundColor', '#77ac30', ...
                                 'ButtonPushedFcn', @(btn, event) interpolateBadChannels());
    interpolateButton.Layout.Row = 5;
    interpolateButton.Layout.Column = [1, 2];
    
    % 查看移除通道后的EEG按钮
    viewPostRemoveButton = uibutton(gridLayout, 'Text', sprintf('Plot Unsel Chann'),...
                                   'ButtonPushedFcn', @(btn, event) viewPostRemoveEEG());
    viewPostRemoveButton.Layout.Row = 5;
    viewPostRemoveButton.Layout.Column = [3,4];
    
    % 查看插值后的EEG按钮
    viewPostInterpolationButton = uibutton(gridLayout, 'Text', sprintf('Plot aft Interp'), ...
                                           'ButtonPushedFcn', @(btn, event) viewPostInterpolationEEG());
    viewPostInterpolationButton.Layout.Row = 5;
    viewPostInterpolationButton.Layout.Column = [5, 6];
    
    % 退出按钮
    exitButton = uibutton(gridLayout, 'Text', 'Done & Save', 'BackgroundColor', '#c42b1c', 'ButtonPushedFcn', @(btn, event) exitOperation());
    exitButton.Layout.Row = 5;
    exitButton.Layout.Column = [7, 8];

    % 设置最后一行的列宽为'auto'，自动调整宽度以满足窗口调整
    gridLayout.ColumnWidth = repmat({'1x'}, 1, 8); % 所有列宽度按照相同比例自动调整

    waitfor(fig); 

    % 默认通道选择处理
    function toggleChannelSelection(channelIndex)
        % 切换当前通道是否被选中
        selectedChannels(channelIndex) = ~selectedChannels(channelIndex);
        % 更新按钮的状态
        if selectedChannels(channelIndex)
            buttonArray(channelIndex).BackgroundColor = '#c42b1c';  % 选中通道，按钮变绿色
        else
            buttonArray(channelIndex).BackgroundColor = defaultButtonColor;  % 取消选中通道，按钮变红色
        end
    end
    
    % 坏导插值操作
    function interpolateBadChannels()
        % 找到所有选中的通道，执行插值操作
        selectedIndices = find(selectedChannels) + 8;
        disp('selectedIndices');
        disp(selectedIndices)
        if ~isempty(selectedIndices)
            % 在EEGLAB中执行坏导插值的代码（假设你已经使用EEGLAB函数）
            % EEG = pop_select(EEG, 'channel', selectedIndices); % 选择需要插值的通道
            EEG_interp = pop_interp(EEG, selectedIndices, 'spherical'); % 执行插值操作
            disp('Interpolation performed for selected channels.');
        else
            disp('No channels selected for interpolation.');
        end
        finnalBadChans = selectedIndices;
    end
    
    % 查看剔除后的EEG图
    function viewPostRemoveEEG()
        % 在EEGLAB中展示剔除后的EEG图
        EEG_filtered = pop_select(EEG, 'channel', find(~selectedChannels) + 8);  % 删除选中的通道
        pop_eegplot(EEG_filtered, 1, 1, 1);
    end
    
    % 查看插值后的EEG图
    function viewPostInterpolationEEG()
        % 在EEGLAB中展示插值后的EEG图
        EEG_interpolated = pop_interp(EEG, find(selectedChannels) + 8, 'spherical');  % 执行插值后返回EEG数据
        EEG_a = EEG_interpolated; 
        for i = 1:8
            EEG_a.data(i,:) = EEG_a.data(i,:)*0;
        end
        pop_eegplot( EEG_a, 1, 1, 1);
        % pop_eegplot(EEG_interpolated, 1, 1, 1);  % 展示插值后的EEG图
    end
    
    % 退出操作
    function exitOperation()
        % 修改代码保存
        EEG_interp = pop_saveset(EEG_interp, 'filename', eegFilename, 'filepath', char(saveFolder));
        disp(['Successfully saved set ', eegFilename, ' at ', saveFolder]);

        % mark step interpolation as finished
        stepFlags.interpolate = true;
        stepFlags.badChannels = finnalBadChans;
        save(flagPath, "stepFlags");
        disp("Mark step Interpolation as Completed");
        disp(['Saved bad channels: ', num2str(finnalBadChans)]);
        disp('Operation completed. Exiting...');
        close(fig);  % 关闭UI界面

        EEG_a = EEG_interp; 
        for i = 1:8
            EEG_a.data(i,:) = EEG_a.data(i,:)*0;
        end
        pop_eegplot( EEG_a, 1, 1, 1);
    end
end