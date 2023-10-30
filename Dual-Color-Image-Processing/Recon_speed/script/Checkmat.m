file_dir = '/home/d2/Recon/motor/back_up';

path_g = fullfile(file_dir,'Red_Recon');
path_r = fullfile(file_dir,'Green_Recon');

file_g = dir(fullfile(path_g,'*.mat'));
file_r = dir(fullfile(path_r,'*.mat'));

% for i = 1:length(file_g)
%     load(fullfile(path_g,file_g(i).name),'ObjRecon');
%     if sum(isnan(ObjRecon))
%         disp([file_g(i).name,' have nan value']);
%     end
%     if mod(i,floor(length(file_g)/10))==0
%         disp(['Green Recon process: ',num2str(i/length(file_g)*100),'%']);
%     end
% end

for i = 1:length(file_r)
    load(fullfile(path_r,file_r(i).name),'ObjRecon');
    if sum(isnan(ObjRecon))
        disp([file_r(i).name,' have nan value']);
    end
    if mod(i,floor(length(file_r)/10))==0
        disp(['Red Recon process: ',num2str(i/length(file_r)*100),'%']);
    end
end