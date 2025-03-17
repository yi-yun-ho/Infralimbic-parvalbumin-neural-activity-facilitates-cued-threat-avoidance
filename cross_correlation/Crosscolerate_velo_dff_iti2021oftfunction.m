function [cross_cov,cross_cov_sub,cross_cov_peak] = Crosscolerate_velo_dff_iti2021oftfunction(filepath)
%Calculate normalized cross correlation in ITI, get peak value within +- 1
%seconds shift
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
dfffilt = filtfilt(d1,dataD.dffNN(1:end-1,:));

%get interpolation of dffN in time N 
dffN=interp1(dataD.timeNN(1:end-1,:),dfffilt,dataN.time); %better downsample than upsample
velononan=interp1(dataN.time(isnan(dataN.velo)==0),dataN.velo(isnan(dataN.velo)==0),dataN.time);
dffN=interp1(dataN.time(isnan(dffN)==0),dffN(isnan(dffN)==0),dataN.time);
velononan(isnan(velononan)==1)=0;
dffN(isnan(dffN)==1)=0;

%% xcov ITI (5 sec after off, 5 sec before next on)
rNoldfr=round(dataN.Noldfr);
maxlag=round(10*dataN.Noldfr); %+-10 second

splitfrsmaller=sort([splitfr,splitfr+600,splitfr+1200]);

cross_cov=zeros(length(splitfrsmaller),2*maxlag+1);



for i=1:length(splitfrsmaller)-1
    cross_cov(i,:) = xcov(velononan(splitfrsmaller(i):splitfrsmaller(i+1)),dffN(splitfrsmaller(i):splitfrsmaller(i+1)),maxlag,'coeff'); 
end

cross_cov(length(splitfrsmaller),:) = xcov(velononan(splitfrsmaller(length(splitfrsmaller)):18011),dffN(splitfrsmaller(length(splitfrsmaller)):18011),maxlag,'coeff'); 



cross_cov_sub=cross_cov(:,maxlag+1-1*rNoldfr:maxlag+1+1*rNoldfr); %find max/min within plus minus 1 sec 
[~,maxloc]=max(abs(cross_cov_sub),[],2);

cross_cov_peak=zeros(size(cross_cov_sub,1),1);
for i=1:size(cross_cov_sub,1)
    cross_cov_peak(i,1)=cross_cov_sub(i,maxloc(i));
end

end