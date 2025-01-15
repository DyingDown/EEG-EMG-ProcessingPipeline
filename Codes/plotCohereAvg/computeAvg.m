function outputFile = computeAvg(inputFolder, outputFile)
    % 输入参数检查
    if nargin < 2
        error('请提供输入文件夹路径和结果保存文件路径');
    end

    % 获取文件夹中所有.mat文件
    matFiles = dir(fullfile(inputFolder, '*.mat'));

    if isempty(matFiles)
        error('输入文件夹中未找到.mat文件');
    end

    % 存储字段数据的结构体
    accumulatedData = struct();
    fieldSizes = struct(); % 用于检查每个字段的矩阵大小

    % 遍历所有文件
    for i = 1:length(matFiles)
        matFilePath = fullfile(matFiles(i).folder, matFiles(i).name);
        fprintf('正在处理文件: %s\n', matFiles(i).name);

        % 加载文件
        loadedData = load(matFilePath);

        % 检查results字段
        if ~isfield(loadedData, 'results')
            warning('文件 %s 中不存在 "results" 结构体，跳过。\n', matFiles(i).name);
            continue;
        end

        results = loadedData.results;

        % 遍历results中的字段
        fieldNames = fieldnames(results);
        for j = 1:length(fieldNames)
            fieldName = fieldNames{j};
            
            if startsWith(fieldName, 'wcohere_') % 判断是否是wcohere数据
                fieldData = results.(fieldName);
                
                % 确认该字段的矩阵大小是否一致
                if ~isfield(fieldSizes, fieldName)
                    fieldSizes.(fieldName) = size(fieldData);
                elseif ~isequal(size(fieldData), fieldSizes.(fieldName))
                    warning('文件 %s 中的字段 %s 大小与其他文件不一致，跳过。\n', ...
                        matFiles(i).name, fieldName);
                    continue;
                end

                % 将数据累积到accumulatedData中
                if ~isfield(accumulatedData, fieldName)
                    accumulatedData.(fieldName) = zeros(size(fieldData));
                end
                accumulatedData.(fieldName) = accumulatedData.(fieldName) + fieldData;
            end
        end
    end

    % 文件计数
    numFiles = length(matFiles);

    % 计算均值
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        
        % 如果字段数据存在且需要计算均值
        if isfield(accumulatedData, fieldName)
            averagedData = accumulatedData.(fieldName) / numFiles;
            
            % 将均值直接存回结果结构体的相应字段
            results.(fieldName) = averagedData;
        end
    end

    % 保存计算后的结果
    save(outputFile, 'results');
    fprintf('所有文件均值已保存到: %s\n', outputFile);
end
