#!/bin/bash
export CMTK_WRITE_UNCOMPRESSED=1
redPath_pre="/home/d2/20230416_1744_g8s-lssm-chriR_5dpf"
greenPath_pre="/home/d2/20230416_1744_g8s-lssm-chriR_5dpf"
# zbbfish="/home/d2/Ref-zbb2.nii"

for ((j=1;j<=2;j=j+1))
do
    redPath=${redPath_pre}/r0$j/dual_Crop
    registPath=${redPath_pre}/r0$j/regist_red
    zbbfish=$registPath/mean_template_1.nii
    # mkdir $registPath
    green_registPath=${greenPath_pre}/g0$j/regist_green
    # mkdir $green_registPath
    greenPath=${greenPath_pre}/g0$j/dual_Crop
    len=$(ls -l $redPath/Red*.nii | grep "^-" | wc -l)
    filename=$(ls $redPath/Red*.nii);
    filename=(${filename//,/ });

    for ((k=0;k<len;k=k+1))
    do
        # i=$((($j-56)*255+$k))
        namenum=$(basename -s .nii ${filename[$k]});
        i=${namenum:3};
        # if [ -e ${registPath}/regist_red_1_${i}.nii ];
        # then
        #     continue
        # fi
        start_time=$(date +%s)
        cmtk make_initial_affine --principal-axes $zbbfish ${redPath}/Red${i}.nii ${redPath}/initial${i}.xform

        cmtk registration --initial ${redPath}/initial${i}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${redPath}/affine${i}.xform $zbbfish ${redPath}/Red${i}.nii

        cmtk reformatx -o ${green_registPath}/regist_green_1_${i}.nii --floating ${greenPath}/Green${i}.nii $zbbfish ${redPath}/affine${i}.xform
        cmtk reformatx -o ${registPath}/regist_red_1_${i}.nii --floating ${redPath}/Red${i}.nii $zbbfish ${redPath}/affine${i}.xform
        
        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo "$redPath/Red${i}.nii done."

    done
 
done

cd /home/user/tgd/Calcium_extract_new/script
matlab -batch regist_run