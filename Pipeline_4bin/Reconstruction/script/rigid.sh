#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# # Set path parameters.
path_g=$1
path_r=$2
k=$3
red_flag=$4

# Initialize path parameters.
zbbfish="/home/d1/230618-01/free/g/Rigid_Green3119.nii"

###### Run rigid registration to zbb.
green_path=$path_g/recon_mat
red_path=$path_r/recon_mat
green_path_rigid=$green_path/rigid
red_path_rigid=$red_path/rigid
# mkdir $green_path_rigid
# mkdir $red_path_reigid
if [[ $red_flag -eq 1 ]]; then

    # file_name=$(ls $red_path/Red*.nii);
    # file_name=(${file_name//,/ });
    # len=$(ls -l ${red_path}/Red*.nii | grep "^-" | wc -l);

    # for ((i=0;i<$len;i=i+1))
    # do
    #     name_num=$(basename -s .nii ${file_name[$i]});
        
    #     # Set k to the number of the name.
    #     k=${name_num:3};

        start_time=$(date +%s)
        # Initialize rigid matrix.
        cmtk make_initial_affine --principal-axes $zbbfish ${red_path}/Red${k}.nii ${red_path}/initial${k}.xform
        
        # Generate rigid matrix.
        cmtk registration --initial ${red_path}/initial${k}.xform --dofs 6,6 --exploration 8 --accuracy 0.05 --cr -o ${red_path}/affine${k}.xform $zbbfish ${red_path}/Red${k}.nii

        # Apply rigid matrix.
        cmtk reformatx -o ${red_path_rigid}/Rigid_Red${k}.nii --floating ${red_path}/Red${k}.nii $zbbfish ${red_path}/affine${k}.xform
        cmtk reformatx -o ${green_path_rigid}/Rigid_Green${k}.nii --floating ${green_path}/Green${k}.nii $zbbfish ${red_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num

    # done
else
    # file_name=$(ls $green_path/Green*.nii);
    # file_name=(${file_name//,/ });
    # len=$(ls -l ${green_path}/Green*.nii | grep "^-" | wc -l);

    # for ((i=0;i<$len;i=i+1))
    # do
    #     name_num=$(basename -s .nii ${file_name[$i]});
        
    #     # Set k to the number of the name.
    #     k=${name_num:5};

        start_time=$(date +%s)
        # Initialize rigid matrix.
        cmtk make_initial_affine --principal-axes $zbbfish ${green_path}/Green${k}.nii ${green_path}/initial${k}.xform
        
        # Generate rigid matrix.
        cmtk registration --initial ${green_path}/initial${k}.xform --dofs 6,6 --exploration 8 --accuracy 0.05 --cr -o ${green_path}/affine${k}.xform $zbbfish ${green_path}/Green${k}.nii

        # Apply rigid matrix.
        cmtk reformatx -o ${red_path_rigid}/Rigid_Red${k}.nii --floating ${red_path}/Red${k}.nii $zbbfish ${green_path}/affine${k}.xform
        cmtk reformatx -o ${green_path_rigid}/Rigid_Green${k}.nii --floating ${green_path}/Green${k}.nii $zbbfish ${green_path}/affine${k}.xform


        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num

    # done
fi