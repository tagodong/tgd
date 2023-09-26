#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# # Set path parameters.
path_g=$1
path_r=$2
G2R_flag=$3

# red_path=${path_r}/dual_Crop
# green_path=${path_g}/dual_Crop
red_path=$path_r/regist_red
green_path=$path_g/regist_green

###### When Red is usful, Regist Green to Red.
if [ $G2R_flag -eq 1 ]; then

    file_name=$(ls $red_path/regist_red_1_*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${red_path}/regist_red_1_*.nii | grep "^-" | wc -l);

    for ((i=0;i<$len;i=i+1))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:13};

        FILE=$red_path/regist_red_2_$k.nii
        if test -f "$FILE"; then
            continue
        fi

        start_time=$(date +%s)
        # Initialize affine matrix.
        cmtk make_initial_affine --principal-axes ${green_path}/regist_green_1_${k}.nii ${red_path}/regist_red_1_${k}.nii ${red_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${red_path}/initial${k}.xform --dofs 6,12 --exploration 8 --accuracy 0.05 --cr -o ${red_path}/affine${k}.xform ${green_path}/regist_green_1_${k}.nii ${red_path}/regist_red_1_${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${red_path}/regist_red_2_${k}.nii --floating ${red_path}/regist_red_1_${k}.nii ${green_path}/regist_green_1_${k}.nii ${red_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num

    done
fi

