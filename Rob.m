function yrob = Rob(y, fc, Fs)
% Robotization effect is achieved through the following steps:
% 1. Compute the Short-Time Fourier Transform (STFT) of the signal
% 2. Keep the magnitude spectrum, but replace the original phase with linear phase
% 3. Perform inverse transform to get the robotized voice

% Parameter settings
Nfft = 512;          % FFT size
Nwind = Nfft;        % Window length
Nov = Nfft/4;        % Overlap length (75% overlap)

% Create Hanning window
if rem(Nwind, 2) == 0   
    Nwind = Nwind + 1;  % Ensure window length is odd
end
halflen = (Nwind-1)/2;
halff = Nfft/2;
halfwin = 0.5 * (1 + cos(pi * (0:halflen)/halflen));
win = zeros(1, Nfft);
acthalflen = min(halff, halflen);
win((halff+1):(halff+acthalflen)) = halfwin(1:acthalflen);
win((halff+1):-1:(halff-acthalflen+2)) = halfwin(1:acthalflen);

% Initialization
N = length(y);
y = y(:)';  % Ensure row vector
yrob = zeros(1, N);

% Achieve robotization by removing phase information via STFT
% Compute STFT
c = 1;
num_frames = 1 + fix((N - Nfft) / Nov);
X = zeros(1 + Nfft/2, num_frames);

for b = 0:Nov:(N-Nfft)
    u = win .* y((b+1):(b+Nfft));
    ft = fft(u);
    X(:, c) = ft(1:(1+Nfft/2))';
    c = c + 1;
end

X_rob = abs(X);  % Keep only magnitude, phase is zero

% Inverse STFT to reconstruct signal
xlen = Nfft + (num_frames - 1) * Nov;
x_temp = zeros(1, xlen);

for b = 0:Nov:(Nov*(num_frames-1))
    ft = X_rob(:, 1 + b/Nov)';
    % Construct full spectrum (conjugate symmetric)
    ft = [ft, conj(ft([((Nfft/2)):-1:2]))];
    px = real(ifft(ft));
    x_temp((b+1):(b+Nfft)) = x_temp((b+1):(b+Nfft)) + px .* win;
end

% Adjust output length to match input
if length(x_temp) >= N
    yrob = x_temp(1:N);
else
    yrob(1:length(x_temp)) = x_temp;
end

% Generate carrier wave
t = (0:N-1) / Fs;
carrier = cos(2 * pi * fc * t);

% Apply carrier modulation
yrob = yrob .* carrier;

% Normalize output
yrob = yrob / (max(abs(yrob)) + eps) * 0.95;
