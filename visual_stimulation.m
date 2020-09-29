function visual_stimulation(nFrames,stimul,repetitions)
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
        stimulus_player(stimul,bigBoardX,window,repetitions)
    case 'Y'
        stimulus_player(stimul,bigBoardY,window,repetitions)
end
%%
% switch toggle
% 
%     case 'X' %a end to end horizontal bar moving along the vertical axis
%         for total=1:50
%              [imageTexture]=Texture_generator(stimul,bigBoardX,window);%a nFrames long movie is transfered into "textures"
%             for index=1:10
%                 Priority(2);
% 
%                for frame=1:nFrames
%                     Screen('DrawTexture', window, imageTexture(frame), [], [] ,0, [], []);%loading the correct frame from the preloaded texture file
%                     vbl=Screen('Flip', window, vbl+(waitframes-0.5)*ifi);%showing the image in the middle of the refresh window
%                end
%                 
%                 vbl_postStim=WaitSecs(4);% attempting to accurately time pauses after the stimulus with a timestamp
%                 
%                 writeDigitalPin(a, 'D11', 1);%until I'm able to trigger this in another way I will test the arduino controlled pulse.
%                 writeDigitalPin(a, 'D11', 0);
%                 vbl_postBlink=WaitSecs(1);%again attempting to accurately time pauses after the stimulus
%                 
%             end
%             
%         end
%         Screen('CloseAll'); %Close display windows
%         Priority(0);
%    
%     
%     case'Y'
%         for total=1:50  
%             for index=1:10
%                 [imageTexture]=Texture_generator(stimul,bigBoardY,window);
%                 writeDigitalPin(a, 'D11', 1);%until I'm able to trigger this in another way I will test the arduino controlled pulse.
%                 writeDigitalPin(a, 'D11', 0);
%                 Priority(2);
%                 WaitSecs('UntilTime', 1);%attempting to accurately time pauses in stimulus onset
% 
%                 for frame=1:600
%                     Screen('DrawTexture', window, imageTexture(frame), [], [] ,0, [], []);
%                     vbl=Screen('Flip', window, vbl+(waitframes-0.5)*ifi);
%                 end
%                     WaitSecs('UntilTime', 4);%again attempting to accurately time pauses after the stimulus
%             end
%         end
% end

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

function stimulus_player(stimul,bigBoard,window,repetitions)

            [imageTexture]=Texture_generator(stimul,bigBoard,window);%a nFrames long movie is transfered into "textures"
            for index=1:repetitions
                Priority(2);

               for frame=1:nFrames
                    Screen('DrawTexture', window, imageTexture(frame), [], [] ,0, [], []);%loading the correct frame from the preloaded texture file
                    vbl=Screen('Flip', window, vbl+(waitframes-0.5)*ifi);%showing the image in the middle of the refresh window
               end
                
                vbl_postStim=WaitSecs(4);% attempting to accurately time pauses after the stimulus with a timestamp
                
                writeDigitalPin(a, 'D11', 1);%until I'm able to trigger this in another way I will test the arduino controlled pulse.
                writeDigitalPin(a, 'D11', 0);
                vbl_postBlink=WaitSecs(1);%again attempting to accurately time pauses after the stimulus
                
            end
            
        Screen('CloseAll'); %Close display windows
        Priority(0);
end