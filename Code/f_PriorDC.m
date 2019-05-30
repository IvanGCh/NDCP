function f_PriorDC(hObject, eventdata, handles)
% f_PriorDC:    selection of previous GF to make FTAN. As the initial GF,
%               read and get headers information to obtain inter-station
%               distance, cut signal (if it is a cross-correlogram), and
%               perform FTAN.
%               At the end, on the visualization step, user can select
%               which part of the FG will be picked (causal or non-causal).

    nsac= evalin('base', 'nsac');
    kreg= evalin('base', 'kreg');
    maxlagsel= evalin('base', 'maxlagsel');
    filetype= evalin('base', 'filetype');
    respix=get(0,'ScreenSize');
    fontesc10=round(10*sqrt(respix(3)^2+respix(4)^2)/2202);   
    fontesc12=round(12*sqrt(respix(3)^2+respix(4)^2)/2202);
    
	if kreg>1
        kreg=kreg-1;
    end
    
    uicontrol('Style','text','String',[num2str(kreg) ' / ',num2str(nsac) , '  file' ],'background','w','FontSize',12,'Units','normalized','Position',[0.3 0.95 0.05 0.03])  
    
    %%
    pathsac= evalin('base', 'pathsac');
    sacfiles= evalin('base', 'sacfiles');
    namesac=[pathsac,sacfiles(kreg).name];
    trace=rdsac(namesac);
    traceHDR=trace.HEADER;
    dt=traceHDR.DELTA;  dt=1/round(1/dt);
    lat=[traceHDR.STLA,traceHDR.EVLA];
    lon=[traceHDR.STLO,traceHDR.EVLO];
    [az,dist]=legs(lat,lon,'gc');
    dist=dist*1.852;
      
    trace=trace.d;
          
    if strcmp(filetype,'correlogram')==1  
        maxtime=dt*(length(trace)-1)/2;
        time=-(maxtime/dt):(maxtime/dt);
        
        if exist('maxlagsel','var')==1
            tcut = -(maxlagsel/dt):(maxlagsel/dt);    
            for k1=1:length(time)
                if round(time(k1))==round(tcut(1))
                    ind1=k1;
                end
                if round(time(k1))==round(tcut(length(tcut)))
                    ind2=k1;
                end
            end
        else
            ind1=1;
            ind2=length(trace);
        end
            
        trace=trace(ind1:ind2);     
        trace=f_Taper(trace,0.005);   
        time=time(ind1:ind2).*dt;
    
    elseif strcmp(filetype,'seismic_record')==1        
        maxlagsel=traceHDR.E;
        time=traceHDR.B:dt:traceHDR.B+((length(trace)-1)*dt);
    end
    
    subplot(3,4,[3,7]),cla
    subplot(3,4,[4,8]),cla
    
    subplot(3,4,9:10),hold off
    plot(time,trace,'k'),axis([min(time) max(time) -max(abs(trace)) max(abs(trace))])
    if strcmp(filetype,'seismic_record')==1
        xlim([0 max(time)])
    end
    namesacfile=sacfiles(kreg).name;
    for kchar=1:length(namesacfile)
        if strcmp(namesacfile(kchar),'_')==1
            namesacfile(kchar)=' ';
        end
    end
    title(['\bf FILE`S NAME: ',char(namesacfile), ],'fontsize',fontesc12)
       
    %%
    Tmin= evalin('base', 'Tmin');
    Tmax= evalin('base', 'Tmax');    
    filt= evalin('base', 'filt');
    fstep= evalin('base', 'fstep');
    width= evalin('base', 'width');
    filterorder= evalin('base', 'filterorder');
    [FTAN,ENV,fcm]    =   f_FTAN_Env(trace,dt,1/Tmax,1/Tmin,filt,fstep,width,filterorder);
    T=1./fcm;   T=T(length(T):-1:1);
    pickopt = 'REPEATED-CLICKS';
       
    if     strcmp(filetype,'correlogram')==1 
        f_Disp4PickCD_corr(time,fcm,T,FTAN,ENV,trace,dist,dt,maxlagsel);
        bg = uibuttongroup('Visible','off','Title','PICKING MODE','Position',[0.505 0.93 0.09 0.067],'SelectionChangedFcn',@f_bselection_corr,'FontSize',fontesc10);   
        r1 = uicontrol(bg,'Style','radiobutton','String','REPEATED-CLICKS','Position',[10 22 150 16],'HandleVisibility','off','FontSize',fontesc10);
        r2 = uicontrol(bg,'Style','radiobutton','String','CLICK&HOLD','Position',[10 3 150 16],'HandleVisibility','off','FontSize',fontesc10);
        bg.Visible = 'on';
    
    elseif strcmp(filetype,'seismic_record')==1
        f_Disp4PickCD_seisrec(time,fcm,T,FTAN,ENV,trace,dist,dt);  
        bg = uibuttongroup('Visible','off','Title','PICKING MODE','Position',[0.505 0.93 0.09 0.067],'SelectionChangedFcn',@f_bselection_corr,'FontSize',fontesc10); %  pickopt = 'REPEATED-CLICKS';
        r1 = uicontrol(bg,'Style','radiobutton','String','REPEATED-CLICKS','Position',[10 22 150 16],'HandleVisibility','off','FontSize',fontesc10);
        r2 = uicontrol(bg,'Style','radiobutton','String','CLICK&HOLD','Position',[10 3 150 16],'HandleVisibility','off','FontSize',fontesc10);
        bg.Visible = 'on';

  end  

    assignin('base', 'kreg', kreg)
    assignin('base', 'trace', trace)
    assignin('base', 'dist', dist)
    assignin('base', 'time', time)
    assignin('base', 'pickopt', pickopt)
end
