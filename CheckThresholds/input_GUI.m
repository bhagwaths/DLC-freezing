function input_GUI
    % Create figure
    f = figure('Position', [375 460 440 419], 'MenuBar', 'none', 'ToolBar', 'none');
    
    % Name
    uicontrol(f, 'Style', 'text', 'Position', [10 360 60 30], 'String', 'Name:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'edit', 'Position', [80 365 330 30], 'FontSize', 12);
    c.Callback = @setName;
    
    % Stage
    uicontrol(f, 'Style', 'text', 'Position', [10 320 60 30], 'String', 'Stage:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'popupmenu', 'Position', [80 324 150 30], 'FontSize', 12);
    c.String = {'', 'conditioning', 'extinction', 'retrieval'};
    c.Callback = @selection;
    
    % FPS
    uicontrol(f, 'Style', 'text', 'Position', [250 320 90 30], 'String', 'Video FPS:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'edit', 'Position', [350 325 60 30], 'FontSize', 12);
    c.Callback = @setFPS;
    
    % Coord
    uicontrol(f, 'Style', 'text', 'Position', [10 280 60 30], 'String', 'Coord:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    filenameEdit1 = uicontrol(f, 'Style', 'edit', 'Position', [80 285 245 30], 'FontSize', 12);
    uicontrol(f, 'Style', 'pushbutton', 'Position', [340 285 70 30], 'String', 'Browse', 'Callback', @selectFile1, 'FontSize', 12);
    
    % Video
    uicontrol(f, 'Style', 'text', 'Position', [10 240 60 30], 'String', 'Video:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    filenameEdit2 = uicontrol(f, 'Style', 'edit', 'Position', [80 245 245 30], 'FontSize', 12);
    uicontrol(f, 'Style', 'pushbutton', 'Position', [340 245 70 30], 'String', 'Browse', 'Callback', @selectFile2, 'FontSize', 12);
    
    % Freeze threshold
    uicontrol(f, 'Style', 'text', 'Position', [5 200 140 30], 'String', 'Freeze threshold:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'edit', 'Position', [150 205 60 30], 'FontSize', 12);
    c.Callback = @setFreezeThresh;
    
    % Freeze duration
    uicontrol(f, 'Style', 'text', 'Position', [220 200 120 30], 'String', 'Freeze duration:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'edit', 'Position', [350 205 60 30], 'FontSize', 12);
    c.Callback = @setFreezeDuration;
    
    % Button
    c = uicontrol(f, 'Style', 'pushbutton', 'Position', [160 140 120 40], 'String', 'Run', 'HorizontalAlignment', 'right', 'FontSize', 12, 'BackgroundColor',[0 0.4470 0.7410], 'ForegroundColor', 'w');
    c.Callback = @analysis;

    % Callback functions
    function setName(src, ~)
        input = guidata(src);
        input.name = get(src, 'String');
        guidata(src,input);
    end

    function setFPS(src, ~)
        input = guidata(src);
        input.FPS = str2double(get(src, 'String'));
        guidata(src,input);
    end

    function setFreezeThresh(src, ~)
        input = guidata(src);
        input.freeze_threshold = str2double(get(src, 'String'));
        guidata(src,input);
    end

    function setFreezeDuration(src, ~)
        input = guidata(src);
        input.freeze_duration = str2double(get(src, 'String'));
        guidata(src,input);
    end

    function selectFile1(src, ~)
        [file, path] = uigetfile('*.csv', 'Select DLC coordinate file');
        if file ~= 0
            filename = fullfile(path, file);
            set(filenameEdit1, 'String', file);
            input = guidata(src);
            input.coord_file = filename;
            guidata(src,input);
        end
    end

    function selectFile2(src, ~)
        [file, path] = uigetfile({'*.avi;*.mp4;*.wmv'}, 'Select behavioral video file');
        if file ~= 0
            filename = fullfile(path, file);
            set(filenameEdit2, 'String', file);
            input = guidata(src);
            input.video_file = filename;
            guidata(src,input);
        end
    end

    function selection(src, ~)
        val = src.Value;
        str = src.String{val};
        input = guidata(src);
        input.stage = str;
        guidata(src,input);
    end

    % Runs DLC analysis after pressing button
    function analysis(src, ~)
        analyze_freezing(guidata(src));
    end
end
