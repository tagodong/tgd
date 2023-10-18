function ExpLogs =  readExpLogsFromTXT(path)

% path='E:\online-opto-data\20220825_1601_chri-g8s-lssm_10dpf\20220825_1601_chri-g8s-lssm_10dpf.txt';
fid=fopen(path);
frameNum=[];
laserOn=[];
xsize=[];
xpos=[];
ysize=[];
ypos=[];
rotationAngleX=[];
rotationAngleY=[];
cropPoint=[];
Moving2FixAffineMatrix=[];
while ~feof(fid)
    [fieldName,value]=read_a_line(fid);
    if(~isempty(fieldName))
        switch fieldName
            case 'frameNum'
                frameNum = cat(1,frameNum,str2num(value));
            case 'laserOn'
                laserOn = cat(1,laserOn,str2num(value));
            case 'xsize'
                xsize = cat(1,xsize,str2num(value));
            case 'xpos'
                xpos = cat(1,xpos,str2num(value));
            case 'ysize'
                ysize = cat(1,ysize,str2num(value));
            case 'ypos'
                ypos = cat(1,ypos,str2num(value));
            case 'rotationAngleX'
                rotationAngleX = cat(1,rotationAngleX,str2num(value));
            case 'rotationAngleY'
                rotationAngleY = cat(1,rotationAngleY,str2num(value));
            case 'cropPoint'
                cropPoint = cat(1,cropPoint,str2num(value));
            case 'Moving2FixAffineMatrix'
                if(size(value)~=12)
                    value='0 0 0 0 0 0 0 0 0 0 0 0';
                end
                Moving2FixAffineMatrix = cat(1,Moving2FixAffineMatrix,str2num(value));
        end
    end
end
fclose(fid);

ExpLogs.frameNum=frameNum;
ExpLogs.laserOn=laserOn;
ExpLogs.xsize=xsize;
ExpLogs.xpos=xpos;
ExpLogs.ysize=ysize;
ExpLogs.ypos=ypos;
ExpLogs.rotationAngleX=rotationAngleX;
ExpLogs.rotationAngleY=rotationAngleY;
ExpLogs.cropPoint=cropPoint;
ExpLogs.Moving2FixAffineMatrix=Moving2FixAffineMatrix;


disp(['load: ' path ': finished']);



end


