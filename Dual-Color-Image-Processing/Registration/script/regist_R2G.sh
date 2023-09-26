#!/bin/bash
# Run affine transformation according to mean template using CMTK.

export CMTK_WRITE_UNCOMPRESSED=1

for ((j=1;j<=1;j++))
do
    # Set the red and green chanel image directory path that is needed to register.
    red_path="/home/d2/220608/r/new/recon_mat/nii2"
    green_path="/home/d2/220608/g/new/recon_mat/nii2"

    # Set the output green chanel image directory path that is registered.
    regist_red_path="/home/d2/220608/r/new/regist_red"
    mkdir $regist_red_path
    regist_green_path="/home/d2/220608/g/new/regist_green"
    mkdir $regist_green_path

    # Set the mean template path.
    # mean_template="/home/d2/motor/r20001_24000/template/mean_template.nii"

    # Read the images.
    file_name=$(ls $red_path/red_recon*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${red_path}/red_recon*.nii | grep "^-" | wc -l);
    # Set the step.
    step_size=1
    echo $red_path

    for ((i=0;i<$len;i=i+$step_size))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:9};

        start_time=$(date +%s)

        # Transform green to red.
        # Initialize affine matrix.
        cmtk make_initial_affine --principal-axes ${red_path}/red_recon${k}.nii ${green_path}/green_recon${k}.nii ${green_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${green_path}/initial${k}.xform --dofs 9,12 --exploration 8 --accuracy 0.05 --cr -o ${green_path}/affine${k}.xform ${red_path}/red_recon${k}.nii ${green_path}/green_recon${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${green_path}/green_recon_G2R${k}.nii --floating ${green_path}/green_recon${k}.nii ${red_path}/red_recon${k}.nii ${green_path}/affine${k}.xform


        # Initialize affine matrix.
        # cmtk make_initial_affine --principal-axes $mean_template ${red_path}/red_recon${k}.nii ${red_path}/initial${k}.xform
        
        # Generate affine matrix.
        # cmtk registration --initial ${red_path}/initial${k}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${red_path}/affine${k}.xform $mean_template ${red_path}/red_recon${k}.nii

        # Apply affine matrix.
        # cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${red_path}/red_recon${k}.nii $mean_template ${red_path}/affine${k}.xform
        # cmtk reformatx -o ${regist_green_path}/regist_green_2_${k}.nii --floating ${green_path}/green_recon_G2R${k}.nii $mean_template ${red_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num
    
    done

done
