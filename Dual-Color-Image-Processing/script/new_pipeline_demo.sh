#!/bin/bash

# Set the path.
file_path="/home/d1/blueLaser"
file_name=$(ls $file_path);
file_name=(${file_name//,/ });

for ((i=0;i<${#file_name[*]};i=i+1))
do
	Path_g=$file_path/${file_name[$i]}/g
	Path_r=$file_path/${file_name[$i]}/r
	Red_flag=1

	###### Run the registration pepline.
	# Run reconstruction.
	cd /home/user/tgd/Dual-Color-Image-Processing/Reconstruction/script/
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; start_num = 325; end_num = 1200; x_shift = 80; recon_demo; quit"

	###### Generate mean_template.
	# Find candidate templates.
	cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script/
	matlab -nodesktop -nosplash -r "file_path = '${Path_g}'; red_flag = $Red_flag; canTemplateFind_run; quit"

	# Run Registration for candidate templates.
	bash regist_candidate.sh ${Path_g} ${Path_r} ${Red_flag}
	if [ $? -eq 0 ]; then
		echo "====Build uboot ok!===="
	else
		echo "====Build uboot failed!===="
		exit 1
	fi

	# Run Crop eyes.
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; eyes_crop_run; quit"

	# Run demons registration.
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; demonsRegist_run; quit"

done