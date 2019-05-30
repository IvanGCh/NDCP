function f_OPEN_SEISMIC_RECORD(hObj,event)
% f_OPEN_SEISMIC_RECORD: allow the user to select the folder that contain 
% SAC files with the seismic records for certain earthquakes.
% As is described in GRANADOS et al., 2019, coordinate headers of STATION
% and EVENT (station A and epicenter) must be in each file, for an
% automatic calculation of DISTANCE and proposal FTAN parameters.
%
% Once the folder is selected, files will be listed, and the  first one 
% will be displayed for a visual verification. After it, PATH and LIST of
% the SAC files will be exported to the base workspace.

    [file,pathsac]=uigetfile('*.sac','Select the SAC file');
    name=[pathsac,file];
    sacfile=rdsac(name);
    trace=sacfile.d;
    dt=sacfile.HEADER.DELTA;    dt=1/round(1/dt);
    
if sacfile.HEADER.STLA ~= -12345 || sacfile.HEADER.EVLA ~= -12345
    stlatlon=[sacfile.HEADER.STLA,sacfile.HEADER.STLO];    
    evlatlon=[sacfile.HEADER.EVLA,sacfile.HEADER.EVLO];
    lat=[stlatlon(1),evlatlon(1)];
    lon=[stlatlon(2),evlatlon(2)];
    [az,dist]=legs(lat,lon,'gc');
    dist=dist*1.852;    % Dist. [NAUTICAL MILES] = 1.852 Dist. [KILOMETERS]
end

    filetype='seismic_record'; 
    time=sacfile.HEADER.B:dt:sacfile.HEADER.B+((length(trace)-1)*dt);
    
    axes('Position',[0.07,0.1,0.9,0.7])
    plot(time,trace./max(abs(trace)),'k')
    xlim([min(time) max(time)])
    xlabel('\bf TIME [s]'),ylabel('\bf NORMALIZED AMPLITUDE')
    
    assignin('base', 'trace', trace)
    assignin('base', 'time', time)
    assignin('base', 'dt', dt)
    assignin('base', 'file', file)
    assignin('base', 'filetype', filetype)
    assignin('base', 'pathsac', pathsac)
        
    existDist=exist('dist','var');
if existDist==1
    assignin('base', 'dist', dist)
    assignin('base', 'az', az)
end

end
