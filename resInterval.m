%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% resInterval.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [step]=resInterval(point,step,tune)
% estimate the lower or upper bound of the interval
%
% for details of input and output structures see VRDFON.m
%

function [step]=resInterval(point,step,tune)

alp=[];

for i=1:point.m
    if i~=point.b
       xx = point.X(:,i)-point.xm; ind = find(point.xm~=0 & xx~=0);
       if ~isempty(ind)
          alp = [alp max(abs(point.xm(ind)./xx(ind)))]; 
       end
    end
end;

if ~isempty(alp)
    
    malp =tune.gammaa*min(alp);

    if ~isnan(malp) && ~isinf(malp)

       mu = rand(2,1); 
       mu = sort(mu);

       step.alow = mu(1)*malp; 
       step.aupp = mu(2)*malp;
       

    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%