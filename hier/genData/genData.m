function [data,probPixel,mask] = genData(nExamples,imSize,noiseParam)
    genFolder = 'genDataEx/';
    [~,~] = mkdir(genFolder);

    saveStr= [genFolder,'ex%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2)), ...
               '_', '_noiseParam-', int2str(100*noiseParam)] ;
           
    params = initParams();
    params.downSampleFactor = 1;
    params.useContext = 1;
    params.alpha = 1;
    
    templateStruct = initTemplates();
    templateStruct.bg=noiseParam;
    
    templateStruct.app = setTemplateApp(templateStruct.sizes);
    templateStruct.app{end+1} = templateStruct.bg;
    cellParams = initPoseCellCentres(imSize,templateStruct.sizes);
    
    ruleStruct = initRules();
    
    probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);
    cellMapStruct = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize);
    posesStruct = getPoses(params,templateStruct,imSize);
    [rotTemplates,~] = getRotTemplates(params,templateStruct);
    
    templateStr = templateStruct.toString(templateStruct);
    pxStr = ['pxInds_', 'sz-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
        cellParams.toString(cellParams), '_', templateStr];
    likePxIdxCell = getLikePxIdxAll(cellParams,posesStruct,pxStr);
    coordInds = cellParams.coordsSize;
    
    nTypes = numel(unique(ruleStruct.parents));
    nBricksType = zeros(nTypes,1);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    maxSlots = size(ruleStruct.children,2);
    
    [gBkLookUp,refPoints] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct);
    conversions = getConversions(nTypes, cellParams);
    
    pGbkRbStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct);
    
    for (n=1:nExamples)
        display(sprintf('Generating example: %d', n));
        
        %bricks: on/off, type, cellCentreIndex,[poseX,Y,theta], rule
        particle = [];
        for(t=1:nTypes) % assume partial ordering goes 1:nTypes
            
            poses = posesStruct.poses{t};
            
            % choose self rooting.
            % *need to make sure don't self root already-existing child.*
            coords = cellParams.coords{t};
            selfRoot = rand(size(coords,1),1) < params.probRoot(t);
            if(t==1 && sum(selfRoot) == 0) % nothing here? create it
               idx = randi(numel(selfRoot));
               selfRoot(idx) = 1;
            end
            selfRootIdx = find(selfRoot == 1);
            if(~isempty(selfRootIdx))
                toAdd = zeros(7,numel(selfRootIdx),1);

                toAdd(1,:) = 1;
                toAdd(2,:) = t;
                toAdd(3,:) = selfRootIdx;
                particle = cat(2,particle,toAdd);
            end
            % choose rules
            ruleIdx = find(ruleStruct.parents==t);
            ruleProbs = ruleStruct.probs(ruleIdx);
            idx = find(particle(2,:)==t);
            
            for(k=1:numel(idx))
                
                % choose rule
                ruleUse = ruleIdx(find(mnrnd(1,ruleProbs)==1));
                
                particle(7,idx(k)) = ruleUse;
                
                % now choose pose
                centreIdx =  particle(3,idx(k));
                centre = cellParams.centres{t}(centreIdx,:);
                coord = cellParams.coords{t}(centreIdx,:);
                
                ids = likePxIdxCell{t}{centreIdx};
                posesChoose = poses(ids,:);
                id = randi(size(posesChoose,1),1);
                particle(4:6,idx(k)) = posesChoose(id,:);
                
                % use pose of cell for angle, not pose itself.
                [~,agInd] = min(abs(posesStruct.angles-centre(3)));
                
                % now choose children
                childrenTypes = ruleStruct.children(ruleUse,:);
                for (slot=1:numel(childrenTypes))
                    
                    cType = childrenTypes(slot);
                    if(cType == 0) continue; end;
                    toAdd = zeros(7,1);
                    toAdd(1) = 1;
                    toAdd(2) = cType;
                    
                    % need to choose child cell
                    probMapAll = pGbkRbStruct{ruleUse,slot}(:,agInd);
                    
                    shiftedIndsAll = shiftGbkInds(gBkLookUp{t,slot}, ...
                                                  squeeze(conversions(:,t,:)), ...
                                                  refPoints(:,t), ...
                                                  coord(1:2));
                    badInds = shiftedIndsAll(2,:) < 1 | shiftedIndsAll(2,:) > coordInds(cType,1) |...
                              shiftedIndsAll(3,:) < 1 | shiftedIndsAll(3,:) > coordInds(cType,2);
                    shiftedInds = shiftedIndsAll(:,~badInds);
                    probMap = probMapAll(~badInds);
                    probMap = probMap/sum(probMap); % renormalize
                    
                    childIdx = find(mnrnd(1,probMap)==1);
                    indUse = shiftedInds(2:end,childIdx);
                    toAdd(3) = sub2ind(coordInds(cType,:),indUse(1),indUse(2),indUse(3));
                    particle = cat(2,particle,toAdd);
                end
            end
            
            
        end
        particleUse{1} = particle;
        
        probPixel = viewAllParticles(particleUse,rotTemplates,params,imSize);
        mask = (probPixel > 0.001);
        cleanData = rand(imSize) < probPixel;
        bg = rand(imSize) < templateStruct.bg;
        data = cleanData.*mask + bg.*(1-mask);

        save(sprintf(saveStr,n), 'probPixel', 'mask', 'data', 'cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct', '-v7.3');
        
    end

end

