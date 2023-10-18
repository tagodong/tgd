function [fieldName,value] = read_a_line(fid)
% read a line in yaml and convert the value to struct
% if it is a value to a key word.
    tline = fgets(fid);
    newLine = remove_brackets(tline);
    if (isField(newLine))
        [fieldName,value] = readFieldValuePair(newLine);
    else
        fieldName = [];
        value = [];
    end
end