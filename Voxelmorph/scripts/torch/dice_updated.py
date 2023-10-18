import os
import nibabel as nib
import numpy as np
from skimage.metrics import structural_similarity as ssim
from skimage.metrics import peak_signal_noise_ratio as psnr
from skimage.metrics import mean_squared_error as mse


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
atlas_file = "/media/user/Fish-free11/usman/ali/atlas2/atlas.nii.gz"
image_dir = "/media/user/Fish-free11/usman/ali/output_images/predicted_images"  # Directory containing the images

dice_scores = []  # List to store individual Dice scores
ssim_scores = []  # List to store individual SSIM scores
psnr_scores = []  # List to store individual PSNR scores
mse_scores = []  # List to store individual MSE scores
variance_scores = []  # List to store individual variance scores

# Load the atlas image using nibabel
atlas_image = nib.load(atlas_file)
atlas_data = atlas_image.get_fdata()
atlas_mask = preprocess_image(atlas_data)

# Calculate the variance of the atlas mask
variance_atlas = np.var(atlas_mask)

# Iterate over the images in the directory
for filename in os.listdir(image_dir):
    if filename.endswith(".nii.gz"):
        image_file = os.path.join(image_dir, filename)

        # Load the predicted image using nibabel
        predicted_image = nib.load(image_file)
        predicted_data = predicted_image.get_fdata()
        predicted_mask = preprocess_image(predicted_data)

        # Calculate the Dice coefficient
        dice_score = dice_coefficient(atlas_mask, predicted_mask)
        dice_scores.append(dice_score)

        # Calculate the SSIM score
        ssim_score = ssim(atlas_mask, predicted_mask)
        ssim_scores.append(ssim_score)

        # Calculate the PSNR score
        mse_score = mse(atlas_mask, predicted_mask)
        max_possible_value = np.max(predicted_data)
        psnr_score = psnr(predicted_data, atlas_data, data_range=max_possible_value)
        psnr_scores.append(psnr_score)

        # Calculate the MSE score
        mse_scores.append(mse_score)

        # Calculate the variance of the predicted mask
        variance_predicted = np.var(predicted_mask)
        variance_scores.append(variance_predicted)

        print(f"Mean Dice score for {filename}: {dice_score}")
        print(f"SSIM score for {filename}: {ssim_score}")
        print(f"PSNR score for {filename}: {psnr_score}")
        print(f"MSE score for {filename}: {mse_score}")
        print(f"Variance score for {filename}: {variance_predicted}")

# Calculate the average scores
average_dice_score = np.mean(dice_scores)
average_ssim_score = np.mean(ssim_scores)
average_psnr_score = np.mean(psnr_scores)
average_mse_score = np.mean(mse_scores)
average_variance_score = np.mean(variance_scores)
std_predicted_variance_score = np.std(variance_scores)
uncertainty = 1 - average_dice_score

print("")
print("Quantitative Assessment:")
print("Average mean Dice score:", average_dice_score)
print("Average SSIM score:", average_ssim_score)
print("Average PSNR score:", average_psnr_score)
print("Average MSE score:", average_mse_score)
print("Average variance score:", average_variance_score)
print("Standard Deviation", std_predicted_variance_score)
print("Uncertainty:", uncertainty)
