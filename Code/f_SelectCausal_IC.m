function f_SelectCausal_IC(hObj,event) %#ok<INUSD>
% f_SelectCausal:   For CROSS-CORRELOGRAMs, user can select which part of
%                   the GF will pick: Causal or Non-Causal. 
%                   From the selected TRACE, NDCP will perform FTAN with
%                   parameters defined at first, and the picking of the
%                   curve will be on the selected part.
%                   For the picking, user must click and hold where the
%                   dispersion of surface waves phenomena appear. Once the
%                   user finish, just release 

    val = get(hObj,'Value');

    time    = evalin('base', 'time');
    dist    = evalin('base', 'dist');
    dt      = evalin('base', 'dt');
    maxlagsel = evalin('base', 'maxlagsel');    
    ind1    = evalin('base', 'ind1');
    ind2    = evalin('base', 'ind2');
    kreg    = evalin('base', 'kreg');    
    pathsac = evalin('base', 'pathsac');
    sacfiles= evalin('base', 'sacfiles');    
    namesac = [pathsac,sacfiles(kreg).name];
    trace   = rdsac(namesac);    
    trace   = trace.d;   
	trace   = trace(ind1:ind2);   
    trace   = f_Taper(trace,0.005);   
    
	Tmin    = evalin('base', 'Tmin');
    Tmax    = evalin('base', 'Tmax');
    filt    = evalin('base', 'filt');
    fstep   = evalin('base', 'fstep');
    width   = evalin('base', 'width');
    filterorder = evalin('base', 'filterorder');  
    minvel  = evalin('base', 'minvel');   
    maxvel  = evalin('base', 'maxvel');      
    respix  =get(0,'ScreenSize');
    fontesc10 =round(10*sqrt(respix(3)^2+respix(4)^2)/2202);
    fontesc12 =round(12*sqrt(respix(3)^2+respix(4)^2)/2202);
    
    [~,ENV,fcm]    =   f_FTAN_Env(trace,dt,1/Tmax,1/Tmin,filt,fstep,width,filterorder);    
    ENVT=ENV(:,length(fcm):-1:1); 
    ENVTn=ENVT(length(trace):-1:1,:);
    T=1./fcm;   T=T(length(T):-1:1);    vel=dist./time;
    [VEL,logTT]     =   meshgrid(dist./time,log10(T));

    % SELECTED OPTION FOR CONTINUOUS OR SEGMENTED PICKING OF THE CURVE
    if val == 3 || val == 4        
        uicontrol('Style','text','String',' # SEGMENTS ','background','w','FontSize',fontesc10,'Units','normalized','Position',[0.76,0.96,0.075,0.03])  
        uicontrol('Style','edit','FontSize',fontesc10,'Callback', {@f_SegmentsNumber},'Units','normalized','Position',[0.775,0.945,0.015,0.025]);    
        uicontrol('Style','pushbutton','String',' PICK ','FontSize',fontesc10,'Callback','uiresume(gcbf)','Units', 'normalized','Position',[0.795,0.945,0.025,0.025]);
        uiwait(gcf)
    elseif val == 1 || val == 2
        numsegm=1;
        assignin('base', 'numsegm', numsegm)
    end    
    
    numsegm= evalin('base', 'numsegm');
    
    %% PICKING THE MAXIMUM AMPLITUDE ON DISPERSED WAVES
    if val==1 || val==3        %% PICKING ON CAUSAL PART
        subplot(3,4,[4,8])
    elseif val ==2 || val==4   %% PICKING ON ANTICAUSAL PART
        subplot(3,4,[3,7]) 
    end
    
	CDpicked_full=[];  
    for ksegm=1:numsegm
        
        % If you want to delete previous point, press BACKSPACE.
        % For ending pincking, press ENTER.
        [pickT,pickF] = getpts;
        
        pickF=10.^(pickF);
        pickF=round(pickF.*1000)./1000; 
        fcmpick=round(fcm'.*1000)./1000;
        
        pickTi = spline(pickF,pickT,fcmpick);  
        [aaa,~]=find(fcmpick>min(pickF));   [bbb,~]=find(fcmpick<max(pickF));
        pickF =fcmpick(min(aaa):max(bbb));  pickT=pickTi(min(aaa):max(bbb));

        CDpicked=pickF;                     % 1st col.:   FREQUENCY
        CDpicked=[CDpicked,1./pickF];       % 2nd col.:   PERIOD
        CDpicked=[CDpicked,dist./pickT];    % 3th col.:   VELOCITY
        CDpicked=[CDpicked,pickT];          % 4st col.:   PICKED TIME

        CDpicked_full=[CDpicked_full;CDpicked];
    end
    
    assignin('base', 'CDpicked', CDpicked)    
%     assignin('base', 'pickTi', pickTi)
%     assignin('base', 'fcmpick',fcmpick)
%     assignin('base', 'pickT', pickT)
%     assignin('base', 'pickF',pickF)
    %figure,plot(fcmpick,pickTi,'*k'),hold on,plot(pickF,pickT,'or'),plot(pickF2,pickTi2,'bs')
    
    %% PLOT OF PICKED DISPERSION CURVE
    Tlog_tick     = evalin('base', 'Tlog_tick');
    ejeT2     = evalin('base', 'ejeT2');
    
    if val==1 || val==3
        subplot(3,4,12),cla,hold on
        title('\bf CAUSAL DISPERSION CURVE')
        pcolor(logTT,VEL,ENVT'),shading interp 
        
    elseif val==2 || val==4
        subplot(3,4,11),cla,hold on
        title('\bf ANTICAUSAL DISPERSION CURVE')
        pcolor(logTT,VEL,ENVTn'),shading interp 
    
    end  
    plot(log10(CDpicked_full(:,2)),abs(CDpicked_full(:,3)),'*g')
    axis([min(log10(T)) max(log10(T)) minvel maxvel])
    set(gca,'XTick',Tlog_tick,'XTickLabel',ejeT2,'fontsize',fontesc10)
    xlabel('\bf PERIOD [s]'),ylabel('\bf GROUP VELOCITY [km/s]')
    
end












