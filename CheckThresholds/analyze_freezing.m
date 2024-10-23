function analyze_freezing(input)
    if ishandle(2) && ishandle(3)
        close([2,3]);
    end

    % Read data
    data = readtable(input.coord_file);
    [~, data_header] = xlsread(input.coord_file);
    frames = data(:,1);
    
    % Coordinates
    coord_cols = strcmp(data_header(3,:),"x") | strcmp(data_header(3,:),"y");
    coord = data(:,coord_cols);

    % Probabilities
    prob_cols = strcmp(data_header(3,:),"likelihood");
    prob = data(:,prob_cols);
    prob(1,:) = []; % remove first frame (cannot calculate distance for this frame)
    
    % Calculate Euclidean distances
    dist = [];
    for i=1:2:width(coord)
        curr_dist = [];
        curr_coord = coord{:,:}(:,i:i+1);
        for j=1:height(coord)-1
            curr_dist = [curr_dist; pdist(curr_coord(j:j+1,:),'euclidean')];
        end
        dist = [dist, curr_dist];
    end
    dist = array2table(dist);
    
    % Replace low prob distances with NaN
    dist{:,:}(prob{:,:} <= 0.5) = NaN; % Replace coords with likelihood of <= 0.5 with NaN
    
    % Find mean distances excluding NaN
    mean_dist = mean(dist{:,:},2,'omitmissing');
    
    % Smooth mean distances
    smooth_mean_dist = smooth(mean_dist);
    
    % Label freezing based on thresholds
    ep_idx = smooth_mean_dist < input.threshold;
    transitions = diff(ep_idx);
    ep_start = find(transitions == 1);
    ep_end = find(transitions == -1);
    if ep_idx(1) == 1
       ep_start = [1; ep_start];
    end
    if ep_idx(end) == 1
        ep_end = [ep_end; numel(ep_idx)];
    end
    ep_lengths = ep_end - ep_start;
    freeze_ep_idx = ep_lengths >= input.duration;
    freeze_start = ep_start(freeze_ep_idx);
    freeze_end = ep_end(freeze_ep_idx);
    freeze_idx = zeros(size(ep_idx));
    for i=1:numel(freeze_start)
        freeze_idx(freeze_start(i)+1:freeze_end(i)) = 1;
    end
    
    frames_col = frames{:,:}(2:end,:);
    
    figure;
    set(gcf,'Position',[10 60 1900 300]);
    ylim([0 7]); xlim([frames_col(1) frames_col(end)])
    for i=1:numel(freeze_start)
        patch([freeze_start(i), freeze_start(i), freeze_end(i), freeze_end(i)], [0 7 7 0], [0.85 0.85 0.85], 'EdgeColor','none'); hold on;
    end
    plot(frames_col,smooth_mean_dist,'LineWidth',2); hold on;
    yline(input.threshold,'LineStyle','--','Color','r');
    xlabel('Frame');
    ylabel('Distance change');
    ax = gca;
    ax.XAxis.Exponent = 0;
    
    vid = VideoReader(input.video_file);
    
    % Set up video figure window
    videofig(vid.NumFrames, @(frm) redraw(frm, vid, freeze_idx, 'freezing'), input.FPS);
    
    % Display initial frame
    redraw(1, vid, freeze_idx, 'freezing');
    
    % Export freezing data to CSV
    if ~contains(fieldnames(input),'stage')
        last_s = NaN;
    elseif strcmp(input.stage,'conditioning')
        last_s = 300;
    elseif strcmp(input.stage,'extinction')
        last_s = 2250;
    elseif strcmp(input.stage,'retrieval')
        last_s = 450;
    end
    
    frames_col = [0; frames_col];
    frames_col = frames_col - (180 * input.FPS);
    freezing_col = freeze_idx * 100;
    freezing_col = [0; freezing_col];
    output_table = array2table([frames_col, freezing_col]);
    output_table.Properties.VariableNames = ["Frames", "Freezing"];

    if ~isnan(last_s)
        output_table = output_table(output_table.Frames <= (input.FPS * last_s), :);
        output_file_name = sprintf('%s_%s_DLC_freezing.csv', input.name, input.stage);
    else
        output_file_name = sprintf('%s_DLC_freezing.csv', input.name);
    end
    writetable(output_table,output_file_name);