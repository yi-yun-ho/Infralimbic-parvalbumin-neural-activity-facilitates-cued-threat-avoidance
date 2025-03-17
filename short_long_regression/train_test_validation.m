% run cross validation
% just validation with 1/folds of testing data (no actual "cross"
% validation 
folds=10;
[Y_test,X_test,Y_train,X_train] = test_train_split(Ys,Xs,folds);
b=regress(Y_train,X_train); %cross validation??

rsq_train=rsquare_function(Y_train,X_train,b); %0.2123 -pv012
rsq_test=rsquare_function(Y_test,X_test,b); %0.1859 -pv012 (different larger than 10%)


