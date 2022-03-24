% slice specific time range from EEG data 
% Inputs:
%   data: 3D tensor of dimensions (trial, sample, electrode)
%   range: vector marking time range in seconds: [start, end]
%   fs: sampling frequency
% Output:
%   sliced_data: 3D tensor of dimensions (trial, sample, electrode) where
%   samples are sliced to match time range.
function sliced_data = slice_data(data, range, fs)
    samp_range = range * fs;
    sliced_data = data(:, samp_range(1):samp_range(2) ,:, :);
end