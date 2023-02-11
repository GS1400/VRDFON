

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initMem.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [point,step,par,info]=initMem(x,f,prt);
% initialize memory
%
% x            % initial point 
% f            % function value at initial point 
% prt          % print level 
%
% point        % structure with info about points and function values
%  .x          %   point with best function value found
%  .f          %   best function value at x
%  .X          %   a list of the m best point so far
%  .F          %   the function values of X
%  .xr         %   newest point 
%  .fr         %   function value at xr
%  .xm         %   point at xr-p
%  .fm         %   function value at xm 
%  .xinit      %   initial point
%  .finit      %   initial function value
%  .b          %   index of best point
%  .m          %   number of best point kept
% step         % structure for step management
%  .p          %   random search direction
%  .deltamin   %   minimal step size
%  .deltamax   %   maximal step size
%  .delta      %   current step size
% par          % structure with parameters modified during the search
%  .T          %   maximal number of random directions
%  .df         %   the difference of best point and the new point
%  .ngood      %   number of extrapolation stages
%  .dir        %   select direction type
%  .state      %   state of cumulative step
%  .desent     %   is there the initial interval or not ?
% info         % performance information for VRBBON
%  .finit      %   initial function value
%  .ftarget    %   target function value (to compute qf)
%  .qf         %   (ftarget-f)/(finit-f)
%  .initTime   %   inital cputime
%  .done       %   done with the search?
%
function [point,step,par,info]=initMem(x,f,prt);

% initialize structure with information about points and function values
%
% starting point
if isempty(x)
  message = 'starting point must be defined';
  disp(message) 
  return      
elseif ~isa(x,'numeric')
  message = 'x should be a numeric vector'; 
  disp(message) 
  return       
end


% dimension
point.n = length(x);

% artificial lower and upper bounds to help prevent overflow
point.low=x-1e20;
point.upp=x+1e20;
point.x=x;
% other point info
point.X     = point.x; 
point.F     = NaN;   
point.xinit = point.x; 
point.finit = NaN;     
point.fr    = NaN;   
point.fm    = NaN;
point.b     = NaN;    
point.m     = 0; 
point.xr    = NaN+ones(point.n,1); 
point.xm    = NaN+ones(point.n,1); 


% initialize structure for step management
%
step.delta  = NaN; 
step.p      = NaN+ones(point.n,1); 
step.alphaE = NaN;
step.alow   = 0;
step.aupp   = Inf;


% initialize structure with parameters modified during the search
par.dir = NaN; par.T = NaN; 
par.df= 1; par.T = NaN; par.ngood =0; par.isub=0;
par.state=-1; par.descent=1;  par.ii=0; par.Dstate=-1;


% initialize info
%
info.initTime     = cputime; 
info.nquadmodel   = 0; 
info.nlinearmodel = 0;
info.model        = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


