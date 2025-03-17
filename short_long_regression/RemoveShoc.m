function [ Avo ] = RemoveShoc( Cross,Shoc,N )
%Remove values that are close to each other within N (frames/units of Shoc or Cross)
%   Detailed explanation goes here

Crosssub=zeros(size(Cross,1),1);
for i=1:length(Shoc)
    duplfr=(abs(Cross-Shoc(i))<=N);
    Crosssub(duplfr,1)=1;
end
Avo=Cross(Crosssub==0);



end
