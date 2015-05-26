function analyzekymoDirections (inputvals,filename)
%inputvals: first column: number of data points (pairs)
%first column after that: speed in nm/s
%next column: time in s


datasets=size(inputvals,1);

for(a=1:1:datasets)
    positioncurve(a).count=1;
    positioncurve(a).pos(1)=0;
end


for(a=1:1:datasets) %loop through datasets
  
    for(b=1:1:inputvals(a,1)) %loop through speed/time pairs
        
       time=round(abs(inputvals(a,b*2+1)));
       speed=inputvals(a,b*2);
       
       for(c=1:1:time) %loop through time
           positioncurve(a).count=positioncurve(a).count+1;
           
           % s = v*t+s0, t=1s;
           positioncurve(a).pos(positioncurve(a).count)=speed*1+positioncurve(a).pos(positioncurve(a).count-1);
       end
       
      
    end

    
    positioncurve(a).slope=diff(positioncurve(a).pos);
    
    %figure;plot(positioncurve(a).pos);
    
end

plusdirection=0;
minusdirection=0;
pauses=0;

pauseduration=3; % pause speed in nm/s seconds

for(a=1:1:datasets) %loop through datasets
    
   plusdirection=plusdirection+size(find(positioncurve(a).slope(:)>pauseduration),1);
   minusdirection=minusdirection+size(find(positioncurve(a).slope(:)<pauseduration*-1),1);
   pauses=pauses+size(find(positioncurve(a).slope(:) > pauseduration*-1 & positioncurve(a).slope(:) < pauseduration),1);
   
end
   

plusdirection
minusdirection
pauses


if(nargin==2)
    

    switches(end+1:size(switcheswithends,2))=0; %fill up with 0 to be able to concatenate

    results=[switches; switcheswithends];

    csvwrite(filename,results');


end