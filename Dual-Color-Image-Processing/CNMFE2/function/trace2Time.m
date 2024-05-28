function Cal_time = trace2Time(Cal_id,output)
    Cal_time = zeros(length(Cal_id),1);
    num = 1;
    for i = 1:length(Cal_id)
        while Cal_id(i) ~= output(num,6)
            num = num + 1;
        end
        Cal_time(i,1) = num;
    end
end