function [out_data,idx_index] = isoRm(in_data,lower_rate,upper_rate)

    if nargin == 1
        lower_rate = 1;
        upper_rate = 1;
    end
    if size(in_data,2) == 2
        q1_1 = prctile(in_data(:,1),25);
        q1_2 = prctile(in_data(:,2),25);
        q3_1 = prctile(in_data(:,1),75);
        q3_2 = prctile(in_data(:,2),75);
        iqr1 = q3_1 - q1_1;
        iqr2 = q3_2 - q1_2;
        lower1 = q1_1 - lower_rate*iqr1;
        lower2 = q1_2 - lower_rate*iqr2;
        upper1 = q3_1 + upper_rate*iqr1;
        upper2 = q3_2 + upper_rate*iqr2;

        idx1 = logical((in_data(:,1)>upper1)+(in_data(:,1)<lower1));
        idx2 = logical((in_data(:,2)>upper2)+(in_data(:,2)<lower2));
        in_data(logical(idx1+idx2),:) = nan;
        out_data = in_data;
    else
        if size(in_data,2) == 1
            q1 = prctile(in_data,25);
            q3 = prctile(in_data,75);
            iqr = q3 - q1;
            lower = q1 - lower_rate*iqr;
            upper = q3 + upper_rate*iqr;
            
            idx = logical((in_data>upper)+(in_data<lower));
            idx_index = find(idx);
            in_data(idx) = nan;
            out_data = in_data;
        else
            disp('Error, your NRscore must be lower than 3!!!');
        end
    end
end