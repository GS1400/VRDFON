

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% VRDFONstep.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% performs one step of VRDFON
% 
%
% function VRDFONstep(tune,fun,prt,n); % initialize solver
%
% tune         % structure contains those tuning parameters that are 
%              %   explicitly specified; the others take default values
%              %   (for choices and defaults see initTune.m)
% fun          % function handle (empty if used in reentrant mode)
% prt          % print level
% n            % problem dimension
%
% function x=VRDFONstep(x,f,prt); % suggest new point
%
% x            % point evaluated (input) or to be evaluated (output)
% f            % function value at input x
% prt          % print level
%               -1 = nothing, 
%                0 = only improved function values
%                1 = some details of the main loop of VRDFON
%                2 = some details of decrease search of VRDFON
%                3 = some details of multi line search of VRDFON
%
% function [xbest,fbest,info]=VRDFONstep();  % read results
%
% xbest        % current best point
% fbest        % function value found at xbest
% info         % performance information for VRDFON
%  .finit      %   initial function value
%  .ftarget    %   target function value (to compute qf)
%  .qf         %   (ftarget-f)/(finit-f)
%  .initTime   %   inital cputime
%  .done       %   done with the search?
%
%
function [x,f,info1]=VRDFONstep(x,f,p,n)

persistent  tune prt point step par info

if nargin==0, 
  %%%%%%%%%%%%%%%%%%%%%
  %%%% return info %%%%
  %%%%%%%%%%%%%%%%%%%%%
  xm=point.xm;
  fm=point.fm;
  if fm<point.fr, x=xm; f=fm; 
  else
      x=point.xr; f=point.fr;
      if info.prt>=0
         disp(['function value improved at nf=',num2str(point.nf),...
            ' to f=',num2str(f)]) 
      end
  end
  info1=info; 
  return;
end;

if nargout==0,
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%% initialize solver environment %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  tune=[]; point=[]; step=[]; par=[]; info=[];
  
  tune=initTune(tune,n);
  
  prt=p;
  info1=info;
  par.Vstate=1;
  % get subspace sizes
  point.n=n;
  point.m=0;
  return;
end

% update of information after computing the initial f
   
if par.Vstate==1  
    [point,step,par,info]=initMem(x,f,prt);
    point=sizeSample(point);
    point.nf=1;
    if isnan(f), f=inf; end
    point.f=max(-1e50,min(f,1e50));
    % get initial values for subspace 
    point.F =  f;
    point.X =  x;
    point.xm = x;
    point.fm = f; 
    point.b = 1; 
    point.m =1; 
    point.Y(1) = 1;
    par.itc = 0;

    step.aupp = tune.aupp; step.alow = tune.alow;

    %%%%%%%%%%%%%
    % main loop %
    %%%%%%%%%%%%%
    if prt>=0
      disp(' ')
      disp(' ') 
      disp('start of main loop of VRDFON:')
      disp(' ')
      disp(' ')
    end
    par.Vstate=2; par.ii=0; info.prt=prt;
end

while 1
    
if par.Vstate==2 % initialization for DS in each iteration
    % update the information
    
   % point.xm = point.X(:,point.b); 
   % point.fm = point.F(point.b);
    point.xr = point.xm; point.finit=point.fm; par.stateTest = '';
    par.ngoodi=par.ngood; par.ngood = 0; par.ngoodold=0;
    point.xinit=point.xm; 
    par.itc = par.itc + 1;
    %par.t=0; par.T=tune.R; par.dir = 1; % pick random direction
    par.Vstate=3; par.state=-1;
    if prt>=0
         disp(' ')
         disp(['=================================================',...
             '=========================='])
         disp(['start of DS at ',num2str(par.itc),'th'])
           disp(['=================================================',...
             '=========================='])
         disp(' ')
    end
end


%%%%%%%%%%%%%%%%%%%%%%%
%%%% update memory %%%%
%%%%%%%%%%%%%%%%%%%%%%%

if par.Vstate==3 
     par.ii = par.ii+1; 
     par.totalngood= 0;
     par.Vstate=4;
     par.state=-1;
end


if par.Vstate==4
    if prt>=2, disp('MLS with random directions'); end   
    par.t=0; par.T = tune.R; par.dir = 1;  
    % MLS using scaled random  directions
    [point,par,step] = initMLS(point,step,par,tune);
     par.Vstate=5;
end
if par.Vstate==5
  [point,par,step,info] = getPoint(point,step,par,tune,info);  
  par.Vstate=6; x = point.xr;
  return
end

