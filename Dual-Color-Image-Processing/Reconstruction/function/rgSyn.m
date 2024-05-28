function [red_ObjRecon,green_ObjRecon] = rgSyn(red_ObjRecon,green_ObjRecon,red_have)
    %% Synchronize red and green.
    if nargin == 2
        red_have =1;
    end

    if red_have
        red_ObjRecon = flip(red_ObjRecon,2);  %%%
        % red_ObjRecon = flip(red_ObjRecon,1);

        red_ObjRecon = flip(red_ObjRecon,3);
    else
        red_ObjRecon = [];
    end


    % for new data.
    green_ObjRecon = flip(green_ObjRecon,1);
%% Rotate the image reference the atlas.
    green_ObjRecon = flip(green_ObjRecon,3);
    
end