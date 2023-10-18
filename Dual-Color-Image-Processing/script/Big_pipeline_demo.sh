#!/bin/bash

# Set the path.
Path_g="/home/d1/learn_220608_g8s_lss_14dpf/g/nii"
Path_r="/home/d1/learn_220608_g8s_lss_14dpf/r/nii"
Red_flag=2

# # Run the registration pepline.
# # Run reconstruction.
# cd /home/user/tgd/Dual-Color-Image-Processing/Reconstruction/script/
# matlab -nodesktop -nosplash -r "path_g = '$Path_g'; path_r = '$Path_r'; red_flag = $Red_flag; start_num = 325; end_num = 1200; x_shift = 80; recon_demo; quit"

# # Find candidate templates.
cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script/
# len=$(ls -l $Path_r/dual_Crop/Red*.nii | grep "^-" | wc -l);
# matlab -nodesktop -nosplash -r "file_path = '$Path_r'; red_flag = $Red_flag; inter_step = $len; canTemplateFind_run; quit"

# Run Affine Registration.
bash regist_affine_big.sh ${Path_g} ${Path_r}
if [ $? -eq 0 ]; then
	echo "====Build uboot ok!===="
else
	echo "====Build uboot failed!===="
	exit 1
fi

# Run nonrigid Registration.
bash regist_nonrigid_mask.sh ${Path_r}
if [ $? -eq 0 ]; then
	echo "====Build uboot ok!===="
else
	echo "====Build uboot failed!===="
	exit 1
fi

# Run Crop eyes.
Mask_path=${Path_r}/template/mean_template_SyN.nii.gz
matlab -nodesktop -nosplash -r "path_g = '$Path_g'; path_r = '$Path_r'; red_flag = $Red_flag; Mask_path = '$Mask_path'; eyes_crop_run; quit"

# Run demons registration.
matlab -nodesktop -nosplash -r "path_g = '$Path_g'; path_r = '$Path_r'; flag = $Red_flag; demonsRegist_run_G; quit"

# Bad image interpolation.
# matlab -batch interp_run