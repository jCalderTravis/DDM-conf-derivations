function [avAcc, detailedResults] = explorePipelineTimeEffect(varargin)

% INPUT
% varargin{1}: boolean. True for short simulations for debugging

% OUTPUT
% detailedResults: Extra details on the plots including correlations
% between some variables

if ~isempty(varargin)
    debugMode = varargin{1};
else
    debugMode = false;
end


%% Look at the qualitative patterns when do/don't have pipeline

if debugMode
    UserSettings = struct('NumPtpnts', 4, 'TotalTrials', 640);
else
    UserSettings = struct('NumPtpnts', 40, 'TotalTrials', 640*100);
end

allModels = produceDefaultModelLists('key');
SimulationConfigs = generateSimConfigs(allModels, UserSettings);
SimulationConfig = SimulationConfigs(5);

SimulationConfig.DriftSD = 0.6;
SimulationConfig.OverallCommitDelay = 0.1;

% Change block settings. All free response.
SimulationConfig.BlockSettings(2) = SimulationConfig.BlockSettings(1);

SimulationConfig.ThreshIntercept = [2000, 2000];
SimulationConfig.ThreshSlope = [0, 0];

SimulationConfig.Threshold = @(simTime, blockType) ...
    threshold_linear(simTime, blockType, ...
    SimulationConfig.ThreshIntercept, ...
    SimulationConfig.ThreshSlope);

% In first block type, confidence report will be simultaneous with decision. 
SimulationConfig.BlockSettings(1).ConfAccumulationTime = 0;
SimulationConfig.ConfCalc = 'TrDs_nonAccumTime';

% Simulate data
DSet = simulateDataSet(SimulationConfig);

% Produce variables need for plotting
DSet.FitSpec.NumBins = 10;
DSet = prepDataForComputationalModelling(DSet, 'together');

% Add signal strength to data
for iP = 1 : length(DSet.P)
    DSet.P(iP).Data.SigStrength = DSet.P(iP).SimHist.EvidenceQual;
end


%% Plot simulated data

XVars(1).ProduceVar = @(Data) Data.SigStrength;
XVars(1).NumBins = 5;

YVars(1).ProduceVar = @(Data, incTrials) mean(Data.ConfCat(incTrials));
YVars(1).ProduceTrialByTrialVar = @(Data) Data.ConfCat;
YVars(1).FindIncludedTrials = @(Data, incTrials) ~isnan(Data.Conf);

Series(1).FindIncludedTrials = @(Data) (Data.BlockType == 1) & (Data.Acc == 0);
Series(2).FindIncludedTrials = @(Data) (Data.BlockType == 2) & (Data.Acc == 0);

PlotStyle.General = 'paper';

PlotStyle.Xaxis(1).Title = 'Signal strength (arb. units)';
PlotStyle.Xaxis(1).Ticks = [0, 0.5, 1, 1.5, 2];
PlotStyle.Xaxis(1).InvisibleTickLablels = [2, 4];
PlotStyle.Xaxis(1).Lims = [-0.2, 2.2];

PlotStyle.Yaxis(1).Title = {'Binned conf. in errors'};
PlotStyle.Yaxis(1).Ticks = linspace(5, 5.5, 5);
PlotStyle.Yaxis(1).InvisibleTickLablels = [2, 4];

PlotStyle.Data(1).Name = 'Immediate conf.';
PlotStyle.Data(1).Colour = mT_pickColour(5);

PlotStyle.Data(2).Name = 'Delayed conf.';
PlotStyle.Data(2).Colour = mT_pickColour(7);

PlotStyle.Data(1).PlotType = 'scatter';
PlotStyle.Data(2).PlotType = 'scatter';
[figHandle, detailedResults] = mT_plotVariableRelations(DSet, XVars, ...
    YVars, Series, PlotStyle);

PlotStyle.Data(1).PlotType = 'line';
PlotStyle.Data(2).PlotType = 'line';
figHandle = mT_plotVariableRelations(DSet, XVars, YVars, Series, ...
    PlotStyle, figHandle);

avAcc = findAverageAccuracy(DSet);


