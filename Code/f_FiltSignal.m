function [signal_f]=f_FiltSignal(signal,dt,nn,fc1,fc2,filt,filttype)
% f_FiltSignal:     Performing and application of a Butterworth filter, with
%                   three filter options:
%                     1.- Butterworth filter described by Proakis J. G. & 
%                         Manolakis, D. G., 2007
%                     2.- Matlab filter function: BUTTER.
%                     3.- Matlab filter function: DESIGNFILT. 

    T=length(signal)*dt;   
    mxn=size(signal);
    if mxn(1)<mxn(2)
        signal=signal';
    end

    f0=1/T;     fN=1/(2*dt);            f=-fN:f0:fN-f0;

    if filt==1
        %% PROGRAMMED FILTER [Proakis J. G. & Manolakis, D. G., 2007]
        FLP1=zeros(length(signal),1);   FHP1=FLP1;  FLP2=FLP1;  FHP2=FLP1;
        for i=1:length(f)
            FLP1(i)=1/(1+((f(i)/fc2)^(2*nn)));
            FHP1(i)=1-1/(1+((f(i)/fc1)^(2*nn)));
            FLP2(i)=1/(1+((f(i)/fc1)^(2*nn)));
            FHP2(i)=1-1/(1+((f(i)/fc2)^(2*nn)));
        end
        FBP=FLP1.*FHP1;     FBR=FLP2.*FHP2;

        if      strcmp('highpass',filttype)==1
            F=FHP1;
        elseif  strcmp('lowpass',filttype)==1
            F=FLP1;
        elseif  strcmp('bandpass',filttype)==1
            F=FBP;
        elseif  strcmp('stop',filttype)==1
            F=FBR;
        end

        signal_f=signal.*0;    ffts=signal.*0;
        for kch=1:mxn(2)
            signal(:,kch)=f_Taper(signal(:,kch),0.01);
            ffts(:,kch)=fftshift(fft(signal(:,kch))/T);
            fftsf(:,kch)=ffts(:,kch).*F;
            signal_f(:,kch)=ifftshift(fftsf(:,kch));
            signal_f(:,kch)=real(ifft(signal_f(:,kch)*T));
        end

    elseif filt==2
        %% [BUTTER + FILTFILT]
        signal_f=signal.*0;
        if      strcmp('highpass',filttype)==1
            [z,t]=butter(4,fc1/fN,'high');
        elseif  strcmp('lowpass',filttype)==1
            [z,t]=butter(4,fc2/fN,'low');
        elseif  strcmp('bandpass',filttype)==1
            [z,t]=butter(4,[fc1/fN fc2/fN],'bandpass');
        elseif  strcmp('stop',filttype)==1
            [z,t]=butter(4,[fc1/fN fc2/fN],'stop');
        end

        for kch=1:mxn(2)
            signal(:,kch)=f_Taper(signal(:,kch),0.01);
            signal_f(:,kch)=filtfilt(z,t,signal(:,kch));
        end


    elseif filt==3
        %% [DESIGNFILT + FILTFILT]
        signal_f=signal.*0;

        if      strcmp('highpass',filttype)==1
            bpFilt= designfilt('highpassiir','FilterOrder',nn,'PassbandFrequency',fc1,...
                'PassbandRipple',0.2,'SampleRate',1/dt);

        elseif  strcmp('lowpass',filttype)==1
            bpFilt= designfilt('lowpassiir','FilterOrder',nn,'PassbandFrequency',fc2,...
                'PassbandRipple',0.2,'SampleRate',1/dt);

        elseif  strcmp('bandpass',filttype)==1
            bpFilt= designfilt('bandpassiir','FilterOrder',nn,'HalfPowerFrequency1',fc1,...
                'HalfPowerFrequency2',fc2,'SampleRate',1/dt);

        elseif  strcmp('stop',filttype)==1
            bpFilt= designfilt('bandstopiir','FilterOrder',nn,'HalfPowerFrequency1',fc1,...
                'HalfPowerFrequency2',fc2,'SampleRate',1/dt);
        end

        for kch=1:mxn(2)
            signal(:,kch)=f_Taper(signal(:,kch),0.01);
            signal_f(:,kch)= filtfilt(bpFilt,signal(:,kch));
        end

    end

	
end