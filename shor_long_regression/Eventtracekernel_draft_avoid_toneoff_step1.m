r%Note 20200330
%get rsq without toneoffset and rsq without avoidance (with shuffled
%avoidance) -> calculate delta r


%maybe should try ridge regression <<< 

clc, clear all, close all

S = dir(fullfile('E:\PV photometry - active avoidance\20190304 active avoidance\20190731 sht_ext_figures for paper use\sht_ext_data','*data.mat'));


for k=1:numel(S)
filepath=(strcat('E:\PV photometry - active avoidance\20190304 active avoidance\20190731 sht_ext_figures for paper use\sht_ext_data\',S(k).name));
[b,rsq_train] = Eventtracekernel(filepath);
[b_toff,rsq_train_toff] = Eventtracekernel_shuffletoneoffset(filepath);
[b_avd,rsq_train_avd] = Eventtracekernel_shuffleavoid(filepath);
filename=S(k).name;
save(strcat(filename(1:5),'regress_avd_toff.mat'), 'b','rsq_train','b_toff','rsq_train_toff', 'b_avd','rsq_train_avd');
clear 'b' 'rsq_train' 'b_toff' 'rsq_train_toff' 'b_avd' 'rsq_train_avd' 
end


%%

S = dir(fullfile('E:\PV photometry - active avoidance\20190304 active avoidance\20190824 toneoff_or_cross_kernel_anvoa\20190824_kernel_regression','*avd_toff.mat'));

ball=zeros(1530,numel(S));
b_0avd=zeros(1530,numel(S));
b_0toff=zeros(1530,numel(S));


rsq=zeros(3,numel(S));
for k=1:12%numel(S)
load(S(k).name); 
ball(:,k)=b;
b_0avd(:,k)=b_avd;
b_0toff(:,k)=b_toff;
rsq(1,k)=rsq_train;
rsq(2,k)=rsq_train_avd;
rsq(3,k)=rsq_train_toff;
clear 'b' 'rsq_train' 'b_avd' 'b_toff' 'rsq_train_avd' 'rsq_train_toff'
end

%%
g1 = repmat({'Cross (Reg)'},7,1);
g2 = repmat({'Cross (Ext)'},7,1);
g3 = repmat({'Tone Off (Sht)'},7,1);
g4 = repmat({'Tone Off (Ext)'},7,1);
g=[g1;g2;g3;g4];
h=boxplot([NorAvoid([2,4:9]);Cross([2,4:9],:);Toneoff([2,4:9],:);Toneoff2([2,4:9],:)],g);
xtickangle(30);