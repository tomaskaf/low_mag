function [timeStamps]=visual_stimulation(nFrames,stimul,repetitions)
close all
PsychDefaultSetup(2);
%choosing the screen n2 where stim should be presented in fullscreen mode
screenNumbers=Screen('Screens');
screenNumber=max(screenNumbers);
white = WhiteIndex(screenNumber);
waitframes=1;%by default we want to refresh every frame
if nargin==0%just for ease of use during testing
    stimul='down'
    repetitions=25;
    nFrames=600;
    disp('default, bottom up, 600frames')
end
a=arduino;%sorry kaspar
grey = 0.5;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
%assessing the refresh rate of our screen
Priority(2)%to get the most accurate timing
ifi = Screen('GetFlipInterval', window);
vbl=Screen('Flip', window);
Priority(0)
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[width, height]=Screen('WindowSize', screenNumber);
w=width;
h=height;

%movingboard is a script generating a 3d matrix of moving grating based on
%input parameters
switch stimul
    case {'up','down'}
        [bigBoardX,~]=movingboard(nFrames,h,w);
        toggle='X';
    case {'left','right'}
        [~,bigBoardY]=movingboard(nFrames,h,w);
        toggle='Y';
end
%%
switch toggle
    case 'X'
       [timeStamps]=stimulus_player(a,stimul,bigBoardX,window,repetitions,nFrames,ifi,vbl,waitframes)
    case 'Y'
       [timeStamps]=stimulus_player(a,stimul,bigBoardY,window,repetitions,nFrames,ifi,vbl,waitframes)
end

end    
    
    


function [imageTexture]=Texture_generator(stimul,bigBoard,window)

    for n=1:600
            %Screen('Close');
            switch stimul
                case 'up'
            imageTexture(n) = Screen('MakeTexture', window, bigBoard(:,:,n));
                case 'down'
            imageTexture(n) = Screen('MakeTexture', window, bigBoard(:,:,abs(n-601)));
                case 'left'
            imageTexture(n) = Screen('MakeTexture', window, bigBoard(:,:,n));
                case 'right'
            imageTexture(n) = Screen('MakeTexture', window, bigBoard(:,:,abs(n-601)));

            end
    end
end

function [timeStamps]=stimulus_player(a,stimul,bigBoard,window,repetitions,nFrames,ifi,vbl,waitframes)
               timeStamps=zeros(1,repetitions);
            [imageTexture]=Texture_generator(stimul,bigBoard,window);%a nFrames long movie is transfered into "textures"
            for index=1:repetitions
                Priority(2);

               for frame=1:nFrames
                    Screen('DrawTexture', window, imageTexture(frame), [], [] ,0, [], []);%loading the correct frame from the preloaded texture file
                    vbl=Screen('Flip', window, vbl+(waitframes-0.5)*ifi);%showing the image in the middle of the refresh window
               end
                
                
%                 writeDigitalPin(a, 'D11', 1);%until I'm able to trigger this in another way I will test the arduino controlled pulse.
%                 writeDigitalPin(a, 'D11', 0);
                if index==1
                    startTime=GetSecs;
                    
                else
                    timeStamps(1,index)=GetSecs-startTime;
                    WaitSecs('UntilTime',startTime+(10*(index-1)));
                end
                
            end
            
        Screen('CloseAll'); %Close display windows
        Priority(0);
end