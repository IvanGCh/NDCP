%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  NDCP: Noisy Dispersion Curve Picking                                 %%%
%%%  Suite package to pick velocity group dispersion curves of surface    %%%
%%%  wavesfrom noise cross correlation data and earthquakes,  Version 1.0 %%%
%%%                                                                       %%%
%%%        Copyright of Ivan Granados Chavarria                           %%%
%%%        Instituto de Geofisica, UNAM, UNIVERSITY OF MEXICO             %%%
%%%        Circuito de la Investigacion Cientifica s/n                    %%%
%%%        Ciudad Universitaria, Delegacion Coyoacan, 04510, Mexico D.F.  %%%
%%%        email:  igranadosc@igeofisica.unam.mx                          %%%
%%%                                                                       %%%
%%%        NDCP can be downloaded from:                                   %%%
%%%        https://github.com/IvanGCh/NDCP                                %%%
%%%                                                                       %%%
%%%    This code is only for research and teaching proposes. If you plan  %%%
%%%    to use it for business purposes please contact the author.         %%%
%%%                                                                       %%%
%%%                                                                       %%%
%%%    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,    %%%
%%%    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES    %%%
%%%    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND           %%%
%%%    NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE          %%%
%%%    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION    %%%
%%%    OF CONTRACT, TORT OR OTHERWISE,ARISING FROM, OUT OF OR IN          %%%
%%%    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS          %%%
%%%    IN THE SOFTWARE.                                                   %%%
%%%                                                                       %%%
%%%                                                                       %%%
%%%        If you use this code, or parts of it, please cite:             %%%
%%%                                                                       %%%
%%%   Granados, I., Calo, M., and Ramos, V. (2019). NOISY DISPERSION      %%%
%%%   CURVE PICKING (NDCP): a Matlab package for group velocity           %%%
%%%   dispersion picking of seismic surface waves.                        %%%
%%%   Submitted to "Computer and Geosciences".                            %%%
%%%                                                                       %%%
%%%                                                                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%          p1_NDCP: MAIN PROGRAM          %%%%%%%%%%%%%%%%%
close all; warning('off'); clc; clear all
load ColorRB

%% Obtaining screen resolution information
set(0,'units','pixels');
respix=get(0,'ScreenSize');
fontesc10=round(10*sqrt(respix(3)^2+respix(4)^2)/2202);
fontesc12=round(12*sqrt(respix(3)^2+respix(4)^2)/2202);
fontesc16=round(16*sqrt(respix(3)^2+respix(4)^2)/2202);

%% Input 'GREEN'S FUNCTION FILE' & Stations list file
% Initial window for signal selection to be processed. It will take all 
% SAC-files contained in the selected folder.
%       [Opt.1 CROSS-CORRELOGRAM]       [Opt.2 SEISMIC-RECORD]
figure
set(gcf,'color',[1,1,1],'Units','normalized','Units','normalized','Position',[0.2,0.35,0.6,0.4])
uicontrol('Style','text',      'Units','normalized','Position',[0.03 0.85 0.27 0.1],'String',' SELECT TYPE OF DATA TO ANALYZE:','FontSize',fontesc12)
uicontrol('Style','pushbutton','Units','normalized','Position',[0.35 0.85 0.2 0.1] ,'String','CROSS-CORRELOGRAM','FontSize',fontesc12,'Callback', {@f_OPEN_CORRELOGRAM} );      
uicontrol('Style','pushbutton','Units','normalized','Position',[0.6 0.85 0.2 0.1]  ,'String','SEISMIC RECORD','FontSize',fontesc12,'Callback', {@f_OPEN_SEISMIC_RECORD} );
uicontrol('Style','pushbutton','Units','normalized','Position',[0.85 0.85 0.12 0.1],'String','CONTINUE','FontSize',fontesc12,'Callback','uiresume(gcbf)');
uiwait(gcf);  
close

