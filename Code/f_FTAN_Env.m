function [FTAN,ENV,fcm,fcwidth]=f_FTAN_Env(trace,dt,fc1,fc2,filt,df,width,nn)
% f_FTAN_Env:   Performing and application of multi-filtering process,
%               based on band-width of interes, and filter parameters
%               selected.
%               See GRANADOS et al., 2018 for further information, 
    L=size(trace);          L=L(1);     
    FTAN=zeros(L,1);       ENV=zeros(L,1);
    nkfil=0;    
    fcwidth=[0,0];
    for kfil=log10(fc1):df:log10(fc2)
        nkfil=nkfil+1;
        fc1=10^(kfil-width);         fc2=10^(kfil+width);
        fcwidth=[fcwidth;fc1,fc2];
        fcm(nkfil)=(fc2+fc1)/2;
        trace_f=f_FiltSignal(trace,dt,nn,fc1,fc2,filt,'bandpass');
        trace_f=f_Taper(trace_f,0.05);
        FTAN=[FTAN,trace_f./max(trace_f)];

        % ENVOLVENTE (TRANSFORMADA DE HILBERT)
        ENVEL=hilbert(trace_f);         ENVEL=abs(ENVEL);
        ENV=[ENV,ENVEL./max(ENVEL)];
    end
    fcwidth=fcwidth(2:length(fcwidth),:);
    FTAN=FTAN(:,2:nkfil+1);       
    ENV=ENV(:,2:nkfil+1);
end
