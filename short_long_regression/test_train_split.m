function [Y_test,X_test,Y_train,X_train] = test_train_split(Y,X,folds)
%Get testing data set for cross-validation
% Ys: calcium signals with only time points when events happens
% Xs: designed matrix
% 
rng('default');
rng(1);
randIdx = randperm(size(Y,1))'; %generate randum number index
foldCnt = floor(size(Y,1) / folds);

dataIdx=true(size(Y,1),1);
dataIdx(randIdx(1:foldCnt,1)) = false; %index for training data
%dataIdx(randIdx(((iFolds - 1)*foldCnt) + (1:foldCnt))) = false; %index for training data

Y_test=Y(~dataIdx,:);
X_test=X(~dataIdx,:);
Y_train=Y(dataIdx,:);
X_train=X(dataIdx,:);



end

