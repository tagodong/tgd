PSF_path_red = '/home/d1/Seizure221211/PSF/PSFr_221009.mat';
PSF_path_green = '/home/d1/Seizure221211/PSF/PSFg221009.mat';

psf_red = load(PSF_path_red,"PSF_1");
psf_green = load(PSF_path_green,"PSF_1");

[wb_red, ~] = BackProjector(psf_red.PSF_1, 'wiener-butterworth');
[wb_green, ~] = BackProjector(psf_green.PSF_1, 'wiener-butterworth');

save('/home/d1/Seizure221211/PSF/wb_red.mat','wb_red','-v7.3');
save('/home/d1/Seizure221211/PSF/wb_green.mat','wb_green','-v7.3');

