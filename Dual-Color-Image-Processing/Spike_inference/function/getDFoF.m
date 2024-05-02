function [DFoF] = getDFoF(CalTrace)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sequences = [1 size(CalTrace,2)];

F0 = zeros(size(CalTrace));
numRegion=size(CalTrace,1);
arg=zeros(numRegion,1);
for i=1:size(sequences,1)
   
    for jj=1:numRegion
    %arg(jj) = quantile(nonzeros(CalTrace3(jj,sequences(i,1):sequences(i,2))),0.66,1);
        arg(jj) = mean(nonzeros(CalTrace(jj,sequences(i,1):sequences(i,2))));
    end
    F0(:,sequences(i,1):sequences(i,2)) = repmat(arg,1,sequences(i,2)-sequences(i,1)+1);
  %  F0(:,sequences(i,1):sequences(i,2)) = repmat(quantile(CalTrace3(:,sequences(i,1):sequences(i,2)),0.8,2),1,sequences(i,2)-sequences(i,1)+1);
    
end
DFoF = (CalTrace - F0)./F0;
% DFoF = waveletDenoise(DFoF);

end