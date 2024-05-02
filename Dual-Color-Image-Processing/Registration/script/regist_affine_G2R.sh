#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# Set path parameters.
path_g=$1
path_r=$2
red_flag=$3
num=$4
red_path=${path_r}/Red_Crop
green_path=${path_g}/Green_Crop
template_path=${path_g}/../template
G2R_path=$green_path/G2R

green_path="/home/d2/Learn/0304/back_up/Green_Crop"

##### Regist to mean template.
# Set the output green chanel image directory path that is registered.

back_up_G2R_path=${template_path}/../back_up/G2R_Affine

## Set function for affine registration.
process_frame() {
    start_time=$(date +%s)
    local k=$1
    # local j=$1
    # name_num=$(basename -s .nii ${file_name[$j]})
    # k=${name_num:9}

    if [ $red_flag -eq 1 ]; then

        start_time=$(date +%s)
        # Initialize affine matrix.
        cmtk make_initial_affine --identity ${red_path}/Red_Crop_${k}.nii ${green_path}/Green_Crop_${k}.nii ${G2R_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${G2R_path}/initial${k}.xform --dofs 12 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_G2R_path}/affine${k}.xform ${red_path}/Red_Crop_${k}.nii ${green_path}/Green_Crop_${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${G2R_path}/Green_Crop_G2R_${k}.nii --floating ${green_path}/Green_Crop_${k}.nii ${red_path}/Red_Crop_${k}.nii ${back_up_G2R_path}/affine${k}.xform

    fi

    end_time=$(date +%s)
    cost_time=$((end_time - start_time))
    echo "$k: Reg & Warp time is $((cost_time/60))min $((cost_time%60))s"
}

# Run affine registration.
process_frame $num