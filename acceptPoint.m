
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% acceptPoint.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [point,par,step,info] = acceptPoint(point,step,par,tune,info)
%
% accept the point xm if extrapolation has been done 
%        or the point xr if fr<fm
%
% reduce the step size if no progress in f has been found
%
% for details of input and output structures see VRDFON.m

function [point,par,step,info] = acceptPoint(point,step,par,tune,info)
    
if par.state==0 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % the end of extrapolation %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  [fb,ind] = min(point.extF); ind =ind(1);

   step.alphaE  = point.extalp(ind); 
   point.xm     =  point.xm+step.alphaE*step.p;        
   point.fm     =  fb;   

   % update X F Y
   [point] = updateXFY(point,step,tune);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if par.descent==1
      [point,step]=initInterval(point,step); 
      par.descent =0;
   else
      [step]=updateInterval(step,par);
   end

   point.extF=[]; point.extalp=[];

   par.ngood = par.ngood+1;
   
    if info.prt>=0
         disp(['function value improved at nf=',num2str(point.nf),...
            ' to f=',num2str(point.fm)]) 
    end
    
     if info.prt>=3
        disp(['extrapolation was stopped at nf=',num2str(point.nf)]);
        disp('----------------------------------------------------')
     end
   
 else
  point.extF=[]; point.extalp=[];
   if par.df>0 
      point.xm  = point.xr;  
      point.fm  = point.fr;
      [point]   = updateXFY(point,step,tune);
      par.ngood = par.ngood+1;
      if info.prt>=0
         disp(['function value improved at nf=',num2str(point.nf),...
            ' to f=',num2str(point.fm)]) 
      elseif info.prt>=3
         disp(['function value improved at nf=',num2str(point.nf),...
            ' to f=',num2str(point.fm),' because of ftrial<fbest'])  
          
      end
      
   end
   [step]=reducedStepSize(step,tune); % reduce the step size
   [step]=updateInterval(step,par); % update interval

 end
 par.state = -1;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
