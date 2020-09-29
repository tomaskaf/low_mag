clear all
%[position_end]=syncVector;
[spacing,chunk,duration,fps,image]=parameter_screener;




%%
meanChunk=chunk/(fps/10);
[sizex,sizey]=size(image);

[raw_mov,Log,LogF]=movieloader(chunk,meanChunk,sizex,sizey); 

%meanextraction
mov=raw_mov-(mean(raw_mov,3));
 %%
[output_mov,output_map]=plotter(mov,1.5)
 
%% 
function [output_mov,output_map]=plotter(mov,sigma)
close all 
gauss=imgaussfilt(mov,sigma);
gauss=movmean(gauss,3,3);
gauss=detrend3(gauss);
output_mov=figure, imshow3D(gauss)

output_map=figure

[fig_phase]=retinotopy(gauss)
title('gaussian filtering, movmean 3 in time ')
% subplot(2,1,2)
% [fig_phase]=retinotopy(mov)
% title('moving mean')

% subplot(2,1,2)
% imshow(vasc(:,:,1))
end
 
function [fig_phase]=retinotopy(array)
[sizex,sizey,sizeZ]=size(array);
data=reshape(array,[sizex*sizey],(sizeZ));
data=permute(data,[2,1]);
Fs = 10; L = size(data,1);
f = Fs*(0:(L/2))/L; %frequency vector
ftarget = 0.07;
D = fft(data);%calculate full fft
pow = abs(D.^2);
[~,ind] = min(abs(f-ftarget));
pow = pow(ind,:);
phase = angle(D(ind,:)) + pi;
%figure, imagesc(log(reshape(pow, [sizex,sizey])))
%phase
fig_phase=imagesc(reshape(phase./(2*pi), [sizex,sizey])); colormap jet
end

%%
function [position_end]=syncVector(fps) %finds stimulus start times 

    %clear all
if nargin==0
    fps=30;
end
    list_trials=dir('*tiff');
    x=zeros([length(list_trials),1],'single');
    f=waitbar(0,'loading synchronizing vector');
    for index_trial=1:length(list_trials)
        waitbar(index_trial/length(list_trials))
                image=imread(list_trials(index_trial).name);
                x(index_trial,1)=mean(image(:));  
    end
    close(f)
    
    maxX=round(max(x));
    maxVect=(maxX-(maxX/10):maxX);
    xR=round(x);
    locations=find(xR>maxX-(maxX/100));
    i=0;
    for index=1:length(locations)
        try
            check=(x(locations(index)))/(x((locations(index))+1));
            if check>1.25%difference in blink/nonblink should be high regardless of bitdepth
                i=i+1;
                position_end(i)=locations(index);
            end
        end
    end
    spacing=round((position_end(1,10)-position_end(1,9))/fps);
        if spacing==10
            chunk=fps*spacing-fps;
            disp('flash')
        elseif spacing==15
            chunk=fps*spacing-fps;

            disp('bar')
        elseif spacing==30
            chunk=fps*spacing-fps;
            disp('moving object')
        end

    position_end(:,1)=[];%%this is due to the mixed order in frames in the first trial. Cant getspinview to lead with zeroes.
    position_end(:,end)=[]; %in order to avoid running out of matrix
end
%%
function [spacing,chunk,duration,fps,image]=parameter_screener(fps) %%determine the parameters of the recording

if nargin==0
    fps=30;
end

    list_trials=dir('*tiff');
    duration=length(list_trials)-100;
    x=zeros([1000,1],'single');
    f=waitbar(0,'checking frames 101-1100 for timing parameters');
    for index_trial=101:2100 %skipping first 100 to avoid the weirdness that might be present
        waitbar((index_trial-100)/2001)
                image=imread(list_trials(index_trial).name);
                x(index_trial-100,1)=mean(image(:));  
    end
    close(f)
    
    maxX=round(max(x));
    maxVect=(maxX-(maxX/10):maxX);
    xR=round(x);
    locations=find(xR>maxX-(maxX/100));
    i=0;
    for index=1:length(locations)
        try
            check=(x(locations(index)))/(x((locations(index))+1));
            if check>1.1%difference in blink/nonblink should be high regardless of bitdepth
                i=i+1;
                position_end(i)=locations(index);
            end
        end
    end
    spacing=round((position_end(1,2)-position_end(1,1))/fps);
        if spacing==10
            chunk=fps*spacing;
            disp('stimulus:flash')
        elseif spacing==15
            chunk=fps*spacing;

            disp('stimulus:bar')
        elseif spacing==30
            chunk=fps*spacing;
            disp('stimulus:moving object')
        else chunk=fps*spacing;
        end
end
%%
function [raw_mov,Log,LogF]=movieloader(chunk,meanChunk,sizex,sizey) 

    list_trials=dir('*tiff');
    f=waitbar(0,'loading movie, searching for trial start ques');
    %set every switch to default
    HIGHedge=0;
    LOWedge=0;
    WRITE="False";
    count=0;
    TRUElogger=0;
    FALSElogger=0;
    i=0;
    %set up movie length optimizing and preallocate memory
    bins=(1:chunk/meanChunk:length(list_trials));
    %raw_mov=zeros(sizex,sizey,meanChunk); %this is how it should be
    raw_mov=zeros(sizex,sizey,130);%forcing this because wtf, the timing is weird
    
    for index_trial=101:length(list_trials) %will skip the first 100 frames due to spinview's missing capacity to add leading zeros
        waitbar((index_trial-100)/(length(list_trials)-100))
                image_prev=imread(list_trials(index_trial-1).name);
                pre_current=mean(image_prev(:));
                image=imread(list_trials(index_trial).name);
                current=mean(image(:));
                slope=pre_current/current;
                if slope>1.1 %meaning we're at the end of a LED blink
                    LOWedge=1;
                    HIGHedge=0;
                elseif slope<0.9 %LED blink starts
                    LOWedge=0;
                    HIGHedge=1;
                end
                
                if LOWedge==1 && HIGHedge==0 %setting WRITE to true if LED turns off
                    WRITE="True";
                else
                    WRITE="False"; %As LED turns on setting WRITE to false.
                end
                
                switch WRITE
                    case "True"
                    i=i+1;
                        
                        
                        
                    TRUElogger=TRUElogger+1;%some logging for debugging
                    Log(TRUElogger)=index_trial;
                    
                    switch i
                        case 1
                            tempM=zeros(sizex,sizey);
                            temp=double(imread(list_trials(index_trial).name));
                            tempM=tempM+temp;
                        case 2
                               temp=double(imread(list_trials(index_trial).name));
                               tempM=tempM+temp;
                        case 3
                            count=count+1;
                            if count>130 
                                WRITE="False";
                            end
                            temp=double(imread(list_trials(index_trial).name));
                            tempM=tempM+temp; 
                            try
                            raw_mov(:,:,count)=raw_mov(:,:,count)+tempM;
                            i=0;
                            end
                            
                    end
                                
                    
                    case "False"
                        count=0;
                        FALSElogger=FALSElogger+1;
                        LogF(FALSElogger)=index_trial;
                end
                

    end   
      
                    
       close(f)             
    end
   
