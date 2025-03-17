function [rsq] = rsquare_function(Y,X,b)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
f=X*b;
rsq=1-( ( norm(X*b-Y) )^2 / ( norm(Y-mean(Y)) )^2 ); 

end




