function f_Insert_width(hObject, eventdata, handles)
% f_Insert_width:    box to insert frequency width of narrow-band filters 
%                    in log10 scale. Description in GRANADOS et al., 2018.
    width=get(hObject,'String');
    handles.edit2=width;
    guidata(hObject,handles);
    width=str2double(width);
    assignin('base', 'width', width)
end


