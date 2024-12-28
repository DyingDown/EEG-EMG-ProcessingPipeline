function isMatch = matches_subj_pattern(folderName)
    % 判断文件夹名字是否符合 subj + 数字 的格式
    pattern = '^subj\d+$';  % 正则表达式
    isMatch = ~isempty(regexp(folderName, pattern, 'once'));
end