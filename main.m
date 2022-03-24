%% Matlab Final
clear;clc;

%% Params
% Data
DATA_PATH = "./Data";
TRAIN_DATA_FILENAME = "motor_imagery_train_data";
TEST_DATA_FILENAME = "motor_imagery_test_data";

imag_range = [2.25 6]; % motor imagination time range [sec]

% trial markings
REMOVE_ROW = 1;
ARTIFACT_ROW = 2;
LEFT_ROW = 3;
RIGHT_ROW = 4;

% electrode index numbers
C3 = 1;
C4 = 2;

% Power Spectrum & Spectrogram
f = 0:0.01:40; % total relevent frequency range
window = 1; % [sec]
overlap = 0.7; % window overlap percentage

% Feature Extraction
% Declare which power bands to extract average power features from.

% Each band is a struct with three fields:
% freq: two number vector indicating frequency band in Hz
% time: two number vector indicating time range
% electrodes: two number vector indicating whether or not to extract from
% the first (C3) and/or second (C4) electrode: 1 - yes, 0 - no.

freq = {[15 18], [9 11], [1 7], [8 10], [0 1], [35, 40]};
time = {[4 6], [4 6], imag_range, imag_range, [4 6], [4 6]};
electrodes = {[1 1], [1 1], [1 1], [1 1], [1,1], [1,1]};
bands = struct('freq', freq, 'time', time, 'electrodes', electrodes);

% Feature selection
n_features = 12;

% Validation
n_folds = 8; % number of folds in each validation iteration

%% Load Data & Set data dependent constants
% load training data
train_data_path = fullfile(DATA_PATH, TRAIN_DATA_FILENAME);
P_C_S = load(train_data_path).P_C_S;

% filter out rows marked ARTIFACT and REMOVE
keep_mask = ~P_C_S.attribute(REMOVE_ROW,:) & ~P_C_S.attribute(ARTIFACT_ROW,:);

% extract data for relevent electrodes
data = P_C_S.data(keep_mask,:,C3:C4);

% get sampling frequency
fs = P_C_S.samplingfrequency;

% set power spectrum params according to sampling frequency
nwindow = floor(window*fs);
noverlap = floor(nwindow*overlap);

% create logical mask for each side (left/right)
left_mask = logical(P_C_S.attribute(LEFT_ROW,:));
right_mask = logical(P_C_S.attribute(RIGHT_ROW,:));

%% Visualize EEG's of both electrodes for 20 random trials for each class
figure('units', 'normalized', 'Position', [0 0.25 0.5 0.5]);
vis_EEG(data(left_mask,:,:), fs, "EEG signal for left side");
figure('units', 'normalized', 'Position', [0.5 0.25 0.5 0.5]);
vis_EEG(data(right_mask,:,:), fs, "EEG signal for right side");

%% Visualize Power Spectrums
% slice out data matching imagination period
image_data = slice_data(data, imag_range, fs);

% get average power spectrum for each electrode and each side
avg_ps_right_C3 = get_avg_ps(image_data(right_mask,:,C3), nwindow, noverlap, f, fs);
avg_ps_left_C3 = get_avg_ps(image_data(left_mask,:,C3), nwindow, noverlap, f, fs);
avg_ps_right_C4 = get_avg_ps(image_data(right_mask,:,C4), nwindow, noverlap, f, fs);
avg_ps_left_C4 = get_avg_ps(image_data(left_mask,:, C4), nwindow, noverlap, f, fs);

% plot power spectrums
figure('units', 'normalized', 'Position', [0.25 0.25 0.5 0.5]);
tl = tiledlayout(2,1);
xlabel(tl,'Frequency [Hz]', "FontSize", 13)
ylabel(tl,'Power [AU]', "FontSize", 13)
title(tl, "Power spectrums (imagination period) - average over trials", "FontSize", 16);
nexttile;
plot(f, [avg_ps_right_C3; avg_ps_left_C3]);
legend("right", "left", "FontSize", 12);
title("C3", "FontSize", 15);
nexttile;
plot(f, [avg_ps_right_C4; avg_ps_left_C4]);
legend("right", "left", "FontSize", 12);
title("C4", "FontSize", 15);

%% Visualise Spectograms
% Get average spectrograms for each electrode and each side
[power_right_C3, st] = avg_spectrogram(data(right_mask,:, C3), nwindow, noverlap, f, fs);
power_left_C3 = avg_spectrogram(data(left_mask,:, C3), nwindow, noverlap, f, fs);
power_right_C4 = avg_spectrogram(data(right_mask,:,C4), nwindow, noverlap, f, fs);
power_left_C4 = avg_spectrogram(data(left_mask,:, C4), nwindow, noverlap, f, fs);

