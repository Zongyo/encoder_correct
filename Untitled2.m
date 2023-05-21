%% for the function test

[DC , cos_amp , cos_phase] = fourier_ts(encoder_error);
tmp = cos_wave_gen(cos_amp(10),cos_phase(10),10,660);
tmp = tmp + cos_wave_gen(cos_amp(20),cos_phase(20),20,660);
tmp = tmp + cos_wave_gen(cos_amp(40),cos_phase(40),40,660);
tmp = tmp + cos_wave_gen(cos_amp(80),cos_phase(80),80,660);
tmp = tmp + cos_wave_gen(cos_amp(60),cos_phase(60),60,660);
tmp=tmp+DC;

tmp_matrix = vector2matrix(encoder_error,10);
tmp_vec = matrix2vector(tmp_matrix);
plot(tmp_vec);
