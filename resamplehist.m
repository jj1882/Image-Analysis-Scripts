function newvalues=resamplehist(value, time)

counter=0;

resampletime=6;

for ( a=1:1: max(size(value)))
    
    for(b=0:resampletime:floor(time(a)))
        counter=counter+1;
        newvalues(counter)=value(a);
    end
    
end

figure;
hist(newvalues,50);

end
