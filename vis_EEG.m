% Visualize 20 random trials of EEG data
% Inputs:
%   data: 3D tensor of dimensions (trial, sample, electrode)
%   fs: sampling frequency
%   titletext: title text for plot
function vis_EEG(data, fs, titletext)
    % get 20 random trials
    rand_trials = data(randperm(size(data,1), 20),:,:);    
    record_time = size(data, 2) / fs; % length of recording [sec]
    t = 0:1/fs:record_time - 1/fs; % time vector for plot
    % create tiled layout
    tl = tiledlayout(4,5);
    title(tl, titletext, "FontSize", 16);
    xlabel(tl,'Time [sec]', "FontSize", 13);
    ylabel(tl, "Amplitude [\muV]", "FontSize", 13);
    for trial_number=1:size(rand_trials,1)
        
        % get trial (and remove degenerate dimension)
        trial = squeeze(rand_trials(trial_number,:,:));
        ax = nexttile;
        % plot first signal with y offset so that they don't cover each other
        plot(t, trial(:,1) + 30); % first electrode
        hold on;
        plot(t, trial(:,2)); % second electrode
        yticks([]); % hide y-axis because it isn't meaningful after offset
    end
    lg  = legend(ax, ["C3" "C4"], "FontSize", 12);
    lg.Layout.Tile = "east";
end
