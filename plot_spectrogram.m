% plot spectrogram
% Inputs:
%   st: vector of window time instants (as outputted by Matlab's
%   Spectrogram function)
%   f: vector of frequencies
%   p: matrix of power for each frequncy and window of dimensions
%   (n_frequency, n_window)
%   linex: x-value of line marking (for marking imagination start)
% Output:
% line: line object
% c: colorbar object
function [line, c] = plot_spectrogram(st, f, p, linex)
    imagesc(st,f,p);
    axis xy; axis tight; colormap(jet);
    c = colorbar;
    line = xline(linex, '-', 'LineWidth', 2);
    set(gca,'FontSize',13)
end