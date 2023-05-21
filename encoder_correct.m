clear;
clc;
close;
%% config
repeat_times = 20;
sample_freq = 42;
signal_len = sample_freq*repeat_times;
sensing_angle =load('sensing_angle.txt');

%%
% 鋸齒波產生器(期望的控制角度)
control_angle = tri_wave_gen(sample_freq,repeat_times,16384,0);

step_x = tri_wave_gen(signal_len,1,signal_len,0);
step_x_1period = tri_wave_gen(sample_freq,1,sample_freq,0);
freq_x = tri_wave_gen(signal_len/2,1,signal_len/2,0);
freq_x_1period = tri_wave_gen(sample_freq/2,1,sample_freq/2,0);

%% 訊號誤差
encoder_error=control_angle-sensing_angle;

%% 將10比連續訊號傅立葉轉換
% 快速傅立葉轉換
[encoder_err_DC , encoder_err_amp , encoder_err_phase] = fourier_ts(encoder_error);

%% 連續訊號的頻率合成
%1倍頻率
freq=repeat_times*1;
correct_error = cos_wave_gen(encoder_err_amp(freq),encoder_err_phase(freq),freq,signal_len);
%2倍頻率
freq=repeat_times*2;
correct_error = correct_error+ cos_wave_gen(encoder_err_amp(freq),encoder_err_phase(freq),freq,signal_len);
%4倍頻率
freq=repeat_times*4;
correct_error = correct_error+ cos_wave_gen(encoder_err_amp(freq),encoder_err_phase(freq),freq,signal_len);
%6倍頻率
freq=repeat_times*6;
correct_error = correct_error+ cos_wave_gen(encoder_err_amp(freq),encoder_err_phase(freq),freq,signal_len);
%8倍頻率
freq=repeat_times*8;
correct_error = correct_error+ cos_wave_gen(encoder_err_amp(freq),encoder_err_phase(freq),freq,signal_len);
%直流
correct_error =correct_error + encoder_err_DC;

%% encoder error arry to matrix

encoder_error_matrix=vector2matrix(encoder_error,repeat_times);
encoder_error_fft_matrix = fft(encoder_error_matrix)/sample_freq;
L=size(encoder_error_fft_matrix,1);
L=L/2;
encoder_error_fft_matrix_abs=abs(encoder_error_fft_matrix(1:L,1:end));

%% 平均頻譜和誤差

encoder_error_avg=matrix2vector(encoder_error_matrix);
encoder_error_fft_avg=matrix2vector(encoder_error_fft_matrix);
encoder_error_avg_abs=abs(encoder_error_fft_avg(1:sample_freq/2));
encoder_error_avg_ang=angle(encoder_error_fft_avg(1:sample_freq/2));

%% cosine 的擬合輸出 偏心誤差
[encoder_err_avg_DC , encoder_err_avg_amp , encoder_err_avg_phase] = fourier_ts(encoder_error_avg);
%1倍頻率
freq=1;
correct_function = cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
%2倍頻率
freq=2;
correct_function=correct_function+cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
%4倍頻率
freq=4;
correct_function=correct_function+cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
%6倍頻率
freq=6;
correct_function=correct_function+cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
%8倍頻率
freq=8;
correct_function=correct_function+cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
%直流
correct_function=correct_function+encoder_err_avg_DC;

%% 機械誤差
%11倍頻率
freq=7;
machine_error=cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
machine_error_full=cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq*repeat_times,signal_len);

%22倍頻率
freq=14;
machine_error=machine_error+cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq,sample_freq);
machine_error_full=machine_error_full+cos_wave_gen(encoder_err_avg_amp(freq),encoder_err_avg_phase(freq),freq*repeat_times,signal_len);


%% 扣除偏心誤差的殘餘誤差 : 機械誤差+電子誤差
residual_error =encoder_error-correct_error;
residual_error_matrix=vector2matrix(residual_error,repeat_times);
residual_error_avg = matrix2vector(residual_error_matrix);
[non , residual_error_avg_amp , residual_error_avg_phase] = fourier_ts(residual_error_avg);


%% 電子誤差

electric_error = residual_error-machine_error_full;
electric_error_matrix = vector2matrix(electric_error,repeat_times);
electric_error_avg = matrix2vector(electric_error_matrix);




%% plot
%repeat_times = 10;
%sample_freq = 66;
%signal_len = sample_freq*repeat_times;

%1-1感測角
%1-2命令角
str=compose("encoder value(1圈 %d步)",sample_freq);
figure (1);
subplot(2,1,1)
plot(sensing_angle);
title(str)
xlabel('step')
ylabel('encoder count')
str=compose("command value(1圈 %d步)",sample_freq);
subplot(2,1,2)
plot(control_angle);
title(str)
xlabel('step')
ylabel('encoder count')

%2命令角-感測角
figure (2);
plot(encoder_error);
title('command angle - sensing angle (encoder error)')
xlabel('step')
ylabel('encoder count')

