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

%for(a=1:1:n)
%    data(a).raw=zeros(xlen,ylen,frames,'uint16');
%end

for(a=1:1:frames)
    for(b=1:1:n)
        temp=imread(files(b).name,a);
        data(b,a).image=temp;
    end
end

for(a=1:1:n)
    
    for(b=1:1:frames)
       entr(a,b)=entropy(data(a,b).image);
       temp=statxture(data(a,b).image,1);
       thirdmoment(a,b)=temp(4);
       uniformity(a,b)=temp(5);
    end
end

for(a=1:1:n)
    entr(a,:)=filter(ones(1,10)/10,1,entr(a,:));
    thirdmoment(a,:)=filter(ones(1,10)/10,1,thirdmoment(a,:));
    uniformity(a,:)=filter(ones(1,10)/10,1,uniformity(a,:));
end

colors=[1 0 0; 0 1 0; 0 0 1];


%for(a=1:1:n)
%    plotdata(a,:)=entr;
%end

figure; plot([1:frames], entr);

objs=sort(findobj(gca,'Type','line'));

for(a=1:1:n)
    set(objs(a),'Color', colors(a,:));
end

figure; plot([1:frames], thirdmoment);

objs=sort(findobj(gca,'Type','line'));

for(a=1:1:n)
    set(objs(a),'Color', colors(a,:));
end

figure; plot([1:frames], uniformity);

objs=sort(findobj(gca,'Type','line'));

for(a=1:1:n)
    set(objs(a),'Color', colors(a,:));
end


   