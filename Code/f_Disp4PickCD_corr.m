function f_Disp4PickCD_corr(time,fcm,T,FTAN,ENV,trace,dist,dt,maxlagsel)
% f_Disp4PickCD_corr:   Program to display selected cross-correlation, 
%                       for a posterior selection of which part of the GF,
%                       user want to pick the dispersion curve.

    colorRB    = evalin('base', 'colorRB');
    minvel    = evalin('base', 'minvel');
    maxvel    = evalin('base', 'maxvel');
    respix=get(0,'ScreenSize');
    fontesc10=round(10*sqrt(respix(3)^2+respix(4)^2)/2202);
    ENVT=ENV(:,length(fcm):-1:1);       % ENVELOPE FOR PERIODS
    ENVTn=ENVT(length(time):-1:1,:);   % ENVELOPE FOR PERIODS (ANTICAUSAL)
    
    %% RESAMPLE OF THE DATA FOR A FASTER CALCULUS
    RESCALE=5;
    dt=dt*RESCALE;  
    trace=resample(double(trace),1,RESCALE);
    ENV=resample(double(ENV),1,RESCALE); 
    FTAN=resample(double(FTAN),1,RESCALE);
    ENVT=resample(double(ENVT),1,RESCALE);
    ENVTn=resample(double(ENVTn),1,RESCALE);
    time=linspace(-max(time),max(time),length(ENV));

    %% STRING AXIS FOR VISUALIZATION OF THE FTAN & DISPERSION CURVES
    ejeT=cell(length(fcm),1);   
    for kk=1:3:length(fcm)
        ejeT{kk}=num2str(round((1/fcm(kk)).*100)./100); 
    end

    Tlog_tick=log10(min(1./fcm)):0.1:log10(max(1./fcm));
    Tlog_tick=round(Tlog_tick*100)/100;
    T_tick2=round(10.^(Tlog_tick)*100)/100;
    ejeT2=cell(length(T_tick2),1);
    for kk=1:2:length(T_tick2)
        ejeT2{kk}=num2str(T_tick2(kk)); 
    end

    %% DISPLAY OF FTAN (WAVEFORM - COLORMAP)   &   VELOCITYvsPERIOD DIAGRAM
    [VEL,logTT]     =   meshgrid(dist./time,log10(T));
    
    % FTAN (WAVEFORM)
    subplot(3,4,[1:2,5:6]),cla,hold off
    nkfil=0;
    for kkf=1:length(fcm)
        nkfil=nkfil+1;
        tracek=FTAN(:,kkf);
        tracek=f_Taper(tracek,0.1);
        tracek=tracek-mean(tracek);
        tracek=tracek./max(abs(tracek));
        plot(time,tracek+(nkfil-1),'k'),hold on
    end
    grid on,axis([-maxlagsel maxlagsel -1 nkfil])
    ylabel('\bf PERIOD [s]'),xlabel('\bf TIME [s]')
    title(['\bf FTAN Dist. ',num2str(dist),' [km]'])
    set(gca,'YTick',1:length(ejeT),'YTickLabel',ejeT)
	    
    [TIME,logFF]    =   meshgrid(time,log10(fcm));
    
    % TIMEvsPERIOD DIAGRAM (ANTICAUSAL)
    subplot(3,4,[4,8]),cla,hold off
    pcolor(TIME,logFF,ENV'),shading interp,hold on,grid on
    axis([0 maxlagsel min(log10(fcm)) max(log10(fcm))])
    xlabel('\bf TIME [s]')
    
    % TIMEvsPERIOD DIAGRAM (CAUSAL)
    subplot(3,4,[3,7]),cla,hold off
    pcolor(TIME,logFF,ENV'),shading interp,hold on,grid on
    axis([-maxlagsel 0 min(log10(fcm)) max(log10(fcm))])
    xlabel('\bf TIME [s]')     
        
    % VELOCITYvsPERIOD DIAGRAM (ANTICAUSAL)
    subplot(3,4,11),cla,hold off,colormap(colorRB)
    pcolor(logTT,VEL,ENVTn'),shading interp
    set(gca,'XTick',Tlog_tick,'XTickLabel',ejeT2,'fontsize',fontesc10)
    xlabel('\bf PERIOD [s]'),ylabel('\bf GROUP VELOCITY [km/s]')
    title('\bf ANTICAUSAL DISPERSION CURVE ')
    axis([min(log10(T)) max(log10(T)) minvel maxvel])
    
    % VELOCITYvsPERIOD DIAGRAM (CAUSAL)  
    subplot(3,4,12),cla,hold off
    pcolor(logTT,VEL,ENVT'),shading interp
    set(gca,'XTick',Tlog_tick,'XTickLabel',ejeT2,'fontsize',fontesc10)
    xlabel('\bf PERIOD [s]'),ylabel('\bf GROUP VELOCITY [km/s]')
    title('\bf CAUSAL DISPERSION CURVE')       
    axis([min(log10(T)) max(log10(T)) minvel maxvel])
    
    assignin('base', 'Tlog_tick', Tlog_tick)
    assignin('base', 'ejeT2', ejeT2)
end















