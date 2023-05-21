%%  function to output cosine
function output = cos_wave_gen(magni,phase,freq,len)

index=0:len-1;
index=index*2*pi/len;
output =magni*cos(index*freq+phase);
output=output';
end