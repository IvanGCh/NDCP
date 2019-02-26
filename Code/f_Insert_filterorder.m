function f_Insert_filterorder(hObject, eventdata, handles)
% f_Insert_filterorder:    box to insert order of the Butterworth filter for
%                          FTAN. Description in GRANADOS et al., 2018.
    filterorder=get(hObject,'String');
    handles.edit2=filterorder;
    guidata(hObject,handles);
    filterorder=str2double(filterorder);
    assignin('base', 'filterorder', filterorder)
end

