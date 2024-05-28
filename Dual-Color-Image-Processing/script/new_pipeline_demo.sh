#!/bin/bash

# Set the path.
file_path="/home/d2/Recon/Check_5.18_20RLD_same"
# Set the global best frame number.
global_number=23671 # real number

# file_name=$(ls $file_path);
# file_name=(${file_name//,/ });

# If your data is fixed fish?
fix_flag=1

# Wether use red channel image as reference?
Red_flag=0
# Wether your data has heart fluorescence
heart_flag=0
# Do you want to process your red channel image.
Red_have=1

# ${#file_name[*]}
for ((i=0;i<1;i=i+1))
do
	# Path_g=$file_path/${file_name[$i]}/g
	# Path_r=$file_path/${file_name[$i]}/r
	Path_g=$file_path/g
	Path_r=$file_path/r

	##### Run the registration pepline.
	# Run reconstruction.
	cd /home/user/tgd/Dual-Color-Image-Processing/Reconstruction/script/
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; heart_flag = $heart_flag; Red_have = $Red_have; x_shift = 40; step_size = 1; recon_demo; quit"

	##### Generate mean_template.
	# Find candidate templates.
	cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script/
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; global_number = $global_number; canTemplateFind_run; quit"
	
	# Run Registration for candidate templates.
	cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script/
	if [ $fix_flag -eq 1 ]; then
		bash regist_candidate_fix.sh ${Path_g} ${Path_r} ${Red_flag} ${heart_flag} ${Red_have}
		if [ $? -eq 0 ]; then
			echo "====Build uboot ok!===="
		else
			echo "====Build uboot failed!===="
			exit 1
		fi
	else
		bash regist_candidate_move.sh ${Path_g} ${Path_r} ${Red_flag}
		if [ $? -eq 0 ]; then
			echo "====Build uboot ok!===="
		else
			echo "====Build uboot failed!===="
			exit 1
		fi
	fi

	# Run Crop eyes.
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; Red_have = $Red_have ;eyes_crop_run; quit"

	# Run demons registration.
	matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; Red_have = $Red_have; demonsRegist_run; quit"

done