function signalt=f_Taper(signal,perc)

signalt=signal;
tapx=linspace(pi/2,3*pi/2,round(perc*(length(signal))));
taperf=(1+sin(tapx))/2;         
taperi=taperf(length(taperf):-1:1);
taperi=taperi'; 
taperf=taperf';
 
taper=[taperi;ones(length(signal)-length(taperf)-length(taperi),1);taperf];  

clear tapx taperf taperi
[~,ncomp]=size(signal);
for kk=1:ncomp
    signalt(:,kk)=signal(:,kk).*taper;
end

end