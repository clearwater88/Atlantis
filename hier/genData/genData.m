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

    ruleStruct = initRules(params.useContext);
    
    probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);
    cellMapStruct = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize);
    posesStruct = getPoses(params,templateStruct,imSize);

    nTypes = numel(unique(ruleStruct.parents));
    nBricksType = zeros(nTypes,1);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    maxSlots = size(ruleStruct.children,2);
    
    [gBkLookUp,refPoints] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct);
    conversions = getConversions(nTypes, cellParams);
    
    pGbkRbStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct);
    
    particles = []; % column: type, locIdx, ruleInd, pose
    for (n=1:nExamples)
        for(t=1:nTypes) % assume partial ordering goes 1:nTypes
            
            % choose self rooting
            coords = cellParams.coords{t};
            selfRoot = rand(size(coords,1),1) < params.probRoot(t);
            if(t==1 && sum(selfRoot) == 0) % nothing here? create it
               idx = randi(numel(selfRoot));
               selfRoot(idx) = 1;
            end
            selfRootIdx = find(selfRoot == 1);
            
            toAdd = zeros(5,numel(selfRootIdx,1));
            toAdd(1,:) = t;
            toAdd(2,:) = selfRootIdx;
            particles = cat(2,particles,toAdd);
            
            % choose rules
            ruleIdx = find(ruleStruct.parents==t);
            ruleProbs = ruleStruct.probs(ruleIdx);
            idx = find(particles(1,:)==t);
            
            for(k=1:numel(idx))
                ruleUse = find(mnrnd(1,ruleProbs)==1);
                particles(3,idx) = ruleIdx(ruleUse);
                
                % now choose pose
                
                % now choose children
            end
            
            
        end
    end

end

