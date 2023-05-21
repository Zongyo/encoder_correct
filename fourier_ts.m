%% function to help generate the single side of freq domain 
function [DC , cos_amp , cos_phase] = fourier_ts(data)
   L=size(data,1);
   data_fft = fft(data);
    data_amp = abs(data_fft)/L;
    data_phase = phase(data_fft);
    if mod(L,2) == 1   % 長度為基數無法/2
        L=L+1;
    end
    DC=data_amp(1)*cos(data_phase(1));
    data_amp = 2*data_amp;
    cos_amp = data_amp(2:L/2+1);
    cos_phase = phase(data_fft(2:L/2+1));
end
