
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VRDFON.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [x,f,info] = VRDFON(fun,x,st,tune);
%
% solves the unconstrained noisy black box optimization problem 
%    min f(x) 
%  
% fun          % function handle for objective function
% x            % starting point (must be specified)
% st           % structure with stop and print criteria
%              %   (indefinite run if no stopping criterion is given)
%  .secmax     %   stop if sec>=secmax (default: inf)
%  .nfmax      %   stop if nf>=nfmax   (default: inf)
%  .qf         %   stop if gf<=accf    (default: 1e-4)
%  .fbest      %   function value accepted as optimal (default: 0)
%  .prt        %   printlevel (default: -1)
%              %   -2: nothing, -1: litte, >=0: more and more
% tune         % optional structure specifying tuning parameters
%              %   for details see initTune.m
%
% x            % best point found 
% f            % function value at best point found 
% info         % performance information for VRDFON
%  .finit      %   initial function value
%  .ftarget    %   target function value (to compute qf)
%  .qf         %   (ftarget-f)/(finit-f)
%  .initTime   %   inital cputime
%  .done       %   done with the search?
%  .acc        %   stop when qf<=acc
%  .secmax     %   stop if sec>=secmax 
%  .nfmax      %   stop if nf>=nfmax 
%  .finit      %   the initial f
%  .prt        %   printlevel 
%              %     -1: nothing, 0: litte, >=1: more and more
% 
function [xbest,fbest,info] = VRDFON(fun,x,st,tune);

persistent finit

%%%%%%%%%%%%%%%%%%%%%%%%
%%%% initial checks %%%%
%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(st,'prt')
    prt=0;
else
   prt=st.prt;
end

if prt>=0,
  disp(' ')
  disp('==============================================================')
  disp('start VRDFON')
  disp('==============================================================')
end;
% check function handle
if isempty(fun)
  message = 'VRDFON needs the function handle fun to be defined';
  disp(message)  
  return
elseif ~isa(fun,'function_handle')
  message = 'fun should be a function handle';
  disp(message)
  return
end;


% add info on stopping criteria
if isfield(st,'secmax'), info.secmax=st.secmax;
else, info.secmax=inf;
end;
if isfield(st,'nfmax'), info.nfmax=st.nfmax;
else, info.nfmax=inf;
end;
if isfield(st,'ftarget'), info.ftarget=st.ftarget;
else, info.ftarget=0;
end;
if isfield(st,'accf'), info.accf=st.accf;
else, info.accf=-inf;
end;



info.prt = prt; % print level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% initialize solver environment %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=length(x);

VRDFONstep(tune,fun,prt,n)
 
initTime=cputime;

%%%%%%%%%%%%%%%%%%%
%%%% main loop %%%%
%%%%%%%%%%%%%%%%%%%
nf=1;
while 1
  % get function value
  f=fun(x);
  if nf==1, finit=f;end
  nf=nf+1;
  % get new point for function evaluation
  x         = VRDFONstep(x,f,prt);
  sec       = (cputime-initTime);
  info.done = (sec>st.secmax)|(nf>=st.nfmax);
  if nf>=1
     qf        = abs((f-st.ftarget)/(finit-st.ftarget));
     info.qf   = qf;
     info.done = (info.done|info.qf<=st.accf);
  end
  info.sec  = sec;
  if info.done,break; end;
end;

%%%%%%%%%%%%%%%%%%%%%
%%%% return info %%%%
%%%%%%%%%%%%%%%%%%%%%
[xbest,fbest,info]=VRDFONstep;


info.qf = (fbest-st.ftarget)/(finit-st.ftarget);
info.sec=sec;
info.nf=nf;
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% solution status  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
if info.qf<=st.accf
  info.status = 'accuracy reached';
elseif nf>=st.nfmax
   info.status = 'nfmax reached';
elseif sec>=st.secmax
  info.status = 'secmax reached';
else
  info.status = 'unknown';
end;



if prt>=0,
  disp('==============================================================')
  disp('end VRDFON')
  disp('==============================================================')
end


