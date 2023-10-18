function [AF, e, y]=useNLMS(sigR,sigG, extendfactor)

% extend the signal
L = length(sigG);
sigR = padarray(sigR, [0 ceil(L*extendfactor)],'symmetric','pre' );
sigG = padarray(sigG, [0 ceil(L*extendfactor)],'symmetric','pre');

[e,y,~] = myNLMS(sigR, sigG, 0.8, 2, -1e-3, -1e-4);

e = thresholdDenoise3(e, mean(sigG)*0.1,0.05);
e = e(ceil(L*extendfactor)+1:end);
y = y(ceil(L*extendfactor)+1:end);
e = e./y;

ARKernel = generateAR1(0.95);
AF = spikeConvolution(e, ARKernel);

end