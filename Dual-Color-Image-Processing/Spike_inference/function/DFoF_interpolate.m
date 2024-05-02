function DFoF_new2 =  DFoF_interpolate(DFoF,diff_thres)

m = mean(DFoF,1);
[nC,nT] = size(DFoF);
%% identify the artifact peak
d_m = [0 diff(m)]; % 

if nargin < 2
    diff_thres = 0.04;
end
% solve 3 point artifact
d_m_id_onset = behavior_on_off(d_m>diff_thres);
d_m_id_onset = find(d_m_id_onset);
tf = d_m(d_m_id_onset+1) < -diff_thres;
d_m_id_onset = d_m_id_onset(tf);

m_new = m;
for i = 1:length(d_m_id_onset)
    id_tmp = d_m_id_onset(i);
    m_new(id_tmp) = mean([m(id_tmp-1), m(id_tmp+1)]);
end

DFoF_new = DFoF;

for i = 1:length(d_m_id_onset)
    id_tmp = d_m_id_onset(i);
    DFoF_new(:, id_tmp) = (DFoF(:, id_tmp-1)+DFoF(:,id_tmp+1))/2;
end

% solve 5 point artifact

DFoF_new2 = DFoF_new;
for i_cell = 1:nC
    DFoF_new2(i_cell,:) = solve_5_point_artifact(d_m, DFoF_new(i_cell,:),0.05);
end



function m_new2 = solve_5_point_artifact(d_m, m_new, diff_thres)


d_m_id_onset = behavior_on_off(d_m>diff_thres);
d_m_id_onset = find(d_m_id_onset);

if d_m_id_onset(end) > nT-3
    d_m_id_onset = d_m_id_onset(1:end-1);
end

tf = d_m(d_m_id_onset+2) < -diff_thres | d_m(d_m_id_onset+3) < -diff_thres;
d_m_id_onset = d_m_id_onset(tf);

m_new2=m_new;
for i = 1:length(d_m_id_onset) 
    id_tmp = d_m_id_onset(i);
        if id_tmp+4 < nT
            m_new2(id_tmp:id_tmp+2) = NaN;
            m_tmp = m_new2(id_tmp-2:id_tmp+4);
            f = fillmissing(m_tmp,'linear','SamplePoints',1:7);   
            m_new2(id_tmp-2:id_tmp+4) = f;
        end
end


end

end