function f_Insert_Distance(hObject, eventdata, handles)

% f_Insert_filterorder:    box to insert order of the Butterworth fitler for
%                          FTAN. Description in GRANADOS et al., 2018.
% f_Insert_Distance
    dist=get(hObject,'String');
    handles.edit2=dist;
    guidata(hObject,handles);
    dist=str2double(dist);
    assignin('base', 'dist', dist)
end