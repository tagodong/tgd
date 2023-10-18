function C = imageBin(A,binSize,dim)
    if nargin == 2
        dim = 3;
    end
    if dim == 3
        C = mean(reshape(A,binSize,size(A,1) / binSize*size(A,2),[]));
        C = reshape(C,size(A,1) / binSize,size(A,2),[]);
        C = permute(C,[2,1,3]);
        C = mean(reshape(C,binSize,size(A,2) / binSize*size(C,2),[]));
        C = reshape(C,size(A,2) / binSize,size(A,1) / binSize,[]);
        C = permute(C,[3,2,1]);
        C = mean(reshape(C,binSize,size(A,3) / binSize*size(C,2),[]));
        C = reshape(C,size(A,3) / binSize,size(A,1) / binSize,[]);
        C = permute(C,[2,3,1]);
    else
        if dim == 2
            C = mean(reshape(A,binSize,[]));
            C = reshape(C,size(A,1) / binSize,[])';
            C = mean(reshape(C,binSize,[]));
            C = reshape(C,size(A,2) / binSize,[])';
        else
            disp('Error: dim must be 2 or 3 !!!');
        end
    end
    
    C = uint16(C);
    
end