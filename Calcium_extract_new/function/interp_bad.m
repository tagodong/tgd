function interp_bad(file_path,pre_name,index_pre,index_post,mip_dir_name,redflag)
	% Syntax: interp_bad(file_path,index_pre,index_post)
	%         file_path: the path of data
	%		  pre_name: the prefix name of all frames. eg: the prefix name of 'regist_red_mat_3_63.mat' is 'regist_red_mat_3_'.
	%         index_pre: the frame before the first bad frame
	%         index_post: the frame after the last bad frame
	%		  mip_dir_name: the directory name of svaed mip of interped bad frame.
	%		  the default mip path is 'file_path/../mip_dir_name'.
	%		  the default mip name is '[mip_dir_name,'_',num2str(i),'.tif']'.
	
	% Long description
	%   After alignment and before segmentation, we should pick out the bad frames(motion blur, 
	%	3D reconstruction mistakes, bad alignment, etc.), and estimate these frames by interpolation.
	index_pre_name = [pre_name,num2str(index_pre),'.mat'];
	index_post_name = [pre_name,num2str(index_post),'.mat'];

	if redflag == 1
		load(fullfile(file_path,index_pre_name),'regist_3_red_image');
		ObjRecon_pre = regist_3_red_image;
		load(fullfile(file_path,index_post_name),'regist_3_red_image');
		ObjRecon_post = regist_3_red_image;
	else
		if redflag == 0
			load(fullfile(file_path,index_pre_name),'regist_3_green_image');
			ObjRecon_pre = regist_3_green_image;
			load(fullfile(file_path,index_post_name),'regist_3_green_image');
			ObjRecon_post = regist_3_green_image;
		else
			load(fullfile(file_path,index_pre_name),'ObjRecon');
			ObjRecon_pre = ObjRecon;
			load(fullfile(file_path,index_post_name),'ObjRecon');
			ObjRecon_post = ObjRecon;
		end
	end


	for i=index_pre+1:index_post-1
		a = (i - index_pre)/(index_post - index_pre); % the weight
		ObjRecon = (1-a)*ObjRecon_pre + a*ObjRecon_post;
		eval(['!mv ',fullfile(file_path,[pre_name,num2str(i),'.mat']),' ',fullfile(file_path,['bp_',pre_name,num2str(i),'.mat'])]);
		if redflag
			regist_3_red_image = ObjRecon;
			save(fullfile(file_path,[pre_name,num2str(i),'.mat']),'regist_3_red_image'); % The original data should be renamed as 'Ori_corrected_noEyesi.mat', 
																		% since we will process all files with prefix 'corrected_noEyes' in CorrMap_multi.m.
		else
			regist_3_green_image = ObjRecon;
			save(fullfile(file_path,[pre_name,num2str(i),'.mat']),'regist_3_green_image'); % The original data should be renamed as 'Ori_corrected_noEyesi.mat', 
																		% since we will process all files with prefix 'corrected_noEyes' in CorrMap_multi.m.
		end
		
		MIPs=[max(ObjRecon,[],3) squeeze(max(ObjRecon,[],2));squeeze(max(ObjRecon,[],1))' zeros(size(ObjRecon,3),size(ObjRecon,3))];
		% figure;imagesc(MIPs);axis image;
		MIP=uint16(MIPs);
        %!!!
		if redflag ~= 0
			imwrite(MIP,fullfile(file_path,'..',mip_dir_name,['regist_red_MIP_3','_',num2str(i),'.tif']));
		else
			imwrite(MIP,fullfile(file_path,'..',mip_dir_name,['regist_green_MIP_3','_',num2str(i),'.tif']));
		end
		
	end

end