function [allParticles,probOn,probOnFinal,msgs] = doInfer(testData,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize)

    % careful with new probMap distributions
    mapStr= ['sweep0', ruleStruct.toString(ruleStruct), '_', probMapStruct.toString(probMapStruct), '_', ...
             'sz-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
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
    pxStr = ['pxInds_', 'sz-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
        cellParams.toString(cellParams), '_', templateStr];
    if(exist([pxStr,'.mat'],'file'))
        display('loading pxIdxCell file');
        load(pxStr,'likePxIdxCells');
    else
        tic
        display('Starting likePxIdxCells computation');
        likePxIdxCells = cell(cellParams.nTypes,1);
        for (n=1:cellParams.nTypes)
            likePxIdxCells{n}= getLikePxIdxAll(cellParams.centres{n}, ...
                cellParams.dims(n,:), ...
                posesStruct.poses{n});
        end
        display('Done likePxIdxCells computation');
        save(pxStr,'likePxIdxCells', '-v7.3');
        toc
    end
    [allParticles,probOn,probOnFinal,msgs] = sampleParticlesBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct,imSize);

end

