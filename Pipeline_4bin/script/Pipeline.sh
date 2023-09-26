#!/bin/bash

# Set the path.
Path_g="/home/d1/230618-01/free/g"
Path_r="/home/d1/230618-01/free/r"
Red_flag=0

###### Run the registration pepline.
# Run reconstruction.
cd /home/user/tgd/Pipeline_4bin/Reconstruction/script/
# matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; start_num = 3120; end_num = 12000; x_shift = 80; recon_demo; quit"

###### Generate mean_template.
# Find candidate templates.
cd /home/user/tgd/Pipeline_4bin/Registration/script/
# matlab -nodesktop -nosplash -r "file_path = '${Path_g}'; red_flag = $Red_flag; canTemplateFind_run; quit"

# Run Registration for candidate templates.
# bash regist_candidate.sh ${Path_g} ${Path_r} ${Red_flag}
# bash temp_Pipeline.sh ${Path_g} ${Path_r} 1
if [ $? -eq 0 ]; then
	echo "====Build uboot ok!===="
else
	echo "====Build uboot failed!===="
	exit 1
fi

# Run Crop eyes.
# matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; eyes_crop_run; quit"

# Run demons registration.
matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; start_num = 3257; end_num = 6203; demonsRegist_run; quit"
