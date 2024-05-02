function [DFoF] = DFoF_compute(Caltrace,sequences)

%% compute DFoF
F0 = zeros(size(Caltrace));
for i = 1:size(sequences,1)
    f0 = prctile(Caltrace(:,sequences(i,1):sequences(i,2)),20,2); % median for denominator
    nT = sequences(i,2)-sequences(i,1)+1;
    F0(:,sequences(i,1):sequences(i,2)) = repmat(f0,1,nT);
end
DFoF = (Caltrace - F0)./F0;

end