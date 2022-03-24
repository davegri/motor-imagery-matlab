% Calculate average spectrogram of data (across trials)
% Inputs:
%   data: 3D tensor of dimensions (trial,sample,electrode)
%   nwindow, noverlap, f, fs: arguments for spectrogram function
% Outputs:
% st: vector of time instants corresponding to the middle of each window
% spec_power: matrix of dimensions (n_freq,n_window) corresponding 
%   to the average power for each window and frequency.
function [spec_power, st] = avg_spectrogram(data, nwindow, noverlap, f, fs)
    % fourier transforms for first trial, and get time vector for
    % plotting later
    [~, ~, st, p] = spectrogram(data(1,:,:), nwindow, noverlap, f, fs);
    spec_power = p; % calculate power

    % sum up spectrograms for rest of trials
    n_trials = size(data,1);
    for t=2:n_trials
        [~,~,~,p] = spectrogram(data(t,:,:)', nwindow, noverlap, f, fs);
        spec_power = spec_power + p;
    end
    
    % divide by number of trials
    spec_power = spec_power/n_trials;
end