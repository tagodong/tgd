% This is an example to implement the Adaptive Filter 
% and compare the result to the conventional methods (direct ratio)

% The data was aquired from dual-channel Fish Data 0107 (GFP-LSSMcrimson)


% Wrote by Chen Shen, 
% for any question plz contact: cshen@ustc.edu.cn

clear;

%% 0. load a 3D image stack for visualization

load('Fish-0107-sample2.mat');

  
%% 1. Plot the comparison between dual-Ratio and the AF result

% call the NLMS algorithm
% Adaptive Filter need a period time steps to converge, 
% extend factor is the ratio of total signal length

extend_factor = 0.05; 
[AF, ~, ~] = useNLMS(sigR,sigG,extend_factor);


% plot the AF result compare with conventional ratio method
    figure(1);
    set(gcf,'position',[0,0,420,350]);
    set(gca,'looseInset',[0 0 0 0]);
    set(gcf,'DefaultAxesLooseInset',[5,5,5,5]);


    subplot(2,2,[3 4]);
    plot(AF,'Color',[0.9290 0.6940 0.1250 0.8], 'LineWidth', 2);
    hold on;
    plot(dualRatio(sigG, sigR),'Color',[85/256 170/256 173/256 0.8],'lineWidth',2);
        xlim([0 1500]);  
        set(gca,'XTickLabel',0:50:150);
        legend('AF','Ratio','Fontname','Arial','FontSize',9)
        xlabel('Time (s)','Fontname','Arial','FontSize',14)
        ylabel('Inferred activity','Fontname','Arial','FontSize',14)
        legend boxoff;


% plot the raw trace of two channel 
    subplot(2,2,[1 2]);
    yyaxis left;
    plot(sigG,'LineWidth',2,'Color',[0.4660 0.6740 0.1880 0.8]); hold on;
        set(gca,'ycolor',"#77AC30");
        ylabel('Intensity (a.u.)','Fontname','Arial','FontSize',14);
    yyaxis right;
    plot(sigR,'LineWidth',2,'Color',[0.6350 0.0780 0.1840 0.8]);
        ylabel('Intensity (a.u.)','Fontname','Arial','FontSize',14)
        set(gca,'ycolor',"#A2142F");
        set(gca,'XTickLabel',[]);
        ylabel('Intensity (a.u.)','Fontname','Arial','FontSize',14)
        legend('EGFP','LSSmCrimson','Fontname','Arial','FontSize',9)
        legend boxoff;
        xlim([0 1500]) 
        set(gca,'looseInset',[0 0 0 0]);

 %% 2. Add Synthetic AR(1) Signals to EGFP

 % AR(1) constant lambda

 Length = length(sigG);
 lambda = 0.95;
 
 amp = 0.37;

 % set random spikes
    spike = zeros(1,Length);
    spike(449) = 1; spike(421) = 1; spike(1119) = 1.1; 
    spike(823)=1.6; spike(622) = 1; spike(139) = 1.1;
    
    a = zeros(1,Length);
 

    for t=2:Length

        a(t)=lambda*a(t-1)+spike(t);

    end

% a is the final artificial synthetic signal 
a = a * amp;


% follow the fomula and construct psudo synthetic signal
pseudoSig = (a+1).*sigG;

%% 3. Plot the comparison
figure(2);

% call the NLMS algorithm
[AF, ~, ~] = useNLMS(sigR,pseudoSig,extend_factor);

% plot the comperison
    set(gcf,'position',[0,0,420,350]);
    subplot(2,2,[3 4]);
    plot(a, 'color',[0.4940 0.1840 0.5566],'LineWidth', 2);
    hold on;
    plot(dualRatio(sigG, sigR),'Color',[85/256 170/256 173/256 0.8],'lineWidth',2);
    hold on;
    plot(AF,'LineWidth', 2,'Color',[0.9290 0.6940 0.1250,0.7]);
        ylabel('Inferred Intensity','Fontname','Arial','FontSize',14);
        xlabel('Time (s)','Fontname','Arial','FontSize',14)
        set(gca,'XTickLabel',0:50:150);
        xlabel('Time (s)','Fontname','Arial','FontSize',14);
        legend('Synthetic','Ratio','AF','Fontname','Arial','FontSize',10);
        legend boxoff;

% plot the Synthetic and EGFP combined signal, EGFP and LSSmCrimson signals
    subplot(2,2,[1 2]);
        yyaxis left;
    plot(pseudoSig,'lineWidth',2,'color',[0.4940 0.1840 0.5566]);hold on;
        ylim([300,1000]);
    plot(sigG,'lineWidth',2, 'color', [0.4660 0.6740 0.1880 0.8],'LineStyle','-'); hold on;
        ylabel('Intensity (a.u.)','Fontname','Arial','FontSize',14)
        set(gca,'ycolor','#77AC30');
        yyaxis right;
    plot(sigR,'lineWidth',2,'color', [0.6350 0.0780 0.1840 0.8]);
        ylabel('Intensity (a.u.)','Fontname','Arial','FontSize',14)
        set(gca,'ycolor',"#A2142F");
        ylim([30,70]);
        legend('Synthetic and EGFP combined','EGFP','LSSmCrimson','Fontname','Arial','FontSize',10);
        set(gca,'XTickLabel',[]);
        legend boxoff;






