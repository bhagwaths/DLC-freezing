day_label = 'Day8';
path = 'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\struggling data\by day\Day8';

names = {'AS-vHIP-BLA-1';
    'AS-vHIP-BLA-2';
    'AS-vHIP-BLA-3';
    'AS-vHIP-BLA-4';
    'AS-vHIP-BLA-5';
    'AS-vHIP-BLA-6';
    'AS-vHIP-BLA-7';
    'AS-vHIP-BLA-8'};

files = {'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-1_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_060.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-2_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_020.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-3_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_020.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-4_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_020.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-5_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_060.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-6_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_060.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-7_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_060.csv';
'C:\Users\bhagwaths\Desktop\AS-vHIP-BLA_DLC_results\coordinates\by day\Day8\AS-vHIP-BLA-8_Day8_Cam1DLC_Resnet50_AS-vHIP-BLAJan21shuffle1_snapshot_060.csv'};

motion_thresholds = [3; 3; 3; 3; 3; 3; 3; 3];
behavioral_durations = [20; 20; 20; 20; 20; 20; 20; 20];

for mouse=1:numel(names)
    % Read data
    data = readtable(files{mouse});
    [~, data_header] = xlsread(files{mouse});
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
    ep_idx = smooth_mean_dist > motion_thresholds(mouse);
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
    struggle_ep_idx = ep_lengths >= behavioral_durations(mouse);
    struggle_start = ep_start(struggle_ep_idx);
    struggle_end = ep_end(struggle_ep_idx);
    struggle_idx = zeros(size(ep_idx));
    for i=1:numel(struggle_start)
        struggle_idx(struggle_start(i)+1:struggle_end(i)) = 1;
    end

    frames_col = frames{:,:}(2:end,:);

    % Export struggling data to CSV
    frames_col = [0; frames_col];
    struggling_col = struggle_idx * 100;
    struggling_col = [0; struggling_col];
    smooth_dist_col = [0; smooth_mean_dist];
    output_table = array2table([frames_col, struggling_col, smooth_dist_col]);
    output_table.Properties.VariableNames = ["Frames", "Struggling", "Distance"];
    
    output_file_name = sprintf('%s_%s_DLC_struggling.csv', names{mouse}, day_label);
    output_file_path = fullfile(path, output_file_name);
    writetable(output_table,output_file_path);
end