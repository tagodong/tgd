function dist_edge = minDistEdge(ObjRecon,A3)
%% function summary: compute the minist dist between the center of brain ROI and the fish edge.
    %  input:
    %   ObjRecon --- 3D calcium imaging data from the Ref-zbb4.nii
    %   A3 --- extracted brain ROI from the ObjRecon
    %  output:
    %   dist_edge --- a vector contain all the minist dist between the center of all brain ROIs and the fish edge.

    %   2022.11.09 by tgd.

%% realiaze
    disp("dist start");
    edge = find(bwperim(ObjRecon));
    [edge_x,edge_y,edge_z] = ind2sub(size(ObjRecon),edge);
    edge = [edge_x edge_y edge_z];
    dist_edge = zeros(size(A3,2),1);
    % waittext(0,'init');
    for i = 1:size(A3,2)
        temp = find(full(A3(:,i)));
        [x,y,z] = ind2sub(size(ObjRecon),temp);
        x_c = round(mean(x));
        y_c = round(mean(y));
        z_c = round(mean(z));
        dist = vecnorm([edge-[x_c*ones(length(edge),1) y_c*ones(length(edge),1) z_c*ones(length(edge),1)]]');
        dist_edge(i)=min(dist);
        % display the progress
        % option = struct('indicator','=','prefix','progress:');
        % waittext(i/size(A3,2),'waitbar',option);
        disp(i/size(A3,2));
    end
    disp("dist done");
end

