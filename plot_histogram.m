% Plot histogram showing the number of left/right trials who's feature
% falls into each bin
% Inputs:
%   pow: vector of length n_trials with the feature for each trial
%   left_mask, right_mask: logical vectors of size n_trials marking
%   left/right sides respectively.
function plot_histogram(feat, left_mask, right_mask)
    % set bin width according to the max size / 25 for asthetic reasons
    BinWidth = max(feat)/25;
    % left histogram
    histogram(feat(left_mask), 10, 'facealpha',.5, "BinWidth", BinWidth);
    % right histogram
    hold on;
    histogram(feat(right_mask), 10, 'facealpha',.5, "BinWidth", BinWidth);
    set(gca,'FontSize',13)
    legend("left", "right");
    hold off;
end