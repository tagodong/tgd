path = '/home/d1/Learn/cnmf_data';
load(fullfile(path,'result','20240108_1706_Gcamp8s_Lss_11dpf_Learn_Fix_Blue.mat'));
load(fullfile(path,'result','neurons.mat'));

start_index = 1;
for i = 1:size(Fragments,1)
    Ca_trace(:,start_index:start_index+length(Fragments(i,1):Fragments(i,2))-1) = merge_C(:,Fragments(i,1):Fragments(i,2));
%     Ca_sequences(i,1:2) = [start_index start_index+length(Fragments(i,1):Fragments(i,2))-1];
    start_index = start_index+length(Fragments(i,1):Fragments(i,2));
end
Ca_trace = zscore(Ca_trace,1,2);
Ca_trace = Ca_trace(merge_SNR>2,:);

Cal_time = trace2Time(Cal_id,output);
po_xy = double(output(Cal_time,8:9))/100.0;
B_base = lasso(Ca_trace(:,Cal_time<10*2400)',po_xy(Cal_time<10*2400,1),'CV',10,'Alpha',1);

save(fullfile(path,'result','B_base.mat'),'B_base');