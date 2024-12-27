function newFolderPath = getParentSibling(filepath, siblingFolderName)
    % 获取父文件夹路径
    [parentFolder, ~, ~] = fileparts(filepath);
    grandParentFolder = fileparts(parentFolder); 

    newFolderPath = fullfile(grandParentFolder, siblingFolderName);
    if ~exist(newFolderPath, "dir")
        mkdir(newFolderPath)
        fprintf("Created a new folder %s\n", newFolderPath);
    end
end