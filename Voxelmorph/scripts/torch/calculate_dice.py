import nibabel as nib
import numpy as np


def preprocess_image(image):
    # Convert image to binary mask
    threshold = 0.5  # Adjust this threshold according to your needs
    mask = image > threshold
    return mask.astype(int)


def dice_coefficient(mask1, mask2):
    intersection = np.logical_and(mask1, mask2)
    dice_score = (2.0 * intersection.sum()) / (mask1.sum() + mask2.sum())
    return dice_score


# Example usage
# Assuming you have two NIfTI files: atlas_image.nii.gz and predicted_image.nii.gz
atlas_file = "E:\\Dataset_3D_volumetric_images\\atlas.nii.gz"
predicted_file = "predicted_moved.nii.gz"

# Load the images using nibabel
atlas_image = nib.load(atlas_file)
predicted_image = nib.load(predicted_file)

# Get the data arrays from the loaded images
atlas_data = atlas_image.get_fdata()
predicted_data = predicted_image.get_fdata()

# Preprocess images to obtain binary masks
atlas_mask = preprocess_image(atlas_data)
predicted_mask = preprocess_image(predicted_data)

# Calculate the Dice coefficient
score = dice_coefficient(atlas_mask, predicted_mask)
print("Dice score:", score)

# Calculate uncertainty and standard deviation
uncertainty = 1 - score  # Uncertainty is 1 - Dice score
# Print the uncertainty and standard deviation
print("Uncertainty: ", uncertainty)