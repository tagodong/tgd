#!/bin/bash

## Transform meantemplate to atlas.
file_dir='/home/d1/zezhen'
# red_flag=0

start_num=(0) # number of sort.
end_num=(3370)
step=1

file_name=$(ls $file_dir); 
file_name=(${file_name//,/ });

# ${#file_name[*]}
for ((i=0;i<1;i=i+1))
do
    regist_out_path=$file_dir/${file_name[$i]}/regist2atlas
    mkdir $regist_out_path
    # if [ $red_flag -eq 1 ];then
    #     mean_template=$file_dir/${file_name[$i]}/r/template/mean_template.nii
    # else
    #     mean_template=$file_dir/${file_name[$i]}/g/template/mean_template.nii
    # fi
    mean_template=$file_dir/${file_name[$i]}/back_up/template/mean_template.nii
    tar_mean_template=$file_dir/${file_name[$i]}/back_up/template/mean_template_exp.nii

    cd /home/user/tgd/Dual-Color-Image-Processing/Registration/script
    # matlab -nodesktop -nosplash -r "input = '${mean_template}'; output = '${mean_template}'; myunshort; quit"
    # matlab -nodesktop -nosplash -r "input = '${tar_mean_template}'; output = '${tar_mean_template}'; myunshort; quit"

    ##### Run registration for mean-template to atlas.
    start_time=$(date +%s)

    # antsRegistration -d 3 --float 1 -o [${regist_out_path}/mean2atlas_,${regist_out_path}/mean2atlas_warped.nii.gz] -n WelchWindowedSinc \
    # -u 0 -r [${tar_mean_template},$mean_template,1] -t Rigid[0.1] -m MI[${tar_mean_template},$mean_template,1,32,Regular,0.25] \
    # -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1vox -t Affine[0.1] -m MI[${tar_mean_template},$mean_template,1,32,Regular,0.25] \
    # -c [200x200x200x0,1e-8,10] -f 12x8x4x2 -s 4x3x2x1vox -t SyN[0.05,6,0.5] -m CC[${tar_mean_template},$mean_template,1,2] -c [200x200x200x200x10,1e-7,10] \
    # -f 12x8x4x2x1 -s 4x3x2x1x0vox

    # mv ${regist_out_path}/mean2atlas_warped.nii.gz $file_dir/${file_name[$i]}/back_up/template/

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Transform was estimated and the time is $(($cost_time/60))min $(($cost_time%60))s"

    ##### Apply the transformation to all frames.
    # path_g=$file_dir/${file_name[$i]}/g/regist_green/green_demons
    # path_r=$file_dir/${file_name[$i]}/r/regist_red/red_demons
    path_g=$file_dir/${file_name[$i]}/back_up/Green_Demons_old
    path_r=$file_dir/${file_name[$i]}/back_up/Red_Demons_old

    cd /home/user/tgd/Dual-Color-Image-Processing/function
    # matlab -nodesktop -nosplash -r "file_path = '$path_g'; prefix_name = 'demons_green_3_'; red_flag = 0; mat2Nii(file_path,prefix_name,red_flag); quit"
    # matlab -nodesktop -nosplash -r "file_path = '$path_r'; prefix_name = 'demons_red_3_'; red_flag = 1; mat2Nii(file_path,prefix_name,red_flag); quit"
    # matlab -nodesktop -nosplash -r "file_path = '$path_g'; prefix_name = 'Green_Demons_'; mat2nii(file_path,prefix_name); quit"
    # matlab -nodesktop -nosplash -r "file_path = '$path_r'; prefix_name = 'Red_Demons_'; mat2nii(file_path,prefix_name); quit"

    path_ants_g=$regist_out_path/g
    path_ants_r=$regist_out_path/r
    # mkdir $path_ants_g
    # mkdir $path_ants_r

    # files_name=$(ls ${path_g}/nii/Green_Demons_*.nii);
    # files_name=(${files_name//,/ });

    # for ((k=${start_num[$i]};k<${end_num[$i]};k=k+$step))
    # do

    #     start_time=$(date +%s)
    #     name_num=$(basename -s .nii ${files_name[$k]})
    #     j=${name_num:13}

    #     antsApplyTransforms -d 3 -v 0 --float 1 -n WelchWindowedSinc -i $path_g/nii/Green_Demons_$j.nii -r $tar_mean_template -o $path_ants_g/ants_g_$j.nii -t $regist_out_path/mean2atlas_1Warp.nii.gz -t $regist_out_path/mean2atlas_0GenericAffine.mat

    #     antsApplyTransforms -d 3 -v 0 --float 1 -n WelchWindowedSinc -i $path_r/nii/Red_Demons_$j.nii -r $tar_mean_template -o $path_ants_r/ants_r_$j.nii -t $regist_out_path/mean2atlas_1Warp.nii.gz -t $regist_out_path/mean2atlas_0GenericAffine.mat

    #     end_time=$(date +%s)
    #     cost_time=$[ $end_time-$start_time ]
    #     echo "Frame $j has applied and the time is $(($cost_time/60))min $(($cost_time%60))s"

    # done
    
    ## Transform the nii to mat.
    matlab -nodesktop -nosplash -r "file_path = '$path_ants_g'; save_path = '$path_g/../Green_Demons'; prefix_name_in = 'ants_g_'; prefix_name_out = 'Green_Demons_'; nii2mat(file_path,save_path,prefix_name_in,prefix_name_out); quit"
    matlab -nodesktop -nosplash -r "file_path = '$path_ants_r'; save_path = '$path_r/../Red_Demons'; prefix_name_in = 'ants_r_'; prefix_name_out = 'Red_Demons_'; nii2mat(file_path,save_path,prefix_name_in,prefix_name_out); quit"
    
    ## Extract the trace for rect mode.
    cd /home/user/tgd/Dual-Color-Image-Processing/Segmentation-Extraction/
    matlab -nodesktop -nosplash -r "adpath; file_dir = '$file_dir/${file_name[$i]}/back_up'; start_frame = 1; calExtract_demo; quit"

    rm -r ${path_g}/nii
    rm -r ${path_r}/nii

done
