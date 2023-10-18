function [out_data,idx_index] = isoRm(in_data)

    ratio = 1.0;
    q1 = prctile(in_data,25);
    q3 = prctile(in_data,75);
    iqr = q3 - q1;
    lower = q1 - ratio*iqr;
    upper = q3 + ratio*iqr;
    
    idx = logical((in_data>upper)+(in_data<lower));
    idx_index = find(idx);
    in_data(idx) = nan;
    out_data = in_data;
end