function plot_cohere(baseDataFolder)
    eeglab;
    dirs = ['a', 'b'];
    
    folders = dir(fullfile(baseDataFolder, "CMCresult_lowerLimb"));  % 获取当前目录下的所有文件和文件夹
    disp(folders)
    for j = 1:length(folders)
        % 跳过 . 和 .. 这两个特殊文件夹
        if strcmp(folders(j).name, '.') || strcmp(folders(j).name, '..')
            continue;
        end
        disp(class(folders(j).name))

        % 拼接完整路径
        fullPath = fullfile(baseDataFolder, folders(j).name);
        % 判断是否是文件夹，并且文件夹名符合条件
        if folders(j).isdir && matches_subj_pattern(folders(j).name)
            fprintf('符合条件的文件夹：%s\n', fullPath);
            
            setsFolder = fullfile(fullPath);
            
            fileList = dir(setsFolder);
            
            % 排除 '.' 和 '..' 文件夹
            fileList = fileList(~ismember({fileList.name}, {'.', '..'}));
    
            for i = 1:length(fileList)
                fileName = fileList(i).name;  % 获取文件或文件夹的名字
                filepath = fullfile(setsFolder, fileName);  % 获取完整路径
                fprintf("当前处理的的文件是：%s\n",filepath);

                [~,name,ext] = fileparts(fileName);
                if ~strcmp(ext, ".set")
                    continue;
                end

        
                metaInfoFile = fullfile(fullPath, "meta_info", name + ".mat");
                info = load(metaInfoFile);

                % for indedx = 1:length(dirs)
                wCMC_C3C4_sitstand('a', info.TL_a, folders(j).name, filepath);
                wCMC_C3C4_sitstand('b', info.TL_b, folders(j).name, filepath);
                % end;
            end
        end
    end
end