#!/bin/bash

## Transform meantemplate to atlas.
file_dir='/home/d1/blueLaser'
red_flag=1
start_num=(324 324 324 324)
end_num=(1199 1199 1199 1199)

zbb_atlas="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"

file_name=$(ls $file_dir);
file_name=(${file_name//,/ });
for ((i=1;i<${#file_name[*]};i=i+1))
do

    regist_out_path=$file_dir/${file_name[$i]}/regist2atlas
    mkdir $regist_out_path
    if [ $red_flag -eq 1 ];then
        mean_template=$file_dir/${file_name[$i]}/r/template/mean_template.nii
    else
        mean_template=$file_dir/${file_name[$i]}/g/template/mean_template.nii
    fi

    cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script
    matlab -nodesktop -nosplash -r "input = '${mean_template}'; output = '${mean_template}'; myunshort; quit"

    ##### Run registration for mean-template to atlas.
    start_time=$(date +%s)

    antsRegistration -d 3 --float 1 -o [${regist_out_path}/mean2atlas_,${regist_out_path}/mean2atlas_warped.nii.gz] -n WelchWindowedSinc \
    -u 0 -r [$zbb_atlas,$mean_template,1] -t Rigid[0.1] -m MI[$zbb_atlas,$mean_template,1,32,Regular,0.25] \
    -c [200x200x0,1e-8,10] -f 8x4x2 -s 3x2x1vox -t Affine[0.1] -m MI[$zbb_atlas,$mean_template,1,32,Regular,0.25] \
    -c [200x200x0,1e-8,10] -f 8x4x2 -s 3x2x1vox -t SyN[0.05,6,0.5] -m CC[$zbb_atlas,$mean_template,1,2] -c [200x200x200x10,1e-7,10] \
    -f 8x4x2x1 -s 3x2x1x0vox

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Transform was estimated and the time is $(($cost_time/60))min $(($cost_time%60))s"

    ##### Apply the transformation to all frames.
    path_g=$file_dir/${file_name[$i]}/g/regist_green/green_demons
    path_r=$file_dir/${file_name[$i]}/r/regist_red/red_demons

    cd /home/user/tgd/Dual-Color-Image-Processing/function
    matlab -nodesktop -nosplash -r "file_path = '$path_g'; prefix_name = 'demons_green_3_'; red_flag = 0; mat2Nii(file_path,prefix_name,red_flag); quit"
    matlab -nodesktop -nosplash -r "file_path = '$path_r'; prefix_name = 'demons_red_3_'; red_flag = 1; mat2Nii(file_path,prefix_name,red_flag); quit"

    path_ants_g=$regist_out_path/g
    path_ants_r=$regist_out_path/r
    mkdir $path_ants_g
    mkdir $path_ants_r

    for ((j=${start_num[i]};j<${end_num[i]};j=j+1))
    do

        start_time=$(date +%s)

        antsApplyTransforms -d 3 -v 0 --float 1 -n WelchWindowedSinc -i $path_g/nii/demons_green_3_$j.nii -r $zbb_atlas -o $path_ants_g/ants_g_$j.nii -t $regist_out_path/mean2atlas_1Warp.nii.gz -t $regist_out_path/mean2atlas_0GenericAffine.mat

        antsApplyTransforms -d 3 -v 0 --float 1 -n WelchWindowedSinc -i $path_r/nii/demons_red_3_$j.nii -r $zbb_atlas -o $path_ants_r/ants_r_$j.nii -t $regist_out_path/mean2atlas_1Warp.nii.gz -t $regist_out_path/mean2atlas_0GenericAffine.mat

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Frame $j has applied and the time is $(($cost_time/60))min $(($cost_time%60))s"

    done
    
    ## Extract the trace for rect mode.
    cd /home/user/tgd/Dual-Color-Image-Processing/Segmentation-Extraction/
    matlab -nodesktop -nosplash -r "adpath; file_dir = '$file_dir/${file_name[$i]}'; calExtract_rect; quit"

done
