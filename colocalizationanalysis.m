clear all;

n=1;

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



tic;

if(n==2)
    for(a=1:1:frames)
        %moverlap(a)=manderscoeff(data(1,a).image,data(2,a).image);
        %[kvals(1,a),kvals(2,a)]=overlapcoeff(data(1,a).image,data(2,a).image);
        pearson(a)=pearsoncorel(data(1,a).image,data(2,a).image);
    end
    
    pearson=filter(ones(1,10)/10,1,pearson(:));
    figure; plot([1:frames], pearson);

elseif(n==3)
     for(a=1:1:frames)
        pearson(1,a)=pearsoncorel(data(1,a).image,data(2,a).image);
        pearson(2,a)=pearsoncorel(data(1,a).image,data(3,a).image);        
        pearson(3,a)=pearsoncorel(data(2,a).image,data(3,a).image);
     end
     
     pearson(1,:)=filter(ones(1,10)/10,1,pearson(1,:));
     pearson(2,:)=filter(ones(1,10)/10,1,pearson(2,:));
     pearson(3,:)=filter(ones(1,10)/10,1,pearson(3,:));
     
     colors=[1 0 0; 0 1 0; 0 0 1];
     
     figure; plot([1:frames], pearson);
     
     objs=sort(findobj(gca,'Type','line'));

    for(a=1:1:3)
        set(objs(a),'Color', colors(a,:));
    end
else
    error('At least 2 sets of images needed');
end

toc

csvwrite([files(1).name(1:end-4) '_coloc.csv'],pearson');





   