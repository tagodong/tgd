#!/bin/bash

# Set path.
file_dir='/home/d1/fix'
file_name=$(ls $file_dir);
file_name=(${file_name//,/ });

for ((i=1;i<${#file_name[*]};i=i+1))
do
    # Uncompress the file.
    file_path=$(ls $file_dir/${file_name[$i]});
    file=(${file_path//,/ });

	Path_g=$file_dir/${file_name[$i]}/g
    7z x $file_dir/${file_name[$i]}/${file[0]} -o$Path_g

    Path_r=$file_dir/${file_name[$i]}/r 
    7z x $file_dir/${file_name[$i]}/${file[1]} -o$Path_r
	
    # Move the file and remove dir.
    mv $Path_g/*/*/*.tif $Path_g/
    rm -r $Path_g/g*

    mv $Path_r/*/*.tif $Path_r/
    rm -r $Path_r/r*

done