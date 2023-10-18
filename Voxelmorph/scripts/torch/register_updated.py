import argparse
import os
import time

import torch
import numpy as np


# import voxelmorph with pytorch backend
os.environ['VXM_BACKEND'] = 'pytorch'
import voxelmorph as vxm

def process_image_pair(moving_path, atlas_path, output_dir, model_path, pair_index):
    # load moving and atlas images
    add_feat_axis = not args.multichannel
    moving = vxm.py.utils.load_volfile(moving_path, add_batch_axis=True, add_feat_axis=add_feat_axis)
    atlas, atlas_affine = vxm.py.utils.load_volfile(atlas_path, add_batch_axis=True, add_feat_axis=add_feat_axis,
                                                    ret_affine=True)

    # Find the minimum and maximum values in the moving array to estimate the range
    min_value = np.min(moving)
    max_value = np.max(moving)

    # Normalize the moving array to the range [0, 1] and convert to float32
    moving = (moving - min_value) / (max_value - min_value)
    # load and set up model
    model = vxm.networks.VxmDense.load(model_path, device)
    model.to(device)
    model.eval()

    # set up tensors and permute
    input_moving = torch.from_numpy(moving).to(device).float().permute(0, 4, 1, 2, 3)
    input_atlas = torch.from_numpy(atlas).to(device).float().permute(0, 4, 1, 2, 3)

    # measure time taken for prediction
    start_time = time.time()
    moved, warp = model(input_moving, input_atlas, registration=True)
    end_time = time.time()
    elapsed_time = end_time - start_time

    # create output directories if they don't exist
    os.makedirs(output_dir, exist_ok=True)
    moved_output_dir = os.path.join(output_dir, "predicted_images")
    warp_output_dir = os.path.join(output_dir, "warp_files")
    os.makedirs(moved_output_dir, exist_ok=True)
    os.makedirs(warp_output_dir, exist_ok=True)

    # save moved image
    moved_output_path = os.path.join(moved_output_dir, f"predicted_{pair_index}.nii.gz")
    moved = moved.detach().cpu().numpy().squeeze()
    vxm.py.utils.save_volfile(moved, moved_output_path, atlas_affine)

    # save warp
    warp_output_path = os.path.join(warp_output_dir, f"warp_{pair_index}.nii.gz")
    warp = warp.detach().cpu().numpy().squeeze()
    vxm.py.utils.save_volfile(warp, warp_output_path, atlas_affine)

    return moved_output_path, warp_output_path, elapsed_time


# parse commandline args
parser = argparse.ArgumentParser()
parser.add_argument('--moving-dir', default="/media/user/Fish-free11/usman/ali/movingtest/movingtest_resized2",
                    help='directory containing moving images')
parser.add_argument('--atlas', default="/media/user/Fish-free11/usman/ali/atlas2/atlas.nii.gz",
                    help='atlas image file')
parser.add_argument('--output-dir', default="/media/user/Fish-free11/usman/ali/output_images/", help='directory to save output images and warps')
parser.add_argument('--model', default="/media/Usman/pythonUsman/scripts/torch/models/0088.pt", help='pytorch model for nonlinear registration')
parser.add_argument('--gpu', default=0, help='GPU number(s) - if not supplied, CPU is used')
parser.add_argument('--multichannel', action='store_true', help='specify that data has multiple channels')
args = parser.parse_args()

# device handling
if args.gpu and (args.gpu != '-1'):
    device = 'cuda'
    os.environ['CUDA_VISIBLE_DEVICES'] = args.gpu
else:
    device = 'cpu'
    os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

# get the list of moving image files
moving_files = sorted(os.listdir(args.moving_dir))

# create output directories if they don't exist
os.makedirs(args.output_dir, exist_ok=True)
moved_output_dir = os.path.join(args.output_dir, "predicted_images")
warp_output_dir = os.path.join(args.output_dir, "warp_files")
os.makedirs(moved_output_dir, exist_ok=True)
os.makedirs(warp_output_dir, exist_ok=True)

total_time = 0  # Initialize total time

# process each image pair
for i, moving_file in enumerate(moving_files):
    moving_path = os.path.join(args.moving_dir, moving_file)

    # process the image pair
    pair_index = i + 1
    moved_output_path, warp_output_path, elapsed_time = process_image_pair(moving_path, args.atlas, args.output_dir, args.model,
                                                             pair_index)
    print(f"Image pair {pair_index} processed. Predicted image saved to {moved_output_path}, Warp saved to {warp_output_path}")
    print(f"Time taken: {elapsed_time} seconds")

    total_time += elapsed_time  # Update total time

print(f"Total time taken for all {len(moving_files)} image pairs: {total_time} seconds")
