[imageSizeX,imageSizeY,~]=size(mov);
meanmov=mean(raw_mov,3);
imagesc(meanmov)
caxis([200 1000]);
h=drawpolygon;
s=poly2mask(h.Position(:,1),h.Position(:,2),imageSizeX,imageSizeY);
roi=raw_mov.*s;
roi2=mov.*s;
[~,~,lengthRoi]=size(roi);


for i=1:lengthRoi
iroi(1,i)=sum(roi(:,:,i),'all');
end
iroi_df=(iroi-mean(iroi))/(mean(iroi));
iroi_df=imgaussfilt(iroi_df,2);
iroi_df=detrend(iroi_df);
iroi_df(iroi_df<0)=0;
plot(iroi_df)

if length(iroi_df)<400
vect=(10:40:320)
xticks(vect)
elseif length(iroi_df)<700
vect=(20:80:640)
xticks(vect)
else
vect=(30:120:960);
xticks(vect)
end