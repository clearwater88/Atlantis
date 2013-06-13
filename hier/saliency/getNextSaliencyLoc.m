function [type,cellLocIdx,val,ratiosIm,logProbCellRatio,logProbOptions,logPsumGNoPoint,logPsumG,stop] = getNextSaliencyLoc(particles,likesIm,countsIm,particleProbs,dirtyRegion,likePxStruct,ratiosImOld,logLikeCellOld,likePxIdxCells,connChilds,connPars,cellParams,ruleStruct,probMapCells,params)
    
    BOUNDARY = -10000;
    
    ratiosIm = cell(numel(particleProbs),1);
    defaultLogLikeIm = zeros(numel(particleProbs),1);
    
    logProbCellRatio = cell(numel(particleProbs),1);
    logPsumGNoPoint = cell(numel(particleProbs),1);
    logPsumG = cell(numel(particleProbs),1);
    
    childMessages = cell(numel(particleProbs),1);
    nBricksOnSelfRoot = zeros(numel(particleProbs),1);
    
    for (i=1:numel(particleProbs))

        defaultLogLikeIm(i) = sum(log(likesIm{i}(:)./countsIm{i}(:)));
        %ratio ONLY
        temp = evalNewLikeRatio(likesIm{i},countsIm{i},likePxStruct,dirtyRegion,ratiosImOld{i});
        ratiosIm{i} = temp;
        
        temp = getLogLikeCellRatio(ratiosIm{i},cellParams,likePxIdxCells,dirtyRegion,logLikeCellOld{i});
        logProbCellRatio{i} = temp;
        
        [logPsumGNoPoint{i},logPsumG{i}] = getTopDownMsgs(particles{i},cellParams,connChilds{i},ruleStruct,probMapCells);
        %[childMessages{i}] = getBottomUpMsgs(particles{i},cellParams,connPars{i},ruleStruct,probMapCells,params);
        [childMessages{i}] = getBottomUpMsgs2(particles{i},cellParams,connPars{i},ruleStruct,probMapCells,params);
        
        % only self-rooted bricks will care if they get a parent
        selfRoot = isSelfRooted(particles{i},connPars{i})==1;
        bricksOnSelfRoot = particles{i}(:,selfRoot);
        nBricksOnSelfRoot(i) = size(bricksOnSelfRoot,2);
        
    end

    [saliencyMaps,logProbOptions] = computeSaliencyMap(defaultLogLikeIm,logProbCellRatio,logPsumGNoPoint,logPsumG,childMessages,nBricksOnSelfRoot,particleProbs,cellParams,params);
    
    nTry = 0;
    nTotLoc = 0;
    for (i=1:numel(saliencyMaps))
       nTotLoc = nTotLoc + numel(saliencyMaps{i}); 
    end
    
    particleUse = particles{1}; %just need one
    % #types x [value,idx]
    while(1)
        
        if (nTry >= nTotLoc)
            type = 0; cellLocIdx = 0; val = -inf; stop = 1;
            break;            
        end
        
        winners = zeros(numel(saliencyMaps),2);
        for (i=1:numel(saliencyMaps))
            [val,win] = max(saliencyMaps{i});
            winners(i,:) = [val,win];
        end
        [val,type] = max(winners(:,1));
        cellLocIdx = winners(type,2);
    
        if(val < BOUNDARY)
            stop = 1;
        else
            stop = 0;
        end
        if (any((getType(particleUse) == type) & (getLocIdx(particleUse) == cellLocIdx)))
            saliencyMaps{type}(cellLocIdx) = -Inf;
            display(['Ignoring already-found salient brick']);
            nTry = nTry + 1;
        else
            break;
        end
    end
    display(['Saliency score: ', num2str(val)]);
    assert(val > -1000000000);
end