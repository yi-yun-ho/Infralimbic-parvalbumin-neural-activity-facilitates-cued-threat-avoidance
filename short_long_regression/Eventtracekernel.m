function [b,rsq_train,rsq_test] = Eventtracekernel(filepath)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
load(filepath,'dataD','NorI','ShortI','ExtI');

dff=dataD.dff;
timeD=dataD.timeD;
onsetT=dataD.onsetT;
offsetT=dataD.offsetT;
R=dataD.R;
L=dataD.L;
rDoricfr=round(dataD.Doricfr);

% predefine event time frames
% avoidances/chamber crossing/tone offset/tone onset

% #####    tone onset    #####
%tone onset = onsetT

% #####    tone offset    #####
%tone offset = offsetT

% #####    all chamber crossing   #####
crossT=sort([R;L]);
% #####    avoidances   ##### 
avoidT=zeros(length(onsetT),1);
%normal trials
avoidT(NorI,1)=offsetT(NorI).*((offsetT(NorI)-onsetT(NorI))<5); % take only avoidance trials - animal crosses within 5 sec
%extended trials
for i=1:length(ExtI)
 if (offsetT(ExtI(i))-onsetT(ExtI(i)))<(5+1.5) % take only avoidance trials - animal crosses within 5 sec
    avoidT(ExtI(i),1)=crossT(find((crossT-(offsetT(ExtI(i))-1.6))>0,1,'first')); % extended tone lasts for another 1.5 after chamber crossing
 end
end
%remove trials without number filled - ex. escape trials and short trials
avoidT=nonzeros(avoidT);

% #####    escapes   ##### 
escapeT=zeros(length(onsetT),1);
%normal trials
escapeT(NorI,1)=offsetT(NorI).*((offsetT(NorI)-onsetT(NorI))>=5); % take only escape trials - animal crosses after 5 sec from tone onset
%extended trials
for i=1:length(ExtI)
 if (offsetT(ExtI(i))-onsetT(ExtI(i)))>(5+1.5) % take only escape trials - animal crosses after 5 sec from tone onset
    escapeT(ExtI(i),1)=crossT(find((crossT-(offsetT(ExtI(i))-1.6))>0,1,'first')); % extended tone lasts for another 1.5 after chamber crossing
 end
end
%remove trials without number filled - ex. escape trials and short trials
escapeT=nonzeros(escapeT);

% #####    shocks   ##### 
shockT=zeros(length(onsetT),1);
shockT(NorI,1)=onsetT(NorI).*((offsetT(NorI)-onsetT(NorI))>=5);
shockT(ExtI,1)=onsetT(ExtI).*((offsetT(ExtI)-onsetT(ExtI))>=(5+1.5));
shockT=nonzeros(shockT);
shockT=shockT+5;

% #####    chamber crossing outside avoidances/escapes   #####
crossT=RemoveShoc(crossT,[avoidT;escapeT],1);
crossT=crossT((crossT>2)&(crossT<(max(timeD)-3))); %only include corssing happened 2sec after start of trial


     
%% filter

% use moving median to remove the baseline fluctuation
mdff=movmedian(dff,30*rDoricfr);
dffn=dff-mdff;

%% downsample from 1000 Hz to 100 Hz sampling rate
dsrate=10; 
Y=decimate(dffn,dsrate);
T=downsample(timeD,dsrate);
Dfr=round(length(T)/(max(T)-min(T)));

% find event time frames in new sampling rate

%tone onset frame in new T
OnDf=zeros(length(onsetT),1);
 for i=1:length(onsetT)
        [~,	OnDf(i,1)]=min(abs(  T-onsetT(i) ));
 end

%tone offset frame in new T
 OfDf=zeros(length(offsetT),1);
 for i=1:length(offsetT)
        [~,	OfDf(i,1)]=min(abs(  T-offsetT(i) ));
 end

%chamber crossing frame in new T 
CrsDf=zeros(length(crossT),1);
 for i=1:length(crossT)
        [~,CrsDf(i,1)]=min(abs(  T-crossT(i) ));
 end

%avoidance frame in new T 
AvDf=zeros(length(avoidT),1);
 for i=1:length(avoidT)
        [~,AvDf(i,1)]=min(abs(  T-avoidT(i) ));
 end 
 
%escape frame in new T 
EsDf=zeros(length(escapeT),1);
 for i=1:length(escapeT)
        [~,EsDf(i,1)]=min(abs(  T-escapeT(i) ));
 end 
  
%escape frame in new T 
ScDf=zeros(length(shockT),1);
 for i=1:length(shockT)
        [~,ScDf(i,1)]=min(abs(  T-shockT(i) ));
 end 
 
%% construct X from event timeframes for regression

X=zeros(length(Y),15*Dfr); 

%0 sec to 2 sec -tone onset
for i=1:2*Dfr
    for j=1:length(OnDf)
        X( (OnDf(j)+i-1),i)=1;
    end
end

%0 sec to 2 sec -tone offset
 for i=1:2*Dfr
    for j=1:length(OfDf)
        X( (OfDf(j)+i-1) ,i+2*Dfr)=1;
    end
 end
 
 %-1 sec to 2 sec -chamber crossing
for i=1:3*Dfr
    for j=1:length(CrsDf)
        X( (CrsDf(j)-1*Dfr+i),i+4*Dfr)=1;
    end
end

%-1 sec to 2 sec -avoidance
 for i=1:3*Dfr
    for j=1:length(AvDf)
        X( (AvDf(j)-1*Dfr+i) ,i+7*Dfr)=1;
    end
 end
 
 %-1 sec to 2 sec -escape
 for i=1:3*Dfr
    for j=1:length(EsDf)
        X( (EsDf(j)-1*Dfr+i) ,i+10*Dfr)=1;
    end
 end
 
 %0 sec to 2 sec -shock
 for i=1:2*Dfr
    for j=1:length(ScDf)
        X( (ScDf(j)+i-1) ,i+13*Dfr)=1;
    end
 end
 
 
%% restrict X,Y to around events - improve regression calculation efficiency   
Ys=Y(sum(X,2)~=0,:);
Xs=X(sum(X,2)~=0,:); % only take rows with definition (rows that is not completely zeros)

%% split to train and test_ get rsquare

% run validation
% just validation with 1/folds of testing data (no actual "cross"
% validation 
folds=10;
[Y_test,X_test,Y_train,X_train] = test_train_split(Ys,Xs,folds);
b=regress(Y_train,X_train); %cross validation??

rsq_train=rsquare_function(Y_train,X_train,b); %0.2123 -pv012
rsq_test=rsquare_function(Y_test,X_test,b); %0.1859 -pv012 (different larger than 10%)


end

