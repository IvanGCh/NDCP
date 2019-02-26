function [spec,freq]=f_Spectrum(trace,dt)
% f_Spectrum:   perform FFT of trace, of certain sampling rate (dt)
%               output variables are the FFT and frequency vector
nxn=size(trace);  L=nxn(1);   K=nxn(2);
T=L*dt;
f0=1/T;     
fN=1/(2*dt); 
freq=-fN:f0:fN-f0;

if      K==1
    spec=fftshift(fft(trace)/T);
elseif  K==3
    spec=zeros(L,K);
    spec(1:L,1)=fftshift(fft(trace(:,1))/T);
    spec(1:L,2)=fftshift(fft(trace(:,2))/T);          
    spec(1:L,3)=fftshift(fft(trace(:,3))/T);
end

end