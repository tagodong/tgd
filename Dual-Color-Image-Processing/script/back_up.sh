#!/bin/bash

file_path='/home/d1/fix'
new_file_path='/home/d1/kexin_raphe/fix'

file_name=$(ls $file_path);
file_name=(${file_name//,/ });
for ((i=0;i<${#file_name[*]};i=i+1))
do

    file_dir='.'
    old_folder=${file_name[$i]}
    new_folder=$old_folder

    mkdir $new_file_path/$file_dir/$new_folder
    mkdir $new_file_path/$file_dir/$new_folder/g
    mkdir $new_file_path/$file_dir/$new_folder/r
    mkdir $new_file_path/$file_dir/$new_folder/g/dual_Crop
    mkdir $new_file_path/$file_dir/$new_folder/g/dual_MIPs
    mkdir $new_file_path/$file_dir/$new_folder/g/regist_green
    mkdir $new_file_path/$file_dir/$new_folder/g/regist_green/green_demons
    mkdir $new_file_path/$file_dir/$new_folder/g/regist_green/green_demons_MIPs
    mkdir $new_file_path/$file_dir/$new_folder/g/template

    mv $file_path/$file_dir/$old_folder/CalTrace $new_file_path/$file_dir/$new_folder/CalTrace
    mv $file_path/$file_dir/$old_folder/CalTrace_Rect $new_file_path/$file_dir/$new_folder/CalTrace_Rect
    mv $file_path/$file_dir/$old_folder/g/dual_Crop/Green* $new_file_path/$file_dir/$new_folder/g/dual_Crop/
    mv $file_path/$file_dir/$old_folder/g/dual_MIPs/* $new_file_path/$file_dir/$new_folder/g/dual_MIPs/
    mv $file_path/$file_dir/$old_folder/g/regist_green/green_demons/*.mat $new_file_path/$file_dir/$new_folder/g/regist_green/green_demons/
    mv $file_path/$file_dir/$old_folder/g/regist_green/green_demons_MIPs/* $new_file_path/$file_dir/$new_folder/g/regist_green/green_demons_MIPs/
    mv $file_path/$file_dir/$old_folder/g/template/mean_template.nii $new_file_path/$file_dir/$new_folder/g/template/

    mkdir $new_file_path/$file_dir/$new_folder/r/dual_Crop
    mkdir $new_file_path/$file_dir/$new_folder/r/dual_MIPs
    mkdir $new_file_path/$file_dir/$new_folder/r/regist_red
    mkdir $new_file_path/$file_dir/$new_folder/r/regist_red/red_demons
    mkdir $new_file_path/$file_dir/$new_folder/r/regist_red/red_demons_MIPs

    mv $file_path/$file_dir/$old_folder/r/dual_Crop/Red* $new_file_path/$file_dir/$new_folder/r/dual_Crop/
    mv $file_path/$file_dir/$old_folder/r/dual_MIPs/* $new_file_path/$file_dir/$new_folder/r/dual_MIPs/
    mv $file_path/$file_dir/$old_folder/r/regist_red/red_demons/*.mat $new_file_path/$file_dir/$new_folder/r/regist_red/red_demons/
    mv $file_path/$file_dir/$old_folder/r/regist_red/red_demons_MIPs/* $new_file_path/$file_dir/$new_folder/r/regist_red/red_demons_MIPs/

done
