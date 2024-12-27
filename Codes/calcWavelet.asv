function [ax_0, period] = calcWavelet(x,N,n,f)
% n sample points
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
    Args.J1=50;
%     JJJ1=Args.J1;
end
ax_0=0;
X=cell(1,N);sX=cell(1,N);
% trials
% Rsqvalue=cell(1,N);
for kn=1:N
    fprintf("%d ",kn)
    %-----------:::::::::::::--------- ANALYZE ----------::::::::::::------------
    [X{1,kn},period,scale] = wavelet(x(:,kn),dt,Args.Pad,Args.Dj,Args.S0,Args.J1,Args.Mother,Args.Cycles);
    %Smooth X and Y before truncating!  (minimize coi)
    nx=size(x(:,kn),1);
    sinv=1./(scale');
    sX{1,kn}=smoothwavelet(sinv(:,ones(1,nx)).*(abs(X{1,kn}).^2),dt,period,Args.Dj,scale);
    if isempty(find(sX{1,kn}>0))
        sX{1,kn} = -sX{1,kn};
    end
%     sX{1,kn}=abs(X{1,kn}).^2;
    ax_0=ax_0+sX{1,kn};
end
% threshold
% alpha = 95;
% thr = 1-(1-alpha/100)^(1/(N-1));
% wcohere(wcohere<thr)=0;
end
