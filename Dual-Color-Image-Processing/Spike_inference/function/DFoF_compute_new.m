function [DFoF,Judge,sequences] = DFoF_compute_new(ifish)

path1 =  getFishPath('activity',ifish);
if ~isempty(dir(fullfile(path1,['*','Result','*',ifish,'*','.mat'])));
    dataName = dir(fullfile(path1,['*','Result','*',ifish,'*','.mat']));
    load(fullfile(dataName.folder,dataName.name),'Result');
    Judge  = logical(Result{1}.Judge);
    nS = size(Result,2); % how many chunk of sequence (continous time recording)

    %% compute sequences and raw calcium
    raw_Ca = [];
    sequences = zeros(nS,2);
    deltaT = 0;
    nT = 0;
    for i = 1:nS
        raw_Ca = [raw_Ca Result{i}.raw_Ca]; 
        sequences(i,1) = nT + 1;    
        [~,deltaT] = size(Result{i}.raw_Ca);
        nT = nT + deltaT;
        sequences(i,2) = nT;
    end

else
        load(fullfile(path1, ['Caltrace_',ifish]),'CalTrace3_original','sequences','center_Coord');
        raw_Ca = CalTrace3_original;
        [nC,~] = size(raw_Ca);
        Judge = true(nC,1);
end

%% compute DFoF
F0 = zeros(size(raw_Ca));
for i = 1:size(sequences,1)
    f0 = median(raw_Ca(:,sequences(i,1):sequences(i,2)),2); % median for denominator
    nT = sequences(i,2)-sequences(i,1)+1;
    F0(:,sequences(i,1):sequences(i,2)) = repmat(f0,1,nT);
end
DFoF = (raw_Ca - F0)./F0;

path2 = getFishPath('onedrive',ifish);

if ~isfolder(path2)
    [~,~] = mkdir(path2);
end

save([path1,'\DFoF.mat'],'DFoF');
save([path1,'\Judge.mat'],'Judge');

save([path2,'\DFoF.mat'],'DFoF');
save([path2,'\Judge.mat'],'Judge');

if ~isfile(fullfile(path1,'sequences.mat'))
    save([path1,'\sequences.mat'],'sequences');
    save([path2,'\sequences.mat'],'sequences');
end

if ~isfile(fullfile(path1,'center_Coord.mat'))
    save([path1,'\center_Coord.mat'],'center_Coord');
    save([path2,'\center_Coord.mat'],'center_Coord');
end

end