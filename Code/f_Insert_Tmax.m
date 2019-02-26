function f_Insert_Tmax(hObject, eventdata, handles)
% f_Insert_Tmax:    box to insert maximum period [seconds] for FTAN
    Tmax=get(hObject,'String');
    handles.edit2=Tmax;
    guidata(hObject,handles);
    Tmax=str2double(Tmax);
    assignin('base', 'Tmax', Tmax)
end


