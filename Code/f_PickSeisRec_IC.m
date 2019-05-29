function f_PickSeisRec(hObj,event) %#ok<INUSD>
% f_PickSeisRec:    For SEISMOGRAMS, user can pick dispersion curve. 
%                   For the picking, user must click and hold where the
%                   dispersion of surface waves phenomena appear. Once the
%                   user finish, just release.
    valnull = get(hObj,'Value');

    time    = evalin('base', 'time');
    dist    = evalin('base', 'dist');
    dt      = evalin('base', 'dt');
    kreg    = evalin('base', 'kreg');    
    pathsac = evalin('base', 'pathsac');
    sacfiles= evalin('base', 'sacfiles');   
    minvel  = evalin('base', 'minvel'); 
    maxvel  = evalin('base', 'maxvel');
    respix  = get(0,'ScreenSize');
    fontesc10 = round(10*sqrt(respix(3)^2+respix(4)^2)/2202);
    
    namesac=[pathsac,sacfiles(kreg).name];
    trace=rdsac(namesac);    
    trace=trace.d;   
    trace=f_Taper(trace,0.005);   
    
	Tmin    = evalin('base', 'Tmin');
    Tmax    = evalin('base', 'Tmax');
    filt    = evalin('base', 'filt');
    fstep   = evalin('base', 'fstep');
    width   = evalin('base', 'width');
    filterorder= evalin('base', 'filterorder');    
    [~,ENV,fcm]    =   f_FTAN_Env(trace,dt,1/Tmax,1/Tmin,filt,fstep,width,filterorder);
    ENVT=ENV(:,length(fcm):-1:1); 
    T=1./fcm;   T=T(length(T):-1:1);    vel=dist./time;
    [VEL,logTT]     =   meshgrid(dist./time,log10(T));
    
    RESCALE=5;
    dt=dt*RESCALE;
    trace=resample(double(trace),1,RESCALE);  
    time=linspace(min(time),max(time),length(trace));
	ENV=resample(double(ENV),1,RESCALE); 
    [TIME,logFF]    =   meshgrid(time,log10(fcm));
    
    subplot(3,4,[3:4,7:8]),cla,hold off
    pcolor(TIME,logFF,ENV'),shading interp,hold on,grid on
    axis([0 max(time) min(log10(fcm)) max(log10(fcm))])
    title('\bf  *** PICK HERE *** '),xlabel('\bf TIME [s]')

    %% PICKING THE MAXIMUM AMPLITUDE ON DISPERSED WAVES
    
    % If you want to delete previous point, press BACKSPACE.
    % For ending pincking, press ENTER.
    [pickT,pickF] = getpts;
    pickF=10.^(pickF);
    pickF=round(pickF'.*1000)./1000;      
    fcmpick=round(fcm'.*1000)./1000;
  
    pickTi = spline(pickF,pickT,fcmpick);  
    [aaa,~]=find(fcmpick>min(pickF));   [bbb,~]=find(fcmpick<max(pickF));
    pickF =fcmpick(min(aaa):max(bbb));  pickT=pickTi(min(aaa):max(bbb));

    CDpicked=pickF;                     % 1st col.:   FREQUENCY
    CDpicked=[CDpicked,1./pickF];       % 2nd col.:   PERIOD
    CDpicked=[CDpicked,dist./pickT];    % 3th col.:   VELOCITY
    CDpicked=[CDpicked,pickT];          % 4st col.:   PICKED TIME

    assignin('base', 'CDpicked', CDpicked)
       
    %%
    
    Tlog_tick     = evalin('base', 'Tlog_tick');
    ejeT2     = evalin('base', 'ejeT2');
    
    subplot(3,4,11),cla,hold on
    pcolor(logTT,VEL,ENVT'),shading interp    
    plot(log10(CDpicked(:,2)),CDpicked(:,3),'*g')
    axis([min(log10(T)) max(log10(T)) minvel maxvel])
    set(gca,'XTick',Tlog_tick,'XTickLabel',ejeT2,'fontsize',fontesc10)
    xlabel('\bf PERIOD [s]'),ylabel('\bf GROUP VELOCITY [km/s]')
    title('\bf CAUSAL DISPERSION CURVE')
    
    
end












