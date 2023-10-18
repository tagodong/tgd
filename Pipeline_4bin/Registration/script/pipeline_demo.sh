#!/bin/bash

# Run the registration pepline.

# Run affine transformation according to atlas using CMTK.
bash regist_atlas.sh

# Calculate the mean of all the templates as the new template.
matlab -batch template_run

# Run affine transformation according to mean template using CMTK.
bash regist_mean.sh

# Run demons registration.
matlab -batch demonsRegist_run

# Bad image interpolation.
matlab -batch interp_run