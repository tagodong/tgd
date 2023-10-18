function Cal_trace = blockTrace(path,input_filename,startnumber,vertex_point,size_matrix)

    FoldInfo=dir(fullfile(path,[input_filename,'*.mat']));

    x = vertex_point(1):vertex_point(1)+size_matrix(1)-1;
    y = vertex_point(2):vertex_point(2)+size_matrix(2)-1;
    z = vertex_point(3):vertex_point(3)+size_matrix(3)-1;
    ROI = meshgrid(x,y,z);

    Cal_trace = zeros(1,size(FoldInfo,1));
    for i = 1:size(FoldInfo,1)
        load(fullfile(path,[input_filename,num2str(startnumber+i-1),'.mat']));

        Cal_trace(1,i) = mean(regist_3_green_image(x,y,z),'all');
        disp(num2str(startnumber+i-1));
        disp(Cal_trace(1,i));
    end
end