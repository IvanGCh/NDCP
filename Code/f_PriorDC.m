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
        time=traceHDR.B:dt:traceHDR.E;
    end
%     if strcmp(filetype,'correlogram')==1        
%         maxtime=(dt*length(trace)-dt)/2;
%         time=-maxtime:dt:maxtime;           time=round(time.*1000)./1000;
%         tcut = -maxlagsel:dt:maxlagsel;
%         for k1=1:length(time)
%             if round(time(k1)*1000)==round(tcut(1)*1000)
%                 ind1=round(k1);
%                 ind2=ind1+2*round(maxlagsel/dt);
%             end
%         end
%         trace=trace(ind1:ind2);   
%         trace=f_Taper(trace,0.005);      
%         time=time(ind1:ind2);
%     
%     elseif strcmp(filetype,'seismic_record')==1        
%         maxlagsel=traceHDR.E;
%         time=traceHDR.B:dt:traceHDR.E;
%     end
    
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

    if strcmp(filetype,'correlogram')==1 
        f_Disp4PickCD_corr(time,fcm,T,FTAN,ENV,trace,dist,dt,maxlagsel);
        
        uicontrol('Style','text','String',' PART OF CC TO PICK ','background','w','FontSize',fontesc10,'Units','normalized','Position',[0.5 0.955 0.1 0.03])  
        uicontrol('Style','popup','String', 'CONTINUOUS CAUSAL|CONTINUOUS NON-CAUSAL|SEGMENTED  CAUSAL|SEGMENTED  NON-CAUSAL','FontSize',fontesc10,'Units','normalized','Position', [0.6 0.935 0.10 0.05],'Callback', @f_SelectCausal2);   

        uicontrol('Style','pushbutton','String','SAVE CURVE','FontSize',fontesc10,'Callback',{@f_SaveDC},'Units', 'normalized','Position', [0.8,0.96,0.08,0.03]);
        uicontrol('Style','pushbutton','String','EXPORT ALL CURVES','FontSize',fontesc10,'Callback',{@f_ExportDC},'Units', 'normalized','Position', [0.89,0.96,0.1,0.03]);
    
    elseif strcmp(filetype,'seismic_record')==1
        f_Disp4PickCD_seisrec(time,fcm,T,FTAN,ENV,trace,dist,dt);
        uicontrol('Style','pushbutton','String', ' PICK DISPERSION CURVE ','FontSize',fontesc10,'Units','normalized','Position', [0.55 0.96 0.12 0.03],'Callback', @f_PickSeisRec);   
        uicontrol('Style','pushbutton','String','SAVE CURVE','FontSize',fontesc10,'Callback',{@f_SaveDC},'Units', 'normalized','Position',[0.7,0.96,0.1,0.03]);
        uicontrol('Style','pushbutton','String','EXPORT ALL CURVES','FontSize',fontesc10,'Callback',{@f_ExportDC},'Units', 'normalized','Position',[0.81,0.96,0.15,0.03]);
    end
    
    assignin('base', 'kreg', kreg)
    assignin('base', 'trace', trace)
    assignin('base', 'dist', dist)
    assignin('base', 'time', time)
end