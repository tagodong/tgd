#!/bin/bash
# Run affine transformation according to atlas using CMTK.

export CMTK_WRITE_UNCOMPRESSED=1


# Set the red chanel image directory path that is needed to register.
path_g=$1
path_r=$2

red_path=${path_r}/template
green_path=${path_g}/dual_Crop

# Set the atlas path.
zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/Ref-zbb2.nii"
# zbbfish="/home/user/tgd/Dual-Color-Image-Processing/data/Atlas/HC_atlas_final.nii"

# Read the red images.
file_name=$(ls $red_path/Red*.nii);
file_name=(${file_name//,/ });
len=$(ls -l $red_path/Red*.nii | grep "^-" | wc -l);

for ((i=0;i<$len;i=i+1))
do
    name_num=$(basename -s .nii ${file_name[$i]});

    # Set k to the number of the name.
    k=${name_num:3};

    start_time=$(date +%s)

    # Initialize affine matrix.
    
    cmtk make_initial_affine --principal-axes $zbbfish ${red_path}/Red${k}.nii ${red_path}/initial${k}.xform
    
    # Generate affine matrix.
    cmtk registration --initial ${red_path}/initial${k}.xform --dofs 9,12 --exploration 6 --accuracy 0.01 --stepfactor 0.1 --sampling 0.25 --cr -o ${red_path}/affine${k}.xform $zbbfish ${red_path}/Red${k}.nii

    # Apply affine matrix.
    cmtk reformatx -o ${red_path}/template${k}.nii --floating ${red_path}/Red${k}.nii $zbbfish ${red_path}/affine${k}.xform
    cmtk reformatx -o ${red_path}/G_template${k}.nii --floating ${green_path}/Green${k}.nii $zbbfish ${red_path}/affine${k}.xform

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $name_num

done

# Average all the templates.
cmtk average_images --avg -o ${red_path}/mean_template.nii ${red_path}/template*.nii
cmtk average_images --avg -o ${red_path}/G_mean_template.nii ${red_path}/G_template*.nii
matlab -nodesktop -nosplash -r "input = '${red_path}/G_mean_template.nii'; output = '${red_path}/G_mean_template.nii'; myushort; quit"

##### Regist to mean template.
red_path=${path_r}/dual_Crop
green_path=${path_g}/dual_Crop

# Set the output green chanel image directory path that is registered.
regist_red_path=${path_r}/regist_red
mkdir $regist_red_path
regist_green_path=${path_g}/regist_green
mkdir $regist_green_path

# Set the mean template path.
mean_template=${path_r}/template/mean_template.nii

# Read the images.
file_name=$(ls $red_path/Red*.nii);
file_name=(${file_name//,/ });
len=$(ls -l ${red_path}/Red*.nii | grep "^-" | wc -l);
# Set the step.
step_size=1

for ((i=0;i<$len;i=i+$step_size))
do
    name_num=$(basename -s .nii ${file_name[$i]});
    
    # Set k to the number of the name.
    k=${name_num:3};

    start_time=$(date +%s)

    # Transform green to red.
    # Initialize affine matrix.
    cmtk make_initial_affine --principal-axes ${red_path}/Red${k}.nii ${green_path}/Green${k}.nii ${green_path}/initial${k}.xform
    
    # Generate affine matrix.
    cmtk registration --initial ${green_path}/initial${k}.xform --dofs 6,12 --exploration 8 --accuracy 0.05 --cr -o ${green_path}/affine${k}.xform ${red_path}/Red${k}.nii ${green_path}/Green${k}.nii

    # Apply affine matrix.
    cmtk reformatx -o ${green_path}/Green_G2R${k}.nii --floating ${green_path}/Green${k}.nii ${red_path}/Red${k}.nii ${green_path}/affine${k}.xform


    # Initialize affine matrix.
    cmtk make_initial_affine --principal-axes $mean_template ${red_path}/Red${k}.nii ${red_path}/initial${k}.xform
    
    # Generate affine matrix.
    cmtk registration --initial ${red_path}/initial${k}.xform --dofs 9,12 --exploration 8 --accuracy 0.05 --cr -o ${red_path}/affine${k}.xform $mean_template ${red_path}/Red${k}.nii

    # Apply affine matrix.
    cmtk reformatx -o ${regist_red_path}/regist_red_1_${k}.nii --floating ${red_path}/Red${k}.nii $mean_template ${red_path}/affine${k}.xform
    cmtk reformatx -o ${regist_green_path}/regist_green_1_${k}.nii --floating ${green_path}/Green_G2R${k}.nii $mean_template ${red_path}/affine${k}.xform

    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo $name_num

done

##### Run inverse unrigid registration to make crop-eyes-MASK.
red_out_path=${path_r}/template
start_time=$(date +%s)
G_mean_template=${red_out_path}/G_mean_template.nii

antsRegistration -d 3 --float 1 -o [${red_out_path}/Rigid_,${red_out_path}/zbb_Rigid.nii.gz] \
-t Rigid[0.1] -m GC[$G_mean_template,$zbbfish,1,32,Regular,0.25]  \
-c [200x200x200x100,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

antsRegistration -d 3 --float 1 -o [${red_out_path}/Affine_,${red_out_path}/zbb_Affine.nii.gz] \
-t Affine[0.1] -m GC[$G_mean_template,${red_out_path}/zbb_Rigid.nii.gz,1,32,Regular,0.25]  \
-c [200x200x200x100,1e-8,10] -f 12x8x4x2 -s 4x3x2x1

antsRegistration -d 3 --float 1 -o [${red_out_path}/SyN_,${red_out_path}/zbb_SyN.nii.gz] \
-t SyN[0.05,6,0.5] -m CC[$G_mean_template,${red_out_path}/zbb_Affine.nii.gz,1,2]  \
-c [200x200x200x200x10,1e-7,10] -f 12x8x4x2x1 -s 4x3x2x1x0

end_time=$(date +%s)
cost_time=$[ $end_time-$start_time ]
echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
echo $name_num