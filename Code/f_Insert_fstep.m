function f_Insert_fstep(hObject, eventdata, handles)
% f_Insert_fstep:    box to insert frequency steps for narrow-band filter 
%                    for FTAN. Description in GRANADOS et al., 2018.
    fstep=get(hObject,'String');
    handles.edit2=fstep;
    guidata(hObject,handles);
    fstep=str2double(fstep);
    assignin('base', 'fstep', fstep)
end

