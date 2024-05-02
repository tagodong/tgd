function costMat = costGet(per_A,per_C,post_A,post_C,siz,dist_thresh,corr_thresh)
    per_centor = centorGet(per_A,siz);
    post_centor = centorGet(post_A,siz);
    costMat = ones(size(per_C,1),size(post_C,1));
    for i = 1:size(per_C,1)
        for j = 1:size(post_C,1)
            cur_dist = norm(per_centor(i,:)-post_centor(j,:),2);
            if cur_dist > dist_thresh
                costMat(i,j) = inf;
                continue;
            end
            cur_corr = corr(per_C(i,:)',post_C(j,:)','type','Pearson');
            if cur_corr < corr_thresh
                costMat(i,j) = inf;
                continue;
            else
                costMat(i,j) = 1-cur_corr;
            end
        end
%         if mod(i,ceil(size(per_C,1)/5))==0
%             disp(['Computing the cost matrix: ',num2str(i/size(per_C,1))]);
%         end
    end
end