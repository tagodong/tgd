function [seg_regions,water_corMap_filter] = coherenceFilter(Coherence,water_corMap,min_size,thresh_Coherence)
%% function summary: Filter regions according to Coherence threshold.

%  input:
%   file_path --- the mat format image directory path.
%   Coherence --- the coherence of segmented regions.
%   water_corMap --- the segmented regions map.
%   min_size --- the minimum size of segmented regions. 
%   thresh_Coherence --- the threshold of coherence.
%   write_flag --- 1: save the water_corMap_filter. 2: don't save.

%  output: 
%   seg_regions --- segmented regions in sparse format.
%   water_corMap_filter --- filtered segmented regions map.

%% Run.
    Mask_Coherence = zeros(size(Coherence),"single");
    Mask_Coherence(Coherence>thresh_Coherence) = 1;
    [d1,d2,d3] = size(Coherence);
    water_corMap_filter = water_corMap.*Mask_Coherence;
    water_corMap_filter = bwareaopen(water_corMap_filter,min_size,6);
    water_corMap_filter = bwlabeln(water_corMap_filter,6);
    num_components_keep3 = max(water_corMap_filter(:));
    seg_regions = sparse(d1*d2*d3,num_components_keep3);
    for k=1:num_components_keep3
        temp  = (water_corMap_filter==k);
        seg_regions(:,k) = sparse(reshape(temp,[d1*d2*d3,1]));
    end
    clear Mask_Coherence;

end