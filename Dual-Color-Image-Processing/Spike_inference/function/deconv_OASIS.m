
%% inputs for this script:
% detrend_ca: detrended DFoF (z-scored)
% sequences

function [spike,denoise_ca,g,sn,lam,b] = deconv_OASIS(detrend_ca,sequences,lambda_value)

oasis_setup;

spike = []; % spike matrix
denoise_ca = []; % denoise calcium matrix
r1 = sequences(1,1);
n_seq = size(sequences,1);
nC = size(detrend_ca,1);
g = zeros(nC,n_seq); % estimated time constant
sn = zeros(nC,n_seq); % std of noise
lam = zeros(nC,n_seq); % lambda, the sparsity parameter
b = zeros(nC,n_seq); % baseline

f=waitbar(0,'processing');
for time = 1:n_seq
    duration = sequences(time,2)-sequences(time,1);
    r2 = r1 + duration;
    CellResp = detrend_ca(:,r1:r2); % detrended DFoF
    [N,~] = size(CellResp);
    sMatrix = [];
    cMatrix = [];
    parfor (i =1:N,8)
        y=transpose(CellResp(i,:));
        
%         [c, s, par]=deconvolveCa(y, 'ar1', 'optimize_pars', true, 'optimize_b', true,...  
%         'maxIter',100);

     
        [c, s, par]=deconvolveCa(y, 'ar1','foopsi','optimize_pars', true,'optimize_b', false,...  
        'maxIter',100,'lambda', lambda_value);
    
   
        % spike
        sMatrix(i,:)=s';
        % denoised calcium
        cMatrix(i,:) = c';
        waitbar(i/N);
        g(i,time) = par.pars;
        sn(i,time) = par.sn;
        lam(i,time) = par.lambda;
        b(i,time) = par.b;
    end

    if mean(std(sMatrix,0,2))<0.003
       sMatrix = zeros(size(sMatrix,1),size(sMatrix,2));
    end
    
    if time == 1
        spike = sMatrix;
        denoise_ca = cMatrix;
    else
        spike = [spike,sMatrix];
        denoise_ca = [denoise_ca,cMatrix];
    end
    r1 = r2+1;
end
close(f);

end
