function analyze_struggle(input)
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

    % Label struggle behavior based on thresholds
    ep_idx = smooth_mean_dist > input.threshold;
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
    struggle_ep_idx = ep_lengths >= input.duration;
    struggle_start = ep_start(struggle_ep_idx);
    struggle_end = ep_end(struggle_ep_idx);
    struggle_idx = zeros(size(ep_idx));
    for i=1:numel(struggle_start)
        struggle_idx(struggle_start(i)+1:struggle_end(i)) = 1;
    end

    frames_col = frames{:,:}(2:end,:);

    figure;
    set(gcf,'Position',[10 60 1900 300]);
    ylim([0 50]); xlim([frames_col(1) frames_col(end)])
    for i=1:numel(struggle_start)
        patch([struggle_start(i), struggle_start(i), struggle_end(i), struggle_end(i)], [0 50 50 0], [0.85 0.85 0.85], 'EdgeColor','none'); hold on;
    end
    plot(frames_col,smooth_mean_dist,'LineWidth',2); hold on;
    yline(input.threshold,'LineStyle','--','Color','r');
    xlabel('Frame');
    ylabel('Distance change');
    ax = gca;
    ax.XAxis.Exponent = 0;

    vid = VideoReader(input.video_file);

    % Set up video figure window
    videofig(vid.NumFrames, @(frm) redraw(frm, vid, struggle_idx, 'struggle'), input.FPS);
    
    % Display initial frame
    redraw(1, vid, struggle_idx, 'struggle');

    % Export struggling data to CSV
    frames_col = [0; frames_col];
    struggling_col = struggle_idx * 100;
    struggling_col = [0; struggling_col];
    smooth_dist_col = [0; smooth_mean_dist];
    output_table = array2table([frames_col, struggling_col, smooth_dist_col]);
    output_table.Properties.VariableNames = ["Frames", "Struggling", "Distance"];
    
    output_file_name = sprintf('%s_DLC_struggling.csv', input.name);
    writetable(output_table,output_file_name);
end