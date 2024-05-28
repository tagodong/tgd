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
if 'dview' in locals():
    cm.stop_server(dview=dview)
c, dview, n_processes = cm.cluster.setup_cluster(
    backend='multiprocessing', n_processes=None, single_thread=False)
print(n_processes)


# Set the prctile of thresh.
mat_data = io.loadmat('/home/d1/Learn/0304/prc_thresh.mat')
prc_thresh = mat_data['new_prc_thrsh']
prc_thresh = prc_thresh.T
prc_thresh = prc_thresh
print(prc_thresh.shape)
id_start = 8
start_num = 64
end_num = 89

for i in range(start_num,end_num+1):

    # ## Load the file.
    fname = '/home/d1/Learn/0304/matdata/Ratio_detrend_zoom_' + str(i) +'.mat'
    fname_mapped = '/home/d1/Learn/0304/matdata/test_' + str(i) +'_d1_358_d2_256_d3_1_order_C_frames_16194.mmap'
    if not os.path.isfile(fname_mapped):
        # now load the file
        fname_mapped = cm.save_memmap([fname],base_name='test_'+str(i)+'_',order='C', border_to_0=0)
    print(fname_mapped)

    # load memory mappable file
    Yr, dims, T = cm.load_memmap(fname_mapped)
    images = Yr.T.reshape((T,) + dims, order='F')
    print(images.shape)

    gsig_tmp = (2, 2)
    correlation_image, peak_to_noise_ratio = cm.summary_images.correlation_pnr(images, # subsample if needed
                                                                            gSig=gsig_tmp[0], # used for filter
                                                                            swap_dim=False) # change swap dim if output looks weird, it is a problem with tiffile

    # parameters for source extraction and deconvolution
    p = 0               # order of the autoregressive system
    K = None            # upper bound on number of components per patch, in general None for CNMFE
    gSig = np.array([2, 2])  # expected half-width of neurons in pixels 
    gSiz = 2*gSig + 1     # half-width of bounding box created around neurons during initialization
    merge_thr = .8      # merging threshold, max correlation allowed
    rf = 40             # half-size of the patches in pixels. e.g., if rf=40, patches are 80x80
    stride_cnmf = 20    # amount of overlap between the patches in pixels 
    tsub = 1            # downsampling factor in time for initialization, increase if you have memory problems
    ssub = 1            # downsampling factor in space for initialization, increase if you have memory problems
    gnb = 0             # number of background components (rank) if positive, set to 0 for CNMFE
    low_rank_background = None  # None leaves background of each patch intact (use True if gnb>0)
    nb_patch = 0        # number of background components (rank) per patch (0 for CNMFE)
    min_corr = np.percentile(correlation_image[correlation_image>0], prc_thresh[i-id_start,0])       # min peak value from correlation image
    min_pnr = np.percentile(peak_to_noise_ratio[peak_to_noise_ratio>0], prc_thresh[i-id_start,1])        # min peak to noise ration from PNR image
    ssub_B = 1          # additional downsampling factor in space for background (increase to 2 if slow)
    ring_size_factor = 1.4  # radius of ring is gSiz*ring_size_factor
    bord_px = 0
    frate = 5
    decay_time = 2
    p_ssub = 1
    p_tsub = 1

    parameters = params.CNMFParams(params_dict={'method_init': 'corr_pnr',  # use this for 1 photon
                                    'K': K,
                                    'gSig': gSig,
                                    'gSiz': gSiz,
                                    'merge_thr': merge_thr,
                                    'p': p,
                                    'tsub': tsub,
                                    'ssub': ssub,
                                    'p_ssub':p_ssub,
                                    'p_tsub':p_tsub,
                                    'rf': rf,
                                    'stride': stride_cnmf,
                                    'only_init': True,    # set it to True to run CNMF-E
                                    'nb': gnb,
                                    'nb_patch': nb_patch,
                                    'method_deconvolution': 'oasis',       # could use 'cvxpy' alternatively
                                    'low_rank_background': low_rank_background,
                                    'update_background_components': True,  # sometimes setting to False improve the results
                                    'min_corr': min_corr,
                                    'min_pnr': min_pnr,
                                    'normalize_init': False,               # just leave as is
                                    'center_psf': True,                    # True for 1p
                                    'ssub_B': ssub_B,
                                    'ring_size_factor': ring_size_factor,
                                    'del_duplicates': True,                # whether to remove duplicates from initialization
                                    'border_pix': bord_px,
                                    'fr': frate,
                                    'decay_time': decay_time,
                                    'dims':dims});                # number of pixels to not consider in the borders)

    cnmfe_model = cnmf.CNMF(n_processes=n_processes, 
                            dview=dview, 
                            params=parameters)
    
    # gsig_tmp = (2,2)
    # correlation_image, peak_to_noise_ratio = cm.summary_images.correlation_pnr(images, # subsample if needed
    #                                                                        gSig=gsig_tmp[0], # used for filter
    #                                                                        swap_dim=False) # change swap dim if output looks weird, it is a problem with tiffile

    # np.nan_to_num(correlation_image,0)
    

    cnmfe_model.fit(images);

    print(f"Num : {cnmfe_model.estimates.A.shape}, {cnmfe_model.estimates.C.shape}")
    
    min_SNR = 2            # SNR threshold
    rval_thr = 0.4    # spatial correlation threshold

    quality_params = {'min_SNR': min_SNR,
                    'rval_thr': rval_thr,
                    'use_cnn': False}
    cnmfe_model.params.change_params(params_dict=quality_params)

    cnmfe_model.estimates.evaluate_components(images, cnmfe_model.params, dview=dview)

    print('*****')
    print(f"Total number of components: {len(cnmfe_model.estimates.C)}")
    print(f"Number accepted: {len(cnmfe_model.estimates.idx_components)}")
    print(f"Number rejected: {len(cnmfe_model.estimates.idx_components_bad)}")

    save_results = True
    if save_results:
        save_path =  '/home/d1/Learn/0304/cnmf_data/h5df/cnmfe_results_'+str(i)+'.hdf5'  # or add full/path/to/file.hdf5
        # cnmfe_model.estimates.Cn = correlation_image # squirrel away correlation image with cnmf object
        cnmfe_model.save(save_path)
    
    
    foot_print_A = cnmfe_model.estimates.A
    C = cnmfe_model.estimates.C
    idx_accept = cnmfe_model.estimates.idx_components
    idx_reject = cnmfe_model.estimates.idx_components_bad
    C_SNR = cnmfe_model.estimates.SNR_comp
    spatial_corr = cnmfe_model.estimates.r_values

    io.savemat('/home/d1/Learn/0304/cnmf_data/matdata/cnmfe_results_'+str(i)+'.mat',{'A':foot_print_A,'C':C,'idx_accept':idx_accept,'idx_reject':idx_reject,'SNR':C_SNR,'r_corr':spatial_corr})

    del cnmfe_model
    
    print(save_path + ' done')

# Stop the multiprocession.
cm.stop_server(dview=dview)
