% Calculate the average power for each band in power_bands
% Inputs:
%   data: 3D tensor of dimensions (trial, sample, electrode)
%   power_bands: struct array with fields: freq, time, electrodes. each
%       struct represents a feature to be extracted according to the 
%       ranges in  "freq" and "time" fields. for the electrodes marked 1 
%       in the "electrode" field
%   nwindow, noverlap, f, fs: arguments for pwelch function
%   T (optional): a function to be applied to the power spectrum before it
%   is integrated in it's respective frequency range.
% Output:
%   pow: a matrix of average powers with dimensions (n_trials,n_features). 
%   each electrode marked as 1 for each band in power_bands adds an 
%   additional feature.
function pow = get_bands_power(data, bands, nwindow, noverlap, fs, T)
    % set T to the identity function if no T is passed
    if nargin == 5
        T = @(x) x;
    end
    % preallocate rows for power matrix, column number is not preallocated
    % because it is decided dynamically based on the electrode field in
    % power_bands
    pow = zeros(size(data,1), 0);
    % loop over bands
    for band=bands
        % get data for relevent time range
        sliced_data = slice_data(data, band.time, fs);
        % get relevent frequency range
        f = band.freq(1):0.01:band.freq(2);
        % add average power for first electrode if needed
        if band.electrodes(1)
            ps = pwelch(sliced_data(:,:,1)', nwindow, noverlap, f, fs, 'power');
            band_pow = bandpower(T(ps), f, 'psd')';
            pow = [pow band_pow];
        end
        % add average power for second electrode if needed
        if band.electrodes(2)
            ps = pwelch(sliced_data(:,:,2)', nwindow, noverlap, f, fs, 'power');
            band_pow = bandpower(T(ps), f, 'psd')';
            pow = [pow band_pow];
        end
    end
end