% After selection of a file in certain folder, NDCP will read all the files
% contained here.
sacfilespre1=dir([pathsac,'*.sac']);    
sacfilespre2=dir([pathsac,'*.SAC']);
sacfilespre=[sacfilespre1;sacfilespre2];
nsac=length(sacfilespre);   
sacfiles={};    nnn=0;
for ksac=1:nsac
    fileksac=sacfilespre(ksac).name;
    if strcmp(fileksac(1),'.')==0
        nnn=nnn+1;
        sacfiles{nnn,1}=char(fileksac);
    end
end
clear sacfilespre sacfilespre1 sacfilespre2 ksac fileksac nnn
sacfiles = struct('name',sacfiles);
nsac=length(sacfiles);   
figure,set(gcf,'color',[1,1,1]),set (gcf, 'Units','normalized','Units','normalized','Position',[0.45,0.5,0.2,0.05])
uicontrol('Style','text','Units','normalized','Position',[0.1 0.1 0.8 0.8],'String',[num2str(nsac),' Signals readed'],'FontSize',fontesc16)
pause(0.5)
close

%% TYPE OF FILTER TO USE AT FTAN STAGE
% Variable 'filt' is designed to use one of the three types of filters
% available and described in GRANADOS et al., 2019.
%   [Opt.1 PROGRAMMED]              (Default)
%   [Opt.2 BUTTER+FILTFILT] 
%   [Opt.3 DESIGNFILT+FILTFILT]
filt=1;

%% INTERSTATION/EPICENTRAL DISTANCE   
figure,set (gcf,'color',[1,1,1])
set (gcf, 'Units', 'normalized', 'Position', [0.15,0.2,0.6,0.6])

