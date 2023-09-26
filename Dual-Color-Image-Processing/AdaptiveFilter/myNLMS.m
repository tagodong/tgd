% This function is an implementation of LMS (Least Mean Square) Algorithm,
% hybrid with L1 normalization and momentum factor

% % written by Chen Shen, 8 Jan 2023
% % for any question please kontakt cshen@ustc.edu.cn



% myNLMS.m - Normalized least mean squares algorithm
%
% Usage: [e, y, w] = myLMS(d, x, mu, M, a)
%
% Inputs:
% d  - the vector of desired signal samples of size Ns
% x  - the vector of input signal samples of size Ns
% mu - the stepsize parameter
% a  - the bias parameter, 
% M  - the number of taps. 
%     rho   L1 normalization factor

% Outputs:
% e - the output error vector of size Ns
% y - inferred baseline
% w - filter parameters
%

function [e, y, w] = myNLMS(x, d, mu, M, a, rho)

Ns = length(d);
if (Ns <= M)  
    print('error: The signal length is less than the filter order');
    return; 
end
if (Ns ~= length(x))  
    print('error: The input signal and the reference signal have different lengths');
    return; 
end

% Initialization
%x = x; 
xx = zeros(M,1);
w1 = zeros(M,1);
y = zeros(Ns,1);
e = zeros(Ns,1);

% Iteration
for n = 1:Ns
     % pick the M tap-input
    xx = [xx(2:M);x(n)];
     % the output of M-order FIR filter 
    y(n) = w1' * xx;
    % normalization step \mu
    k = mu/(a + xx'*xx);
    % the error of i-th iteration
    e(n) = d(n) - y(n);
    w1 = w1 + k * e(n) * xx - ...
        rho*sign(e(n)); 
    % update weights
    w(:,n) = w1;
end
end