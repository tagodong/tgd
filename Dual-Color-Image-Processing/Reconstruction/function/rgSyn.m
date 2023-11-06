function [red_ObjRecon,green_ObjRecon] = rgSyn(red_ObjRecon,green_ObjRecon)
%% Synchronize red and green.
    red_ObjRecon = flip(red_ObjRecon,2);

    % for new data.
    green_ObjRecon = flip(green_ObjRecon,1);

%% Rotate the image reference the atlas.
    red_ObjRecon = flip(red_ObjRecon,3);
    green_ObjRecon = flip(green_ObjRecon,3);
    
end