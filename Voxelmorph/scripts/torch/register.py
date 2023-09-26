#!/usr/bin/env python

"""
Example script to register two volumes with VoxelMorph models.

Please make sure to use trained models appropriately. Let's say we have a model trained to register a
scan (moving) to an atlas (fixed). To register a scan to the atlas and save the warp field, run:

    register.py --moving moving.nii.gz --fixed fixed.nii.gz --model model/0010.pt --moved moved.nii.gz --warp warp.nii.gz
    register.py --moving /media/jamshaid/Empty/Voxelmorph_data/moved_100_images/Green1.nii --fixed /media/jamshaid/Empty/Voxelmorph_data/fixed_100_images/green_regist_3_1.nii --model models/0010.pt --moved moved.nii.gz --warp warp.nii.gz

fix
/media/jamshaid/Empty/Voxelmorph_data/moved_100_images/green_regist_3_1.nii
moving
/media/jamshaid/Empty/Voxelmorph_data/moved_100_images/Green1.nii

The source and target input images are expected to be affinely registered.
"""

import argparse
import os

import torch

# import voxelmorph with pytorch backend
os.environ['VXM_BACKEND'] = 'pytorch'
import voxelmorph as vxm

# parse commandline args
parser = argparse.ArgumentParser()
parser.add_argument('--moving', default="E:\\Dataset_3D_volumetric_images\\movingtest\\Green1.nii",
                    help='moving image (source) filename')
parser.add_argument('--fixed', default="E:\\Dataset_3D_volumetric_images\\fixedtest\\green_regist_3_1.nii",
                    help='fixed image (target) filename')
parser.add_argument('--moved', default="predicted_moved.nii.gz", help='warped image output filename')
parser.add_argument('--model', default="models/0020.pt", help='pytorch model for nonlinear registration')
parser.add_argument('--warp', default="predicted_warp.nii.gz", help='output warp deformation filename')
parser.add_argument('-g', '--gpu', default=0, help='GPU number(s) - if not supplied, CPU is used')
parser.add_argument('--multichannel', action='store_true', help='specify that data has multiple channels')
args = parser.parse_args()

# device handling
if args.gpu and (args.gpu != '-1'):
    device = 'cuda'
    os.environ['CUDA_VISIBLE_DEVICES'] = args.gpu
else:
    device = 'cpu'
    os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

# load moving and fixed images
add_feat_axis = not args.multichannel
moving = vxm.py.utils.load_volfile(args.moving, add_batch_axis=True, add_feat_axis=add_feat_axis)
fixed, fixed_affine = vxm.py.utils.load_volfile(args.fixed, add_batch_axis=True, add_feat_axis=add_feat_axis,
                                                ret_affine=True)

# load and set up model
model = vxm.networks.VxmDense.load(args.model, device)
model.to(device)
model.eval()

# set up tensors and permute
input_moving = torch.from_numpy(moving).to(device).float().permute(0, 4, 1, 2, 3)
input_fixed = torch.from_numpy(fixed).to(device).float().permute(0, 4, 1, 2, 3)

# predict
moved, warp = model(input_moving, input_fixed, registration=True)

# save moved image
if args.moved:
    moved = moved.detach().cpu().numpy().squeeze()
    vxm.py.utils.save_volfile(moved, args.moved, fixed_affine)

# save warp
if args.warp:
    warp = warp.detach().cpu().numpy().squeeze()
    vxm.py.utils.save_volfile(warp, args.warp, fixed_affine)
