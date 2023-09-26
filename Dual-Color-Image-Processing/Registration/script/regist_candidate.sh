#!/bin/bash
# Run Registration for candidate templates.

export CMTK_WRITE_UNCOMPRESSED=1

# Set path parameters.
path_g=$1
path_r=$2
red_flag=$3
red_path=${path_r}/dual_Crop
green_path=${path_g}/dual_Crop

if [ $red_flag -eq 0 ]; then
    template_path=${path_g}/template
else
    template_path=${path_r}/template
    Green_template_path=${path_r}/template/Green_template
    mkdir ${Green_template_path}
fi

# Initialize path parameters.
zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"

###### When Red is usful, Regist Green to Red.
if [ $red_flag -eq 1 ]; then

    G2R_path=$green_path/G2R
    mkdir ${G2R_path}
    file_name=$(ls $green_path/Green*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${green_path}/Green*.nii | grep "^-" | wc -l);

    for ((i=0;i<$len;i=i+1))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:5};

        start_time=$(date +%s)
        # Initialize affine matrix.
        cmtk make_initial_affine --principal-axes ${red_path}/Red${k}.nii ${green_path}/Green${k}.nii ${G2R_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${G2R_path}/initial${k}.xform --dofs 6,12 --exploration 8 --accuracy 0.05 --cr -o ${G2R_path}/affine${k}.xform ${red_path}/Red${k}.nii ${green_path}/Green${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${G2R_path}/Green_G2R${k}.nii --floating ${green_path}/Green${k}.nii ${red_path}/Red${k}.nii ${G2R_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num

    done
fi


###### Regist best candidate template.
# Initialize affine matrix.
cmtk make_initial_affine --principal-axes $zbbfish ${template_path}/Best_Can_template.nii ${template_path}/Best_initial.xform

# Generate affine matrix.
cmtk registration --initial ${template_path}/Best_initial.xform --dofs 6,6 --exploration 6 -f 0.1 -s 0.25 --accuracy 0.01 --cr -o ${template_path}/Best_affine.xform $zbbfish ${template_path}/Best_Can_template.nii

# Apply affine matrix.
cmtk reformatx -o ${template_path}/Best_mean_template.nii --floating ${template_path}/Best_Can_template.nii $zbbfish ${template_path}/Best_affine.xform

###### Regist candidate templates.
# Read the red images.
Affine_template_path=${template_path}/affine_template
file_name=$(ls $template_path/Can_template*.nii);
file_name=(${file_name//,/ });
len=$(ls -l $template_path/Can_template*.nii | grep "^-" | wc -l);

# Run affine registration.
for ((i=0;i<$len;i=i+1))
do
    name_num=$(basename -s .nii ${file_name[$i]});

    # Set k to the number of the name.
    k=${name_num:12};

    start_time=$(date +%s)

    # Initialize affine matrix.
    cmtk make_initial_affine --principal-axes ${template_path}/Best_mean_template.nii ${template_path}/Can_template${k}.nii ${Affine_template_path}/initial${k}.xform
    
    # Generate affine matrix.
    cmtk registration --initial ${Affine_template_path}/initial${k}.xform --dofs 6,12 --exploration 6 -f 0.1 -s 0.25 --accuracy 0.01 --cr -o ${Affine_template_path}/affine${k}.xform ${template_path}/Best_mean_template.nii ${template_path}/Can_template${k}.nii

    # Apply affine matrix.
    cmtk reformatx -o ${Affine_template_path}/Can_template_affine${k}.nii --floating ${template_path}/Can_template${k}.nii ${template_path}/Best_mean_template.nii ${Affine_template_path}/affine${k}.xform

    # Regist Green which was used for crop eyes.
    if [ $red_flag -eq 1 ]; then
        cmtk reformatx -o ${Green_template_path}/Green_Can_template_affine${k}.nii --floating ${G2R_path}/Green_G2R${k}.nii ${template_path}/Best_mean_template.nii ${Affine_template_path}/affine${k}.xform
    fi

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $name_num

done

###### Average all the candidate templates.
cmtk average_images --avg --outfile-name ${template_path}/affine_mean_template.nii ${Affine_template_path}/Can_template_affine*.nii
mean_template=${template_path}/affine_mean_template.nii
if [ $red_flag -eq 1 ]; then
    cmtk average_images --avg --outfile-name ${template_path}/Green_affine_mean_template.nii ${Green_template_path}/Green_Can_template_affine*.nii
    mean_template=${template_path}/Green_affine_mean_template.nii
fi
matlab -nodesktop -nosplash -r "input = '${mean_template}'; output = '${mean_template}'; myushort; quit"

##### Run inverse nonrigid registration to make crop-eyes-MASK.
start_time=$(date +%s)

antsRegistration -d 3 --float 1 -o [${template_path}/Rigid_,${template_path}/zbb_Rigid.nii.gz] \
-t Rigid[0.1] -m GC[$mean_template,$zbbfish,1,32,Regular,0.25]  \
-c [200x200x200x100,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

antsRegistration -d 3 --float 1 -o [${template_path}/Affine_,${template_path}/zbb_Affine.nii.gz] \
-t Affine[0.1] -m GC[$mean_template,${template_path}/zbb_Rigid.nii.gz,1,32,Regular,0.25]  \
-c [200x200x200x100,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

antsRegistration -d 3 --float 1 -o [${template_path}/SyN_,${template_path}/zbb_SyN.nii.gz] \
-t SyN[0.05,6,0.5] -m CC[$mean_template,${template_path}/zbb_Affine.nii.gz,1,2]  \
-c [200x200x200x200x10,1e-7,10] -f 12x8x4x2x1 -s 4x3x2x1x0

end_time=$(date +%s)
cost_time=$[ $end_time-$start_time ]
echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
echo $name_num

###### Crop eyes.
matlab -nodesktop -nosplash -r "template_path = '${template_path}'; eyes_crop_template_run; quit"

# Run demons registration.
matlab -nodesktop -nosplash -r "template_path = '${template_path}'; demonsRegistTemplate_run; quit"

###### Average all the candidate templates.
cmtk average_images --avg --outfile-name ${template_path}/mean_template.nii ${template_path}/template_demons/template_demons*.nii

##### Regist to mean template.
red_path=${path_r}/dual_Crop
if [ $red_flag -eq 1 ]; then
    green_path=${G2R_path}
else
    green_path=${path_g}/dual_Crop
fi

# Set the output green chanel image directory path that is registered.
regist_red_path=${path_r}/regist_red
mkdir $regist_red_path
regist_green_path=${path_g}/regist_green
mkdir $regist_green_path

# Set the mean template path.
mean_template=${template_path}/mean_template.nii

# Set the output green chanel image directory path that is registered.
regist_red_path=${path_r}/regist_red
mkdir $regist_red_path
regist_green_path=${path_g}/regist_green
mkdir $regist_green_path

# Run affine registration.
red_path=${path_r}/dual_Crop
if [ $red_flag -eq 1 ]; then
    green_path=${G2R_path}
    file_name=$(ls ${green_path}/Green_G2R*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${green_path}/Green_G2R*.nii | grep "^-" | wc -l);

    for ((i=0;i<$len;i=i+1))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:9};

        start_time=$(date +%s)

        # Initialize affine matrix.
        cmtk make_initial_affine --principal-axes $mean_template ${red_path}/Red${k}.nii ${red_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${red_path}/initial${k}.xform --dofs 6,12 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${red_path}/affine${k}.xform $mean_template ${red_path}/Red${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${red_path}/Red${k}.nii $mean_template ${red_path}/affine${k}.xform
        cmtk reformatx -o ${regist_green_path}/regist_green_1_${k}.nii --floating ${green_path}/Green_G2R${k}.nii $mean_template ${red_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num

    done

else
    green_path=${path_g}/dual_Crop
    file_name=$(ls ${green_path}/Green*.nii);
    file_name=(${file_name//,/ });
    len=$(ls -l ${green_path}/Green*.nii | grep "^-" | wc -l);

    for ((i=0;i<$len;i=i+1))
    do
        name_num=$(basename -s .nii ${file_name[$i]});
        
        # Set k to the number of the name.
        k=${name_num:5};

        start_time=$(date +%s)

        # Initialize affine matrix.
        cmtk make_initial_affine --principal-axes $mean_template ${green_path}/Green${k}.nii ${green_path}/initial${k}.xform
        
        # Generate affine matrix.
        cmtk registration --initial ${green_path}/initial${k}.xform --dofs 6,12 --exploration 8 -s 0.25 --accuracy 0.05 --cr -o ${green_path}/affine${k}.xform $mean_template ${green_path}/Green${k}.nii

        # Apply affine matrix.
        cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${red_path}/Red${k}.nii $mean_template ${green_path}/affine${k}.xform
        cmtk reformatx -o ${regist_green_path}/regist_green_1_${k}.nii --floating ${green_path}/Green${k}.nii $mean_template ${green_path}/affine${k}.xform

        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
        echo $name_num

    done
fi
