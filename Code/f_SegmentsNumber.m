function f_SegmentsNumber(hObject, eventdata, handles)
% f_SegmentsNumber:     for CROSS-CORRELOGRAMS, box to insert Time to cut the
%                       length of causal and non-causal part of GF.
    numsegm=get(hObject,'String');
    handles.edit2=numsegm;
    guidata(hObject,handles);
    numsegm=str2double(numsegm);
    
    assignin('base', 'numsegm', numsegm)
end


