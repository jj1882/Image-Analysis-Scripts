function R=manderscoeff(channel1, channel2)
% Manders Overlap Coefficient
% Zinchuk & Zinchuk, Current Protocols in Cell Biology 4, 4.19.1

min1=min(min(channel1));
min2=min(min(channel2));

ch1=double(channel1-min1);
ch2=double(channel2-min2);

max1=max(max(ch1));
max2=max(max(ch2));

ch1=ch1/max1;
ch2=ch2/max2;

R=sum(sum(ch1 .* ch2))/sqrt( sum(sum(ch1.*ch1)) * sum(sum(ch2.*ch2)));

