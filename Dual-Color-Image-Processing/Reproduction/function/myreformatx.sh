#!/bin/bash
# Run Registration for candidate templates.

imgae_in=$1
refer_image=$2
tform=$3
image_out=$4

cmtk reformatx -o ${image_out} --floating ${imgae_in} ${refer_image} ${tform}
