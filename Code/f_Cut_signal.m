function f_Cut_signal(hObject, eventdata, handles)
% f_Cut_signal:    for CROSS-CORRELOGRAMS, box to insert Time to cut the
%                  length of causal and non-causal part of GF.
    maxlag=get(hObject,'String');
    handles.edit2=maxlag;
    guidata(hObject,handles);
    maxlag=str2double(maxlag);
    assignin('base', 'maxlagsel', maxlag)
end


