import logging
import matplotlib.pyplot as plt
import numpy as np
import os
from scipy.ndimage import gaussian_filter
from tifffile.tifffile import imwrite

import caiman as cm
from caiman.utils.visualization import nb_view_patches3d
import caiman.source_extraction.cnmf as cnmf
from caiman.source_extraction.cnmf import params as params
from caiman.paths import caiman_datadir
import tifffile
import scipy.io as io

logging.basicConfig(format=
                          "%(relativeCreated)12d [%(filename)s:%(funcName)20s():%(lineno)s] [%(process)d] %(message)s",
                    filename="/tmp/caiman.log",
                    level=logging.WARNING)

# open multiprocession.
# if 'dview' in locals():
#     cm.stop_server(dview=dview)
# c, dview, n_processes = cm.cluster.setup_cluster(
#     backend='multiprocessing', n_processes=20, single_thread=False)
# print(n_processes)

# start_num = 8
# end_num = 188

# for i in range(start_num,end_num+1,8):
i = 65
# fname = '/home/d1/Learn/0304/Ratio_detrend_' + str(i) +'.mat'
fname_mapped = '/home/d1/Learn/0304/test_65_d1_358_d2_256_d3_1_order_C_frames_16194.mmap'
# if not os.path.isfile(fname_mapped):
    # now load the file
# fname_mapped = cm.save_memmap([fname],base_name='test_'+str(i)+'_',order='C', border_to_0=0)
print(fname_mapped)

Yr, dims, T = cm.load_memmap(fname_mapped)
images = Yr.T.reshape((T,) + dims, order='F')
print(images.shape)

gsig_tmp = (2, 2)
correlation_image, peak_to_noise_ratio = cm.summary_images.correlation_pnr(images[:5000,:,:], # subsample if needed
                                                                        gSig=gsig_tmp[0], # used for filter
                                                                        swap_dim=False) # change swap dim if output looks weird, it is a problem with tiffile
np.nan_to_num(correlation_image,0)
# np.nan_to_num(peak_to_noise_ratio,0)

io.savemat('/home/d1/Learn/0304/corr_'+str(i)+'.mat',{'correlation_image':correlation_image,'peak_to_noise_ratio':peak_to_noise_ratio})
