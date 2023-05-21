%% sample_freq,repeat_times,maxval,minval
function output = tri_wave_gen(sample_freq,repeat_times,maxval,minval)
    vpp = maxval-minval;
    output = zeros(sample_freq*repeat_times,1);
    for i= 0 : repeat_times-1
      for j=1:sample_freq
          output(i*sample_freq+j)=(vpp/sample_freq)*(j-1)+minval;
      end
    end
end
