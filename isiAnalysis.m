function accum=isiAnalysis
%intrinsic analysis
%Navigate the current folder to a directory containing your image files
%(.tiff), and no additional image files
clear all
list=dir('*tiff');
[~, reorder] = sort_nat({list.name});
list = list(reorder);
nFrames=length(list);

x=zeros(length(list),1);

f=waitbar(0,'detecting stimulus length');
for index_trial=1:length(list)
    waitbar((index_trial)/(length(list)))
    A=tiffread2(list(index_trial).name);
    image=single(A.data);
    x(index_trial,1)=mean(image(:));
end
close(f)

pkThresh = max(x)/1.15;
[~, locs] = findpeaks(x, 'MinPeakHeight', pkThresh);

interval = min(diff(locs))-3;
[sizex,sizey]=size(image);

accum = zeros(sizex,sizey,interval);
buffer = zeros(sizex,sizey,interval+100);
startFrame = 11;

while startFrame<nFrames-interval
    startFrame %#ok<NOPRT>
    %load the data into the buffer
    for ix = 1:length(buffer)
        B=tiffread2(list(startFrame-11+ix).name);
        buffer(:,:,ix) = single(B.data);
    end
    %detect the first falling edge
    V = squeeze(mean(mean(buffer,1),2)) > pkThresh;
    if ~any(V)
        break
    end
    blinkFrame = find(V(1:end-1) & ~V(2:end),1, 'first');

    accum = accum+buffer(:,:,blinkFrame+1:blinkFrame+interval);

    startFrame = startFrame-10+blinkFrame + interval +1;
end

%figure, imshow3D(accum-mean(accum,3));
end
