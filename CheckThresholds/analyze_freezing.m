function analyze_freezing(input)
    if ishandle(2) && ishandle(3)
        close([2,3]);
    end
    % Read data
    data = readtable(input.coord_file);
    frames = data(:,1);
    
    % Coordinates
    coord = data(:,[2:3, 5:6, 8:9, 11:12]);
    coord.Properties.VariableNames = ["nose_x", "nose_y", "leftear_x", "leftear_y",...
                                        "rightear_x", "rightear_y", "tailbase_x", "tailbase_y"];
    
    % Probabilities
    prob = data(:,[4,7,10,13]);
    prob.Properties.VariableNames = ["nose", "leftear", "rightear", "tailbase"];
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
    dist.Properties.VariableNames = ["nose", "leftear", "rightear", "tailbase"];
    
    % Replace low prob distances with NaN
    dist{:,:}(prob{:,:} <= 0.5) = NaN; % Replace coords with likelihood of <= 0.5 with NaN
    
    % Find mean distances excluding NaN
    mean_dist = mean(dist{:,:},2,'omitmissing');
    
    % Smooth mean distances
    smooth_mean_dist = smooth(mean_dist);
    
    % Label freezing based on thresholds
    ep_idx = smooth_mean_dist < input.freeze_threshold;
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
    freeze_ep_idx = ep_lengths >= input.freeze_duration;
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
    yline(input.freeze_threshold,'LineStyle','--','Color','r');
    xlabel('Frame');
    ylabel('Distance change');
    ax = gca;
    ax.XAxis.Exponent = 0;
    
    vid = VideoReader(input.video_file);
    
    % Set up video figure window
    videofig(vid.NumFrames, @(frm) redraw(frm, vid, freeze_idx), input.FPS);
    
    % Display initial frame
    redraw(1, vid, freeze_idx);
    
    % Export freezing data to CSV
    if strcmp(input.stage,'conditioning')
        last_s = 300;
    elseif strcmp(input.stage,'extinction')
        last_s = 2250;
    end
    
    frames_col = [0; frames_col];
    frames_col = frames_col - (180 * input.FPS);
    freezing_col = freeze_idx * 100;
    freezing_col = [0; freezing_col];
    output_table = array2table([frames_col, freezing_col]);
    output_table.Properties.VariableNames = ["Frames", "Freezing"];
    output_table = output_table(output_table.Frames <= (input.FPS * last_s), :);
    
    output_file_name = sprintf('%s_%s_DLC.csv', input.name, input.stage);
    writetable(output_table,output_file_name);