if par.Vstate==6
  point.fr=f; par.df  = point.fm-point.fr;
  par.ext = (par.df>=tune.gamma*step.alphaE^2&par.nE <= tune.E); 
  if par.ext,
      par.state=0; par.Vstate=5; continue;
  else

    if par.state==-1, par.state=1; par.Vstate=5; continue;
    else
        [point,par,step,info] = acceptPoint ...
                                (point,step,par,tune,info);
         par.totalngood =  par.totalngood+par.ngood;                   
        if par.t==par.T && par.state==-1, par.Vstate=7;end
        if par.Vstate~=7, par.Vstate=5; continue; end
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MLS with random subspace direction if m>=3 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if point.m>=3
   if par.Vstate==7
        if prt>=2, disp('MLS with random subspace directions'); end
        par.t=0; par.T=1; par.dir  = 2;   % pick random subspace direction
        % MLS using random subspace direction
        [point,par,step] = initMLS(point,step,par,tune);
        par.Vstate=8;
   end
   if par.Vstate==8
       par.ngood=0;
      [point,par,step,info] = getPoint(point,step,par,tune,info);
      x = point.xr; par.Vstate=9; 
      return;
   end
   if par.Vstate==9      
      point.fr=f; par.df  = point.fm-point.fr;
      par.ext = (par.df>=tune.gamma*step.alphaE^2&par.nE <= tune.E); 
      if par.ext,
          par.state=0; par.Vstate=8; continue;
      else
        
        if par.state==-1, par.state=1; par.Vstate=8; continue;
        else
            [point,par,step,info] = acceptPoint...
                                         (point,step,par,tune,info);
             par.totalngood =  par.totalngood+par.ngood;                        
             ok = (par.ngood ==0);
            if ok
                par.Vstate=10;
            else
                par.Vstate=8; continue
            end
            
        end
      end
    end
else
   if  par.Vstate==7, par.Vstate=10; end
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct quadratic or linear model %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if par.Vstate==10
 if tune.model
     ok = (point.m>=5); 
     if ok
      info.model = info.model+1; par.ngoodold = par.ngood;
      if prt>=2, disp('reduced quadratic model was constructed'); end
     % construct a quadratic model
     [point,step] = fit(point,step,tune);
      par.Vstate=11;
     else
         if prt>=2, disp('reduced linear model was constructed'); end
         par.Vstate=15; 
     end 
 else
     par.Vstate=15;
 end
end  
if par.Vstate==11 && ~ point.randg
    info.nquadmodel = info.nquadmodel+1;
    if info.prt>=2
      fprintf(['fit is successful \nthe gradient and Hessain', ...
            ' are estimated\n'])
    end
    [step]=genRadius(point,step,tune); % generate the radius
    par.Vstate=12;
end
if par.Vstate==12
    par.t = 0; par.T =1; par.dir  = 3;   % pick TR direction
    if info.prt>=2
        disp('start of MLS using trust region direction')
    end 
    [point,par,step] = initMLS(point,step,par,tune);
    par.Vstate=13;
end
if par.Vstate==13
  par.ngood=0;
  [point,par,step,info] = getPoint(point,step,par,tune,info);  
   x = point.xr; par.Vstate=14; 
   return;
end
if par.Vstate==14
  point.fr=f; par.df  = point.fm-point.fr;
  par.ext = (par.df>=tune.gamma*step.alphaE^2&par.nE <= tune.E); 
  if par.ext,
      par.state=0; par.Vstate=13; continue;
  else
    
    if par.state==-1, par.state=1; par.Vstate=13; continue;
    else
        [point,par,step,info] = acceptPoint(point,step,par,tune,info);
        par.totalngood =  par.totalngood+par.ngood;
        ok = (par.ngood ==0);
        if ok,par.Vstate=15; 
        else, 
            par.Vstate=13;  step.d = (0.5+rand)*step.d; 
            continue
        end
    end
  end
end
if par.Vstate==11 && point.randg
     par.t=0; par.T=1; 
     par.dir = 4; % pick  random scaled gradient direction
    if info.prt>=2
        disp('start of MLS using scaled gradient direction')
    end 
    % MLS using scaled gradient direction
     [point,par,step] = initMLS(point,step,par,tune);
     par.Vstate=16;      
end
if par.Vstate==16  
   par.ngood=0;
   [point,par,step,info] = getPoint(point,step,par,tune,info);  
   x = point.xr; par.Vstate=17; 
   return;
end
if par.Vstate==17 
  point.fr=f; par.df  = point.fm-point.fr;
  par.ext = (par.df>=tune.gamma*step.alphaE^2&par.nE <= tune.E); 
  if par.ext,
      par.state=0; par.Vstate=16; continue
  else
    
    if par.state==-1, par.state=1; par.Vstate=16; continue
    else
        [point,par,step,info] = acceptPoint(point,step,par,tune,info);
        par.totalngood =  par.totalngood+par.ngood;
        ok = (par.ngood ==0);
        if ok, 
            par.Vstate=15; 
        else
            par.Vstate=16;  continue
        end
    end
  end
else
  if par.Vstate==10, par.Vstate=15; end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% possibly restart the interval
% update step sizes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  par.Vstate==15
    % restart the interval
    res = (par.totalngood==0 & point.m>=3);
    % restate the interval since there is no improvement
    if res 
       if info.prt>=1
          disp('the interval has been restarted by resInterval')
       end
       [step]=resInterval(point,step,tune);
    end
    if par.ii==tune.T0
        par.Vstate=2; 
        if step.delta <= tune.deltamin, return; end
        % expand or reduce the step size depending on
        % whether there exits any improvement on f or not

        if info.prt>=1
           disp(['step size delta = ',num2str(step.delta),';'])
        end
        [step]=updateStepSize(step,par,tune);
        par.ii=0;  par.state=-1; 
    else
        par.Vstate=3; 
    end
end % if
end % while
end % VRDFONstep

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

