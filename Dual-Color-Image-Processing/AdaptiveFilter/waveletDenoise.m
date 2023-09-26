%% function summary: To Apply the wavelet denoise on the input signal

%  input:
%   nx --- the input signal
%  output:
%   xd --- the denoised signal

function xd = waveletDenoise(nx)

[c,l] = wavedec(nx,3,'db6');

sigma = wnoisest(c,l,1);

alpha = 2;

thr = wbmpen(c,l,sigma,alpha);

keepapp = 1;

xd = wdencmp('gbl',c,l,'db6',3,thr,'s',keepapp);


end

 

