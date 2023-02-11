

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initTune.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function tune=initTune(tune,n);
% initialize tuning parameters
%
% tune         % on input, tune contains those tuning parameters
%              % that are explicitly set; the others take default values
% n            % problem dimension
%
% tune         % on output, tune contains all tuning parameters: 
%   .mmax      % maximum number of best points kept
%   .T0        % maximal number of calls to RLS in DS
%   .R         % maximal number of random directions in RLS
%   .E         % maximal number of extrapolations in RLS
%   .deltamin  % minimum threshold for stopping VRBBON
%   .deltamax  % initial step size
%   .gamma     % factor for adjusting forcing function
%   .gammaE    % factor for extrapolation test
%   .gammaX    % factor for adjusting X
%   .gammaa    % tiny factor for finding a robustified interval
%   .gammar    % factor for adjusting the random direction
%   .gammad1   % factors for updating the trust region radius
%   .gammad2   % factors for updating the trust region radius
%   .gammav    % factor for adjusting sc and y
%   .alpmin    % minimum step size in RLS
%   .Q         % factor for adjusting Delta
%   .dmin      % minimum value for the trust region radius
%   .dmax      % maximum value for the trust region radius
%   .alow      % lower bound for initial interval
%   .aupp      % upper bound for initial interval  
%   .gammap    % factor for adjusting the trust region direction
%   .minqeps   % minimum threshild for stopping minq8
%   .minqmax   % maxiumu number of iterations in minq8
%   .model     % linear or quadratic model
%   .bis       % bisection (1: geometric mean, 2: cubic)
%   .mbis      % parameter for bisection
%
function tune=initTune(tune,n);

% initialize structure containing all tuning parameters 
%
% tune % structure containing all tuning parameters 
%      % all parameters have a default that can be overwritten 
%      % by specifying it as an input
%  .mmax      % maximum number of best points kept
%  .T0        % maximal number of calls to RLS in DS
%  .R         % maximal number of random directions in RLS
%  .E         % maximal number of extrapolations in RLS
%  .deltamin  % minimum threshold for stopping VRDFON
%  .deltamax  % initial step size
%  .gamma     % factor for adjusting forcing function
%  .gammaE    % factor for extrapolation test
%  .gammaX    % factor for adjusting X
%  .gammaa    % tiny factor for finding a robustified interval
%  .gammar    % factor for adjusting the random direction
%  .gammad1   % factors for updating the trust region radius
%  .gammad2   % factors for updating the trust region radius
%  .gammav    % factor for adjusting sc and y
%  .alpmin    % minimum step size in RLS
%  .Q         % factor for adjusting Delta
%  .dmin      % minimum value for the trust region radius
%  .dmax      % maximum value for the trust region radius
%  .alow      % lower bound for initial interval
%  .aupp      % upper bound for initial interval  
%  .gammap    % factor for adjusting the trust region direction
%  .minqeps   % minimum threshild for stopping minq8
%  .minqmax   % maxiumu number of iterations in minq8
%  .model     % linear or quadratic model
%  .mbis      % parameter for bisection
%  .comBound  % complexity bound verified?


if ~exist('tune'), tune=[]; end;

% maximum number of best points kept
if ~isfield(tune,'mmax'), 
    tune.mmax = min(0.5*n*(n+3),230);
end;

% maximum number of calls to robustified line search
% using random direction in DS
if ~isfield(tune,'T0'), tune.T0 = n; end;


% complexity bound verified?
if ~isfield(tune,'comBound'), tune.comBound = 2; end;

switch  tune.comBound
    case 2
        if ~isfield(tune,'R'), tune.R = n; end;
    case 1
        if ~isfield(tune,'R'), tune.R = max(1,fix(n/2)); end;
        if ~isfield(tune,'C'), tune.C = max(1,fix(n/2)); end;
    case 0
        if ~isfield(tune,'C'), tune.C = n; end;
    otherwise 
        error('comBound should be one of 0,1,2')
end

if isfield(tune,'C')
  tune.C = min(tune.C,n);
end
if isfield(tune,'R')
    tune.R = min(tune.R,n);
end



% maximal number of random trials
if ~isfield(tune,'E'), tune.E= Inf; end;

% minimum threshold for stopping VRDFON
if ~isfield(tune,'deltamin'), tune.deltamin = 0; end;

% initial step size 
if ~isfield(tune,'deltamax'), tune.deltamax = 1; end;

% factor for adjusting forcing function
if ~isfield(tune,'gamma'), tune.gamma = 1e-6; end;

% factor for extrapolation test
if ~isfield(tune,'gammaE'), tune.gammaE = 3; end;

% factor for adjusting X
if ~isfield(tune,'gammaX'), tune.gammaX = 100; end;

% tiny factor for finding a robustified interval
if ~isfield(tune,'gammaa'), tune.gammaa = 1e-5; end;

% factor for adjusting the random direction
if ~isfield(tune,'gammar'), tune.gammar = 1e-30; end;

% factors for updating the trust region radius
if ~isfield(tune,'gammad1'), tune.gammad1 = 0.1; end;
if ~isfield(tune,'gammad2'), tune.gammad2 = 2; end;

% factor for adjusting sc and y
if ~isfield(tune,'gammav'), tune.gammav = 100; end;

% minimum step size in RLS
if ~isfield(tune,'alpmin'), tune.alpmin = 1e-3*rand; end;

% factor for adjusting delta
if ~isfield(tune,'Q'), tune.Q = 1.5; end;

% minimum value for the trust region radius
if ~isfield(tune,'dmin'), tune.dmin = 1e-4; end;

% maximum value for the trust region radius
if ~isfield(tune,'dmax'), tune.dmax = 1e+3; end;

% lower bound for initial interval
if ~isfield(tune,'alow'), tune.alow = 1e-2; end;

% upper bound for initial interval
if ~isfield(tune,'aupp'), tune.aupp = 0.99; end;

% factor for adjusting the trust region direction
if ~isfield(tune,'gammap'), tune.gammap = 0.25; end;

% minimum threshild for stopping minq8
if ~isfield(tune,'minqeps'), tune.minqeps = 1e-8; end;

% maxiumu number of iterations in minq8
if ~isfield(tune,'minqmax'), tune.minqmax = 10000; end;

% linear or quadratic model
if ~isfield(tune,'model'), tune.model = 1; end;

% parameter for perturbed random direction
if ~isfield(tune,'gammak'), tune.gammak = 0.85; end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     