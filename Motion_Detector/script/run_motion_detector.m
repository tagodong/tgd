clear;
load('/home/user/tgd/Motion_Detector/Data/0804_3_test99.mat');
load('/home/user/tgd/Motion_Detector/Data/AF-0804-3.mat');
load('/home/user/tgd/Motion_Detector/Data/0804_3_dist.mat');

[Ca_Detected,Lo_Detected_all,Info_Detected] = motionDetector(Cal_G,AF,0.02,dist_edge,net);
