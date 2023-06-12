
% MinTry, reentrant uncoonstrained optimization
% driver.m      % driver for reentrant uncoonstrained optimization
% mintry.m      % reentrant uncoonstrained optimization algorithm
% VRBBONstep.m  % <solver>step.m must exist for each solver
% initTune.m    % must exist for each solver
% initMem.m     % must exist for each solver
% VRBBONrun.m   % temporary; will ultimately be VRBBON.m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% driver.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mintry driver for reentrant unconstrained optimization
%
% replace in the driver the starting point and the Rosenbrock function 
% by your own problem data.
%

clear
clc
%rng('default')

solverPath = input('add path:',"s");

% standard initialization
init.n=2;     % problem dimension
              % For tuning or to see intermediate results, 
              % a nonstandard initialization may be used.
              % For details see mintry.m
              
              
init.paths = [solverPath,'/minq8'];

mintry(init); % initialize mintry

x=[-1 -1]';   % starting point 
fun=@(x)(x(1)-1)^2+100*(x(2)-x(1)^2)^2; % evaluate Rosenbrock function at x

tune=[];

st.prt=2; st.nfmax=5000; st.secmax=inf; st.ftarget=0; st.accf=1e-4;

% The following loop may be replaced by an arbitrarily complex 
% computing environment. 
% in place of this comment one may wish to save the history, 
% and/or check stopping tests 

[xbest,fbest,info] = VRDFON(fun,x,st,tune)



    