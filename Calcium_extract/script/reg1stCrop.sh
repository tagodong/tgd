#!/bin/bash
export CMTK_WRITE_UNCOMPRESSED=1
# please fill the filename here, "Obj_ref.nii" by default
# filename = "/home/d2/Ref-zbb2.nii"

# check the file is exist, if not stop this script running
if [ ! -f "$filename" ]; then


for i in $(seq 62 255)
do
    # start counting the exec. time
 start_time=$(date +%s)

 # make intiital transform
  cmtk make_initial_affine --principal-axes /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/Red${i}.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_1_nii/initial${i}.xform
 
 # affine registration, dofs = 12 (9, 6 as optional)
  cmtk registration --initial /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_1_nii/initial${i}.xform --dofs 12,12 --exploration 8 --accuracy 0.05 --cr -o /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_1_nii/affine1st${i}.xform /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/Red${i}.nii
 
	
# make non-rigid registration (optional, time consuming)
# cmtk warp -o ffd5${i}.xform --grid-spacing 40 --fast --initial affine${i}.xform Obj_ref.nii Rescaled_Obj_${i}.nii
 
# apply the transformation on the original 3-D stack	
 cmtk reformatx -o /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_1_nii/Red_1stAffined_${i}.nii --floating /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/Red${i}.nii /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_1_nii/affine1st${i}.xform

 # delete the original 3-D stack (optional)
 # rm Red${i}.nii
 

	end_time=$(date +%s)
	
	cost_time=$[ $end_time-$start_time ]

	# print out the i-th exec. time
	echo ${i}
	echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
	

done

fi
