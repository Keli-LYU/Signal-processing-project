function y = TFCT_Interp(X,t,Nov)

% y = TFCT_Interp(X, t, hop)   
% Interpolation of the vector from TFCT
%
% X : matrix from TFCT
% t : time vector (real values) on which we interpolate
% For each value of t (and each column), we interpolate the spectrum magnitude 
% and determine the phase difference between 2 successive columns of X
% 
% y : the output is a matrix where each column corresponds to the interpolation of the corresponding column of X
% while preserving the phase jump from one column to another
%
% program largely inspired by a program made at Columbia University


[nl,nc] = size(X);

% calculate N = Nfft
N = 2*(nl-1);

% if nargin <3
%   % default value
%   Nov = N/2;
% end

% Initializations
%-------------------
% The interpolated spectrum
y = zeros(nl, length(t));

% Initial phase
ph = angle(X(:,1)); 

% Phase shift between each FFT sample
dphi = zeros(nl,1);
dphi(2:nl) = (2*pi*Nov)./(N./(1:(N/2)));

% First column index of the interpolated column to calculate 
% (first column of Y). This index will be incremented
% in the loop
ind_col = 1;

% Add a column of zeros to X to avoid the problem of 
% X(col+1) at the end of the loop
X = [X,zeros(nl,1)];


% Loop for interpolation
%----------------------------
% For each value of t, we calculate the new column of Y from 2
% successive columns of X

%% Your program starts here

% Interpolate for each time point t
for i = 1:length(t)
    % Get current time point t(i)
    ti = t(i);
    
    % Determine the two adjacent integer column indices where t(i) lies
    col = floor(ti) + 1;  % Left column index
    
    % Calculate interpolation weight (between 0 and 1)
    alpha = ti - floor(ti);  % Fractional part
    
    % Get magnitude and phase of two adjacent columns
    mag1 = abs(X(:, col));      % Magnitude of left column
    mag2 = abs(X(:, col+1));    % Magnitude of right column
    
    ph1 = angle(X(:, col));     % Phase of left column
    ph2 = angle(X(:, col+1));   % Phase of right column
    
    % Linear interpolation of magnitude
    mag = (1-alpha) * mag1 + alpha * mag2;
    
    % Calculate phase difference between two columns
    delta_ph = ph2 - ph1;
    
    % Adjust phase difference to [-pi, pi] range (phase unwrapping)
    delta_ph = angle(exp(1i * delta_ph));
    
    % Cumulative phase: base phase + interpolated phase increment
    % Instantaneous frequency deviation = (delta_ph - dphi) / (2*pi)
    ph = ph + dphi + alpha * (delta_ph - dphi);
    
    % Adjust phase to [-pi, pi] range
    ph = angle(exp(1i * ph));
    
    % Reconstruct complex spectrum
    y(:, ind_col) = mag .* exp(1i * ph);
    
    % Increment output column index
    ind_col = ind_col + 1;
end
