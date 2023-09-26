function ret=isField(str)
%This function checks to see if this is a field in the form of
% `field:`
%
% If no field is present it returns 0
% If a field is present it returns 1
ret = contains(str,":");

end