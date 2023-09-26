#!/bin/bash
export CMTK_WRITE_UNCOMPRESSED=1
redPath="/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/r/01/dual_Crop/"
regist_red_path="/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/r/01/regist_red"
mkdir $regist_red_path

greenPath="/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/g/01/dual_Crop"
regist_green_path="/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/g/01/regist_green"
mkdir $regist_green_path

# zbbfish=${redPath}/Red8316.nii
# zbbfish_Red="/home/d1/atlas-zebrafish/Red17438.nii"
# zbbfish_Green=$zbbfish_Red
# zbbfish_Green="/home/d1/atlas-zebrafish/Green17438.nii"
# zbbfish_Red="/home/d1/atlas-zebrafish/Ref-zbb2.nii"
zbbfish_Red="/home/d1/g8s_lss-huc-chri_8dpf_2023-05-20_11-36-16/r/regist_red_1_8210.nii"

filename=$(ls $redPath/Red*.nii);
filename=(${filename//,/ });
len=$(ls -l $redPath/Red*.nii | grep "^-" | wc -l);

for ((j=0;j<$len;j=j+1))
do

    namenum=$(basename -s .nii ${filename[$j]});
    k=${namenum:3};

    start_time=$(date +%s)
    cmtk make_initial_affine --principal-axes $zbbfish_Red ${redPath}/Red${k}.nii ${redPath}/initial${k}.xform
    # cmtk make_initial_affine --principal-axes $zbbfish_Green ${greenPath}/Green${k}.nii ${greenPath}/initial${k}.xform

    cmtk registration --initial ${redPath}/initial${k}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${redPath}/affine${k}.xform $zbbfish_Red ${redPath}/Red${k}.nii
    # cmtk registration --initial ${greenPath}/initial${k}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o ${greenPath}/affine${k}.xform $zbbfish_Green ${greenPath}/Green${k}.nii

    # cmtk reformatx -o ${redPath}/regist_red_1_${k}.nii --floating ${redPath}/Red${k}.nii $zbbfish ${redPath}/affine${k}.xform
    cmtk reformatx -o ${regist_green_path}/regist_green_1_${k}.nii --floating ${greenPath}/Green${k}.nii $zbbfish_Red ${redPath}/affine${k}.xform
    cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${redPath}/Red${k}.nii $zbbfish_Red ${redPath}/affine${k}.xform
    # cmtk reformatx -o ${regist_red_path}/template${k}.nii --floating ${redPath}/Red${k}.nii $zbbfish ${redPath}/affine${k}.xform

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $namenum
 
done

cd /home/user/tgd/Calcium_extract_new/script
matlab -batch regist_run