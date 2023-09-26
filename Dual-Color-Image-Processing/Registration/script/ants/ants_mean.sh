#!/bin/bash
# Run affine transformation according to mean template using CMTK.

export CMTK_WRITE_UNCOMPRESSED=1

for ((j=1;j<=1;j++))
do
    # Set the red and green chanel image directory path that is needed to register.
    path_g="/home/d1/20230620_1607_g8s-lssm-tph2-chri_11dpf_fix/fix/g"
    path_r="/home/d1/20230620_1607_g8s-lssm-tph2-chri_11dpf_fix/fix/r"
    red_path=${path_r}/dual_Crop
    green_path=${path_g}/dual_Crop

    # Set the output green chanel image directory path that is registered.
    regist_red_path=${path_r}/regist_red
    mkdir $regist_red_path
    regist_green_path=${path_g}/regist_green
    mkdir $regist_green_path

    # Set the mean template path.
    mean_template=${path_g}/template/mean_template.nii

    # Read the images.
    file_name=$(ls $green_path/Green*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${green_path}/Green*.nii | grep "^-" | wc -l);
    # Set the step.
    step_size=1
    echo $green_path

    for ((i=0;i<$len;i=i+$step_size))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:5};

        start_time=$(date +%s)

        # Run Rigid transformation.
        antsRegistration -d 3 --float 1 -n BSpline -o ${green_path}/Rigid${k}_ \
        -t Rigid[0.1] -m GC[$mean_template,${green_path}/Green${k}.nii,1,32,Regular,0.25] \
        -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

        # Apply to red.
        antsApplyTransforms -d 3 --float 1 -u short -n BSpline -i ${green_path}/Green${k}.nii -o ${green_path}/G_Rigid${k}.nii.gz \
        -r $mean_template -t ${green_path}/Rigid${k}_0GenericAffine.mat 

        # Apply to green.
        antsApplyTransforms -d 3 --float 1 -u short -n BSpline -i ${red_path}/Red${k}.nii -o ${red_path}/R_Rigid${k}.nii.gz \
        -r $mean_template -t ${green_path}/Rigid${k}_0GenericAffine.mat 

        # Run Affine transformation.
        antsRegistration -d 3 --float 1 -n BSpline -o ${green_path}/Affine${k}_ \
        -t Affine[0.1] -m GC[$mean_template,${green_path}/G_Rigid${k}.nii.gz,1,32,Regular,0.25] \
        -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1
        
        # Apply to red.
        antsApplyTransforms -d 3 --float 1 -u short -n BSpline -i ${red_path}/R_Rigid${k}.nii.gz -o ${regist_red_path}/regist_red_1_${k}.nii.gz \
        -r $mean_template -t ${green_path}/Affine${k}_0GenericAffine.mat

        # Apply to green.
        antsApplyTransforms -d 3 --float 1 -u short -n BSpline -i ${green_path}/G_Rigid${k}.nii.gz -o ${regist_green_path}/regist_green_1_${k}.nii.gz \
        -r $mean_template -t ${green_path}/Affine${k}_0GenericAffine.mat 

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num
    
    done

done
