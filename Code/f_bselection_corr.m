function f_bselection_corr(source,event)

    pickopt=event.NewValue.String;
    filetype  = evalin('base', 'filetype');
    fontesc10 = evalin('base', 'fontesc10');

    if strcmp(filetype,'correlogram')==1
        if     strcmp(pickopt,'CLICK&HOLD')==1
          uicontrol('Style','popup','String', 'CONTINUOUS CAUSAL|CONTINUOUS ANTICAUSAL|SEGMENTED  CAUSAL|SEGMENTED  ANTICAUSAL','FontSize',fontesc10,'Units','normalized','Position', [0.61 0.92 0.13 0.05],'Callback', @f_SelectCausal_CH); 
        elseif strcmp(pickopt,'REPEATED-CLICKS')==1
          uicontrol('Style','popup','String', 'CONTINUOUS CAUSAL|CONTINUOUS ANTICAUSAL|SEGMENTED  CAUSAL|SEGMENTED  ANTICAUSAL','FontSize',fontesc10,'Units','normalized','Position', [0.61 0.92 0.13 0.05],'Callback', @f_SelectCausal_IC); 
        end
        
    elseif strcmp(filetype,'seismic_record')==1
        if      strcmp(pickopt,'CLICK&HOLD')==1
            uicontrol('Style','pushbutton','String', 'PICK DISPERSION CURVE','FontSize',fontesc10,'Units','normalized','Position', [0.67 0.95 0.13 0.025],'Callback', @f_PickSeisRec_CH); 
        elseif strcmp(pickopt,'REPEATED-CLICKS')==1
            uicontrol('Style','pushbutton','String', 'PICK DISPERSION CURVE','FontSize',fontesc10,'Units','normalized','Position', [0.67 0.95 0.13 0.025],'Callback', @f_PickSeisRec_IC); 
        end
        
    end
    
    assignin('base', 'pickopt', pickopt)
end
