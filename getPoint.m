
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% getPoint.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [point,par,step,info] = getPoint(point,step,par,tune,info)
%
% compute the trial point xr
%
% for details of input and output structures see VRDFON.m

function [point,par,step,info] = getPoint(point,step,par,tune,info)

switch par.state
case -1 % new direction
    par.t=par.t+1; par.nE=0;  

    [point,step,par] = direction(point,step,par,tune);

case 0  % extrapolate stage
      par.nE=par.nE+1;
      if info.prt>=3 
          disp('----------------------------------------------------')
          disp([num2str(par.nE),'th extrapolation at nf=',...
                  num2str(point.nf)]);
      end   

    point.fext = point.fr; 

    point.extF(par.nE)   = point.fr; point.extalp(par.nE) =  step.alphaE;

    step.alphaE = step.alphaE*tune.gammaE;

case 1 % opposite direction
  step.p = -step.p; par.nE = 0;
end
point.xr = point.xm+step.alphaE*step.p;
point.nf=point.nf+1;

 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
