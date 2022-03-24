% Calculate the average power spectrum across all trials in data
% Inputs:
%   data: matrix of dimensions (trial, sample)
%   nwindow, noverlap, f, fs: arguments for pwelch function
% Output:
%   avg_ps: average power spectrum across all trials
function avg_ps = get_avg_ps(data, nwindow, noverlap, f, fs)
    ps = pwelch(data', nwindow, noverlap, f, fs, 'power');
    avg_ps = mean(ps, 2)';
end