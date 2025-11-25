function AudioEffectGUI
    % Create the main figure
    hFig = figure('Name', 'Audio Effect Processor', ...
                  'NumberTitle', 'off', ...
                  'Position', [100, 100, 1000, 600], ...
                  'MenuBar', 'none', ...
                  'ToolBar', 'figure', ...
                  'Resize', 'on');

    % Data storage
    data = struct();
    data.y = [];
    data.Fs = 44100;
    data.y_processed = [];
    data.player_orig = [];
    data.player_proc = [];

    % --- Layout ---
    
    % Control Panel (Left)
    panelWidth = 0.25;
    hPanel = uipanel('Parent', hFig, ...
                     'Title', 'Controls', ...
                     'Position', [0, 0, panelWidth, 1]);

    % Load Button
    uicontrol('Parent', hPanel, 'Style', 'pushbutton', ...
              'String', 'Load Audio (WAV)', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.92, 0.8, 0.05], ...
              'Callback', @loadAudio);

    % File Name Text
    hTextFile = uicontrol('Parent', hPanel, 'Style', 'text', ...
                          'String', 'No file loaded', ...
                          'Units', 'normalized', ...
                          'Position', [0.1, 0.88, 0.8, 0.03], ...
                          'HorizontalAlignment', 'center');

    % Effect Selection
    uicontrol('Parent', hPanel, 'Style', 'text', ...
              'String', 'Select Effect:', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.82, 0.8, 0.03], ...
              'HorizontalAlignment', 'left');
              
    hPopup = uicontrol('Parent', hPanel, 'Style', 'popupmenu', ...
                       'String', {'Time Stretching', 'Pitch Shifting', 'Robotization'}, ...
                       'Units', 'normalized', ...
                       'Position', [0.1, 0.77, 0.8, 0.05], ...
                       'Callback', @updateParams);

    % Parameter 1 Label
    hParam1Label = uicontrol('Parent', hPanel, 'Style', 'text', ...
                             'String', 'Speed Ratio (0.5 = slow, 2.0 = fast):', ...
                             'Units', 'normalized', ...
                             'Position', [0.1, 0.70, 0.8, 0.03], ...
                             'HorizontalAlignment', 'left');

    % Parameter 1 Edit
    hParam1Edit = uicontrol('Parent', hPanel, 'Style', 'edit', ...
                            'String', '1.0', ...
                            'Units', 'normalized', ...
                            'Position', [0.1, 0.67, 0.8, 0.04]);

    % Process Button
    uicontrol('Parent', hPanel, 'Style', 'pushbutton', ...
              'String', 'Process', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.55, 0.8, 0.08], ...
              'Callback', @processAudio, ...
              'FontWeight', 'bold', ...
              'FontSize', 12);

    % Play Controls
    uicontrol('Parent', hPanel, 'Style', 'text', ...
              'String', 'Playback:', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.45, 0.8, 0.03], ...
              'HorizontalAlignment', 'left');

    uicontrol('Parent', hPanel, 'Style', 'pushbutton', ...
              'String', 'Play Original', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.40, 0.8, 0.05], ...
              'Callback', @playOriginal);

    uicontrol('Parent', hPanel, 'Style', 'pushbutton', ...
              'String', 'Play Processed', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.34, 0.8, 0.05], ...
              'Callback', @playProcessed);
              
    uicontrol('Parent', hPanel, 'Style', 'pushbutton', ...
              'String', 'Stop All', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.28, 0.8, 0.05], ...
              'Callback', @stopAudio);

    % Status Text
    hStatus = uicontrol('Parent', hPanel, 'Style', 'text', ...
                        'String', 'Ready', ...
                        'Units', 'normalized', ...
                        'Position', [0.1, 0.05, 0.8, 0.1], ...
                        'HorizontalAlignment', 'left');

    % Plotting Area (Right)
    hAx1 = subplot(2, 2, 2, 'Parent', hFig); % Top Right (Spectrogram Orig)
    hAx2 = subplot(2, 2, 1, 'Parent', hFig); % Top Left (Waveform Orig)
    hAx3 = subplot(2, 2, 4, 'Parent', hFig); % Bottom Right (Spectrogram Proc)
    hAx4 = subplot(2, 2, 3, 'Parent', hFig); % Bottom Left (Waveform Proc)
    
    % Adjust subplot positions manually to fit the right side
    set(hAx2, 'Position', [0.30, 0.55, 0.30, 0.35]);
    set(hAx1, 'Position', [0.65, 0.55, 0.30, 0.35]);
    set(hAx4, 'Position', [0.30, 0.10, 0.30, 0.35]);
    set(hAx3, 'Position', [0.65, 0.10, 0.30, 0.35]);

    % --- Callbacks ---

    function loadAudio(~, ~)
        [file, path] = uigetfile('*.wav', 'Select a WAV file');
        if isequal(file, 0)
            return;
        end
        
        try
            [y, Fs] = audioread(fullfile(path, file));
            % Convert to mono if stereo
            if size(y, 2) > 1
                y = mean(y, 2);
            end
            
            data.y = y;
            data.Fs = Fs;
            data.y_processed = []; % Clear previous result
            set(hTextFile, 'String', file);
            set(hStatus, 'String', sprintf('Loaded: %s\nFs: %d Hz\nLength: %.2fs', file, Fs, length(y)/Fs));
            
            % Plot Original
            plotWaveform(hAx2, y, Fs, 'Original Signal');
            plotSpectrogram(hAx1, y, Fs, 'Original Spectrogram');
            
            % Clear Processed plots
            cla(hAx4); title(hAx4, '');
            cla(hAx3); title(hAx3, '');
            
        catch ME
            errordlg(['Error loading file: ' ME.message], 'Load Error');
        end
    end

    function updateParams(~, ~)
        val = get(hPopup, 'Value');
        switch val
            case 1 % Time Stretching
                set(hParam1Label, 'String', 'Speed Ratio (0.5 = slow, 2.0 = fast):');
                set(hParam1Edit, 'String', '1.0');
            case 2 % Pitch Shifting
                set(hParam1Label, 'String', 'Pitch Ratio (e.g. 1.5=higher, 0.8=lower):');
                set(hParam1Edit, 'String', '1.0');
            case 3 % Robotization
                set(hParam1Label, 'String', 'Carrier Frequency (Hz):');
                set(hParam1Edit, 'String', '440');
        end
    end

    function processAudio(~, ~)
        if isempty(data.y)
            msgbox('Please load an audio file first.', 'Warning');
            return;
        end
        
        set(hStatus, 'String', 'Processing...');
        drawnow;
        
        try
            val = get(hPopup, 'Value');
            paramStr = get(hParam1Edit, 'String');
            param = str2double(paramStr);
            
            if isnan(param)
                error('Invalid parameter value');
            end
            
            y_in = data.y;
            Fs = data.Fs;
            y_out = [];
            
            % Add code folder to path if needed
            if ~exist('PVoc', 'file')
                addpath('code');
            end
            
            switch val
                case 1 % Time Stretching
                    % PVoc(x, rapp, Nfft, Nwind)
                    % rapp is speed ratio. 
                    % If user wants 2x speed, rapp=2.
                    y_out = PVoc(y_in, param, 1024, 1024);
                    
                case 2 % Pitch Shifting
                    % To shift pitch by ratio k without changing duration:
                    % 1. Stretch time by 1/k (make it longer if k>1)
                    % 2. Resample by k (make it shorter/faster, raising pitch)
                    k = param;
                    rapp = 1/k;
                    y_stretched = PVoc(y_in, rapp, 1024, 1024);
                    
                    % Resample to restore original length (approx)
                    % resample(x, P, Q) resamples at P/Q * Fs
                    % We want to play at k * Fs speed effectively to raise pitch
                    % So we resample such that new length is 1/k of stretched length
                    % Stretched length is k * original.
                    % So new length is original.
                    
                    [P, Q] = rat(1/k); 
                    % We want to shrink the signal by factor k.
                    % So new length = old length / k.
                    % resample(x, P, Q) -> length * P / Q.
                    % We want P/Q = 1/k.
                    
                    y_out = resample(y_stretched, P, Q);
                    
                case 3 % Robotization
                    % Rob(y, fc, Fs)
                    y_out = Rob(y_in, param, Fs);
            end
            
            % Normalize output to avoid clipping
            y_out = y_out / max(abs(y_out)) * 0.95;
            
            data.y_processed = y_out;
            
            % Plot Processed
            plotWaveform(hAx4, y_out, Fs, 'Processed Signal');
            plotSpectrogram(hAx3, y_out, Fs, 'Processed Spectrogram');
            
            set(hStatus, 'String', 'Processing Complete.');
            
        catch ME
            set(hStatus, 'String', ['Error: ' ME.message]);
            errordlg(ME.message, 'Processing Error');
        end
    end

    function playOriginal(~, ~)
        if ~isempty(data.y)
            stopAudio();
            data.player_orig = audioplayer(data.y, data.Fs);
            play(data.player_orig);
        end
    end

    function playProcessed(~, ~)
        if ~isempty(data.y_processed)
            stopAudio();
            data.player_proc = audioplayer(data.y_processed, data.Fs);
            play(data.player_proc);
        end
    end

    function stopAudio(~, ~)
        if ~isempty(data.player_orig) && isvalid(data.player_orig)
            stop(data.player_orig);
        end
        if ~isempty(data.player_proc) && isvalid(data.player_proc)
            stop(data.player_proc);
        end
    end

    % --- Helper Functions ---
    function plotWaveform(ax, y, Fs, titleStr)
        t = (0:length(y)-1)/Fs;
        plot(ax, t, y);
        title(ax, titleStr);
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Amplitude');
        grid(ax, 'on');
        axis(ax, 'tight');
    end

    function plotSpectrogram(ax, y, Fs, titleStr)
        % Use spectrogram function
        % spectrogram(x,window,noverlap,nfft,fs,'yaxis')
        axes(ax); % Make ax current
        spectrogram(y, 256, 128, 256, Fs, 'yaxis');
        title(ax, titleStr);
    end

end
