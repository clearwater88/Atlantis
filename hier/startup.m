RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', 100*sum(clock)))

addpath(genpath('inits'));
addpath(genpath('visualize'));
addpath(genpath('utils'));
addpath(genpath('localizer'));
addpath(genpath('likelihood'));
addpath(genpath('samplers'));
addpath(genpath('brickGetters'));
addpath(genpath('readData'));
addpath(genpath('saliency'));
addpath(genpath('learn'));
addpath(genpath('bpmatlab'));
addpath(genpath('learning'));
addpath(genpath('genData'));
addpath(genpath('m2html'));

javaaddpath(fullfile('.','bp.jar'));