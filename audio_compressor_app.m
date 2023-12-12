function audio_compressor_app()
    % Define parameters for recording
    fs = 44100; % Sample rate
    nBits = 16; % Number of bits per sample
    nChannels = 1; % Number of channels (mono audio)
    
    % Create a figure window
    hFig = figure('Name', 'Audio Compressor', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Position', [100, 100, 500, 400]);
    
    % Add buttons and axes to the figure
    uicontrol('Style', 'pushbutton', 'String', 'Record Audio', 'Position', [20, 350, 100, 30], 'Callback', @recordAudio);
    uicontrol('Style', 'pushbutton', 'String', 'Select Audio', 'Position', [140, 350, 100, 30], 'Callback', @selectAudio);
    uicontrol('Style', 'pushbutton', 'String', 'Play Original', 'Position', [260, 350, 100, 30], 'Callback', @playOriginal);
    uicontrol('Style', 'pushbutton', 'String', 'Save Original', 'Position', [380, 350, 100, 30], 'Callback', @saveOriginal);
    uicontrol('Style', 'pushbutton', 'String', 'Compress Audio', 'Position', [20, 310, 100, 30], 'Callback', @compressAudio);
    uicontrol('Style', 'pushbutton', 'String', 'Play Compressed', 'Position', [140, 310, 100, 30], 'Callback', @playCompressed);
    uicontrol('Style', 'pushbutton', 'String', 'Save Compressed', 'Position', [260, 310, 100, 30], 'Callback', @saveCompressed);
    
    % Axes for original and compressed audio
    hAxesOriginal = axes('Parent', hFig, 'Position', [0.1, 0.55, 0.8, 0.2]);
    hAxesCompressed = axes('Parent', hFig, 'Position', [0.1, 0.15, 0.8, 0.2]);
    title(hAxesOriginal, 'Original Audio');
    title(hAxesCompressed, 'Compressed Audio');
    
    % Initialize variables
    audioData = [];
    compressedData = [];
    
    % Nested functions for callbacks
    function recordAudio(~, ~)
        recObj = audiorecorder(fs, nBits, nChannels);
        disp('Recording...');
        recordblocking(recObj, 5); % Record for 5 seconds
        disp('Recording stopped.');
        audioData = getaudiodata(recObj);
        plot(hAxesOriginal, audioData, 'Color', 'blue');
    end
    
    function selectAudio(~, ~)
        [fileName, pathName] = uigetfile('*.wav', 'Select an audio file');
        if fileName ~= 0
            [audioData, fs] = audioread(fullfile(pathName, fileName));
            plot(hAxesOriginal, audioData, 'Color', 'blue');
        end
    end
    
    function playOriginal(~, ~)
        if ~isempty(audioData)
            sound(audioData, fs);
        end
    end
    
    function saveOriginal(~, ~)
        if ~isempty(audioData)
            [fileName, pathName] = uiputfile('*.wav', 'Save Original Audio');
            if fileName ~= 0
                audiowrite(fullfile(pathName, fileName), audioData, fs);
            end
        end
    end
    

    function compressAudio(~, ~)
        if ~isempty(audioData)
            % Apply more aggressive dynamic range compression
            threshold = 0.05; % Lower threshold for more compression
            ratio = 8; % Higher compression ratio
            attackTime = 0.005; % Shorter attack time
            releaseTime = 0.05; % Shorter release time
        
            % Normalize audio data
            audioData = audioData / max(abs(audioData));
        
            % Initialize compressor state
            gain = 1;
            compressedData = zeros(size(audioData));
        
            % Apply compression to each sample
            for i = 1:length(audioData)
                if abs(audioData(i)) > threshold
                    gain = max(gain - attackTime, 1/ratio);
                else
                    gain = min(gain + releaseTime, 1);
                end
                compressedData(i) = gain * audioData(i);
            end
        
            % Plot compressed audio
            plot(hAxesCompressed, compressedData, 'Color', 'green');
        end
    end


    
    function playCompressed(~, ~)
        if ~isempty(compressedData)
            sound(compressedData, fs);
        end
    end
    
    function saveCompressed(~, ~)   
        if ~isempty(compressedData)
            [fileName, pathName] = uiputfile('*.wav', 'Save Compressed Audio');
            if fileName ~= 0
                audiowrite(fullfile(pathName, fileName), compressedData, fs);
            end
        end
    end
end
