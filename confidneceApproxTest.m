function [fig, avAcc, DSet] = confidneceApproxTest(simNumber, varargin)

% INPUT
% simNumber: The number of the model to simulate
% varargin: boolean. True for a short simulation for debugging

% NOTES 
% A lapse rate of zero is currently just assumed by this script for use in
% simulateConfFromRt


%% Simulate data
UserSettings = struct('NumPtpnts', 40, 'TotalTrials', 640*20);

if ~isempty(varargin) && varargin{1}
    UserSettings = struct('NumPtpnts', 4, 'TotalTrials', 640);
end

allModels = produceDefaultModelLists('key');
SimulationConfigs = generateSimConfigs(allModels, UserSettings);
SimulationConfig = SimulationConfigs(simNumber); %3
SimulationConfig.ConfCalc = 'pCorrect';

SimulationConfig.DeltaT = 0.0001;
SimulationConfig.ConfNoiseSd = 0; % To make any discrepancies clearer
SimulationConfig.ConfLapseRate = 0;


DSet = simulateDataSet(SimulationConfig);

DSet.SimSpec = SimulationConfig;

fig = plotAccWithConf(DSet, 'line', 'raw', true);
avAcc = findAverageAccuracy(DSet);



