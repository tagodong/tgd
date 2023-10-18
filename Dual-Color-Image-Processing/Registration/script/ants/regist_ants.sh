#!/bin/bash
# Run affine transformation according to atlas using CMTK.
# export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=20

for ((j=3;j<=3;j++))
do

    # Set the red chanel image directory path that is needed to register.
    # path_r="/home/d1/HC_atlas_test"
    # red_path=${path_r}/seizure_con_r
    red_out_path="/home/d1/HC_atlas_test/ants"
    mkdir ${red_out_path}
    move_fish="/home/d1/atlas-zebrafish/Ref-zbb2.nii"

    # Set the atlas path.
    # zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb1.nii"
    # zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/HC_atlas_final.nii"
    # zbbfish="/home/d1/atlas-zebrafish/HC_atlas_final.nii"
    zbbfish="/home/d1/20230808_1534_g8s-lssm-none_7dpf-fix/fix/g/template/mean_template.nii"
    # Read the red images.
    # file_name=$(ls $red_path/Red*.nii);
    # file_name=(${file_name//,/ });
    # len=$(ls -l $red_path/Red*.nii | grep "^-" | wc -l);

    # Set the template step (recommend 100).
    step_size=4

    for ((i=0;i<1;i=i+${step_size}))
    do
        # name_num=$(basename -s .nii ${file_name[$i]});

        # Set k to the number of the name.
        # k=${name_num:3};

        start_time=$(date +%s)

        # Initialize affine matrix.

        antsRegistration -d 3 --float 1 -o [${red_out_path}/Rigid${k}_,${red_out_path}/zbb_Rigid${k}.nii.gz] \
        -t Rigid[0.1] -m GC[$zbbfish,$move_fish,1,32,Regular,0.25]  \
        -c [200x200x200x10,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

        antsRegistration -d 3 --float 1 -o [${red_out_path}/Affine${k}_,${red_out_path}/zbb_Affine${k}.nii.gz] \
        -t Affine[0.1] -m GC[$zbbfish,${red_out_path}/zbb_Rigid${k}.nii.gz,1,32,Regular,0.25]  \
        -c [200x200x200x10,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

        antsRegistration -d 3 --float 1 -o [${red_out_path}/SyN${k}_,${red_out_path}/G_SyN${k}.nii.gz] \
        -t SyN[0.05,6,0.5] -m CC[$zbbfish,${red_out_path}/zbb_Affine${k}.nii.gz,1,2]  \
        -c [200x200x200x200x10,1e-7,10] -f 12x8x4x2x1 -s 4x3x2x1x0

        # Apply to red.
        # antsApplyTransforms -d 3 --float 1 -n BSpline -i ${red_out_path}/zbb_Affine${k}.nii.gz -o ${red_out_path}/my_warp_shell_2${k}.nii.gz \
        # -r $zbbfish -t ${red_out_path}/SyN_0Warp.nii.gz -t ${red_out_path}/SyN_0InverseWarp.nii.gz

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num
    
    done

done