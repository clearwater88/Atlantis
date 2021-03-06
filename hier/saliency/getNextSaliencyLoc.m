function [type,cellLocIdx,val,ratiosIm,logProbCellRatio,logProbOptions,logPsumGNoPoint,logPsumG] = ...
    getNextSaliencyLoc(data, ...
                       particles, ...
                       likesIm, ...
                       countsIm, ...
                       particleProbs, ...
                       dirtyRegion,nPosesCell,posesStruct,ratiosImOld,logLikeCellOld,likePxIdxCells,connChilds,connPars,cellParams,ruleStruct,cellMapStruct,params,templateStruct)
    
    ratiosIm = cell(numel(particleProbs),1);
    defaultLogLikeIm = zeros(numel(particleProbs),1);
    
    logProbCellRatio = cell(numel(particleProbs),1);
    logPsumGNoPoint = cell(numel(particleProbs),1);
    logPsumG = cell(numel(particleProbs),1);
    
    childMessages = cell(numel(particleProbs),1);
    nBricksOnSelfRoot = zeros(numel(particleProbs),1);
    nBricksOff =  zeros(numel(particleProbs),1);
    
    for (i=1:numel(particleProbs))

        defaultLogLikeIm(i) = sum(log(likesIm{i}(:)./countsIm{i}(:)));
        %ratio ONLY
        tic
        temp = evalNewLikeRatio(data,templateStruct,likesIm{i},countsIm{i},posesStruct,dirtyRegion,ratiosImOld{i},params);
        toc
        ratiosIm{i} = temp;
        
        logProbCellRatio{i} = getLogLikeCellRatio(ratiosIm{i},cellParams,likePxIdxCells,dirtyRegion,nPosesCell,logLikeCellOld{i});
        
        [logPsumGNoPoint{i},logPsumG{i}] = getTopDownMsgs(particles{i},cellParams,connChilds{i},ruleStruct,cellMapStruct);
        [childMessages{i}] = getBottomUpMsgs(particles{i},cellParams,connPars{i},ruleStruct,cellMapStruct,params);
        
        % only self-rooted bricks will care if they get a parent
        selfRoot = isSelfRooted(particles{i},connPars{i})==1;
        bricksOnSelfRoot = particles{i}(:,selfRoot);
        nBricksOnSelfRoot(i) = size(bricksOnSelfRoot,2);
        nBricksOff(i) = sum(~getOn(particles{i}));
    end

    [saliencyMaps,logProbOptions] = ...
        computeSaliencyMap(defaultLogLikeIm,logProbCellRatio,logPsumGNoPoint,logPsumG,childMessages,nBricksOnSelfRoot,nBricksOff,particleProbs,cellParams,params);
    
    nTry = 0;
    nTotLoc = 0;
    for (i=1:numel(saliencyMaps))
       nTotLoc = nTotLoc + numel(saliencyMaps{i}); 
    end
    
    particleUse = particles{1}; %just need one
    % #types x [value,idx]
    while(1)
        
        if (nTry >= nTotLoc)
            type = 0; cellLocIdx = 0; val = -inf;
            break;            
        end
        
        winners = zeros(numel(saliencyMaps),2);
        for (i=1:numel(saliencyMaps))
            [val,win] = max(saliencyMaps{i});
            winners(i,:) = [val,win];
        end
        [val,type] = max(winners(:,1));
        cellLocIdx = winners(type,2);
    
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