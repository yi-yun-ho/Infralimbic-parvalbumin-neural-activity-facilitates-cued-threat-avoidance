function [cross_cov,cross_cov_sub,cross_cov_peak] = Crosscolerate_velo_dff_iti2019_2function(filepath)
%Calculate normalized cross correlation in ITI, get peak value within +- 1
%change to add 3 before habituation tones 20210716 

%   Detailed explanation goes here
load(filepath); %filepath='A:\20180814 Regression And Motor analysis data from May\pv005d1.mat'

%    latency=7 if it is day3   latency=5 if it is day1  
%latency=7; %if it is day3
latency=5; %if it is day1

%% Filter and resample

%filter with 7Hz (half of the 15Hz)
d1 = designfilt('lowpassiir','FilterOrder',8, ...
    'HalfPowerFrequency',7,'SampleRate',dataD.Doricfr,'DesignMethod','butter');
%fvtool(d1)
dfffilt = filtfilt(d1,dataD.dff(1:end-1,:));

%get interpolation of dffN in time N 
dffN=interp1(dataD.timeD(1:end-1,:),dfffilt,dataN.timeN); %better downsample than upsample

dataN.veloN=interp1(dataN.timeN(isnan(dataN.velo)==0),dataN.velo(isnan(dataN.velo)==0),dataN.timeN);


%% xcov ITI (5 sec after off, 5 sec before next on)
rNoldfr=round(dataN.Noldfr);
maxlag=round(10*dataN.Noldfr); %+-10 second

cross_cov=zeros(length(dataN.cueoff)+3,2*maxlag+1);

for i=1:3
    cross_cov(i,:) = xcov(dataN.veloN(dataN.cueon(1)-(120-(i-1)*40)*rNoldfr:dataN.cueon(1)-(120-(i)*40)*rNoldfr),dffN(dataN.cueon(1)-(120-(i-1)*40)*rNoldfr:dataN.cueon(1)-(120-(i)*40)*rNoldfr),maxlag,'coeff'); 
end

for i=1:(length(dataN.cueoff)-1)
    cross_cov(i+3,:) = xcov(dataN.veloN(dataN.cueoff(i)+5*rNoldfr:dataN.cueon(i+1)-5*rNoldfr),dffN(dataN.cueoff(i)+5*rNoldfr:dataN.cueon(i+1)-5*rNoldfr),maxlag,'coeff'); 
end

cross_cov(length(dataN.cueoff),:) = xcov(dataN.veloN(dataN.cueoff(length(dataN.cueoff))+5*rNoldfr:(dataN.cueoff(length(dataN.cueoff))+20*rNoldfr)),dffN(dataN.cueoff(length(dataN.cueoff))+5*rNoldfr:(dataN.cueoff(length(dataN.cueoff))+20*rNoldfr)),maxlag,'coeff'); 



cross_cov_sub=cross_cov(:,maxlag+1-1*rNoldfr:maxlag+1+1*rNoldfr); %find max/min within plus minus 1 sec 
[~,maxloc]=max(abs(cross_cov_sub),[],2);

cross_cov_peak=zeros(length(cross_cov_sub),1);
for i=1:length(cross_cov_sub)
    cross_cov_peak(i,1)=cross_cov_sub(i,maxloc(i));
end

end