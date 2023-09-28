function [figA, avAcc] = derivationAndComputationTest(simNumber, ...
    derivationsPaperSettings, varargin)

% INPUT
% simNumber: The number of the model to simulate.
% derivationsPaperSettings: bool. If true makes plots from the manuscript.
% varargin{1}: boolean. True for short simulations for debugging

% OUTPUT
% avAcc: Average accuracy in the stimulated dataset, not in the dataset
% contrsucted using the predictions of the likeihood function

if ~isempty(varargin)
    debugMode = varargin{1};
else
    debugMode = false;
end

%% Simulate data
UserSettings = struct('NumPtpnts', 40, 'TotalTrials', 640*20);

if debugMode
    UserSettings = struct('NumPtpnts', 4, 'TotalTrials', 640);
end

allModels = produceDefaultModelLists('key');
SimulationConfigs = generateSimConfigs(allModels, UserSettings);
SimulationConfig = SimulationConfigs(simNumber); 
if derivationsPaperSettings
    SimulationConfig.ConfLapseRate = 0;
    SimulationConfig.CommitDelaySD = 0;
    SimulationConfig.DeltaT = 0.0001;
else
    SimulationConfig.ConfLapseRate = 1;
    SimulationConfig.CommitDelaySD = 0;
    SimulationConfig.DeltaT = 0.0001;
    SimulationConfig.ConfNoiseSd = 0;
end
    
DSet = simulateDataSet(SimulationConfig);
DSet.SimSpec = SimulationConfig;
avAcc = findAverageAccuracy(DSet);


%% Predict confidence using the true parameter values

findIncludedTrials = @(Data) ~isnan(Data.Conf);
DSet.FitSpec.NumBins = 10;
PredDSet = DSet;
[DSet, ~] = prepDataForComputationalModelling(DSet, 'together');

for iP = 1 : length(DSet.P)
    
    % We first need to know the confidence bin edges that would be used in 
    % the modelling
    TmpDSet = PredDSet;
    TmpDSet.P = PredDSet.P(iP);
    [TmpDSet, binEdges] = prepDataForComputationalModelling(TmpDSet, ...
        'together');
    PredDSet.P(iP) = TmpDSet.P;
    
    % We don't want the first and last bin edges, which correspond to the min
    % and max responses
    assert(length(binEdges) == 1)
    binEdges = binEdges{1};
    binEdges(1) = [];
    binEdges(end) = [];
    
    % Convert to the paramter structure for the modelling code
    ParamStruct = switchParamCoding([], [], DSet.SimSpec, 'modelling');
    ParamStruct.Thresholds = binEdges';
    
    % Check can convert it to setting for simulation and back without changing
    % the structure. i.e. check of the switchParamCoding code
    SpecA = ParamStruct;
    TmpSpec = switchParamCoding(SimulationConfig.Name, DSet.P(iP).Data, ...
        SpecA, 'simulation');
    SpecB = switchParamCoding([], [], TmpSpec, 'modelling');
    SpecA = rmfield(SpecA, 'Thresholds');
    if ~isequaln(SpecA, SpecB); error('bug'); end
    
    % Simulate
    [SimConf, estEvQual] = simulateConfFromRt(SimulationConfig.Name, ...
        findIncludedTrials, ParamStruct, DSet.P(iP).Data, DSet.Spec);
    
    PredDSet.P(iP).Data.ConfCat = SimConf;
    PredDSet.P(iP).Data.EvidenceQual = estEvQual;
end


%% Plot both
figA = figure;
figA = plotConfAgainstTimeAndEv(DSet, 'scatter', figA, ...
    'binned', true, false, 'D');
figA = plotConfAgainstTimeAndEv(PredDSet, 'errorShading', figA, ...
    'binned', true, false, 'D');



