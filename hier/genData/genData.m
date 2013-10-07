function genData(nStart,nEnd,imSize)

    close all;

    genFolder = 'genDataEx/';
    [~,~] = mkdir(genFolder);

    saveStr= [genFolder,'exClean%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2))] ;
           
    params = initParams();
    params.downSampleFactor = 1;
    params.useContext = 1;
    params.alpha = 1;
    
    templateStruct = initTemplates();
    templateStruct.bg=0;
    
    templateStruct.app = setTemplateApp(templateStruct.sizes);
    templateStruct.app{end+1} = templateStruct.bg;
    cellParams = initPoseCellCentres(imSize,templateStruct.sizes);
    
    ruleStruct = initRules();
    
    probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);
    cellMapStruct = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize);
    posesStruct = getPoses(params,templateStruct,imSize);
    [rotTemplates,~] = getRotTemplates(params,templateStruct);
    
    templateStr = templateStruct.toString(templateStruct);

    pxStr = ['pxInds_', 'imSize-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
             cellParams.toString(cellParams), '_', templateStr];
    
    likePxIdxCell = getLikePxIdxAll(cellParams,posesStruct,pxStr);
    coordInds = cellParams.coordsSize;
    
    nTypes = numel(unique(ruleStruct.parents));
    nBricksType = zeros(nTypes,1);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    maxSlots = size(ruleStruct.children,2);
      
    conversions = getConversions(nTypes, cellParams);
    
    for (n=nStart:nEnd)
        display(sprintf('Generating example: %d', n));
        
        %bricks: on/off, type, cellCentreIndex,[poseX,Y,theta], rule
        particle = [];
        for(t=1:nTypes) % assume partial ordering goes 1:nTypes
            
            poses = posesStruct.poses{t};
            
            % choose self rooting.
            % *need to make sure don't self root already-existing child.*
            selfRoot = rand(size(cellParams.coords{t},1),1) < params.probRoot(t);
            if(t==1 && sum(selfRoot) == 0) % nothing here? create it
               %idx=8808; %straight up, angle=0
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
                
                % choose pose
                centreIdx =  particle(3,idx(k));
                centre = cellParams.centres{t}(centreIdx,:);
                coord = cellParams.coords{t}(centreIdx,:);
                
                ids = likePxIdxCell{t}{centreIdx};
                posesChoose = poses(ids,:);
                id = randi(size(posesChoose,1),1);
                particle(4:6,idx(k)) = posesChoose(id,:);
                
                % use pose of cell for angle, not pose itself.
                [~,agInd] = min(abs(posesStruct.angles-centre(3)));

                % choose rule
                ruleUse = ruleIdx(find(mnrnd(1,ruleProbs)==1));
                particle(7,idx(k)) = ruleUse;
                
                % now choose children
                childrenTypes = ruleStruct.children(ruleUse,:);
                for (slot=1:numel(childrenTypes))
                    
                    cType = childrenTypes(slot);
                    if(cType == 0) continue; end;
                    toAdd = zeros(7,1);
                    toAdd(1) = 1;
                    toAdd(2) = cType;
                    
                    % need to choose child cell
%                     probMapAll = pGbkRbStruct{ruleUse,slot}(:,agInd);
%                     
%                     shiftedIndsAll = shiftGbkInds(gBkLookUp{t,slot}, ...
%                                                   squeeze(conversions(:,t,:)), ...
%                                                   refPoints(:,t), ...
%                                                   coord(1:2));
                              


                                              
                                              
%                     badInds = shiftedIndsAll(2,:) < 1 | shiftedIndsAll(2,:) > coordInds(cType,1) |...
%                               shiftedIndsAll(3,:) < 1 | shiftedIndsAll(3,:) > coordInds(cType,2);
%                     shiftedInds = shiftedIndsAll(:,~badInds);
%                     probMap = probMapAll(~badInds);
%                     probMap = probMap/sum(probMap); % renormalize
                    
                    
                    locs = cellMapStruct.locs{ruleUse,slot,agInd};

                    %indUse = shiftedInds(2:end,childIdx);
                    
                    % need to convert to right reference frame now
                    convs=squeeze(conversions(:,t,:));
                    
                    temp = cat(1,cType*ones(1,size(locs,1)),locs');
                    shiftedIndsAll = shiftGbkInds(temp, ...
                                                  convs, ...
                                                  cellMapStruct.refPoints(:,ruleUse), ...
                                                  coord(1:2));

                     badInds = shiftedIndsAll(2,:) < 1 | shiftedIndsAll(2,:) > coordInds(cType,1) |...
                               shiftedIndsAll(3,:) < 1 | shiftedIndsAll(3,:) > coordInds(cType,2);
                     shiftedInds = shiftedIndsAll(:,~badInds);
                     
                     probMapAll = cellMapStruct.probMap{ruleUse,slot,agInd};
                     probMap = probMapAll(~badInds);
                     probMap = probMap/sum(probMap); % renormalize
                     childIdx = find(mnrnd(1,probMap)==1);
 
                     loc = shiftedInds(2:end,childIdx);
                    
                    
                    
                   
                    
                    toAdd(3) = sub2indNoCheck(coordInds(cType,:),loc(1),loc(2),loc(3));
                    particle = cat(2,particle,toAdd);
                end
            end
            
            
        end
        particleUse{1} = particle;
        
        probPixel = viewAllParticles(particleUse,rotTemplates,params,imSize);
        mask = (probPixel > 0.001);
        cleanData = rand(imSize) < probPixel;

        figure(1);
        subplot(1,3,1); imshow(cleanData);
        subplot(1,3,2); imshow(mask);
        subplot(1,3,3); imshow(probPixel);
        %pause;
        
        save(sprintf(saveStr,n), 'particle','probPixel', 'mask','cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct', 'cellParams','-v7.3');
       
        figure(2);
        sz(1) = ceil(sqrt(size(particle,2)));
        sz(2) = ceil(size(particle,2)/sz(1));
        for(i=1:size(particle,2))
           subplot(sz(1),sz(2),i);  imshow(viewAllParticles(toCell(particle(:,1:i)),rotTemplates,params,imSize));
        end
        
    end

end

