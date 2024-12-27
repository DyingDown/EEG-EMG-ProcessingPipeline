function isEqual = compareCells(array1, array2)
    % compareArrays compares two 2D double arrays to determine if they are equal.
    %
    % Parameters:
    % array1: First 2D double array
    % array2: Second 2D double array
    %
    % Returns:
    % isEqual: A boolean value. True if the two arrays are equal, False otherwise.

    % 检查尺寸是否一致
    if ~isequal(size(array1), size(array2))
        isEqual = false;
        return;
    end

    % 比较数值内容是否相同
    isEqual = isequal(array1, array2);
end
