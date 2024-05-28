#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# Set path parameters.
path_g=$1
path_r=$2
red_flag=$3
fix_flag=$4
num=$5
red_have=$6

red_path=${path_r}/Red_Crop
template_path=${path_g}/../template
back_up_affine_path=${template_path}/../back_up/Affine

if [ $fix_flag -eq 1 ]; then
    green_path=${path_g}/Green_Crop
else
    green_path=${path_g}/Green_Crop/G2R
fi

##### Regist to mean template.
# Set the output green chanel image directory path that is registered.
regist_red_path=${path_r}/Red_Registration
regist_green_path=${path_g}/Green_Registration

# Set the mean template path.
mean_template=${template_path}/mean_template.nii
# file_name=$(ls ${green_path}/Green_Crop_*.nii);
# file_name=(${file_name//,/ });

## Set function for affine registration.
process_frame() {
    start_time=$(date +%s)
    local k=$1
    # local j=$1
    # name_num=$(basename -s .nii ${file_name[$j]})
    # k=${name_num:9}

    if [ $red_flag -eq 0 ]; then

        # Initialize affine matrix.
        cmtk make_initial_affine --centers-of-mass $mean_template ${green_path}/Green_Crop_${k}.nii ${green_path}/initial${k}.xform
        # Generate affine matrix.
        cmtk registration --initial ${green_path}/initial${k}.xform --dofs 6,12 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_affine_path}/affine${k}.xform $mean_template ${green_path}/Green_Crop_${k}.nii
    
    else

        # Initialize affine matrix.
        cmtk make_initial_affine --centers-of-mass $mean_template ${red_path}/Red_Crop_${k}.nii ${red_path}/initial${k}.xform
        # Generate affine matrix.
        cmtk registration --initial ${red_path}/initial${k}.xform --dofs 6,12 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_affine_path}/affine${k}.xform $mean_template ${red_path}/Red_Crop_${k}.nii
        echo "$k"
    fi

    # Apply affine matrix to the red channel.
    if [ $red_have -eq 1 ]; then
        cmtk reformatx -o ${regist_red_path}/Red_Affine_${k}.nii --floating ${red_path}/Red_Crop_${k}.nii $mean_template ${back_up_affine_path}/affine${k}.xform
    fi
    
    # Apply affine matrix to the green channel.
    if [ $fix_flag -eq 1 ]; then
        cmtk reformatx -o ${regist_green_path}/Green_Affine_${k}.nii --floating ${green_path}/Green_Crop_${k}.nii $mean_template ${back_up_affine_path}/affine${k}.xform
    else
        cmtk reformatx -o ${regist_green_path}/Green_Affine_${k}.nii --floating ${green_path}/Green_Crop_G2R_${k}.nii $mean_template ${back_up_affine_path}/affine${k}.xform
    fi
    
    end_time=$(date +%s)
    cost_time=$((end_time - start_time))
    echo "$k: Reg & Warp time is $((cost_time/60))min $((cost_time%60))s"
}

# Run affine registration.
process_frame $num
