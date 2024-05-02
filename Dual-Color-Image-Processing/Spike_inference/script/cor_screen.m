for i =1:size(Cal_G,1)
    cor(i,1) = max(xcorr(denoise_ca(i,:)',AF_exp(i,:)','normalized',10));
    snr(i,1) = mysnr(Cal_R(i,:));
end

[sort_cor,idx] = sort(cor);
plot(sort_cor)

[sort_snr,idx_snr] = sort(snr);
plot(sort_snr)
id_s = idx_snr(sort_snr<20);

id = idx(sort_cor>0.2);
plot(Cal_G(id_s(end),:),'g');
hold on;
plot(Cal_R(id_s(end),:),'r');

num = 0;
for i = 1:length(id)
    if ~ismember(id(i),id_s)
        num = num +1;
        com_id(num) = id(i);
    end
end

Cal_G_screen = Cal_G(com_id,:);
Cal_R_screen = Cal_R(com_id,:);
detrend_G_screen = detrend_ca(com_id,:);
spike_screen = sMatrix_total(com_id,:);

s_exp.filter.Cal_G = Cal_G_screen;
s_exp.filter.Cal_R = Cal_R_screen;
s_exp.filter.detrend_G = detrend_G_screen;
s_exp.filter.spike = spike_screen;
s_exp.filter.spike_conv = denoise_ca(com_id,:);

s_exp.origin.Cal_G = Cal_G;
s_exp.origin.Cal_R = Cal_R;
s_exp.origin.detrend_G = detrend_ca;
s_exp.origin.spike = sMatrix_total;
s_exp.origin.spike_conv = denoise_ca;


%% con
sequences = [1:340,530:2771];
% Cal_G_tmp = Cal_G(:,530:3300);
% Cal_G_o = Cal_G_tmp(:,sequences);
% Cal_R_tmp = Cal_R(:,530:3300);
% Cal_R_o = Cal_R_tmp(:,sequences);
% denoise_ca_o = denoise_ca(:,sequences);
AF = AF_con(:,530:3300);
AF = AF(:,sequences);

for i =1:size(Cal_G,1)
    [cor(i,1),index(i,1)] = max(xcorr(denoise_ca(i,:)',AF(i,:)','normalized',10));
    [s_cor(i,1)] = max(xcorr(denoise_ca(i,:)',AF(i,:)','normalized',0));
    snr(i,1) = mysnr(Cal_R_o(i,:));
end
hist(index)

[sort_cor,idx] = sort(cor);
figure
plot(sort_cor)

[sort_cor,idx] = sort(s_cor);
figure
plot(sort_cor)

[sort_snr,idx_snr] = sort(snr);
plot(sort_snr)
id_s = idx_snr(sort_snr<20);

figure;
id = idx(sort_cor>0.2);
plot(Cal_G_o(idx_snr(length(id_s)-1),:),'g');
hold on;
plot(Cal_R_o(idx_snr(length(id_s)-1),:),'r');

coordinates = neuronsSpatialDistribution(162,A3,ObjRecon);

com_id = [];
num = 0;
for i = 1:length(id)
    if ~ismember(id(i),id_s)
        num = num +1;
        com_id(num) = id(i);
    end
end

s_con.filter.Cal_G = Cal_G_o(com_id,:);
s_con.filter.Cal_R = Cal_R_o(com_id,:);
s_con.filter.detrend_G = detrend_ca(com_id,:);
s_con.filter.spike = sMatrix_total(com_id,:);
s_con.filter.spike_conv = denoise_ca(com_id,:);

s_con.origin.Cal_G = Cal_G_o;
s_con.origin.Cal_R = Cal_R_o;
s_con.origin.detrend_G = detrend_ca;
s_con.origin.spike = sMatrix_total;
s_con.origin.spike_conv = denoise_ca;