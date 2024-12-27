function hFig = plotData(EMGData, EEGData, filename, TL_a, TL_b, startPoints, isPeakPoint, isDual, EMGBanList, EEGBanList)
    % plotData Plot the waves and modify start points in Real time
    %
    % Inputs
    %   EMGData     - (double array)
    %   EEGData     - (double array)
    %   filename    - (string) 数据源文件名字
    %   TL_a        - (int) 事件a时长
    %   TL_b        - (int) 事件b时长
    %   startPoints - (array) 打点列表
    %   isPeakPoint - (bool) 打点位置是不是在峰值上
    %   isDual      - (bool) 是否给AB都进行了打点 true表示都打了
    %
    % Author: o_oyao

    disp("Start Drawing or Updating Figure")
    marks = [];
    for i = 1:length(startPoints)
        if isPeakPoint == true
            if (isDual == true) && (mod(i, 2) == 0)
                marks = [marks, (startPoints(i) - TL_b / 2) / 1000, startPoints(i)/1000, (startPoints(i) + TL_b / 2) / 1000]; % 打点位置为峰值,且为b事件
            else
                marks = [marks, (startPoints(i) - TL_a / 2) / 1000, startPoints(i)/1000, (startPoints(i) + TL_a / 2) / 1000]; % 打点位置为峰值 a事件
            end
        else
            if (isDual == true) && (mod(i, 2) == 0)
                marks = [marks, startPoints(i) / 1000, (startPoints(i) + TL_b) / 1000]; % event b
            else
                marks = [marks, startPoints(i) / 1000, (startPoints(i) + TL_a) / 1000]; % event a
            end
        end
    end

    disp(marks);
        
    N1 = length(EMGData(1,:)); % EMG通道数量
    N2 = length(EEGData(1,:)); % EEG通道数量
    N = N1 + N2; % 总通道数量 24个，对应了24eegemg_sitstand_locs.ced文件里的24个

    if isempty(findall(0, 'Name', ['Window ' char(filename)], 'Type', 'figure'))
        hFig = figure;  % 如果没有找到已命名的窗口，就新建一个
        disp("Didn't find exisiting window, create a new one")
    else
        hFig = findall(0, 'Name', ['Window ' char(filename)], 'Type', 'figure');
        close(hFig);  % 关闭已打开的图形窗口
        hFig = figure;  % 重新创建一个新的图形窗口
    end

    % 数据展示-不展示特定meg通道
    yrangeEMG = 200;
    yrangeEEG = 100;
    t = 0.001:0.001:length(EMGData(:,1))/1000; % 以秒为单位的时间向量
    offsets = zeros(N, 1); % 创建一个N*1的竖矩阵，所有元素为0， 用来在y轴体现偏移
    
    set(gcf, 'Name', ['Window ' char(filename)]);
    hold on
    for j=1:8
        %if j == 2 || j == 3
        %j=9不需要删除emg通道
        if ismember(j, EMGBanList)
            result = 0;
        else
            result = 1;
        end
        offsets(j) = yrangeEMG*(N1-j);
        plot(t, (EMGData(:,j)+offsets(j))*result)
    end
    for j=1:16
        if ismember(j, EEGBanList)
            result = 0;
        else
            result = 1;
        end
        offsets(N1+j) = yrangeEMG*(N1)+200+yrangeEEG*(16-j);
        plot(t, (EEGData(:,j)+offsets(N1+j))*result)
    end
    for j=1:length(marks)
        plot([marks(j) marks(j)], [-yrangeEMG yrangeEMG*8+200+yrangeEEG*16], 'k', 'LineWidth', 2)
        % %%%%%% 周期线
        % if mod(i, 2) == 1
        %         period = TL_a/1000; % a类周期
        % else
        %         period = TL_b/1000; % b类周期
        % end
        % plot([marks(i)+period marks(i)+period], [-yrangeEMG yrangeEMG*8+200+yrangeEEG*16], 'r', 'LineWidth', 2)
    
    end
    hold off
    channelLabels = {'TA','PL','MG','LG','RF','VM','LBF','Semi',...
        'P4','CP2','FC5','C3','P3','C2','FC6','C4','CP6','F3','FC2','FC1', 'F4',...
        'CP5','C1','CP1'};
    % Ensure offsets are sorted in increasing order
    [offsets_sorted, idx] = sort(offsets);
    % disp(idx);
    channelLabels_sorted = channelLabels(idx);
    
    % Plot settings
    set(gca, 'YTick', offsets_sorted, 'YTickLabel', channelLabels_sorted)
    xlim([0 30])
    ylim([-yrangeEMG yrangeEMG * N1 + yrangeEEG * N2 + 400])
end

