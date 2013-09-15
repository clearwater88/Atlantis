function [trainInds, testInds] = splitData(nData,nTrainPerc,nTestPerc,trainMask)
    % trainMask must be nData x 1. 1 where it is OK to train on, 0 otherwise
    if(~exist('nTrainPerc','var'))
        nTrainPerc = 0.5;
    end
    if(~exist('nTestPerc','var'))
        nTestPerc = 0.5;
    end
    if(~exist('trainMask', 'var'))
        trainMask = ones(nData,1);
    end
    
    assert(nData == numel(trainMask));

    assert(nTrainPerc+nTestPerc <= 1.000001);
    inds = randperm(nData);

    nTrain = floor(nData*nTrainPerc);
    nTest = floor(nData*nTestPerc);
    testInds = inds(nTrain+1:nTrain+nTest);
    
    trainInds = inds(1:nTrain);
    trainMaskInds = trainMask(trainInds);
    trainInds(trainMaskInds==0) = [];
end

