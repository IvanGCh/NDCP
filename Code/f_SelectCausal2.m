function f_SelectCausal2(hObj,event) %#ok<INUSD>
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
    
    RESCALE=5;
    dt=dt*RESCALE;
    trace=resample(double(trace),1,RESCALE);  
    time=linspace(-maxlagsel,maxlagsel,length(trace));
	ENV=resample(double(ENV),1,RESCALE); 
    [TIME,logFF]    =   meshgrid(time,log10(fcm));
    
    
    if val==1 || val==3        %% PICKING ON CAUSAL PART
        subplot(3,4,[4,8]),cla,hold off
        pcolor(TIME,logFF,ENV'),shading interp,hold on,grid on
        axis([0 maxlagsel min(log10(fcm)) max(log10(fcm))])
        title('\bf  *** PICK HERE *** '),xlabel('\bf TIME [s]')
        
    elseif val ==2 || val==4   %% PICKING ON ANTICAUSAL PART
        subplot(3,4,[3,7]),cla,hold off
        pcolor(TIME,logFF,ENV'),shading interp,hold on,grid on
        axis([-maxlagsel 0 min(log10(fcm)) max(log10(fcm))])
        title('\bf  *** PICK HERE *** '),xlabel('\bf TIME [s]')        
    end

    % SELECTED OPTION FOR CONTINUOUS OR SEGMENTED PICKING OF THE CURVE
    if val == 3 || val == 4        
        uicontrol('Style','text','String',' # segm. ','background','w','FontSize',fontesc10,'Units','normalized','Position',[0.7,0.95 ,0.05,0.03])  
        uicontrol('Style','edit','FontSize',fontesc10,'Callback', {@f_SegmentsNumber},'Units','normalized','Position',[0.74,0.96,0.015,0.03]);    
        uicontrol('Style','pushbutton','String',' PICK ','FontSize',fontesc10,'Callback','uiresume(gcbf)','Units', 'normalized','Position',[0.765,0.96,0.025,0.03]);
        uiwait(gcf)
    elseif val == 1 || val == 2
        numsegm=1;
        assignin('base', 'numsegm', numsegm)
    end    
    
    numsegm= evalin('base', 'numsegm');
    
    % PICKING THE MAXIMUM AMPLITUDE ON DISPERSED WAVES
    
	CDpicked_full=[];  
    for ksegm=1:numsegm
        
        [~,pickT,pickF] = f_Selectdata('sel','br'); 
        pickF=10.^(pickF);
        pickF=round(pickF'.*1000)./1000;      
        fcmpick=round(fcm'.*1000)./1000;

        % SEARCHING IN EACH PICKED PERIOD
        CDpicked=zeros(length(fcm),4);   
        L2=round(length(time)/2);
        for kfil=1:length(fcmpick)-1       
            valnull=[0,0,0];
            for kkt=L2+round(min(pickT)/dt):L2+round(max(pickT)/dt)
                for kkp=1:length(pickT)
                    if time(kkt)==pickT(kkp) && fcmpick(kfil)==pickF(kkp)
                        valnull=[valnull;(pickT(kkp)),pickF(kkp),ENV(kkt,kfil)];
                    end
                end
            end
        [~,maxampind]=max(valnull(:,3));
        CDpicked(kfil,1)=valnull(maxampind,2);     % 1st col.:   FREQUENCY
        CDpicked(kfil,4)=valnull(maxampind,1);     % 4st col.:   PICKED TIME
        end
        CDpicked(:,2)=1./CDpicked(:,1);            % 2nd col.:   PERIOD
        CDpicked(:,3)=dist./CDpicked(:,4);         % 3th col.:   VELOCITY

        [r,c,~] = find(CDpicked);   ind=0;
        for k=1:length(c)
            if c(k)==1 && r(k)~=0
                ind=[ind,r(k)];
            end
        end
        CDpicked=CDpicked(ind(2:length(ind)),:);
        CDpicked_full=[CDpicked_full;CDpicked];
    end
    
    assignin('base', 'CDpicked', CDpicked)
    
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












