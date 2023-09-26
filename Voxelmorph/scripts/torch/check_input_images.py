import os
import nibabel as nib
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# Set the paths to the fixed and moving image folders
fixed_folder = 'E:\\Dataset_3D_volumetric_images\\fixedtest'
moving_folder = 'E:\\Dataset_3D_volumetric_images\\movingtest'

# Get the list of files in the folders
fixed_files = os.listdir(fixed_folder)
moving_files = os.listdir(moving_folder)

# Sort the file lists
fixed_files.sort()
moving_files.sort()

# Determine the number of images to display
num_images = min(len(fixed_files), len(moving_files), 5)

# Create a figure with two subplots (grids)
fig = plt.figure(figsize=(15, 15))
gs = gridspec.GridSpec(2, 1, height_ratios=[1, 1])

# Set up the ImageGrid for each subplot
grid1 = gridspec.GridSpecFromSubplotSpec(1, num_images, subplot_spec=gs[0])
grid2 = gridspec.GridSpecFromSubplotSpec(1, num_images, subplot_spec=gs[1])

# Display the fixed images in the first grid
for i in range(num_images):
    # Load the fixed image
    fixed_img = nib.load(os.path.join(fixed_folder, fixed_files[i]))
    fixed_data = fixed_img.get_fdata()

    # Display the fixed image in the grid
    ax = fig.add_subplot(grid1[i])
    ax.imshow(fixed_data[:, :, fixed_data.shape[2] // 2], cmap='gray')
    ax.axis('off')

# Display the moving images in the second grid
for i in range(num_images):
    # Load the moving image
    moving_img = nib.load(os.path.join(moving_folder, moving_files[i]))
    moving_data = moving_img.get_fdata()

    # Display the moving image in the grid
    ax = fig.add_subplot(grid2[i])
    ax.imshow(moving_data[:, :, moving_data.shape[2] // 2], cmap='gray')
    ax.axis('off')

# Adjust spacing between subplots
gs.update(hspace=0.1)

# Show the figure with the grids
plt.show()
