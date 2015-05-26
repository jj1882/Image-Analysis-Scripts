function kymoanalysis2()

RED=1;
GREEN=2;
BLUE=3;


[tiffilename, tifpathname] = uigetfile('*.tif;', 'Select storage.tif');

if isequal(tiffilename,0)
    error('storage.tif from multipleoverlay (EMBL imagej) is required');
else
    cd(tifpathname);
    storagetif=imread(tiffilename);
end

[file(RED).name, file(RED).path] = uigetfile('*.tif;*.stk;*.lsm', 'select red channel');

[file(GREEN).name, file(GREEN).path] = uigetfile('*.tif;*.stk;*.lsm', 'select green channel');

[file(BLUE).name, file(BLUE).path] = uigetfile('*.tif;*.stk;*.lsm', 'select blue channel');

channels=ones(1,3);  % All 3 channels are active by default

for a=RED:1:BLUE
    if isequal(file(a).name,0)
        channels(a)=0;
    else
        cd(file(a).path);
        image(a,:)=tiffread25( file(a).name );
    end
end

for a=RED:1:BLUE
    if(channels(a))
        disp(['Getting Kymographs ' int2str(a)]);
        kymos(a,:)=getkymographs(image(a,:),storagetif);
        
    end
end


%Find out which ones are loades ad get kymograph dimensions
for a=RED:1:BLUE
    if(channels(a))
        numberofkymos=size(kymos,2);
        
        for b=1:1:numberofkymos
            dimensions(b).y=size(kymos(a,b).image,1);
            dimensions(b).x=size(kymos(a,b).image,2);
        end
         
        break
    end
end


%Now fill the empty channels with black
for a=RED:1:BLUE
    
    if(channels(a)==0)
      
        for b=1:1:numberofkymos
            kymos(a,b).image=zeros(dimensions(b).y, dimensions(b).x ,'uint16');
        end
    end
    
end

cd(tifpathname); %if we left it for some reason...

for a=1:1:numberofkymos
    for(b=RED:1:BLUE)
        %rgbkymo(a).image(:,:,b)=im2uint8(kymos(b,a).image);
    end
    rgbkymo(a).image(:,:,:)=makergbfusion(kymos(1,a).image,kymos(2,a).image,kymos(3,a).image,'vertical');
    
    [fname,err]=sprintf('%s kymo%03d.tif',tiffilename,a);
    
    imwrite(rgbkymo(a).image,fname,'tif','Compression','none');
    
    imwrite(kymos(1,a).image,[fname(1:end-4) 'ch1.tif'] ,'tif','Compression','none');
    imwrite(kymos(2,a).image,[fname(1:end-4) 'ch2.tif'] ,'tif','Compression','none');
    imwrite(kymos(3,a).image,[fname(1:end-4) 'ch3.tif'] ,'tif','Compression','none');

    clear fname;
    
    %figure;
    %imshow (rgbkymo(a).image );
end
    

% pic(:,:,1)=im2uint8(imadjust(image(1,1).data));
% pic(:,:,2)=im2uint8(imadjust(image(2,1).data));
% pic(:,:,3)=im2uint8(imadjust(image(3,1).data));
% 
% imshow(pic);

end


        
 




