RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', 100*sum(clock)))

addpath(genpath('inits'));
addpath(genpath('visualize'));
addpath(genpath('utils'));
addpath(genpath('localizer'));
addpath(genpath('likelihood'));