function [Ca_Detected,Lo_Detected_all,Info_Detected] = motionDetector(Caltrace,AF_caltrace,Peak_thresh,Min_dist,Detector_net,Signal_conf,Fs)
%% function summary: Detecte the caltrace and remove the false signal peaks.
    %  input:
    %   Caltrace --- the origional Caltrace.
    %   AF_caltrace --- the Adaptive Filtered Caltrace or OASIS convolution Caltrace.
    %   Peak_thresh --- the threshold of peaks.
    %   Min_dist --- the minist dist between the center of brain ROI and the fish edge.
    %   Detector_net --- the trained detector net.
    %   Signal_conf --- the threshold of predicted confidence degree.(defaul is 0.5)
    %   Fs --- the frequency of image.(default is 10)
    %  output:
    %   Ca_Detected --- the detected and repaired Caltrace.
    %   Lo_Detected --- the real peaks location.
    %   Info_Detected --- [signal_framents,signal_framents_true,rate;peak_framents,peak_framents_true,rate].

    %   2023.03.12 by tgd.

%% Initialize all parameters.
if nargin == 5
    Signal_conf = 0.5;
    Fs = 10;
end
% fragments length must be even number.
fragments_len = 170;
classes = categorical([0 1]);

%% generate the peak signal fragments location.
[m,n] = size(AF_caltrace);
num_fragments = 0;
peaks_Lo_Fragments = zeros(floor(m/10),4);
Ca_Detected = AF_caltrace;
for i = 1:m
    peaks_Lo = AF_caltrace(i,:) >= Peak_thresh;
    Ca_Detected(i,~peaks_Lo) = 0;
    % find continuous region, start with 1 and end with -1.
    peaks_Map = diff([0 peaks_Lo 0]);
    % create the continuous peak fragements,only continuous length >= 2*Fs.
    j = 1;
    while j <= n
        if peaks_Map(j)==1
            for len = 1:n
                if peaks_Map(j+len) == -1
                    break;
                end
            end
            if len >= 2 * Fs
                num_fragments = num_fragments + 1;
                % record the location of peak fragements, [neuron i, start point, end point, length].
                peaks_Lo_Fragments(num_fragments,1:4) = [i j j+len-1 len-1];
            else
                Ca_Detected(i,j:j+len-1) = 0;
            end
            j = j + len + 1;
        else
            j = j+1;
        end
    end
end

%% generate peak signal fragments.
Lo_Detected_all = zeros(num_fragments,4);
signal_fragments = zeros(num_fragments,fragments_len);
dist_feature = zeros(num_fragments,1);
signal_num = 0;
for i = 1:num_fragments
    len = peaks_Lo_Fragments(i,3) - peaks_Lo_Fragments(i,2) + 1;
    len_fold = ceil(len/fragments_len);
    % expand the center point to fragments length.
    for j =1:len_fold
        cen_point = peaks_Lo_Fragments(i,2) + round(len*j/(len_fold+1));
        signal_num = signal_num + 1;
        if cen_point-fragments_len/2+1 >0 && cen_point+fragments_len/2 <= n
            signal_fragments(signal_num,1:fragments_len) = Caltrace(peaks_Lo_Fragments(i,1),cen_point-fragments_len/2+1:cen_point+fragments_len/2);
        else
            if cen_point+fragments_len/2 <= n
                signal_fragments(signal_num,1:fragments_len) = Caltrace(peaks_Lo_Fragments(i,1),1:fragments_len);
            else
                signal_fragments(signal_num,1:fragments_len) = Caltrace(peaks_Lo_Fragments(i,1),n-fragments_len+1:n);
            end
        end
        dist_feature(signal_num,1) = Min_dist(peaks_Lo_Fragments(i,1));
        Lo_Detected_all(signal_num,1:5) = [peaks_Lo_Fragments(i,:),len_fold];
    end
end

%% detect the signal fragments.
sf = waveletScattering('SignalLength',fragments_len,'SamplingFrequency',Fs,'InvarianceScale',10);
signal_feature = sf.featureMatrix(signal_fragments');
Npaths = size(signal_feature,2);
dist_feature = repelem(dist_feature,Npaths);
signal_feature = permute(signal_feature,[2 3 1]);
signal_feature = reshape(signal_feature,size(signal_feature,1)*size(signal_feature,2),[]);
signal_feature_cell = mat2cell([signal_feature,dist_feature],ones(size(signal_feature,1),1),34);
signal_predict = Detector_net.predict(signal_feature_cell,'SequenceLength','shortest');
signal_class = signal_predict(:,2) > Signal_conf;
signal_class = reshape(signal_class,Npaths,signal_num);
ClassCounts = countcats(categorical(signal_class));
[~,idx] = max(ClassCounts);
signal_class_true = classes(idx);

%% repair the AF-Ca signal and statistics relevant information.
Info_Detected = zeros(2,3);
Lo_Detected = zeros(1,4);
i = 1;
num_Lo = 0;
while i <= signal_num
    if ~sum(signal_class_true(i:i+Lo_Detected_all(i,5)-1) == categorical(0))
        num_Lo = num_Lo+1;
        Lo_Detected(num_Lo,1:4) = Lo_Detected_all(i,1:4);
        if Lo_Detected_all(i,2)-Fs > 0 && Lo_Detected_all(i,3)+2*Fs <= n
            Ca_Detected(Lo_Detected_all(i,1),Lo_Detected_all(i,2)-Fs:Lo_Detected_all(i,3)+2*Fs) = AF_caltrace(Lo_Detected_all(i,1),Lo_Detected_all(i,2)-Fs:Lo_Detected_all(i,3)+2*Fs);
        else
            if Lo_Detected_all(i,2)-Fs > 0
                Ca_Detected(Lo_Detected_all(i,1),Lo_Detected_all(i,2)-Fs:Lo_Detected_all(i,3)) = AF_caltrace(Lo_Detected_all(i,1),Lo_Detected_all(i,2)-Fs:Lo_Detected_all(i,3));
            else
                Ca_Detected(Lo_Detected_all(i,1),Lo_Detected_all(i,2):Lo_Detected_all(i,3)+2*Fs) = AF_caltrace(Lo_Detected_all(i,1),Lo_Detected_all(i,2):Lo_Detected_all(i,3)+2*Fs);
            end
        end
    else
        Ca_Detected(Lo_Detected_all(i,1),Lo_Detected_all(i,2):Lo_Detected_all(i,3)) = 0;
    end
    i = i + Lo_Detected_all(i,5);
end
Info_Detected(:,1:2) = [signal_num,sum(signal_class_true == categorical(1));num_fragments,num_Lo];
Info_Detected(:,3) = Info_Detected(:,2)./Info_Detected(:,1);

end