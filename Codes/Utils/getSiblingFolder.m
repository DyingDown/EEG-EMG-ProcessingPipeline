function siblingPath = getSiblingFolder(folderpath, siblingName)
    parent = fileparts(folderpath);
    siblingPath = fullfile(parent, siblingName);
    if ~exist(siblingPath, "dir")
        mkdir(siblingPath);
        fprintf("Create directory %s\n", siblingPath);
    end
end