% calculate difference of spectrogram
power_diff_C3 = abs(power_right_C3 - power_left_C3);
power_diff_C4 = abs(power_right_C4 - power_left_C4);

% plot spectrograms
figure('units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
tl = tiledlayout(2,3, 'TileSpacing','Compact');
title(tl, "Spectrograms", 'FontSize',19);
xlabel(tl, "Time (sec)", 'FontSize',15);
ylabel(tl, "Frequency (Hz)", 'FontSize',15);
nexttile;
plot_spectrogram(st, f, power_left_C3, imag_range(1));
title("C3 - Left", 'FontSize',15);
nexttile;
plot_spectrogram(st, f, power_right_C3, imag_range(1));
title("C3 - Right", 'FontSize',15);
nexttile;
[~, col1] = plot_spectrogram(st, f, power_diff_C3, imag_range(1));
title("C3 - Diff", 'FontSize',15);
nexttile;
plot_spectrogram(st, f, power_left_C4, imag_range(1));
title("C4 - Left", 'FontSize',15);
nexttile;
line = plot_spectrogram(st, f, power_right_C4, imag_range(1));
title("C4 - Right", 'FontSize',15);
nexttile;
[~, col2] = plot_spectrogram(st, f, power_diff_C4, imag_range(1));
title("C4 - Diff", 'FontSize',15);
% legend for whole layout
lg = legend(line, "Imagination Start", 'FontSize',13);
lg.Layout.Tile = "north";

% color bar labels for last two plots
label = ylabel(col1, "Power (AU)", "FontSize", 15);
label = ylabel(col2, "Power (AU)", "FontSize", 15);

%% Power histograms of informative frequency bands (in specific time windows)
% get average power in each informative frequency band
pow = get_bands_power(data, bands(1:2), nwindow, noverlap, fs);
pow = reshape(pow, size(pow,1), [], size(data,3)); % reshape to index by electrode

% plot histograms
% declare main layout
figure('units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
t_main = tiledlayout(1,2, 'TileSpacing','Compact');
% declare seperate column for each electrode
l_C3 = tiledlayout(t_main,'flow','TileSpacing','Compact');
l_C4 = tiledlayout(t_main,'flow','TileSpacing','Compact');
l_C4.Layout.Tile = 2;
title(t_main, "Histograms of power in specific frequency and time ranges", "FontSize", 16);
xlabel(t_main, "Power [AU]", "FontSize", 13)
ylabel(t_main, "Num of Trials", "FontSize", 13);
% plot histograms for each band (1 for each electrode)
for b=1:size(pow,2)
    band_des = band_description(bands(b));
    % plot C3
    nexttile(l_C3);
    plot_histogram(pow(:,C3,b), left_mask, right_mask);
    subtitle(l_C3, "C3", "FontSize", 15);
    subtitle(band_des);
    
    % plot C4
    nexttile(l_C4);
    plot_histogram(pow(:,C4,b), left_mask, right_mask);
    subtitle(band_des);
    subtitle(l_C4, "C4","FontSize", 15);
end

%% Feature Extraction
% get features
train_features = get_features(data, bands, nwindow, noverlap, f, fs);

% select best features using chi-squared tests for dependance of class on
% features
feature_idx_rank = fscchi2(train_features, right_mask);
selected_feature_idxs = feature_idx_rank(1:n_features);
train_samples = train_features(:,selected_feature_idxs);

%% histograms of top 6 features
plot_top_feat_hist(train_features, right_mask, left_mask, bands);

%% Training & Validation
[val_acc, tr_acc] = kfolds_valid(8, train_samples, right_mask);

% print validation results
fprintf('\nValidation Accuracy: %0.2f +- %0.2f%%' ,mean(val_acc), std(val_acc));
fprintf('\nTraining Accuracy: %0.2f +- %0.2f%%' ,mean(tr_acc), std(tr_acc));

%% classify test data
% load test data
test_data_path = fullfile(DATA_PATH, TEST_DATA_FILENAME);
test_data = load(test_data_path).data;

% extract data for relevent electrodes
test_data = test_data(:,:,C3:C4);

% get test features
test_features = get_features(test_data, bands, nwindow, noverlap, f, fs);
test_samples = test_features(:,selected_feature_idxs); % select relevant features

% train and predict test labels
pred_test_labels = classify(test_samples, train_samples, right_mask);