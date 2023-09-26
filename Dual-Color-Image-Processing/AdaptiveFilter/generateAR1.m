% This Function is a temporary implementation of Generating AR(1) Kernel
% maybe modified in the future
% Wrote by Chen Shen
% input: gamma
% output: AR


function AR = generateAR1(gamma)
% 10s decay 
Length = 100;
s = zeros(1,Length+1);


s(2)=1;


AR=zeros(1,Length+1);


for t=2:Length+1

    AR(t)=gamma*AR(t-1)+s(t);

end

AR(1)=[];

end