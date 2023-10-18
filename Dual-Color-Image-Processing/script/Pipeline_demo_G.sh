#!/bin/bash

# Set the path.
Path_g="/home/d1/20230809_1529_g8s-lssm-none_8dpf-fix/fix/g"
Path_r="/home/d1/20230809_1529_g8s-lssm-none_8dpf-fix/fix/r"
Red_flag=0

# Run the registration pepline.
# Run reconstruction.
cd /home/user/tgd/Dual-Color-Image-Processing/Reconstruction/script/
# matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; start_num = 325; end_num = 1200; recon_demo; quit"

# Find candidate templates.
cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script/
matlab -nodesktop -nosplash -r "file_path = '${Path_g}'; red_flag = $Red_flag; canTemplateFind_run; quit"

# Run Affine Registration.
bash regist_affine_G.sh ${Path_g} ${Path_r}
if [ $? -eq 0 ]; then
	echo "====Build uboot ok!===="
else
	echo "====Build uboot failed!===="
	exit 1
fi

# Run Crop eyes.
matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; red_flag = $Red_flag; eyes_crop_run; quit"

# Run Nonrigid registration using Ants for eyes_crop_mean_template.
bash regist_nonrigid.sh ${Path_g}
if [ $? -eq 0 ]; then
	echo "====Build uboot ok!===="
else
	echo "====Build uboot failed!===="
	exit 1
fi

# Run demons registration.
matlab -nodesktop -nosplash -r "path_g = '${Path_g}'; path_r = '${Path_r}'; flag = $Red_flag; demonsRegist_run_G; quit"

# Bad image interpolation.
# matlab -batch interp_run