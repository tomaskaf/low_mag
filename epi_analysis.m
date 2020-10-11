function [mov,raw_mov]=epi_analysis(fps,sigma)

if nargin==0
    fps=10;
    sigma=1.15;
end

[spacing,chunk,duration,fps,image,meanChunk,sizex,sizey]=parameter_screener(fps);




%%

[raw_mov,Log,LogF]=movieloader(chunk,meanChunk,sizex,sizey,fps); 
raw_mov(:,:,end)=[];
%meanextraction
mov=raw_mov-(mean(raw_mov,3));
 %%
%[output_mov,output_map]=plotter(mov,sigma)
 
%% 
function [output_mov,output_map]=plotter(mov,sigma)

%%

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
function [spacing,chunk,duration,fps,image,meanChunk,sizex,sizey]=parameter_screener(fps) %%determine the parameters of the recording

if nargin==0
    fps=10;
end
%%
    list=dir('*tiff');
    list_trials=list(108:end);
    duration=length(list_trials);
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
    chunk=fps*spacing;
    meanChunk=chunk/(fps/10);
    [sizex,sizey]=size(image);
end
%%
function [raw_mov,Log,LogF]=movieloader(chunk,meanChunk,sizex,sizey,fps) 
%%
    list=dir('*tiff');
    list_trials=list(108:end);
    f=waitbar(0,'loading movie');
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
    raw_mov=zeros(sizex,sizey,round(chunk));%forcing this because wtf, the timing is weird
    
    for index_trial=2:length(list_trials) 
        waitbar((index_trial)/(length(list_trials)))
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
                
                if  LOWedge==1 && HIGHedge==0%setting WRITE to true if LED turns off
                    WRITE="True";               
                else 
                    WRITE="False"; %As LED turns on setting WRITE to false.
            
                 end
                
                switch WRITE
                    case "True"
                    i=i+1;
                        
                        
                        
                    TRUElogger=TRUElogger+1;%some logging for debugging
                    Log(TRUElogger)=index_trial;
                    
%                   if fps==30
%                     switch i
%                         case 1
%                             tempM=zeros(sizex,sizey);
%                             temp=double(imread(list_trials(index_trial).name));
%                             tempM=tempM+temp;
%                         case 2
%                                temp=double(imread(list_trials(index_trial).name));
%                                tempM=tempM+temp;
%                         case 3
%                             count=count+1
%                             temp=double(imread(list_trials(index_trial).name));
%                             tempM=tempM+temp; 
%                             try
%                             raw_mov(:,:,count)=raw_mov(:,:,count)+tempM;
%                             i=0;
%                             end
%                     end
%                     end
%                   if fps==10
                       count=count+1
                       temp=double(imread(list_trials(index_trial).name));
                       try
                       raw_mov(:,:,count)=raw_mov(:,:,count)+temp;
                       end
%                   end
                    
                    case "False"
                        count=0;
                        FALSElogger=FALSElogger+1;
                        LogF(FALSElogger)=index_trial;
                
                

                end   
      
                    
                   
    end
    close(f) 
end
end
