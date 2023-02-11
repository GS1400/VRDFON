

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mintry.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reentrant unconstrained optimization 
% minimize fun(x)
%
% function mintry(init);                      % initialize mintry
% function x=mintry(x,f,prt); % enter f=fun(x), return next point to try
% function [xbest,fbest,info]=mintry('show')  % show results
% 
% init     % structure with print and tune information
%          %     missing fields imply default information
%  .prt    %   print level
%                 -1 = nothing
%            0,1,2,3 = about solver (little, more, more and more)
%                  4 = showing how to call solver
%                                 
%          %
%  .solver %   solver, one of 'VRDFON', ...
%  .tune   %   tuning parameters for this solver
%          %     (solver specific, see initTune.m of the solver)
% x        % point evaluated (input) or to be evaluated (output)
% f        % function value at input x
% prt      % change print level (optional) 
% xbest    % point with best function value found
% fbest    % best function value, fbest=fun(xbest)
% info     % summary of optimization behavior
%
% see driver.m for usage
%
function [x,f,info]=mintry(x,f,p)

persistent prt solver

aux.VRDFON='minq8';  % auxiliary solver needed for solver VRDFON

if nargin==1   
  if isstruct(x), 
    % initialization of solver environment
    init=x;
    prt=-1; if isfield(init,'prt'), prt=init.prt; end;
    solver='VRDFON'; if isfield(x,'solver'), solver=init.solver; end;
    if exist(aux.(solver))~=2,
      eval(['addpath ',init.paths])
    end;
    tune=[]; 
    if isfield(init,'tune'), tune=init.tune; end;
    fun=[]; % reenetrant mode has no function handle
    n=init.n;
    stepCall=[solver,'step(tune,fun,prt,n);'];
    eval(stepCall);
    if prt>3, disp(stepCall); end;
    return;
  end;

  if ischar(x), 
    % return best point and summary info
    stepCall=['[x,f,info]=',solver,'step();'];
    eval(stepCall);
    if prt>=0, xbest=x,fbest=f,info, end
    if prt>3, disp(stepCall); end;
    return;
  end;

  % inconsistent initialization
  init=x
  error('inconsistent input');
end;

% perform one step of the algorithm chosen
if nargin==3, 
  % update print level
  stepCall=['x=',solver,'step(x,f,p);'];
else 
  stepCall=['x=',solver,'step(x,f);'];
end;
eval(stepCall);
if prt>3, disp(stepCall); end;

