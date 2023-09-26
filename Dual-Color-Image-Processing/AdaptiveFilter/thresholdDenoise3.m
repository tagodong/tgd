% This function is a simple threshold denoiser
% if the abs value of input signal x less than threshold
% then div by factor of 8
% input: x,           vector
%        threshold,   number
%        factor       number < 0

% output x,           vector
% writtern by Chen Shen, cshen@ustc.edu.cn

function x = thresholdDenoise3(x, threshold, factor)

% whether it is a column vector and return length of the signal
if iscolumn(x)
    L = size(x,1);
else
    L = size(x,2);
end

  for i=1:L
    
     if (abs(x(i))<threshold)
     x(i)=x(i) * factor;
     end
  end
x(x<0)=0;

end

 
