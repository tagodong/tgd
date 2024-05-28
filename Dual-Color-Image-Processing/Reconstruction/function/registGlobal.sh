#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# Set path parameters.
green_path=$1
red_path=$2
red_flag=$3
global_number=$4
zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"
back_up_path=$red_path/../back_up/Parameters

### Regist global frame to zbb.
if [ $red_flag -eq 1 ]; then
    # Initialize Rigid matrix.
    cmtk make_initial_affine --principal-axes ${zbbfish} ${red_path}/Rigid_pre/Red_Recon_${global_number}.nii ${back_up_path}/global_${global_number}.xform

    # Generate Rigid matrix.
    cmtk registration --initial ${back_up_path}/global_${global_number}.xform --dofs 6,6 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_path}/Global_${global_number}.xform ${zbbfish} ${red_path}/Rigid_pre/Red_Recon_${global_number}.nii

    # Apply the Rigid transform.
    cmtk reformatx -o ${red_path}/../Global_${global_number}.nii --floating ${red_path}/Rigid_pre/Red_Recon_${global_number}.nii ${zbbfish} ${back_up_path}/Global_${global_number}.xform
else
    # Initialize Rigid matrix.
    cmtk make_initial_affine --principal-axes ${zbbfish} ${green_path}/Rigid_pre/Green_Recon_${global_number}.nii ${back_up_path}/global_${global_number}.xform

    # Generate Rigid matrix.
    cmtk registration --initial ${back_up_path}/global_${global_number}.xform --dofs 6,6 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${back_up_path}/Global_${global_number}.xform ${zbbfish} ${green_path}/Rigid_pre/Green_Recon_${global_number}.nii

    # Apply the Rigid transform.
    cmtk reformatx -o ${green_path}/../Global_${global_number}.nii --floating ${green_path}/Rigid_pre/Green_Recon_${global_number}.nii ${zbbfish} ${back_up_path}/Global_${global_number}.xform
fi