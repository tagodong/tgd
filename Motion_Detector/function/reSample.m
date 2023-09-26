function s_signal = reSample(signal, sig_labels, sam_length, length, step)
%%  function summary: resample signal recording the labelled signal data.
    %   input:
    %   signal --- a matrix which a row is a complete original signal, so the number of the columns are the number of the original signal.
    %   sig_labels --- a matrix which contain labled data, and a row correspond a lable(signal index, position, class).
    %   sam_length --- a half length of resample region, default is 50.
    %   length --- the length of resample signal(window width), default is 256.
    %   step --- the step length between two adjacent Windows, default is 2.
    %   output:
    %   s_signal --- a table is composed of resampled siganl and index(row index and column start index).

    % example:
    %   signal = [signal_1;signal_2]
    %   sig_labels = [signal_index_1,position_1,class_1;signal_index_2,position_2,class_2]
    %   2022.10.18 by tgd.

%% Parameter Settings
    if nargin == 2
        sam_length = 50;
        length = 256;
        step = 2;
    else
        if nargin ~= 5
            error("Insufficient number of input parameters!");
        end
    end

%% reliaze the function
   [m, ~] = size(sig_labels);
   [~, n] = size(signal);
   upratio = floor(sam_length/step);
   short_signal = zeros(1, length);
   signal_class = zeros(1,1);
   signal_index = zeros(1,2);
   num = 1;
%    waittext(0,'init');
   for i = 1:m
       sig_index = sig_labels(i,1);
       pos = sig_labels(i,2);
       class = sig_labels(i,3);
       % move to the left
       for j = 1:upratio+1
           cur_pos = pos - step*(j-1);
           end_pos = cur_pos+length-1;
           if cur_pos > 0 && end_pos <= n
               short_signal(num,:) = signal(sig_index,cur_pos:end_pos);
               signal_class(num,1) = class;
               signal_index(num,:) = [sig_index,cur_pos];
               num = num +1;
           end
       end
       % move to the right
       for j = 1:upratio
           cur_pos = pos + step*j;
           end_pos = cur_pos+length-1;
           if end_pos <= n
               short_signal(num,:) = signal(sig_index,cur_pos:end_pos);
               signal_class(num,1) = class;
               signal_index(num,:) = [sig_index,cur_pos];
               num = num +1;
           end
       end
       % display the progress
    %    option = struct('indicator','=','prefix','resample progress:');
    %    waittext(i/m,'waitbar',option);
   end
   s_signal = table(short_signal, signal_class, signal_index, 'VariableNames', {'signal'; 'class'; 'index'});
   disp('resample done!')
end
