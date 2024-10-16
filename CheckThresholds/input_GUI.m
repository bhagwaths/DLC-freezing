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
    
    % Behavior
    bg = uibuttongroup(f, 'Position', [.05 .45 .88 .11], 'Title', 'Behavior:');
    c = uicontrol(bg, 'Style', 'radiobutton', 'Position', [80 11 100 20], 'FontSize', 12);
    c.String = 'Freezing';
    c.Callback = @selectFreezing;

    c = uicontrol(bg, 'Style', 'radiobutton', 'Position', [200 11 100 20], 'FontSize', 12);
    c.String = 'Struggling';
    c.Callback = @selectStruggling;

    % Threshold
    uicontrol(f, 'Style', 'text', 'Position', [5 142 140 30], 'String', 'Motion threshold:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'edit', 'Position', [150 147 60 30], 'FontSize', 12);
    c.Callback = @setThresh;

    % Duration
    uicontrol(f, 'Style', 'text', 'Position', [216 142 130 30], 'String', 'Behavior duration:', 'HorizontalAlignment', 'right', 'FontSize', 12);
    c = uicontrol(f, 'Style', 'edit', 'Position', [350 147 60 30], 'FontSize', 12);
    c.Callback = @setDuration;
    
    % Button
    c = uicontrol(f, 'Style', 'pushbutton', 'Position', [160 90 120 40], 'String', 'Run', 'HorizontalAlignment', 'right', 'FontSize', 12, 'BackgroundColor',[0 0.4470 0.7410], 'ForegroundColor', 'w');
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

    function setThresh(src, ~)
        input = guidata(src);
        input.threshold = str2double(get(src, 'String'));
        guidata(src,input);
    end

    function setDuration(src, ~)
        input = guidata(src);
        input.duration = str2double(get(src, 'String'));
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

    function selectFreezing(src, ~)
        input = guidata(src);
        if src.Value
            input.freezing = true;
            input.struggling = false;
        end
        guidata(src,input)
    end

    function selectStruggling(src, ~)
        input = guidata(src);
        if src.Value
            input.struggling = true;
            input.freezing = false;
        end
        guidata(src,input)
    end

    % Runs DLC analysis after pressing button
    function analysis(src, ~)
        input = guidata(src);
        if input.freezing
            analyze_freezing(input);
        elseif input.struggling
            analyze_struggle(input);
        end
    end
end
