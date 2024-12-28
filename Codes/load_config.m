function config = load_config()
    configFilePath = "config.json";
    if exist(configFilePath, 'file')
        fid = fopen(configFilePath, 'r');
        raw = fread(fid, inf);
        str = char(raw');
        fclose(fid);
        config = jsondecode(str);
    else
        disp('配置文件未找到');
        config = [];
    end
end
