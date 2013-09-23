function [data] = genData(nExamples)
    imSize = [20,100];
    noiseParam = 0.1;
    
    params = initParams();
    params.useContext = 1;
    params.alpha = 1;

    cellParams = initPoseCellCentres(imSize);
    templateStruct = initTemplates();
    templateStruct.bg=noiseParam;
    
    templateStruct.app = setTemplateApp(templateStruct.sizes);
    templateStruct.app{end+1} = templateStruct.bg;
    
    ruleStruct = initRules(params.useContext);
    
    probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);
    cellMapStruct = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize);
    posesStruct = getPoses(params,templateStruct,imSize);
    
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
    
    particles = []; % column: type, locIdx, ruleInd, poseX,poseY,poseAngle
    for (n=1:nExamples)
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
            
            toAdd = zeros(6,numel(selfRootIdx),1);
            toAdd(1,:) = t;
            toAdd(2,:) = selfRootIdx;
            particles = cat(2,particles,toAdd);
            
            % choose rules
            ruleIdx = find(ruleStruct.parents==t);
            ruleProbs = ruleStruct.probs(ruleIdx);
            idx = find(particles(1,:)==t);
            
            for(k=1:numel(idx))
                
                % choose rule
                ruleUse = ruleIdx(find(mnrnd(1,ruleProbs)==1));
                
                particles(3,idx(k)) = ruleUse;
                
                % now choose pose
                centreIdx =  particles(2,idx(k));
                centre = cellParams.centres{t}(centreIdx,:);
                coord = cellParams.coords{t}(centreIdx,:);
                
                ids = likePxIdxCell{t}{centreIdx};
                posesChoose = poses(ids,:);
                id = randi(size(posesChoose,1),1);
                particles(4:6,idx(k)) = posesChoose(id,:);
                
                % use psoe of cell for angle, not pose itself.
                [~,agInd] = min(abs(posesStruct.angles-centre(3)));
                
                % now choose children
                childrenTypes = ruleStruct.children(ruleUse,:);
                for (slot=1:numel(childrenTypes))
                    
                    cType = childrenTypes(slot);
                    if(cType == 0) continue; end;
                    toAdd = zeros(6,1);
                    toAdd(1) = cType;
                    
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
                    toAdd(2) = sub2ind(coordInds(cType,:),indUse(1),indUse(2),indUse(3));
                    particles = cat(2,particles,toAdd);
                end
            end
            
            
        end
    end

end

