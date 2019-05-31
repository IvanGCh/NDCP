function f_Disp4PickCD_seisrec(time,fcm,T,FTAN,ENV,trace,dist,dt)
% f_Disp4PickCD_seisrec:    Program to display selected seismic record, 
%                           which could be selected to pick the 
%                           corresponding dispersion curve.
   
    colorRB    = evalin('base', 'colorRB');
    minvel    = evalin('base', 'minvel');
    maxvel    = evalin('base', 'maxvel');
    respix=get(0,'ScreenSize');
    fontesc10=round(10*sqrt(respix(3)^2+respix(4)^2)/2202);
    ENVT=ENV(:,length(fcm):-1:1);       % ENVELOPE FOR PERIODS
    ENVTn=ENVT(length(time):-1:1,:);   % ENVELOPE FOR PERIODS (NON-CAUSAL)
    timeor=time;
    
    %% RESAMPLE OF THE DATA FOR A FASTER CALCULUS
    RESCALE=5;
    dt=dt*RESCALE;  
    trace=resample(double(trace),1,RESCALE);
    ENV=resample(double(ENV),1,RESCALE); 
    FTAN=resample(double(FTAN),1,RESCALE);
    ENVT=resample(double(ENVT),1,RESCALE);
    ENVTn=resample(double(ENVTn),1,RESCALE);
	time=linspace(min(timeor),max(timeor),length(ENV));

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
    [TIME,logFF]    =   meshgrid(time,log10(fcm));
    [VEL,logTT]     =   meshgrid(dist./time,log10(T));
    
    % FTAN (WAVEFORM)
    subplot(3,4,[1:2,5:6]),hold off
    nkfil=0;
    for kkf=1:length(fcm)
        nkfil=nkfil+1;
        tracek=FTAN(:,kkf);
        tracek=f_Taper(tracek,0.1);
        tracek=tracek./max(abs(tracek));
        plot(time,tracek+(nkfil-1),'k'),hold on
    end
    grid on,axis([0 max(time) -1 nkfil])
    ylabel('\bf PERIOD [s]'),xlabel('\bf TIME [s]')
    title(['\bf FTAN Dist. ',num2str(dist),' [km]'])
    set(gca,'YTick',1:length(ejeT),'YTickLabel',ejeT)
	
    % VELOCITYvsPERIOD DIAGRAM 
    subplot(3,4,11),hold off,colormap(colorRB)
    pcolor(logTT,VEL,ENVT'),shading interp
    axis([min(log10(T)) max(log10(T)) minvel maxvel])
    set(gca,'XTick',Tlog_tick,'XTickLabel',ejeT2,'fontsize',fontesc10)
    xlabel('\bf PERIOD [s]'),ylabel('\bf GROUP VELOCITY [km/s]')
    title('\bf DISPERSION CURVE')
       
    % FTAN (COLORMAP)... FOR A FTAN-like PICKING
    subplot(3,4,[3:4,7:8]),hold off,colormap(colorRB)
    pcolor(TIME,logFF,ENV'),shading interp,hold on,grid on
    axis([0 max(time) min(log10(fcm)) max(log10(fcm))])
    set(gca,'YTick',Tlog_tick,'YTickLabel',ejeT)
    title(['\bf FTAN Dist. ',num2str(dist),' [km]'])
    xlabel('\bf TIME [s]')

    
    assignin('base', 'Tlog_tick', Tlog_tick)
    assignin('base', 'ejeT2', ejeT2)
end
