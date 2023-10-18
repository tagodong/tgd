%% function summary: Convolution of spike-like signals with a kernal


function convolved = spikeConvolution(spike, Kernel)

L = length(spike);

spike(spike<0)=0;
positivecConvolved = conv(spike, Kernel);
positivecConvolved = positivecConvolved(1:L);


convolved = positivecConvolved;

end