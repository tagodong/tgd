#!/bin/bash

template_path='/home/d2/Recon/motor/template'
mean_template=$template_path/Green_affine_mean_template.nii
zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"

start_time=$(date +%s)

antsRegistration -d 3 --float 1 -o [${template_path}/zbb_Ants_,${template_path}/zbb_SyN.nii.gz] -n WelchWindowedSinc -u 0 -r [$mean_template,$zbbfish,1] \
-t Rigid[0.1] -m MI[$mean_template,$zbbfish,1,32,Regular,0.25] -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1vox \
-t Affine[0.1] -m MI[$mean_template,$zbbfish,1,32,Regular,0.25] -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1vox \
-t SyN[0.05,6,0.5] -m CC[$mean_template,$zbbfish,1,2] -c [200x200x200x10,1e-7,10] -f 8x4x2x1 -s 3x2x1x0vox

end_time=$(date +%s)
cost_time=$[ $end_time-$start_time ]
echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
echo $name_num

