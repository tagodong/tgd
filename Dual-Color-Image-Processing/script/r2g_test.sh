#!/bin/bash

# Set the path.
file_path="/home/d2/motor"
file_name=$(ls $file_path);
file_name=(${file_name//,/ });
fix_flag=1
Red_flag=1
heart_flag=0

Path_g=$file_path/g20001_24000
Path_r=$file_path/r20001_24000

cd /home/user/tgd/Dual-Color-Image-Processing/Reconstruction/script/
matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; heart_flag = $heart_flag; start_num = 1; end_num = 4000; step_size = 10; x_shift = 80; recon_demo; quit"


cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script/
bash regist_G2R.sh
