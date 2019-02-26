function f_SaveDC(hObj,event) 
% f_SaveDC:     Save the curve that the user pick at the moment. Once the
%               user select the PICK-CURVE option, it will be saved in an
%               array called 'pickedcurves'. If user don't click on
%               SAVE-CURVE, the picked curve will not be considered to
%               export.
%               'pickedcurves' vector's size is: NxP, N is the number of
%               files; P=2 for CROSS-CORRELOGRAM (one for each part of GF),
%               or P=1 for SEISMIC RECORD.

    filetype     = evalin('base', 'filetype'); 
    CDpicked     = evalin('base', 'CDpicked');
    pickedcurves = evalin('base', 'pickedcurves');   
    kreg         = evalin('base', 'kreg');
    
    if strcmp(filetype,'correlogram')==1 
        if mean(CDpicked(:,4))<0
            pickedcurves{kreg,1}=CDpicked;
        elseif mean(CDpicked(:,4))>0
            pickedcurves{kreg,2}=CDpicked;
        end
    elseif strcmp(filetype,'seismic_record')==1
        pickedcurves{kreg}=CDpicked;
    end

    assignin('base', 'pickedcurves', pickedcurves)
    
end




