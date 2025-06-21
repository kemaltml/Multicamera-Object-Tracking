function corrected = smooth_linear(data, windowSize,a)
    % data: x, y veya z vektörü
    % windowSize: kaç veride bir doğrusal düzeltme yapılacağı

    N = length(data);
    corrected = data;  % Orijinali koruyarak başla

    for i = 1:N - windowSize + 1
        idx = i:i+windowSize-1;
        x = idx';
        y = data(idx);
        
        p = polyfit(x, y, a);  % Doğrusal regresyon
        y_fit = polyval(p, x);  % Uygulanan düz çizgi

        % Değeri güncelle
        corrected(idx) = y_fit;
    end
end


% Certainly! Here’s a breakdown of what the smooth_linear MATLAB function does:

% Purpose
% This function smooths a data vector by applying a moving linear (or polynomial) fit over a sliding window. It replaces each window of data with the fitted values, effectively reducing noise and smoothing the signal.

% Parameters
% data: The input vector (e.g., x, y, or z data).
% windowSize: The number of data points in each window for fitting.
% a: The degree of the polynomial for fitting (e.g., 1 for linear).
% Step-by-Step Explanation
% Initialization

% N is the length of the input data.
% corrected is initialized as a copy of data to store the smoothed result.
% Sliding Window Loop

% Loops over the data so that each window of size windowSize is processed.
% Window Indexing

% idx selects the indices for the current window.
% x is a column vector of indices (used as the independent variable).
% y is the segment of data in the current window.
% Polynomial Fitting

% polyfit fits a polynomial of degree a to the data in the window.
% polyval evaluates the fitted polynomial at the same indices.
% Update Smoothed Data

% The original data in the window is replaced with the fitted (smoothed) values.
% Gotchas & Notes
% Overlapping Windows: Each data point may be updated multiple times (since windows overlap), so the last fit "wins" for each point.
% Edge Effects: The last windowSize-1 points are not smoothed, as the loop stops before the end.
% Parameter a: If a is set to 1, this is a moving linear fit (common for smoothing). Higher values fit higher-degree polynomials.
% Example Usage
% Let me know if you want a visualization or have questions about specific parts!