%3命令角-感測角(頻域)
figure (3);
plot(encoder_err_amp);
title('encoder error (frequency domain)')
xlabel('1/step')
ylabel('|error|')

%5.1 拆分的encoder誤差
%5.2 encoder誤差的頻譜
figure (5);
subplot(2,1,1)
str=compose("每圈的encoder error(共%d圈)",repeat_times);
plot(step_x_1period,encoder_error_matrix);
title(str)
xlabel('step')
ylabel('encoder count')
subplot(2,1,2)
stem(freq_x_1period,encoder_error_fft_matrix_abs);
str=compose("每圈encoder error的頻譜(共%d圈)",repeat_times);
title(str)
xlabel('1/step')
ylabel('|encoder error|')

%6.1 平均的encoder error誤差
%6.2 平均的encoder error頻譜
figure (6);
subplot(2,1,1)
str=compose("%d圈encoder error頻譜的平均",repeat_times);
title('10次 fft 平均的結果')
stem(freq_x_1period,encoder_error_avg_abs);
title(str)
xlabel('1/step')
ylabel('|encoder error|')
subplot(2,1,2)
stem(freq_x_1period,encoder_error_avg_ang*180/pi)
title('平均後的相位')
xlabel('1/step')
ylabel('ㄥencoder error (deg)')
ylim([-180 180])

%4偏心誤差 VS 原始誤差
figure (4);
plot(step_x,correct_error,'k',step_x,encoder_error,'-.');
str = compose("偏心誤差(DC+1,2,4,6,8倍頻) vs 原始誤差\n實線:偏心誤差  虛線:原始誤差");
title(str);
xlabel('step')
ylabel('encoder error')

%7 偏心誤差 vs 原始誤差(平均)
figure (7);
plot(step_x_1period,correct_function,step_x_1period,encoder_error_avg,'-.');
str = compose("偏心誤差(DC+1,2,4,6,8倍頻) vs 原始誤差(%d圈平均)\n實線:偏心誤差  虛線:原始誤差",repeat_times);
title(str)
xlabel('step')
ylabel('encoder count')

%8 剩餘誤差
figure (8);
plot(step_x,residual_error);
title('平均誤差 - 角度補償')
xlabel('step')
ylabel('encoder count')

%9 拆分剩餘誤差
%原本為'剩餘誤差 每5圈電子角為一筆數據,共22筆'，但不明白這麼做的原因
%步進馬達50圈換一圈，每5圈可以看出重現性，但外轉子馬達不一樣7轉或11轉換一圈這麼做會把有重現性的數據做平均掉
figure (9)
plot(step_x_1period,residual_error_matrix);
title('剩餘誤差')
xlabel('step')
ylabel('encoder count')

%10.1 餘誤差大小
%10.2 餘誤差相位
figure (10)
subplot(2,1,1)
stem(freq_x_1period,residual_error_avg_amp)
title('剩餘誤差的大小')
xlabel('1/step')
ylabel('|encoder error|')
subplot(2,1,2)
stem(freq_x_1period,residual_error_avg_phase*180/pi)
title('剩餘誤差的相位')
xlabel('1/step')
ylabel('ㄥencoder error * pi')
ylim([-180 180])

%11 剩餘 VS 機械誤差(分開)
figure (11)
subplot(2,1,1);
plot(residual_error_matrix);
ylim([-10 15])
xlim([1 30])
title('殘餘物差')
xlabel('step')
ylabel('encoder count')
subplot(2,1,2);
plot(electric_error_matrix);
ylim([-10 15])
xlim([1 30])
title('電子誤差')
xlabel('step')
ylabel('encoder count')

%11 剩餘 VS 機械誤差(平均)
figure (12)
plot(step_x_1period,machine_error,step_x_1period,residual_error_avg,'--');
str = compose("機械誤差(11、22倍頻) VS 剩餘誤差\n實線:機械誤差  虛線:剩餘誤差");
title(str)
xlabel('step')
ylabel('encoder count')

%12-1電子誤差
%12-2殘餘誤差
figure (13)
subplot(2,1,1);
plot(residual_error);
ylim([-10 15])
xlim([1 660])
title('殘餘物差')
xlabel('step')
ylabel('encoder count')
subplot(2,1,2);
plot(residual_error-machine_error_full);
ylim([-10 15])
xlim([1 660])
title('電子誤差')
xlabel('step')
ylabel('encoder count')

%12電子VS殘餘 誤差
figure (14)
plot(step_x,residual_error,'--',step_x,electric_error);
str = compose("剩餘誤差 VS 電子誤差\n實線:電子誤差  虛線:剩餘誤差");
title(str)
xlabel('step')
ylabel('encoder count')

%12電子VS殘餘 平均誤差
figure (15)
plot(step_x_1period,residual_error_avg,'--',step_x_1period,electric_error_avg);
str = compose("剩餘誤差 VS 電子誤差(%d圈平均)\n實線:電子誤差  虛線:剩餘誤差",repeat_times);
title(str)
xlabel('step')
ylabel('encoder count')


