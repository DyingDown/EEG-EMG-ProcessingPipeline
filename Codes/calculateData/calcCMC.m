function [wcohere, ax_0, ay_0,scale] = calcCMC(x,y,N,n,f)
    % n sample points
    %scale is equal to 1/f, because w0 is set to 6 in wave_base
    dt=1/f;
    % 1/frequency
    %----------default arguments for the wavelet transform-----------
    Args=struct('Pad',1,...      % pad the time series with zeroes (recommended)
                'Dj',5, ...    % this will do 12 sub-octaves per octave
                'S0',1,...    % this says start at a scale of 2 years
                'J1',[],...
                'FreqAxis', 1,...  % default is to display in frequency, not period
                'Mother','Morlet', ...
                'MaxScale',[],...   %a more simple way to specify J1
              'Cycles',-1);
    % Args=parseArgs(varargin,Args,{'BlackandWhite'});
    if isempty(Args.J1)
        if isempty(Args.MaxScale)
            Args.MaxScale=(n*.17)*2*dt; %auto maxscale
        end
    %     Args.J1=round(log2(Args.MaxScale/Args.S0)/Args.Dj);
        Args.J1=50;%J1是小波分析的频率上限，可自行设置
    %     JJJ1=Args.J1;
    end


    % 初始化累积变量
    ax_0 = 0; ay_0 = 0; axy_0 = 0;

    % 初始化外层变量
    sinv = []; period = []; scale = [];

    % 批量处理每个试验
    for kn = 1:N
        fprintf("%d ", kn);
        if mod(kn, 4000) == 0
            fprintf("\n")
        end

        % 小波变换计算
        [X, period, scale] = wavelet(x(:, kn), dt, Args.Pad, Args.Dj, Args.S0, Args.J1, Args.Mother, Args.Cycles);
        [Y, ~, ~] = wavelet(y(:, kn), dt, Args.Pad, Args.Dj, Args.S0, Args.J1, Args.Mother, Args.Cycles);

        % Scale 平滑和归一化
        % if kn == 1
        sinv = 1 ./ (scale');
        % end

        % 平滑结果累加

        nx=size(x(:,kn),1);
        ny=size(y(:,kn),1);
        sX = smoothwavelet(sinv(:, ones(1, nx)) .* (abs(X) .^ 2), dt, period, Args.Dj, scale);
        sY = smoothwavelet(sinv(:, ones(1, ny)) .* (abs(Y) .^ 2), dt, period, Args.Dj, scale);

        % 计算 Cross wavelet 并平滑累加
        Wxy = X .* conj(Y);
        sWxy = smoothwavelet(sinv(:, ones(1, nx)) .* Wxy, dt, period, Args.Dj, scale);

        % 累计结果（避免存储所有变量）
        ax_0 = ax_0 + sX;
        ay_0 = ay_0 + sY;
        axy_0 = axy_0 + sWxy;
    end

    wcohere=abs(axy_0).^2./(ax_0.*ay_0);
    
    % threshold
    %显著CMC提取
    % alpha = 95;
    % thr = 1-(1-alpha/100)^(1/(N-1));
    % wcohere(wcohere<thr)=0;
end



