#!/bin/bash

file_path='/home/d1/kexin_raphe/norm'

dir_name=$(ls $file_path);
dir_name=(${dir_name//,/ });
for ((i=0;i<${#dir_name[*]};i=i+1))
do

    file_name=$(ls $file_path/${dir_name[$i]}/*.7z);
    file_name=(${file_name//,/ });

    7z x ${file_name[0]} -r -o$file_path/${dir_name[$i]}/g
    mv $file_path/${dir_name[$i]}/g/g*/*/*.tif $file_path/${dir_name[$i]}/g/

    7z x ${file_name[1]} -r -o$file_path/${dir_name[$i]}/r
    mv $file_path/${dir_name[$i]}/r/raw/*.tif $file_path/${dir_name[$i]}/r/

done