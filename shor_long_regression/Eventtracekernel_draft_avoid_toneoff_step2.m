%get rsq without toneoffset and rsq without avoidance (with shuffled
%avoidance) -> calculate delta r

%run Eventtracekernel_draft_aoid_toneoff.m first


%% use non rigid regression

S = dir(fullfile('E:\PV photometry - active avoidance\20190304 active avoidance\20190824 toneoff_or_cross_kernel_anvoa\20190824_kernel_regression','*avd_toff.mat'));

ball=zeros(1530,numel(S));
b_0avd=zeros(1530,numel(S));
b_0toff=zeros(1530,numel(S));


rsq=zeros(3,numel(S));
for k=1:numel(S)
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
xbar = 1:3;
IL=[2,4:9];
databar = [mean(rsq(1,IL)) mean(rsq(2,IL))  mean(rsq(3,IL))]';
err1=std(rsq(1,IL))/(length(rsq(1,IL))^0.5);
err2=std(rsq(2,IL))/(length(rsq(2,IL))^0.5);
err3=std(rsq(3,IL))/(length(rsq(3,IL))^0.5);
err = [err1 err2 err3];

figure()


b=bar(xbar,databar,0.5,'Facecolor','flat');
hold on
b.CData(2,:) = [0.7 0.7 0.7];

b.CData(1,:) = [233/255    152/255    117/255];

