import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt

# Load the NIfTI file
file_path = 'E:\\Dataset_3D_volumetric_images\\moved.nii.gz'
nii_img = nib.load(file_path)

# Get the data array from the image
data = nii_img.get_fdata()

# Select the slice indices to display
slice_indices = [10, 20, 35, 50, 63]  # Update with the desired slice indices

# Create a figure and axes for subplots
fig, axes = plt.subplots(1, len(slice_indices), figsize=(12, 4))

# Loop over the slice indices and display each slice image
for i, slice_index in enumerate(slice_indices):
    # Extract the selected slice from the data
    slice_data = data[:, :, slice_index]

    # Display the slice image
    axes[i].imshow(slice_data, cmap='gray')

    # Set the axis labels
    axes[i].set_xlabel('X')
    axes[i].set_ylabel('Y')

    # Set the plot title
    axes[i].set_title(f'Slice {slice_index}')

# Adjust the spacing between subplots
plt.tight_layout()

# Show the plot
plt.show()
