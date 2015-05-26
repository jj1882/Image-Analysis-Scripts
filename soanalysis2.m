function soanalysis2(timeinterval)


    n=1;
    if(nargin<1)
      timeinterval=10 %Time b/w frames
    end

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

    xlen=imageinfo(1).Width;
    ylen=imageinfo(2).Height;

    for(a=1:1:n)
        data(a).raw=zeros(xlen*ylen,frames,'uint16');
    end

    for(a=1:1:frames)
        for(b=1:1:n)
            data(b,a).image=imread(files(b).name,a);
        end
    end

    tic;
    
    
    %Calculate Texture measures
    for(a=1:1:n)

        %Only 15% slower than matrix operation but much less memory use

        for(b=1:1:frames)

            temp=double(data(a,b).image(:));
            stdev(a,b)=std(temp);
            means(a,b)=mean(temp);

            stx=statxture(data(a,b).image);

            smoothness(a,b)=stx(3);
            thirdmoment(a,b)=stx(4);
            uniformity(a,b)=stx(5);
            entropy(a,b)=stx(6);

        end 

        normstdev=stdev./means; %Scale with mean

    end

    normstdev=stdev./means; %Scale with mean

    %Calculate colocalization
    if(n==2)
        for(a=1:1:frames)
            pearson(a)=pearsoncorel(data(1,a).image,data(2,a).image);
        end
    elseif(n==3)
         for(a=1:1:frames)
            pearson(1,a)=pearsoncorel(data(1,a).image,data(2,a).image);
            pearson(2,a)=pearsoncorel(data(1,a).image,data(3,a).image);        
            pearson(3,a)=pearsoncorel(data(2,a).image,data(3,a).image);
         end
    else
        error('At least 2 sets of images needed');
    end
    
    toc;

    
    % Plot the data
    
    timepoints=[delay:timeinterval:(frames-1)*timeinterval+delay];

    fig=figure;
    orient landscape;
    suptitle(files(1).name(1:end-7),16);
    set(gcf,'Position',[10 10 1600 600]);
 
    chplot(timepoints,pearson,'Pearson Correlation',1,0);
    chplot(timepoints,normstdev,'Stdev / mean',2,0);
    chplot(timepoints,stdev,'Stdev',3,0);
    chplot(timepoints,means,'mean',4,0);
    chplot(timepoints,smoothness,'smoothness',5,0);
    chplot(timepoints,thirdmoment,'third moment',6,0);
    chplot(timepoints,uniformity,'uniformity',7,0);
    chplot(timepoints,entropy,'entropy',8,0);
   
    hgexport(fig,[files(1).name(1:end-4) '_stdev.eps']);
    
    csvwrite([files(1).name(1:end-4) '_stdev.csv'],cat(1,timepoints,pearson,timepoints,stdev)');
    
    beep;
    
end

%graph=getframe(gcf);

%imwrite(graph.cdata, [files(1).name(1:end-4) '_stdev.tif'],'Compression','lzw');

%csvwrite([files(1).name(1:end-4) '_stdev.csv'],cat(1,timepoints,plotdata)');


function chplot(x,y,glabel,position, gtitle)
    colors=[1 0 0; 0 0 1; 0 1 0];
    subplot(2,4,position);
    h=plot(x,y);
    objs=sort(findobj(h,'Type','line'));

    for(a=1:1:size(objs,1))
         set(objs(a),'Color', colors(a,:));
    end
    xlabel('time [s]'); %,'FontSize',16);
    ylabel(glabel); %,'FontSize',16);

    if(gtitle)
        title(files(1).name(1:end-7),'FontSize',16)
    end

end





