%% compute snr 
% within a time window,
% mean value of detrended calcium divided by std of noise,
% std of noise is estimated by the std of negative idfference of detrended
% calcium
function snr_curve = snr_compute(detrend_ca_curve)
    T = length(detrend_ca_curve);
    snr_curve = zeros(T,1);
    winLength = 50;
    iseven = rem(winLength, 2) == 0;
    if iseven
        win_seq = winLength/2:T-winLength/2;
    else
        win_seq = (winLength-1)/2+1:T-(winLength-1)/2;
    end
    for j = win_seq
        if iseven
            startF = j-winLength/2+1;
            endF = j + winLength/2;
        else
            startF = j-(winLength-1)/2;
            endF = j+(winLength-1)/2;
        end
        ca_win = detrend_ca_curve(startF:endF);
        win_diff = diff(ca_win);
        m_win = mean(ca_win);
        neg_diff_win = win_diff(win_diff<0);
        std_win = std(neg_diff_win);
        if std_win >= 0.1 %&& m_win > 0
            snr_curve(j) = m_win/std_win;
        else
            snr_curve(j) = 0;
        end
    end
end