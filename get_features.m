% Extract the following features from data:
%   1) average power + log10(average power) for each band + electrode in power_bands
%   2) slope + intercept of a linear approximation of log(pow) relative to
%   log(freq) only for C3 electrode
% features are normalized using zscore
% Inputs:
%   data: 3D tensor of dimensions (trial, sample, electrode)
%   power_bands: struct array with fields: freq, time, electrodes. each
%       struct represents a feature to be extracted according to the 
%       ranges in  "freq" and "time" fields. for the electrodes marked 1 
%       in the "electrode" field
%   nwindow, noverlap, f, fs: arguments for pwelch function
% Output:
%   F: feature matrix of dimensions (n_trial, n_feature)

function F = get_features(data, bands, nwindow, noverlap, f, fs)
    % size isn't preallocated beacuse F is reassigned during runtime
    F = zeros(0, 0); 

    % power bands (sum of power in each frequency + time band for each eletrode)
    pow_band_feat = get_bands_power(data, bands, nwindow, noverlap, fs);
    F = [F pow_band_feat];
    
    % log10 of power bands
    F = [F log10(pow_band_feat)];
        
    % slope & intercept
    psC3 = pwelch(data(:,:,1)', nwindow, noverlap, f, fs, 'power');
    slope_intercept = zeros(size(data,1), 2);
    for i=1:size(psC3,2)
        % f(1) = 0 thus we take f from the second place to avoid -Inf
        slope_intercept(i,1:2) = polyfit(log(f(2:end)),log(psC3(2:end,i)),1);
    end
    F = [F slope_intercept];

    % normalize features
    F = zscore(F);
end