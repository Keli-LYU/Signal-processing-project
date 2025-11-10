%% Phase Vocoder Project Test Script
% This script quickly tests all functionalities

clear all; close all; clc;

disp(' ');
disp('1. Load test audio');

try
    [y, Fs] = audioread('Extrait.wav');
    y = y(:,1);  % Use mono channel only
    disp('Audio loaded successfully');
    fprintf(' - Sample rate: %d Hz\n', Fs);
    fprintf(' - Number of samples: %d\n', length(y));
    fprintf(' - Duration: %.2f seconds\n', length(y)/Fs);
catch
    error('Audio file loading failed! Please ensure Extrait.wav is in the current directory.');
end

disp(' ');
disp('2. Perform STFT for subsequent tests');

Nfft = 512;
Nwind = Nfft;
Nov = Nfft/4;
% Perform forward transform, result 'X' will be used by other tests
X = TFCT(y', Nfft, Nwind, Nov);

disp(' ');
disp('3. Test TFCT_Interp (frequency domain interpolation)');

try
    % Test time stretching
    rapp = 1.5;  % Speed up by 1.5x
    [nl, nc] = size(X);
    Nt = [0:rapp:(nc-2)];
    
    % Interpolation
    X2 = TFCT_Interp(X, Nt, Nov);
    
    if ~isempty(X2) && all(isfinite(X2(:)))
        disp('TFCT_Interp test passed');
        fprintf(' - Input frames: %d\n', nc);
        fprintf(' - Output frames: %d\n', length(Nt));
        fprintf(' - Compression ratio: %.2f\n', length(Nt)/nc);
    else
        warning('TFCT_Interp output contains invalid values');
    end
catch ME
    fprintf('TFCT_Interp test failed: %s\n', ME.message);
end

disp(' ');
disp('4. Test PVoc (speed modification)');

try
    % Test slowdown
    ylent = PVoc(y, 2/3, 512);
    
    if ~isempty(ylent) && all(isfinite(ylent))
        disp('PVoc speed modification test passed');
        fprintf(' - Original length: %d samples\n', length(y));
        fprintf(' - Slowed down length: %d samples\n', length(ylent));
        fprintf(' - Length ratio: %.2f\n', length(ylent)/length(y));
    else
        warning('PVoc output contains invalid values');
    end
catch ME
    fprintf('   PVoc test failed: %s\n', ME.message);
end

disp(' ');
disp('5. Test pitch modification');

try
    a = 2; b = 3;
    yvoc = PVoc(y, a/b, 512, 512);
    ypitch = resample(yvoc, a, b);
    
    if ~isempty(ypitch) && all(isfinite(ypitch))
        disp('Pitch modification test passed');
        fprintf(' - Original length: %d samples\n', length(y));
        fprintf(' - Pitch modified length: %d samples\n', length(ypitch));
        fprintf(' - Pitch change: %.2f times\n', b/a);
    else
        warning('Pitch modification output contains invalid values');
    end
catch ME
    fprintf('Pitch modification test failed: %s\n', ME.message);
end

disp(' ');
disp('6. Test Rob (robotization)');

try
    Fc = 500;
    yrob = Rob(y, Fc, Fs);
    
    if ~isempty(yrob) && all(isfinite(yrob))
        disp(' Rob robotization test passed');
        fprintf(' - Output length: %d samples\n', length(yrob));
        fprintf(' - Dynamic range: [%.4f, %.4f]\n', min(yrob), max(yrob));
    else
        warning('Rob output contains invalid values');
    end
catch ME
    fprintf('Rob test failed: %s\n', ME.message);
end

disp(' ');
disp('7. Generate test audio files');

try
    % Save test results
    if exist('ylent', 'var')
        audiowrite('test_speed_slow.wav', ylent/max(abs(ylent)), Fs);
        disp('Slow speed effect saved as: test_speed_slow.wav');
    end
    
    if exist('ypitch', 'var')
        audiowrite('test_pitch_high.wav', ypitch/max(abs(ypitch)), Fs);
        disp('High pitch effect saved as: test_pitch_high.wav');
    end
    
    if exist('yrob', 'var')
        audiowrite('test_robot.wav', yrob, Fs);
        disp('Robot effect saved as: test_robot.wav');
    end
catch ME
    fprintf('Some audio files failed to save: %s\n', ME.message);
end

disp(' ');
disp('8. Generate visualization comparison plots');

try
    figure('Position', [100, 100, 1200, 800]);
    
    % Original signal
    subplot(3,2,1);
    plot((0:length(y)-1)/Fs, y);
    title('Original Signal');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
    
    subplot(3,2,2);
    spectrogram(y, 128, 120, 128, Fs, 'yaxis');
    title('Original Signal - Spectrogram');
    
    % Speed modification
    if exist('ylent', 'var')
        subplot(3,2,3);
        plot((0:length(ylent)-1)/Fs, ylent);
        title('Speed Modified (Slow)');
        xlabel('Time (s)'); ylabel('Amplitude');
        grid on;
        
        subplot(3,2,4);
        spectrogram(ylent, 128, 120, 128, Fs, 'yaxis');
        title('Speed Modified - Spectrogram');
    end
    
    % Robotization
    if exist('yrob', 'var')
        subplot(3,2,5);
        plot((0:length(yrob)-1)/Fs, yrob);
        title('Robotization Effect');
        xlabel('Time (s)'); ylabel('Amplitude');
        grid on;
        
        subplot(3,2,6);
        spectrogram(yrob, 128, 120, 128, Fs, 'yaxis');
        title('Robotization - Spectrogram');
    end
    
    sgtitle('Phase Vocoder Effects Comparison', 'FontSize', 14, 'FontWeight', 'bold');
    disp(' Visualization plots generated');
catch ME
    fprintf('Visualization generation failed: %s\n', ME.message);
end