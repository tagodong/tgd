function [CR_dtr_total, DFoF] = detrend_data(DFoF,sequences)
DFoF = zscore(DFoF,[],2);
win_dtr = 50; % window for detrend
CR_dtr_total = [];
n_seq = size(sequences,1);
for time = 1:n_seq
    DFoF_time = DFoF(:, sequences(time,1):sequences(time,2) );
%     DFoF_time = zscore(DFoF_time,[],2);
    DFoF(:, sequences(time,1):sequences(time,2) ) = DFoF_time;
    [N,T] = size(DFoF_time);
    
    CR_dtr = zeros(size(DFoF_time));%output

        for i=1:N
            cr = DFoF_time(i,:);
            crd = 0*cr;
            for j=1:win_dtr:T
                if j<=win_dtr
                    tlim1 = 1;
                    tlim2 = 50;
                elseif j>T-win_dtr
                    tlim1 = T-50;
                    tlim2 = T;
                else
                    tlim1 = j-win_dtr;
                    tlim2 = j+win_dtr;
                end
                crr = cr(tlim1:tlim2);
                crd(max(1,j-win_dtr):min(T,j+win_dtr)) = prctile(crr,15);
            end
            if mod(i,100)==0
                disp(num2str(i));
            end
            CR_dtr(i,:) = cr-crd;
    %         
        end
        
    %CR_dtr = zscore(CR_dtr,0,2);
    if time == 1
        CR_dtr_total = CR_dtr;
    else
        CR_dtr_total = [CR_dtr_total,CR_dtr];
    end
     
end


  
% [N,T] = size(DFoF);
% 
% CR_dtr = zeros(size(DFoF));%output
% 
%     for i=1:N
%         cr = DFoF(i,:);
%         crd = 0*cr;
%         for j=1:win_dtr:T
%             if j<=win_dtr
%                 tlim1 = 1;
%                 tlim2 = 200;
%             elseif j>T-win_dtr
%                 tlim1 = T-200;
%                 tlim2 = T;
%             else
%                 tlim1 = j-win_dtr;
%                 tlim2 = j+win_dtr;
%             end
%             crr = cr(tlim1:tlim2);
%             crd(max(1,j-win_dtr):min(T,j+win_dtr)) = prctile(crr,15);
%         end
%         if mod(i,100)==0
%             disp(num2str(i));
%         end
%         CR_dtr(i,:) = cr-crd;
% %         
%     end


% CR_dtr_total = CR_dtr;
% CR_dtr_total = zscore(CR_dtr_total,[],2);

     


end