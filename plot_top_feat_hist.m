% Plot histograms of top features excluding  #1 and #3
% This function uses magic numbers to extract specific features and also
% plots the specific titles that match them, and is thus not a general
% purpose function that will not be relevent if the features change
% Inputs:
%   train_features: matrix of training features
function plot_top_feat_hist(train_features, right_mask, left_mask, bands)
    % create layout
    figure('units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
    tl = tiledlayout(2,2, "TileSpacing", "Compact");
    title(tl, "Histograms of 4 features (as ranked using chi-squared tests)", "FontSize", 18)
    xlabel(tl, "Feature value bins", "FontSize", 15);
    ylabel(tl, "num of trials", "FontSize", 15);
    
    % plot feature #2
    feature = train_features(:,14);
    nexttile;
    plot_histogram(feature, left_mask, right_mask);
    title("#2" + newline + "C3: log10 of average power in band:");
    subtitle(band_description(bands(1)));
    
    % plot feature #4
    feature = train_features(:,13);
    nexttile;
    plot_histogram(feature, left_mask, right_mask);
    title("#4" + newline + "C4: log10 of average power in band:");
    subtitle(band_description(bands(1)));
    
    % plot feature #5
    feature = train_features(:,11);
    nexttile;
    plot_histogram(feature, left_mask, right_mask);
    title("#5" + newline + "C3: average power in band:");
    subtitle(band_description(bands(6)));
    
    % plot feature #6
    feature = train_features(:,23);
    nexttile;
    plot_histogram(feature, left_mask, right_mask);
    title("#6" + newline + "C3: log10 of average power in band:");
    subtitle(band_description(bands(6)));
end