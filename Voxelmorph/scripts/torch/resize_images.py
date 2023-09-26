
import os
import numpy as np
import nibabel as nib
from skimage.transform import resize

# Folder path containing the fixed images
image_folder = '/media/user/Fish-free2/usman/motor-g8s_lssm/train/'

# Get a list of image files in the folder
image_files = os.listdir(image_folder)

# Output directory to save the resized images
output_folder = '/media/user/Fish-free2/usman/motor-g8s_lssm/train/new_resized_movtrain'
os.makedirs(output_folder, exist_ok=True)

# Target shape for resizing
target_shape = (400, 304, 208)

# Resize and save the images
for file in image_files:
    file_path = os.path.join(image_folder, file)

    try:
        # Load the image
        image = nib.load(file_path).get_fdata()

        # Resize the image
        resized_image = resize(image, target_shape, order=1, mode='constant', anti_aliasing=True)

        # Save the resized image
        output_file = os.path.join(output_folder, file)
        nib.save(nib.Nifti1Image(resized_image, np.eye(4)), output_file)

        print(f"Resized image saved: {output_file}")

    except Exception as e:
        print(f"Error processing file: {file_path}")
        print(e)

print("Image resizing and saving completed.")