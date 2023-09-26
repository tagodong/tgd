#!/bin/bash
export CMTK_WRITE_UNCOMPRESSED=1
redPath="/home/d1/221207/221207_28814/R/dual_Crop"
regist_red_path="/home/d1/221207/221207_28814/R/regist_red"
mkdir $regist_red_path
greenPath="/home/d1/221207/221207_28814/G/dual_Crop"
regist_green_path="/home/d1/221207/221207_28814/G/regist_green"
mkdir $regist_green_path
# zbbfish=${redPath}/Red8316.nii
zbbfish="/home/d1/atlas-zebrafish/Red17438.nii"
# zbbfish="/media/user/Fish-free2/221207_23dpf/R/atlas/mean_template_1.nii"

filename=$(ls $redPath/Red*.nii);
filename=(${filename//,/ });

for ((j=0;j<801;j=j+1))
do

    namenum=$(basename -s .nii ${filename[$j]});
    k=${namenum:3};

    start_time=$(date +%s)
    cmtk make_initial_affine --principal-axes $zbbfish ${redPath}/Red${k}.nii ${redPath}/initial${k}.xform

    cmtk registration --initial ${redPath}/initial${k}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${redPath}/affine${k}.xform $zbbfish ${redPath}/Red${k}.nii

    # cmtk reformatx -o ${redPath}/regist_red_1_${k}.nii --floating ${redPath}/Red${k}.nii $zbbfish ${redPath}/affine${k}.xform
    cmtk reformatx -o ${regist_green_path}/regist_green_1_${k}.nii --floating ${greenPath}/Green${k}.nii $zbbfish ${redPath}/affine${k}.xform
    cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${redPath}/Red${k}.nii $zbbfish ${redPath}/affine${k}.xform
    # cmtk reformatx -o ${regist_red_path}/template${k}.nii --floating ${redPath}/Red${k}.nii $zbbfish ${redPath}/affine${k}.xform

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $namenum
 
done

# cd /home/user/tgd/Calcium_extract_new/script
# matlab -batch regist_run