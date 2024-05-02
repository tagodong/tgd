function cor = corGet(seg_regions)
    cor = zeros(size(seg_regions,2),3);
    for i = 1:size(seg_regions,2)
        cur_id = find(seg_regions(:,i)>0);
        [x,y,z] = ind2sub([380,308,210],cur_id);
        cor(i,:) = mean([x,y,z]);
    end
end