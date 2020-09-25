function visual_stimulation(nFrames,stimul)
close all
PsychDefaultSetup(2);
%Screen('Preference', 'SkipSyncTests', 1);
%choosing the screen n2 where stim should be presented in fullscreen mode
screenNumbers=Screen('Screens');
screenNumber=max(screenNumbers);
white = WhiteIndex(screenNumber);
waitframes=1;%by default we want to refresh every frame and I don't really see the point in having this as an input argument
if nargin==0
    stimul='down'
    nFrames=600;
    disp('default, bottom up, 600frames')
end
%a=arduino;
grey = 0.5;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
%assessing the refresh rate of our screen
Priority(2)
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


%% session trigger via bpod

% 
%  sma = prepareStateMachine;
%  TrialManager = TrialManagerObject;
%  TrialManager.startTrial(sma);


%%
switch toggle
    case 'X'
        for total=1:50  
            for index=1:10
               [imageTexture]=Texture_generator(stimul,bigBoardX,window);
%              writeDigitalPin(a, 'D11', 1);%until I'm able to trigger this in another way I will test the arduino controlled pulse.
%              writeDigitalPin(a, 'D11', 0);
               Priority(2);
               WaitSecs('UntilTime', 1);%attempting to accurately time pauses in stimulus onset
                
               for frame=1:600
                    Screen('DrawTexture', window, imageTexture(frame), [], [] ,0, [], []);
                    vbl=Screen('Flip', window, vbl+(waitframes-0.5)*ifi);
               end
                WaitSecs('UntilTime', 4);%again attempting to accurately time pauses after the stimulus
            end
        end
        Screen('CloseAll'); %Close display windows
        Priority(0);
    case'Y'
        for total=1:50  
            for index=1:10
                [imageTexture]=Texture_generator(stimul,bigBoardY,window);
                for frame=1:600
                    Screen('DrawTexture', window, imageTexture(frame), [], [] ,0, [], []);
                    vbl=Screen('Flip', window, vbl+(waitframes-0.5)*ifi);
                end
            end
        end
end

end    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %     index
%     writeDigitalPin(a, 'D11', 1);
%     pause(0.1)
%     writeDigitalPin(a, 'D11', 0);
%     pause(0.9)
%     for n=1:600
%         Screen('Close');
%         switch stimul
%             case 'up'
%         imageTexture = Screen('MakeTexture', window, bigBoardX(:,:,n));
%             case 'down'
%         imageTexture = Screen('MakeTexture', window, bigBoardX(:,:,abs(n-601)));
%             case 'left'
%         imageTexture = Screen('MakeTexture', window, bigBoardY(:,:,n));
%             case 'right'
%         imageTexture = Screen('MakeTexture', window, bigBoardY(:,:,abs(n-601)));
%        
%         end
%         
%         Screen('DrawTexture', window, imageTexture, [], [] ,0, [], []);
%         Screen('Flip', window);
%         
%     end
%     %pause(4)
%end

%     writeDigitalPin(a, 'D11', 0);
%     writeDigitalPin(a, 'D11', 1);
% 
% 
% for index=1:10
%     for n=1:600
%         Screen('Close');
%         imageTexture = Screen('MakeTexture', window, bigBoardX(:,:,abs(n-601)));
%         Screen('DrawTexture', window, imageTexture, [], [] ,0, [], []);
%         Screen('Flip', window);
%     end
% end
% 
% 
%     writeDigitalPin(a, 'D11', 0);
%     writeDigitalPin(a, 'D11', 1);
% 
% 
% for index=1:10
% 
%     
%     for n=1:600
%         Screen('Close');
%         imageTexture = Screen('MakeTexture', window, bigBoardY(:,:,n));
%         Screen('DrawTexture', window, imageTexture, [], [] ,0, [], []);
%         Screen('Flip', window);
%     end
% end
% 
%     writeDigitalPin(a, 'D11', 0);
%     writeDigitalPin(a, 'D11', 1);
% 
% 
% for index=1:10
%     for n=1:600
%         Screen('Close');
%         imageTexture = Screen('MakeTexture', window, bigBoardY(:,:,abs(n-601)));
%         c
%     end
% end
%     writeDigitalPin(a, 'D11', 0);
%     pause(5);
%     writeDigitalPin(a, 'D11', 1);
% end
% 
%     writeDigitalPin(a, 'D11', 0);
%     pause(5);
%     writeDigitalPin(a, 'D11', 1);




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