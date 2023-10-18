#!/bin/bash
export CMTK_WRITE_UNCOMPRESSED=1
redPath="/home/d1/kx221019/20230221_1019_g8s-lssm-tph2-chri_8dpf/recon2";
zbbfish="/home/d1/kx221019/regist/mean_template_3.nii";
subname=("02" "03" "04" "05" "06" "07" "08" "09");
write_path="/home/d1/kx221019/regist"
for i in ${subname[@]}
do
    currentpath=$redPath/$i;
    filepath=$currentpath/recon_newPSF/dual_Crop;
    filename=$(ls $filepath/Green*.nii);
    filename=(${filename//,/ });

    for j in ${filename[@]}
    do
        namenum=$(basename -s .nii $j);
        namenum=${namenum:5};
        currentfile=$j;

        start_time=$(date +%s)
 
        cmtk make_initial_affine --principal-axes $zbbfish $currentfile ${filepath}/initial${j}.xform

        cmtk registration --initial ${filepath}/initial${j}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${filepath}/affine${j}.xform $zbbfish $currentfile

        cmtk reformatx -o ${write_path}/regist_1_${namenum}.nii --floating $currentfile $zbbfish ${filepath}/affine${j}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $currentfile;

    done

done




