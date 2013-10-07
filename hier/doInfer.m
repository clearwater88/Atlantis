function [allParticles,probOn,probOnFinal,msgs,ratiosIm,avgLogLikeIm] = doInfer(testData,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize)

    % careful with new probMap distributions
    mapStr= ['sweep', ruleStruct.toString(ruleStruct), '_', probMapStruct.toString(probMapStruct), '_', ...
             'imSize-', int2str(imSize(1)), '-', int2str(imSize(2)), '_', ...
             cellParams.toString(cellParams)];
    if(exist([mapStr,'.mat'],'file'))
        display('loading probmap file');
        load(mapStr,'cellMapStruct');
    else
        % probMapCells: size of [ruleId,slot,loc] cell: each is an array.
        % These are the p(r|s) and p(g|r)
        [cellMapStruct] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize);
        save(mapStr,'cellMapStruct', '-v7.3');
    end

    % centre of poses, bounds, angles used, rotated templates, etc.
    posesStruct = getPoses(params,templateStruct,imSize);

    templateStr = templateStruct.toString(templateStruct);
    % precompute
    pxStr = ['pxInds_', 'imSize-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
             cellParams.toString(cellParams), '_', templateStr];
    
    likePxIdxCells = getLikePxIdxAll(cellParams,posesStruct,pxStr);
    
    [allParticles,probOn,probOnFinal,msgs,ratiosIm,avgLogLikeIm] = sampleParticlesBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct,imSize);

end

