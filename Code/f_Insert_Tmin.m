function f_Insert_Tmin(hObject, eventdata, handles)
% f_Insert_Tmin:    box to insert minimum period [seconds] for FTAN
    Tmin=get(hObject,'String');
    handles.edit2=Tmin;
    guidata(hObject,handles);
    Tmin=str2double(Tmin);
    assignin('base', 'Tmin', Tmin)
end

