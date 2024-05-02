function [detrend_ca] = denoise(detrend_ca)

for i = 1:size(detrend_ca,1)
    if max(detrend_ca(i,:)) == inf
        detrend_ca(i,:) = 0;
    end
end

end