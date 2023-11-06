function myCMTK(path_g,path_r,red_flag,i)

    eval(['!bash regist_affine.sh ',path_g,' ',path_r,' ',num2str(red_flag),' ',num2str(i)]);

end