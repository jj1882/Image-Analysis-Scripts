clear all;

n=1;

timeinterval=10 %Time b/w frames

while(1)
    [files(n).name, pathname] = uigetfile('*.tif;', ['Select channel ' int2str(n)]);
    
    
    if(files(n).name==0)
        break  
    else
        n=n+1;
        if(n>3)
            break;
        end
    end
    cd(pathname);
end

n=n-1;



disp(files(1).name);
delay=input('Please enter delay in min.sec ');

delay=floor(delay)*60+(delay-floor(delay))*100; %Change Minutes.Seconds into seconds

imageinfo=imfinfo(files(1).name);

frames=size(imageinfo,1);

timepoints=[delay:timeinterval:(frames-1)*timeinterval+delay];

xlen=imageinfo(1).Width;
ylen=imageinfo(2).Height;

for(a=1:1:n)
    data(a).image=zeros(xlen,ylen,frames,'uint16');
end

for(a=1:1:frames)
    for(b=1:1:n)
        temp=imread(files(b).name,a);
        data(b,a).image=temp;
    end
end



tic;

if(n==2)
    for(a=1:1:frames)
        pearson(a)=pearsoncorel(data(1,a).image,data(2,a).image);
    end
    
    pearson=filter(ones(1,10)/10,1,pearson(:));
    figure; plot(timepoints, pearson);

elseif(n==3)
     for(a=1:1:frames)
        pearson(1,a)=pearsoncorel(data(1,a).image,data(2,a).image);
        pearson(2,a)=pearsoncorel(data(1,a).image,data(3,a).image);        
        pearson(3,a)=pearsoncorel(data(2,a).image,data(3,a).image);
     end
     
     pearson(1,:)=filter(ones(1,10)/10,1,pearson(1,:));
     pearson(2,:)=filter(ones(1,10)/10,1,pearson(2,:));
     pearson(3,:)=filter(ones(1,10)/10,1,pearson(3,:));
    
    
     figure; plot(timepoints, pearson);
     
         
else
    error('At least 2 sets of images needed');
end

set(gcf,'DefaultAxesColorOrder',[1 0 0;0 0 1;0 1 0]); % Color Order: Red, Blue, Green

set(gcf,'Position',[10 10 800 600]);

axis([0 timepoints(end) -1 1]);

xlabel('time [s]','FontSize',16);
ylabel('Pearson''s correlation coefficient Rr','FontSize',16);
title(files(1).name(1:end-7),'FontSize',16);

toc

csvwrite([files(1).name(1:end-4) '_coloc.csv'],pearson');





   