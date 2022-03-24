% output a user friendly description of a frequency + time band to be used
% for plotting purposes
% Input: band struct with "freq" and "time" fields each containing a vector
% with two numbers.
function descr = band_description(band)
descr = int2str(band.freq(1))+"-"+int2str(band.freq(2))+" Hz, "...
        + int2str(band.time(1))+"-"+int2str(band.time(2))+" sec";
end