

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% driverVRDFON.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:3
    for j=1:100
        fprintf('=')
    end
    fprintf('\n')
end

fprintf(['VRDFON solves a unconstrained noisy black box',...
    ' optimization of a not necessarily smooth function of \n',...
    ' many continuous arguments. No derivatives are needed.',...
    ' A limited amount of noise is tolerated.\n\n']);
disp('===============================================================')

clear;


solverPath = input(['Insert the VRDFON path \n',...
    '>> solverPath='],'s');


if ~exist(solverPath, 'dir')
    disp('the directory does not exist')
    return
end

eval(['addpath ',solverPath,'/minq8'])


disp('===============================================================')


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create noise

fprintf(['noise.level: 0.0001/0.01/0.1 \n',...
         'noise.type:  1 (absolute) or  2 (relative)\n',...
         'noise.distr: 1 (uniform)  or  2 (Gauss)\n'])
  
noise = struct('noisefun',1,'level',0.0001,'type',1,'distr',1)

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create problem definition


% define problem parameters (to be adapted to your problem)
n=10; % dimension
p=2;  % Norm in objective function
e=1;  % Exponent in objective function function

% create random matrix and right hand side for objective function
% (specific to the model problem; replace by whatever data you
% need to provide to your objectiv function)
A=rand(n)-0.5; 
b=-sum(A,2);

% create objective function f(x)=||Ax-b||_p^e
fun0  = @(x) norm(A*x-b,p).^e; 
fun  = @(x) funf(x,fun0,noise);  

% To solve your own problem, simply replace in the previous line 
% the expression after @(x) by your expression or function call. 
% Parameters in this expression are passed by value, hence are 
% fixed during minimization.

% start and stop info
x      = 2*rand(n,1);  % starting point

% problem definition complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('===============================================================')


fullinfo=1;  

Tuning=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve the problem with VRDFON

tic; % set clock


if fullinfo    % define stop and print criteria
               % (indefinite run if no stopping criterion is given)
    % pass stop and print criteria
    % (indefinite run if no stopping criterion is given)
    st = struct('secmax',180,'nfmax',500*n,'finit',fun(x),...
         'fbest',0.001*fun(x),'accf',0.0001,'prt',2,'reallife','0')
else
    st = []; % budgets are chosen inside VRDFON
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  solve the problem with VRDFON
if Tuning % self-tuning and info
    % given are the defaults
    % only the deviating parameters need to be set!
     fprintf([...
        '====================================================\n',...
        'maximum number of calls to MLS in DS: ',...
        'tune.T0 = n \n',...
        '====================================================\n',...
        'number of random direction in MLS: ',...
        'tune.R = n \n',...
        '====================================================\n',...
        'maximal number of extrapolation step: ',...
        'tune.E= Inf \n',...
        '====================================================\n',...
        'minimum threshold for stopping test: ',...
        'tune.deltamin = 0 \n',...
        '====================================================\n',...
        'initial step size: tune.deltamax = 1  \n',...
        '====================================================\n',...
        'factor for adjusting forcing function: ',...
        'tune.gamma = 1e-6 \n',...
        '====================================================\n',...
        'factor for extrapolation test: tune.gammaE = 3 \n',...
        '====================================================\n',...
        'factor for adjusting X: tune.gammaX = 100 \n',...
        '====================================================\n',...
        'tiny factor for construction of a interval: ',...
        'tune.gammaa = 1e-5 \n',...
        '====================================================\n',...
        'factor for adjusting the random direction: ',...
        'tune.gammar = 1e-30',...
        '====================================================\n',...
        'factors for updating the trust region radius: ',...
        'tune.gammad1 = 0.1, tune.gammad2 = 2 \n',...
        '====================================================\n',...
        'factor for adjusting sc and y: ',...
        'tune.gammav = 100 \n',...
        '====================================================\n',...
        'minimum threshod for extrapolation step size in MLS: ',...
        'tune.alpmin = 1e-3*rand \n',...
        '====================================================\n',...
        'factor for adjusting delta: ',...
        'tune.Q = 1.5 \n',...
        '====================================================\n',...
        'minimum value for the trust region radius: ',...
        'tune.dmin = 1e-4\n',...
        '====================================================\n',...
        'maximum value for the trust region radius: ',...
        'tune.dmax = 1e+3\n',...
        '====================================================\n',...
        'lower bound for initial interval: ',...
        'tune.alow = 1e-2\n',...
        '====================================================\n',...
        'upper bound for initial interval: ',...
        'tune.aupp = 0.99\n',...
        '====================================================\n',...
        'factor for adjusting the trust region direction: ',...
        'tune.gammap = 0.25\n',...
        '====================================================\n',...
        'minimum threshild for stopping minq8: ',...
        'tune.minqeps = 1e-8\n',...
        '====================================================\n',...
        'maxiumu number of iterations in minq8: ',...
        'tune.minqmax = 10000\n',...
        '====================================================\n',...
        'complexity bound verified? ',...
        'tune.comBound = 2',...
        '====================================================\n',...
        'parameter for perturbed random direction: ',...
        'tune.gammak = 0.85',...
        '====================================================\n',...
        'linear or quadratic model: tune.model = 1 \n']);     
    

    
     
        tune = struct('comBound',2,'T0',n,'R',n,'E',inf,...
            'model',1,'deltamax',1,'gamma',1e-6,'gammaE',3,...
            'gammaX',100,'gammaa',1e-5,'gammar',1e-30,...
            'gammad1',0.1,'gammad2',2,'gammav',100,...
            'alpmin',1e-3*rand,'dmin',1e-4,'dmax',1e3,...
            'alow',1e-2,'aupp',0.99,'gammap',0.25,'gammak',0.85,...
            'deltamin',0,'minqeps',1e-8,'minqmax',10000);
else
   tune = []; % full tuning inside VRDFON is used
end

  
[x,f,info] = VRDFON(fun,x,st,tune);

% the problem solved possibly by VRDFON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' '), disp(' '), disp(' '), disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
% display output
if ~isempty(info.error),
   error = info.error
else
    
if info.prt>=-1
disp('==============================================================');
disp('VRDFON completed silently');
disp('==============================================================');
disp('display output:');

format long
info               % progress report by VRDFON
disp('------------------------------------------------------------');
nfused=info.nf;               % number of function evaluations used
disp(['the number of function evaluations used: ',num2str(nfused)])
disp('------------------------------------------------------------');
secused=cputime-info.initTime;   % time used up to now
disp(['time used up to now: ',num2str(secused)])
disp('-------------------------------------------------------------');
if noise.noisefun
  ftrue = info.ftrue;
  disp(['the noisy function value at xbest (f): ',num2str(f)])
else
  disp(['the function value at xbest (f): ',num2str(f)])
end
disp('-------------------------------------------------------------');
qf = info.qf;
disp(['qf:=(ftrue-fbest)/(finit-fbest): ',num2str(qf)])
disp('-------------------------------------------------------------');
disp(['the number of quadratic models used: ',...
    num2str(info.nquadmodel)])
disp('-------------------------------------------------------------');
disp(['the total number of linear models used: ',...
      num2str(info.nlinearmodel)])
disp('-------------------------------------------------------------');
disp(['the total number of models used: ',num2str(info.model)])
end

end

for i=1:3
    for j=1:100
        fprintf('=')
    end
    fprintf('\n')
end
