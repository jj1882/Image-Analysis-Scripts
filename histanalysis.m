clear all;

n=1;

while(1)
    [files(n).name, pathname] = uigetfile('*.tif;', ['Select channel ' int2str(n)]);
    
    
    if(files(n).name==0)
        break
    else
        n=n+1;
    end
    cd(pathname);
end

n=n-1;


imageinfo=imfinfo(files(1).name);

frames=size(imageinfo,1);

xlen=imageinfo(1).Width;
ylen=imageinfo(2).Height;

for(a=1:1:n)
    data(a).raw=zeros(xlen*ylen,frames,'uint16');
end

for(a=1:1:frames)
    for(b=1:1:n)
        temp=imread(files(b).name,a);
        data(b).raw(:,a)=temp(:);
    end
end

for(a=1:1:n)
    data(a).means=mean(data(a).raw);
    data(a).maxvals=max(data(a).raw);
    data(a).minvals=min(data(a).raw);

    for(b=1:1:frames)
        data(a).stdev(b)=std(double(data(a).raw(:,b)));
    end
end

colors=[1 0 0; 0 1 0; 0 0 1];


for(a=1:1:n)
    plotdata(a,:)=filter(ones(1,10)/10,1,data(a).stdev); %/max(data(a).stdev);
end

figure; plot([1:frames], plotdata);

objs=sort(findobj(gca,'Type','line'));

for(a=1:1:n)
    set(objs(a),'Color', colors(a,:));
end


csvwrite([files(1).name(1:end-4) '_stdev.csv'],plotdata');

   