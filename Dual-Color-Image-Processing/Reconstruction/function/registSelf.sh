#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# Set path parameters.
green_path=$1
red_path=$2
red_flag=$3
red_have=$4
num=$5
global_number=$6
zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"
back_up_path=$red_path/../back_up/Parameters

### Regist to self.
start_time=$(date +%s)

if [ $red_flag -eq 1 ]; then
    # Initialize Rigid matrix.
    cmtk make_initial_affine --principal-axes ${red_path}/../Global_${global_number}.nii ${red_path}/Rigid_pre/Red_Recon_${num}.nii ${back_up_path}/Red_Rigid_initial_${num}.xform

    # Generate Rigid matrix.
    cmtk registration --initial ${back_up_path}/Red_Rigid_initial_${num}.xform --dofs 6,6 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_path}/Red_Rigid_${num}.xform ${red_path}/../Global_${global_number}.nii ${red_path}/Rigid_pre/Red_Recon_${num}.nii

    # Apply the Rigid transform.
    cmtk reformatx -o ${red_path}/Rigid_post/Red_Rigid_${num}.nii --floating ${red_path}/Rigid_pre/Red_Recon_${num}.nii ${red_path}/../Global_${global_number}.nii ${back_up_path}/Red_Rigid_${num}.xform
    cmtk reformatx -o ${green_path}/Rigid_post/Green_Rigid_${num}.nii --floating ${green_path}/Rigid_pre/Green_Recon_${num}.nii ${red_path}/../Global_${global_number}.nii ${back_up_path}/Red_Rigid_${num}.xform
else
    # Initialize Rigid matrix.
    cmtk make_initial_affine --principal-axes ${green_path}/../Global_${global_number}.nii ${green_path}/Rigid_pre/Green_Recon_${num}.nii ${back_up_path}/Green_Rigid_initial_${num}.xform

    # Generate Rigid matrix.
    cmtk registration --initial ${back_up_path}/Green_Rigid_initial_${num}.xform --dofs 6,6 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_path}/Green_Rigid_${num}.xform ${green_path}/../Global_${global_number}.nii ${green_path}/Rigid_pre/Green_Recon_${num}.nii

    # Apply the Rigid transform.
    if [ $red_have -eq 1 ]; then
        cmtk reformatx -o ${red_path}/Rigid_post/Red_Rigid_${num}.nii --floating ${red_path}/Rigid_pre/Red_Recon_${num}.nii ${green_path}/../Global_${global_number}.nii ${back_up_path}/Green_Rigid_${num}.xform
    fi
    
    cmtk reformatx -o ${green_path}/Rigid_post/Green_Rigid_${num}.nii --floating ${green_path}/Rigid_pre/Green_Recon_${num}.nii ${green_path}/../Global_${global_number}.nii ${back_up_path}/Green_Rigid_${num}.xform
fi

end_time=$(date +%s)
cost_time=$((end_time - start_time))
echo "$num: Reg & Warp time is $((cost_time/60))min $((cost_time%60))s"