jitter=rand(length(rsq(3,IL)),1)/10;
for i=1:length(rsq(3,IL))
    plot([0.95+jitter(i), 1.95+jitter(i), 2.95+jitter(i)],[rsq(1,IL(i)), rsq(2,IL(i)), rsq(3,IL(i))],'-o','Color' ,[0.3 0.3 0.3],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',5);
end

er = errorbar(xbar,databar,err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

xticks([1 2 3]);
xticklabels({'origin','w/0 avoid','w/0 tone off'});
xtickangle(30);

ylabel('Change in R^2');
%ylim([0 14]);
set(findall(gcf,'-property','FontSize'),'FontSize',20);
set(gca, 'FontName', 'helvetica');
set(gcf, 'Units', 'inches');
set(gcf,'Position',[7.0729/2    7.0521/2    5.5/2    4.125]);
set(gcf,'renderer','Painters')

% plot([1 2],[4 4],'k');
% t=text(1.2,4.5,'n.s.');
% t(1).FontSize=20;
% 
% plot([3 4],[16.5 16.5],'k');
% t=text(3.35,17.3,'N.S.');
% t(1).FontSize=12;
% 
%ylim([-10 5]);
hold off

%%
xbar = 1:2;
IL=[2,4:9];
databar = [mean(rsq(2,IL)-rsq(1,IL))  mean(rsq(3,IL)-rsq(1,IL))]';
err1=std(rsq(2,IL)-rsq(1,IL))/(length(rsq(2,IL))^0.5);
err2=std(rsq(3,IL)-rsq(1,IL))/(length(rsq(3,IL))^0.5);
err = [err1 err2];

figure()


b=bar(xbar,databar,0.5,'Facecolor','flat');
hold on
b.CData(2,:) = [0.7 0.7 0.7];

b.CData(1,:) = [233/255    152/255    117/255];


jitter=rand(length(rsq(2,:)),1)/10;
for i=1:length(IL)
    plot((0.95+jitter(IL(i))),(rsq(2,IL(i))'-rsq(1,IL(i))'),'o','Color' ,[0.3 0.3 0.3],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',1);
end

jitter=rand(length(rsq(2,:)),1)/10;
for i=1:length(IL)
    plot((1.95+jitter(IL(i))),(rsq(3,IL(i))'-rsq(1,IL(i))'),'o','Color' ,[0.3 0.3 0.3],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',1);
end


er = errorbar(xbar,databar,err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
er.CapSize = 1;

xticks([1 2]);
xticklabels({'w/o avoid','w/o tone off'});
xtickangle(45);

ylabel('\Delta R^2');
%ylim([0 14]);
set(findall(gcf,'-property','FontSize'),'FontSize',7);
set(gca, 'FontName', 'Arial');
set(gca, 'Units', 'centimeter');
set(gca,'Position',[7.0729/2    7.0521/2   1.2949 1.9346]);
set(gcf,'renderer','Painters')

% plot([1 2],[4 4],'k');
% t=text(1.2,4.5,'n.s.');
% t(1).FontSize=20;
% 
% plot([3 4],[16.5 16.5],'k');
% t=text(3.35,17.3,'N.S.');
% t(1).FontSize=12;
% 
ylim([-0.06 0.025]);
t=text(0.9,-0.056,'*');
t(1).FontSize=6;

t=text(1.6,-0.054,'n.s.');
t(1).FontSize=6;
hold off

[test,p]=ttest((rsq(2,IL)-rsq(1,IL))); %p=0.0205 %0.0125 non rigid
[test,p]=ttest((rsq(3,IL)-rsq(1,IL))); %p=0.0550 %0.0802 non rigid
[test,p]=ttest((rsq(2,IL)-rsq(1,IL)),(rsq(3,IL)-rsq(1,IL))); %p=0.4457 %%0.1477 non rigid

%% Patch b 

fig=figure;

Ty=[2,4:9];

toneoffav=zeros(102*2,7);
for i=1:length(Ty)
toneoffav(:,i)=smooth(ball(102*2+1:102*4,Ty(i))',10,'rlowess');

end

meanonsetav=mean(toneoffav','omitnan');
errav=std(toneoffav','omitnan')/length(Ty)^0.5;

%LINE MAP <<<<<<<<<
tbf=0;taf=2;
%avoidance
x1=1/102:1/102:2;
y1=meanonsetav;
error1=errav;
patch([x1 fliplr(x1)],[y1+error1 fliplr(y1-error1)],[0.7 0.7 0.7],...
    'EdgeColor','none');
hold on;
plot(x1,y1,'Color',[0 0 0]);
%plot([0 0],[-0.05 maxdff],'r');
ylabel('Regression coefficient');
%title('aligned to chamber crossing')

ylim([0 0.05]);
yticks([0 0.01 0.02 0.03 0.04 0.05]);
yticklabels({'0','','0.02','','0.04',''});
xlim([0 2]);
%yticks([0 0.05 0.10 0.15 0.20]);
set(gca, 'Layer', 'top');
%yticklabels({'0','05','10','15','20'})
xlabel('Time (s)');
set(gca, 'Layer', 'top');
hold off
set(findall(gcf,'-property','FontSize'),'FontSize',7);
set(gca, 'FontName', 'Arial');
set(gca, 'Units', 'centimeter');
%set(gcf,'Position',[7.0729/2    7.0521/2    6.6669/2    5]);
set(gca,'Position',[7.0729/2    7.0521/2   2.6 1.7119 ]);
set(gcf,'renderer','Painters')
%%
fig=figure;

Ty=[2,4:9];
avoidav=zeros(102*3,7);
for i=1:length(Ty)
avoidav(:,i)=smooth(ball(102*7+1:102*10,Ty(i))',10,'rlowess');

end
meanonsetav=mean(avoidav','omitnan');
errav=std(avoidav','omitnan')/length(Ty)^0.5;

%LINE MAP <<<<<<<<<
tbf=0;taf=2;
%avoidance
x1=-1+1/102:1/102:2;
y1=meanonsetav;
error1=errav;
patch([x1 fliplr(x1)],[y1+error1 fliplr(y1-error1)],[0.7 0.7 0.7],...
    'EdgeColor','none');
hold on;
plot(x1,y1,'Color',[0 0 0]);
plot([0 0],[0 0.05],'k');
ylabel('Regression coefficient');
%title('aligned to chamber crossing')

ylim([0 0.05]);
yticks([0 0.01 0.02 0.03 0.04 0.05]);
yticklabels({'0','','0.02','','0.04',''});
xlim([-1 2]);
%yticks([0 0.05 0.10 0.15 0.20]);
set(gca, 'Layer', 'top');
%yticklabels({'0','05','10','15','20'})
xlabel('Time (s)');
set(gca, 'Layer', 'top');
hold off

set(findall(gcf,'-property','FontSize'),'FontSize',7);
set(gca, 'FontName', 'Arial');
set(gca, 'Units', 'centimeter');
%set(gcf,'Position',[7.0729/2    7.0521/2    6.6669/2    5]);
set(gca,'Position',[7.0729/2    7.0521/2   2.6 1.7119 ]);
set(gcf,'renderer','Painters')

%%
