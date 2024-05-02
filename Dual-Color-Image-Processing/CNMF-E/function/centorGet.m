function centor = centorGet(A,siz)
    %%  Get crntor of A.
    centor = zeros(size(A,2),2);
    for i = 1:size(A,2)
        index = find(A(:,i)>0);
        weight = full(A(A(:,i)>0,i));
        weight = weight/sum(weight);
        [x,y] = ind2sub(siz,index);
        centor(i,1:2) = weight'*[x,y];
    end
end