#!/bin/bash

file_path='/home/d1/kexin_raphe'
file_dir='20230809_1529_g8s-lssm-none_8dpf-fix'
motor='fix'
motor1='fix1'

mkdir $file_path/$file_dir/$motor
mkdir $file_path/$file_dir/$motor/g
mkdir $file_path/$file_dir/$motor/r
mkdir $file_path/$file_dir/$motor/g/dual_Crop
mkdir $file_path/$file_dir/$motor/g/dual_MIPs
mkdir $file_path/$file_dir/$motor/g/regist_green
mkdir $file_path/$file_dir/$motor/g/regist_green/green_demons
mkdir $file_path/$file_dir/$motor/g/regist_green/green_demons_MIPs
mkdir $file_path/$file_dir/$motor/g/template

mv $file_path/$file_dir/$motor1/CalTrace $file_path/$file_dir/$motor/CalTrace
mv $file_path/$file_dir/$motor1/g/dual_Crop/Green* $file_path/$file_dir/$motor/g/dual_Crop/
mv $file_path/$file_dir/$motor1/g/dual_MIPs/* $file_path/$file_dir/$motor/g/dual_MIPs/
mv $file_path/$file_dir/$motor1/g/regist_green/green_demons/* $file_path/$file_dir/$motor/g/regist_green/green_demons/
mv $file_path/$file_dir/$motor1/g/regist_green/green_demons_MIPs/* $file_path/$file_dir/$motor/g/regist_green/green_demons_MIPs/
mv $file_path/$file_dir/$motor1/g/template/mean_template.nii $file_path/$file_dir/$motor/g/template/

mkdir $file_path/$file_dir/$motor/r/dual_Crop
mkdir $file_path/$file_dir/$motor/r/dual_MIPs
mkdir $file_path/$file_dir/$motor/r/regist_red
mkdir $file_path/$file_dir/$motor/r/regist_red/red_demons
mkdir $file_path/$file_dir/$motor/r/regist_red/red_demons_MIPs

mv $file_path/$file_dir/$motor1/r/dual_Crop/Red* $file_path/$file_dir/$motor/r/dual_Crop/
mv $file_path/$file_dir/$motor1/r/dual_MIPs/* $file_path/$file_dir/$motor/r/dual_MIPs/
mv $file_path/$file_dir/$motor1/r/regist_red/red_demons/* $file_path/$file_dir/$motor/r/regist_red/red_demons/
mv $file_path/$file_dir/$motor1/r/regist_red/red_demons_MIPs/* $file_path/$file_dir/$motor/r/regist_red/red_demons_MIPs/