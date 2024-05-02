function tmp = artifact_detect(DFoF)
DFoF = zscore(DFoF,[],2);
max_DFoF = max(DFoF,[],2);
std_DFoF = std(DFoF,[],2);

tmp = max_DFoF./std_DFoF;

end