import os

import nibabel as nib
import numpy as np
from scipy.ndimage import zoom

# Folder path containing the fixed images
image_folder = 'E:\\Dataset_3D_volumetric_images\\fixedtest'

# Get a list of image files in the folder
image_files = os.listdir(image_folder)
image_files = sorted(image_files)[:100]  # Select the first 100 images

# Read the image files and store the image data
images = []
for file in image_files:
    file_path = os.path.join(image_folder, file)
    image = nib.load(file_path).get_fdata()
    images.append(image)

# Resize the images to the desired shape
resized_images = []
# target_shape = (128, 128, 64)
target_shape = (160, 128, 64)
for image in images:
    resized_image = zoom(image, (target_shape[0] / image.shape[0],
                                 target_shape[1] / image.shape[1],
                                 target_shape[2] / image.shape[2]))
    resized_images.append(resized_image)

# Convert the resized image data to numpy array
resized_images = np.array(resized_images)

# Create the atlas by averaging the resized images
atlas = np.mean(resized_images, axis=0)

# Save the atlas as a NIfTI file
# image_folder = 'E:\\Dataset_3D_volumetric_images\\fixedtest'
atlas_file = 'E:\\Dataset_3D_volumetric_images\\atlas.nii.gz'
nib.save(nib.Nifti1Image(atlas, np.eye(4)), atlas_file)

# Print the shape of the atlas
print("Atlas shape:", atlas.shape)
