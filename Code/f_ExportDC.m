function f_ExportDC(hObj,event) 
% f_ExportDC:   export as ASCII file all the curves picked and saved for
%               NDCP. If records were CROSS-CORRELOGRAMS, NDCP will save
%               one file per each part of the GF.
%               Files saved will be named as the SAC file, and will be
%               composed by 4 columns:
%                   1st     FREQUENCY
%                   2nd     PERIOD
%                   3rd     PICKED TIME IN RECORD
%                   4th     GROUP VELOCITY [km/s]

    filetype     = evalin('base', 'filetype'); 
    pickedcurves = evalin('base', 'pickedcurves');   
    pathsac      = evalin('base', 'pathsac');    
    sacfiles     = evalin('base', 'sacfiles'); 
    nsac         = evalin('base', 'nsac');
    
    figure,set(gcf,'color',[1,1,1]),set (gcf, 'Units','normalized','Units','normalized','Position',[0.45,0.5,0.2,0.05])
    uicontrol('Style','text','Units','normalized','Position',[0.1 0.1 0.8 0.8],'String', ['WRITING ',num2str(nsac),' DISPERSION CURVES'],'FontSize',16)
    pause(0.5),  close
    format long
        
    if strcmp(filetype,'correlogram')==1 
                
       for kf=1:nsac
           DCname=sacfiles(kf).name;
           nameout=[pathsac,DCname(1:length(DCname)-4)];
           DCa=pickedcurves{kf,1};
           DCb=pickedcurves{kf,2};
           if isempty(DCa)==0
                dlmwrite([nameout,'a.txt'],DCa,'delimiter','\t','precision',6);
           end
           if isempty(DCb)==0
                dlmwrite([nameout,'b.txt'],DCb,'delimiter','\t','precision',6);           
           end       
       end
       
	elseif strcmp(filetype,'seismic_record')==1
        
       for kf=1:nsac
           DCname=sacfiles(kf).name;
           nameout=[pathsac,DCname(1:length(DCname)-4)];
           DC=pickedcurves{kf,1};
           if isempty(DC)==0
               dlmwrite([nameout,'.txt'],DC,'delimiter','\t','precision',6);   
           end
       end
        
    end
    
end
