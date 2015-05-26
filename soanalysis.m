clear all;
close all;
n=1;

timeinterval=10 %Time b/w frames

filtersize=0  


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

disp('Reading files');

tic;

for(a=1:1:frames)
    for(b=1:1:n)
        data(b,a).image=imread(files(b).name,a);
    end
end

toc;

disp('Calculating');

tic;

if(n==2)
    for(a=1:1:frames)
        pearson(a)=pearsoncorel(data(1,a).image,data(2,a).image);
    end
    
    if(filtersize>0)
    
        filtertemp=filter(ones(1,filtersize)/filtersize,1,pearson);
    
        pearson(filtersize:end-filtersize)=filtertemp(filtersize:end-filtersize);
    
    end


elseif(n==3)
     for(a=1:1:frames)
        pearson(1,a)=pearsoncorel(data(1,a).image,data(2,a).image);
        pearson(2,a)=pearsoncorel(data(1,a).image,data(3,a).image);        
        pearson(3,a)=pearsoncorel(data(2,a).image,data(3,a).image);
     end
     
     
     if(filtersize>0)
             
        for(a=1:1:3)
            filtertemp=filter(ones(1,filtersize)/filtersize,1,pearson(a,:));
            pearson(a,filtersize:end-filtersize)=filtertemp(filtersize:end-filtersize);
        end
        
     end
             
         
else
    error('At least 2 sets of images needed');
end

colors=[1 0 0; 0 0 1; 0 1 0];

fig1=figure; plot(timepoints, pearson);

objs=sort(findobj(fig1,'Type','line'));

for(a=1:1:size(objs,1))
     set(objs(a),'Color', colors(a,:));
end

set(fig1,'DefaultAxesColorOrder',[1 0 0;0 0 1;0 1 0]); % Color Order: Red, Blue, Green, reverse

set(fig1,'Position',[10 10 800 600]);

axis([0 timepoints(end) 0 1]);

xlabel('time [s]','FontSize',16);
ylabel('Pearson''s correlation coefficient Rr','FontSize',16);
title(files(1).name(1:end-7),'FontSize',16);

%graph=getframe(fig1);

%imwrite(graph.cdata, [files(1).name(1:end-4) '_coloc.tif'],'Compression','lzw');

saveas(fig1,[files(1).name(1:end-4) '_coloc.png'],'png');


csvwrite([files(1).name(1:end-4) '_coloc.csv'],cat(1,timepoints,pearson)');

for(a=1:1:n)
    
    for(b=1:1:frames)
        data(a).stdev(b)=std(double(data(a,b).image(:)));
    end
    
    data(a).stdev=data(a).stdev/max(data(a).stdev); %Normalization to 1
end

timepoints=[delay:timeinterval:(frames-1)*timeinterval+delay];

for(a=1:1:n)
    plotdata(a,:)=data(a).stdev;
    
    if(filtersize>0)
        filtertemp=filter(ones(1,10)/10,1,plotdata(a,:));
   
        plotdata(a,filtersize:end-filtersize)=filtertemp(filtersize:end-filtersize);
    end
    
end

fig2=figure; plot(timepoints, plotdata);

objs=sort(findobj(fig2,'Type','line'));

for(a=1:1:size(objs,1))
     set(objs(a),'Color', colors(a,:));
end

set(fig2,'Position',[10 10 800 600]);

axis([0 timepoints(end) 0 1]);

xlabel('time [s]','FontSize',16);
ylabel('Normalized standard deviation','FontSize',16);
title(files(1).name(1:end-7),'FontSize',16);

%graph=getframe(fig2);

%imwrite(graph.cdata, [files(1).name(1:end-4) '_stdev.tif'],'Compression','lzw');

saveas(fig2,[files(1).name(1:end-4) '_stdev.png'],'png');

csvwrite([files(1).name(1:end-4) '_stdev.csv'],cat(1,timepoints,plotdata)');

toc;

beep;







   