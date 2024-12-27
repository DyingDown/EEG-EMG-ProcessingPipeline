function processRawDatas(baseDataFolder)
    folders = dir(baseDataFolder);  % 获取当前目录下的所有文件和文件夹
    for i = 1:length(folders)
        % 跳过 . 和 .. 这两个特殊文件夹
        if strcmp(folders(i).name, '.') || strcmp(folders(i).name, '..')
            continue;
        end
        disp(folders(i).name)
        % if ~strcmp(folders(i).name, 'subj5')
        %     continue;
        % end

        % 拼接完整路径
        fullPath = fullfile(baseDataFolder, folders(i).name);
        % 判断是否是文件夹，并且文件夹名符合条件
        if folders(i).isdir && matches_subj_pattern(folders(i).name)
            fprintf('符合条件的文件夹：%s\n', fullPath);
            % 如果满足条件，对其子文件夹递归调用
            % traverse_folders(fullPath);
            originalDataFolders = fullfile(fullPath, "/original");
            % 获取文件夹中的所有文件和文件夹（包括隐藏文件）
            fileList = dir(originalDataFolders);
            
            % 排除 '.' 和 '..' 文件夹
            fileList = fileList(~ismember({fileList.name}, {'.', '..'}));

            for i = 1:length(fileList)
                fileName = fileList(i).name;  % 获取文件或文件夹的名字
                filepath = fullfile(originalDataFolders, fileName);  % 获取完整路径
                processRawDataFile(filepath, true)
                
            end
        end
    end

end

function isMatch = matches_subj_pattern(folderName)
    % 判断文件夹名字是否符合 subj + 数字 的格式
    pattern = '^subj\d+$';  % 正则表达式
    isMatch = ~isempty(regexp(folderName, pattern, 'once'));
end