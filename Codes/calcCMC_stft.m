function [wcohere, sx_ave, sy_ave] = calcCMC_stft(x, y, Fs)
% Fs = 1000;
N = size(x, 2);
N_T = size(x, 1);
nfft = 2^nextpow2(N_T); % the number of FFT points
winparam = round(Fs*0.4); % 400ms windows are used in STFT

sx = cell(1,N);
sy = cell(1,N);
sx_ave = 0;
sy_ave = 0;
swxy = cell(1,N);
swxy_ave = 0;

for kn=1:N
    [sx{kn}, freqs, ax] = subfunc_stft(x(:,kn), winparam, nfft, Fs); % STFT
    [sy{kn}, freqs, ay] = subfunc_stft(y(:,kn), winparam, nfft, Fs); % STFT
    wxy=ax.*conj(ay);
    swxy{kn} = wxy;
    swxy_ave = swxy_ave + swxy{kn};

    sx_ave = sx_ave + sx{kn};
    
    sy_ave = sy_ave + sy{kn};
end
sx_ave = sx_ave / N;
sy_ave = sy_ave / N;
swxy_ave = swxy_ave / N;
wcohere=abs(swxy_ave).^2./(sx_ave.*sy_ave)/Fs;

f_lim = [min(freqs(freqs>0)), 48]; % specify the frequency range to be shown (remove 0Hz)
f_idx = find((freqs<=f_lim(2))&(freqs>=f_lim(1)));
wcohere = wcohere(f_idx, :);
sx_ave = sx_ave(f_idx, :);
sy_ave = sy_ave(f_idx, :);

