function myCMTK(path_g,path_r,red_flag,fix_flag,i,flag,red_have)

    if nargin == 6
        red_have = 1;
    end

    if flag == 1
        eval(['!bash regist_affine_G2R.sh ',path_g,' ',path_r,' ',num2str(red_flag),' ',num2str(i)]);
    else
        if flag == 2
            eval(['!bash regist_affine.sh ',path_g,' ',path_r,' ',num2str(red_flag),' ',num2str(fix_flag),' ',num2str(i),' ',num2str(red_have)]);
        end
    end
    

end