% Once the SAC file selected is read, headers containing STATION-EVENT
% location will be used to calculate DISTANCE for the proposal definition
% of FTAN parameters.
if strcmp(filetype,'correlogram')==1    
    uicontrol('Style','text','String',' CROSS-CORRELOGRAM RECORD ','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.95,0.25,0.035])  
    uicontrol('Style','text','String',' Cut Signal ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.5,0.1,0.035])  
    uicontrol('Style','edit','FontSize',fontesc10,'Callback', {@f_Cut_signal},'Units','normalized','Position',[0.16,0.5,0.08,0.035]);        
elseif strcmp(filetype,'seismic_record')==1    
    uicontrol('Style','text','String',' SEISMIC RECORD ','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.95,0.25,0.035])          
end

uicontrol('Style','text','String',' Distance [km] ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.9,0.1,0.035]) 
if exist('dist','var')==1
    uicontrol('Style','edit','FontSize',fontesc10,'String',num2str(dist),'Callback',{@f_Insert_Distance},'Units','normalized','Position',[0.16,0.9,0.08,0.035]);
else
    uicontrol('Style','edit','FontSize',fontesc10,'Callback',{@f_Insert_Distance},'Units','normalized','Position',[0.16,0.9,0.08,0.035]);
end

% Visualization of selected file TRACE and AMPLITUDE SPECTRUM.
axes('Position',[0.08,0.09,0.89,0.3])
plot(time,trace./max(abs(trace)),'k')
xlim([min(time) max(time)]),xlabel('\bf TIME [s]'),ylabel('\bf NORMALIZED AMPLITUDE')

subplot(2,3,2:3),   [SPEtrace,freq]=f_Spectrum(trace,dt);
loglog(freq,abs(SPEtrace),'k'),hold on
xlim([min(freq) max(freq)]),xlabel('\bf FREQUENCY [Hz]')
    
%% FTAN PARAMETERS
% At each interstation/epicentral distance, NDCP proposes some
% parameters empirically optimized for the FTAN. User can test different values to
% ensure the best emergence of the Surface wave dispersion pattern.
if      dist<15
    defFTAN=[0.2,4,0.025,0.07,8];
    minvel=0.1;
    maxvel=3.0;
elseif  dist>=15 && dist<80 
    defFTAN=[0.5,10,0.025,0.07,8];
    minvel=0.1;
    maxvel=3.5;
elseif  dist>=80 && dist<150 
    defFTAN=[1,25,0.025,0.07,8];
    minvel=0.5;
    maxvel=4.5;
elseif  dist>150
    defFTAN=[3,80,0.025,0.07,8];
    minvel=1;
    maxvel=6;
end

uicontrol('Style','text','String',' FTAN PARAMETERS ','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.8,0.25,0.035])  
uicontrol('Style','text','String',' T min [s] ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.75,0.1,0.035])  
uicontrol('Style','edit','FontSize',fontesc10,'String',num2str(defFTAN(1)),'Callback',{@f_Insert_Tmin},'Units','normalized','Position',[0.16,0.75,0.08,0.035]);

uicontrol('Style','text','String',' T max [s] ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.7,0.1,0.035])  
uicontrol('Style','edit','FontSize',fontesc10,'String',num2str(defFTAN(2)),'Callback', {@f_Insert_Tmax},'Units','normalized','Position',[0.16,0.7,0.08,0.035]);        

uicontrol('Style','text','String',' fstep ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.65,0.1,0.035])  
uicontrol('Style','edit','FontSize',fontesc10,'String',num2str(defFTAN(3)),'Callback', {@f_Insert_fstep},'Units','normalized','Position',[0.16,0.65,0.08,0.035] );        

uicontrol('Style','text','String',' width ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.6,0.1,0.035])  
uicontrol('Style','edit','FontSize',fontesc10,'String',num2str(defFTAN(4)),'Callback', {@f_Insert_width},'Units','normalized','Position',[0.16,0.6,0.08,0.035]);        

uicontrol('Style','text','String',' Filter order ','background','w','FontSize',fontesc12,'Units','normalized','Position',[0.05,0.55,0.1,0.035])  
uicontrol('Style','edit','FontSize',fontesc10,'String',num2str(defFTAN(5)),'Callback', {@f_Insert_filterorder},'Units','normalized','Position',[0.16,0.55,0.08,0.035]);        
   
uicontrol('Style','pushbutton','String','PROCESS','FontSize',fontesc10,'Callback','uiresume(gcbf)','Units', 'normalized','Position',[0.05,0.45,0.2,0.035]);
uiwait(gcf)
close

if  exist('Tmin','var')==0,           Tmin=defFTAN(1);        end
if  exist('Tmax','var')==0,           Tmax=defFTAN(2);        end
if  exist('fstep','var')==0,          fstep=defFTAN(3);       end
if  exist('width','var')==0,          width=defFTAN(4);       end
if  exist('filterorder','var')==0,    filterorder=defFTAN(5); end
if     exist('maxlagsel','var')==0 && strcmp(filetype,'correlogram') ==1
    maxlagsel=maxlag;       
elseif exist('maxlagsel','var')==0 && strcmp(filetype,'seismic_record') ==1
    maxlagsel=max(time);   
end

%%
fig_princ=figure(1);
set(gcf,'color',[1,1,1])
set (gcf, 'Units','normalized','Units','normalized','Position',[0,0.04,1,0.88])

% READ and DISPLAY of selected SAC files in correspondingly folder.
% in this step the user can select Prior or Next file to visualize:
%   - TRACE of the Cross-correlogram or seismic record (left bottom)
%   - Narrow-band filtered TRACES, where the dispersion phenomena could be 
%     observed.
%   - COLOR MAP of FTAN, where the user is allowed to pick dispersion curve
%           [RED: lower energy]    [BLUE: higher energy]
% 	- GROUP VELOCITY - PERIOD Diagram & dispersion curve (once is was picked)

kreg=1;
uicontrol('Style','pushbutton','Units','normalized','Position',[0.12 0.95 0.13 0.03],'String','PREVIOUS','Callback', {@f_PriorDC} );
uicontrol('Style','pushbutton','Units','normalized','Position',[0.37 0.95 0.13 0.03],'String','NEXT','Callback', {@f_NextDC} );       

namesac=[pathsac,sacfiles(kreg).name];
trace=rdsac(namesac);
traceHDR=trace.HEADER;
dt=traceHDR.DELTA;   dt=1/round(1/dt);
[az,dist]=legs([traceHDR.STLA,traceHDR.EVLA],[traceHDR.STLO,traceHDR.EVLO],'gc');
dist=dist*1.852;
trace=trace.d;

if strcmp(filetype,'correlogram')==1 
    pickedcurves=cell(nsac,2);
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
        trace=trace(ind1:ind2);  
        time=time(ind1:ind2).*dt;  clear tcut maxtime kl   
    else
        ind1=1;
        ind2=length(trace);
    end
	trace=f_Taper(trace,0.05);   
elseif strcmp(filetype,'seismic_record')==1
    pickedcurves=cell(nsac,1);
    trace=f_Taper(trace,0.05);
    maxlag=length(trace)*dt;
	time=traceHDR.B:dt:traceHDR.E;
end

subplot(3,4,9:10),cla
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
uicontrol('Style','text','String',[num2str(kreg) ' / ',num2str(nsac) , '  file' ],'background','w','FontSize',12,'Units','normalized','Position',[0.3 0.95 0.05 0.03])

% STEP where the FTAN process is calculated by f_FTAN_Env function.
[FTAN,ENV,fcm,fcwidth]    =   f_FTAN_Env(trace,dt,1/Tmax,1/Tmin,filt,fstep,width,filterorder);
T=1./fcm;   
T=T(length(T):-1:1);    
vel=dist./time;

% For each type of the file selected (CROSS-CORRELOGRAM or SEISMIC RECORD),
% this step includes VISUALIZATION of color-maps diagrams, picked curves,
% and allows the user for selecting the curve that will be saved and exported in ASCII format.
if strcmp(filetype,'correlogram')==1 
    f_Disp4PickCD_corr(time,fcm,T,FTAN,ENV,trace,dist,dt,maxlagsel);
    uicontrol('Style','text','String',' PART OF CC TO PICK ','background','w','FontSize',fontesc10,'Units','normalized','Position',[0.5 0.955 0.1 0.03])  
    uicontrol('Style','popup','String', 'CONTINUOUS CAUSAL|CONTINUOUS ANTICAUSAL|SEGMENTED  CAUSAL|SEGMENTED  ANTICAUSAL','FontSize',fontesc10,'Units','normalized','Position', [0.6 0.935 0.10 0.05],'Callback', @f_SelectCausal2);   
    uicontrol('Style','pushbutton','String','SAVE CURVE','FontSize',fontesc10,'Callback',{@f_SaveDC},'Units', 'normalized','Position', [0.8,0.96,0.08,0.03]);
    uicontrol('Style','pushbutton','String','EXPORT ALL CURVES','FontSize',fontesc10,'Callback',{@f_ExportDC},'Units', 'normalized','Position', [0.89,0.96,0.1,0.03]);

   elseif strcmp(filetype,'seismic_record')==1
    f_Disp4PickCD_seisrec(time,fcm,T,FTAN,ENV,trace,dist,dt);
    uicontrol('Style','pushbutton','String', ' PICK DISPERSION CURVE ','FontSize',fontesc10,'Units','normalized','Position', [0.55 0.96 0.12 0.03],'Callback', @f_PickSeisRec);   
	uicontrol('Style','pushbutton','String','SAVE CURVE','FontSize',fontesc10,'Callback',{@f_SaveDC},'Units', 'normalized','Position',[0.7,0.96,0.1,0.03]);
    uicontrol('Style','pushbutton','String','EXPORT ALL CURVES','FontSize',fontesc10,'Callback',{@f_ExportDC},'Units', 'normalized','Position',[0.81,0.96,0.15,0.03]);
end


