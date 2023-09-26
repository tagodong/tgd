import os
import numpy as np
import scipy.io as sio
import nibabel as nib

def convert_mat_to_nii(mat_file, output_dir):
    # Load .mat file
    mat_data = sio.loadmat(mat_file)
    
    # Extract the volumetric image data
    volume = mat_data['ObjRecon']
    
    # Create NIfTI image
    nii_image = nib.Nifti1Image(volume, np.eye(4))
    
    # Save NIfTI image to .nii file
    output_file = os.path.splitext(mat_file)[0] + '.nii.gz'
    output_path = os.path.join(output_dir, output_file)
    nib.save(nii_image, output_path)
    
    print(f"Converted {mat_file} to {output_file}")

# Set the input folder containing .mat files
input_folder = '/media/user/Fish-free21/data/big_data/fixed/regist_green_mat_3/'

# Set the output folder where the .nii files will be saved
output_folder = '/media/user/Fish-free21/data/big_data/fixed/fixed/'

# Iterate over each .mat file in the input folder
for file_name in os.listdir(input_folder):
    if file_name.endswith('.mat'):
        file_path = os.path.join(input_folder, file_name)
        convert_mat_to_nii(file_path, output_folder)
