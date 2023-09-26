#!/bin/bash
export CMTK_WRITE_UNCOMPRESSED=1

for i in $(seq 62 255)
do
    start_time=$(date +%s)
 
    cmtk make_initial_affine --principal-axes /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_crop_2_nii/Red_Cropped_${i}.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/initial${i}.xform

	cmtk registration --initial /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/initial${i}.xform --dofs 9 --exploration 8 --accuracy 0.05 --cr -o /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/affine${i}.xform /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_crop_2_nii/Red_Cropped_${i}.nii
	
     #  cmtk warp -o ffd5${i}.xform --grid-spacing 40 --refine 1 --jacobian-weight 1e-5 --energy-weight 1e-1 --fast --initial affine${i}.xform Obj_ref.nii Rescaled_Obj_${i}.nii

    cmtk warp -o /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/ffd5${i}.xform --grid-spacing 40 --fast --initial /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/affine${i}.xform /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_crop_2_nii/Red_Cropped_${i}.nii
#	cmtk reformatx -o affine${i}.nii --floating Rescaled_Obj_${i}.nii Obj_ref.nii affine${i}.xform
	#rename ${i} ObjRecon_EdgRemoved${i} ObjRecon_EdgRemoved${i}.nii
	
	cmtk reformatx -o /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/regist_3_red_${i}.nii --floating /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_crop_2_nii/Red_Cropped_${i}.nii /home/d2/Ref-zbb2.nii /home/d1/210804_tif/r_210804/r_210804_con1/r_210804_1/cmtk_red/c_regist_3_nii/ffd5${i}.xform
 
    end_time=$(date +%s)
    cost_time=$[ $end_time-$start_time ]
    echo "Reg & Warp time is $(($cost_time/60))min $(($cost_time%60))s"
    echo ${i}
done




