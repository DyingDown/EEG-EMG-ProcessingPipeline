%{
    参数：filepath 表示源数据文件的路径
    返回值：返回大打点信息，就是每个event的开始时间
    主要原理就是从源数据文件里找到 # %d+%d...这种格式的一行，
%}

function startPoints = extract_startPoints(filePath)
    % 检查文件是否存在
    if ~isfile(filePath)
        error('源数据文件不存在: %s', filePath);
    end
    
    % 打开文件读取
    fid = fopen(filePath, 'r');
    if fid == -1
        error('无法打开文件: %s', filePath);
    end
    
    % 初始化返回值
    startPoints = [];
    pattern = '^\d+(\+\d+)*$'; % 匹配数字+数字格式的正则表达式

     try
        % 逐行读取文件
        while ~feof(fid)
            line = fgetl(fid); % 读取一行
            if startsWith(line, '#') % 判断是否以 '#' 开头
                trimmedLine = strtrim(line(2:end)); % 去掉开头的 '#' 和多余空格
                if ~isempty(trimmedLine) && ~isempty(regexp(trimmedLine, pattern, 'once'))
                    % 如果符合正则表达式，则提取数字
                    startPointstrs = split(trimmedLine, '+'); % 按 '+' 分割字符串
                    startPoints = str2double(startPointstrs); % 转换为数字数组
                    break; % 找到第一个符合条件的行后退出
                end
            end
        end
    catch exception
        fclose(fid);
        rethrow(exception);
    end
    
    % 关闭文件
    fclose(fid);
    
    % 如果没有找到符合条件的行，返回警告
    if isempty(startPoints)
        disp('未在源数据中找到打点信息.');
    end
end