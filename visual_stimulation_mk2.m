function [time_vect]=visual_stimulation_mk2(duration,repetitions)
PsychDefaultSetup(2);
if nargin==0
    duration=10;
    repetitions=10;
end

dq = daq("ni");
ctr = addoutput(dq,"Dev1", "ctr0", "PulseGeneration");
ctr.Terminal

stimdur = duration;
angle=[45,90,135,180,225,270,315,360];
ncondition=length(angle);


dg=DriftGrating_Blue;
screenid = max(Screen('Screens'));
dg.openWindow(screenid);

time_vect=zeros(2,repetitions);

for i=1:repetitions

startTime=GetSecs;
if i>2
start(dq,"Duration",seconds(1));
stop(dq);
end
post_daq=WaitSecs('UntilTime',startTime+1)
time_vect(1,i)=post_daq-startTime

time_stamp=[];
stim_count=5;

 
condition=mod(stim_count-1,ncondition)+1;
dg.angle=angle(condition);
dg.cyclespersecond=1/stimdur;
dg.cyclesperdegree=0.05;
dg.amplitude=1;


disp(['showing stimulus: ' int2str(angle(condition))])


[ts,start_time] = dg.fireStim(stimdur);
dg.putBlank(168);
post_stimul=WaitSecs('UntilTime',startTime+15);
%time_stamp=[time_stamp; ts(1) angle(condition)];
time_vect(2,i)=post_stimul-startTime;

stim_count=stim_count+1;
end
end
