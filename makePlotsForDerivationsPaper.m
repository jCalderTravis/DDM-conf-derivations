function pipeSimResults = makePlotsForDerivationsPaper(saveDir, varargin)
% Makes the plots for the paper. Must be run from the folder in which 
% this file is located because function adds relative directories to the 
% Matlab path.

% INPUT
% saveDir: str. Directory in which to save the results
% varargin{1}: boolean. True for short simulations for debugging

% OUTPUT
% pipeSimResults: Some detailed results from the function exploring the
% effect of pipeline time

paths = {'./mat-comp-model-tools', ...
    './simDecisionAndConf', ...
    './DDM-conf-tools-shadow'};
for thisPath = paths
    addpath(thisPath{1})
end

set(groot,'defaultAxesTickLabelInterpreter', 'latex');
set(groot,'defaulttextinterpreter', 'latex');
set(groot,'defaultLegendInterpreter', 'latex');

if ~isempty(varargin)
    debugMode = varargin{1};
else
    debugMode = false;
end


%% Plots for model illustration
modelIllustrations

%% Does confidence still approximate accuracy after approx.

fig1 = figure;

model = [1, 5];  %'NDscFlatNoneSameMvar' and 'TrDsFlatDvarSameMvar'
titles = {'{\bf No variability in $\varphi$}', ...
    '{\bf Variability in $\varphi$}'};

allAcc = cell(2, 1);
for iPlot = [1, 2]
    [tmpFig, allAcc{iPlot}, ~] = confidneceApproxTest(model(iPlot), debugMode);
    title(titles{iPlot})
    
    mT_exportNicePdf(14*(4/8), 15.9, saveDir, ...
        ['confidenceToAcc_tmpFig_' num2str(iPlot)])
    
    figAx = findobj('Parent', tmpFig, 'Type', 'axes');
    figAx = figAx(1);
    
    % Copy to master figure
    figure(fig1)
    subPlt = subplot(1, 2, iPlot);
    
    axNew = copyobj(figAx, fig1);
    set(axNew, 'Position', get(subPlt,'position'));
    delete(subPlt);
    
    close(tmpFig)
end

mT_exportNicePdf(14*(4/8), 15.9, saveDir, 'confidenceToAcc')
save([saveDir '/confidenceToAcc_avAcc'], 'allAcc')


%% Does predicted confidence match real confidence?

allAcc = cell(10, 1);
for i = 1 : 10
    [~, allAcc{i}] = derivationAndComputationTest(i, true, debugMode);
    
    allModels = produceDefaultModelLists('key');
    modelName = allModels{i};
    
    mT_exportNicePdf(13*(4/5), 13.9*(4/5), saveDir, ['modelTest_' modelName])
    
end
save([saveDir '/' 'derivAndCompTest' '_avAcc'], 'allAcc')


%% New explaination for relationship between signal strength and confidence

[avAcc, pipeSimResults] = explorePipelineTimeEffect(debugMode);

% Run t-tests on the correlation values produced accross participants
resultsTable = mT_analyseParams(pipeSimResults.Correlations, ...
    {'Immediate conf.', 'Delayed conf.'}');
mT_produceStatsLatexSnippet(resultsTable);

mT_exportNicePdf(14/2, 15.9/2, saveDir, 'signalStrenghtAndCofnidence')
save([saveDir '/' 'signalStrenghtAndCofnidence' '_avAcc'], 'avAcc')
save([saveDir '/' 'signalStrenghtAndCofnidence' '_pipeSimResults'], ...
    'pipeSimResults')


