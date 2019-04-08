%
% Copyright (c) 2019 at github.com
% All rights reserved. Please read the "license.txt" for license terms.
%
% Developer : R.Gowri, Dr. R. Rathipriya
% Contact email - gowri.candy@gmail.com ,
% rathi_priyar@periyaruniversity.ac.in
% 
% thanks to yarpiz.com for its support

clc;
clear;
close all;

%% Problem Definition

data=LoadDataset();

nf=3;

CostFunction=@(u) FSCost(u,nf,data);        % Cost Function

nVar=data.nx;       % Number of Decision Variables

VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin=0;         % Lower Bound of Variables
VarMax=1;         % Upper Bound of Variables

%% VFO Parameters

MaxIt=20;       % Maximum Number of Iterations

nPop=20;        % Population Size (plant Size)
ka=0.3;         %accumulation rate
kc=0.1;         % charge dissipation rate
kb=0.5;         % Trap Best charge stagnation
t=0;
T=0.003;
% potential Limits
PotMax=0.1*(VarMax-VarMin);
PotMin=-PotMax;

%% Initialization

empty_flytrap.Potential=0.15;
empty_flytrap.Charge=0;
empty_flytrap.Status=0;
empty_flytrap.Cost=[];
empty_flytrap.Out=[];
empty_particle.Best=[];

empty_flytrap.Best.Potential=0.15;
empty_flytrap.Best.Charge=0;
empty_flytrap.Best.Status=0;
empty_flytrap.Best.Cost=[];
empty_flytrap.Best.Out=[];

flytrap=repmat(empty_flytrap,nPop,1);

BestSol.Cost=inf;

for i=1:nPop
    
    % Initialize Potential
    flytrap(i).Potential=zeros(VarSize);
    
    % Initialize Charge
    flytrap(i).Charge=unifrnd(VarMin,VarMax,VarSize);
    
    % Evaluation
    [flytrap(i).Cost, flytrap(i).Out]=CostFunction(flytrap(i).Charge);
    
    % Status
    flytrap(i).Status=0;   % initially open flytrap
    
    % Update Personal Best
    flytrap(i).Best.Charge=flytrap(i).Charge;
    flytrap(i).Best.Status=flytrap(i).Status;
    flytrap(i).Best.Cost=flytrap(i).Cost;  
    flytrap(i).Best.Out=flytrap(i).Out;
    
    % Update Global Best
    if flytrap(i).Best.Cost<BestSol.Cost    
        BestSol=flytrap(i).Best;
    end
    
end
BestCost=zeros(MaxIt,1);

%% VFO Main Loop
it=1;
while it<= MaxIt
    id=[];
    for i=1:nPop
       t=0;
       if flytrap(i).Status~=2 % unsealed flytrap  
            t=rand()*0.001;
            if t<=T 
                flytrap(i).Status =1; % flytrap closure

                % update Potential
                flytrap(i).Potential=rand(VarSize).*flytrap(i).Potential+0.15*exp(-2000*t);

                % Apply Potential Limits
                flytrap(i).Potential = max(flytrap(i).Potential,PotMin);
                flytrap(i).Potential = min(flytrap(i).Potential,PotMax);
               
                % update flytrap Charge
                flytrap(i).Charge=ka*flytrap(i).Potential+(1-kc)*flytrap(i).Charge+kb*flytrap(i).Best.Charge(end);

                % Potential Mirror Effect
                IsOutside=(flytrap(i).Charge<VarMin | flytrap(i).Charge>VarMax);
                flytrap(i).Potential(IsOutside)=-flytrap(i).Potential(IsOutside);

                % Apply Charge Limits
                flytrap(i).Charge = max(flytrap(i).Charge,VarMin);
                flytrap(i).Charge = min(flytrap(i).Charge,VarMax);

                % Evaluation
                [flytrap(i).Cost, flytrap(i).Out]=CostFunction(flytrap(i).Charge);
    
                % find current best and eval Object Status
                if flytrap(i).Status ==1 && flytrap(i).Cost<flytrap(i).Best.Cost
                    % sealing the current best
                    flytrap(i).Status=2;
                    
                    % update the flytrap best
                    flytrap(i).Best.Status=2;
                    flytrap(i).Best.Charge=flytrap(i).Charge;
                    flytrap(i).Best.Cost=flytrap(i).Cost;
                    flytrap(i).Best.Out=flytrap(i).Out;
                   
                    % Update Global Best
                    if flytrap(i).Best.Cost<BestSol.Cost
                        BestSol=flytrap(i).Best;
                    end
                    
                    if ~isempty(id)     %unsealing the sealed trap
                        flytrap(id).Status=1;
                        flytrap(id).Best.Status=1;
                    end
                    id=i;
                end
            end
        end       
    end
    it=it+1;
    % seal the best flytrapuntil another best flytrap arrives
     BestCost(it)=BestSol.Cost;
     disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
end
           
%% Results

figure;
plot(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');