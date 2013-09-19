function [templateStruct,probMapStruct,ruleStruct] = doLearning(trainInds,params,ruleStruct,templateStruct,probMapStruct)
        
        allParticles = cell(numel(trainInds),1);
        probOn = cell(numel(trainInds),1);
        msgs = cell(numel(trainInds),1);
            
        % learning
        % templates separate for now
        if(templateStruct.doLearning == 1)
            templateStruct = learnTemplates(trainInds,params,templateStruct);
        end
        
        for (it=1:params.emIters)
            for (i=1:numel(trainInds))                
                [~,trainData] = readData(params,templateStruct.app{end},trainInds(i));
                
                imSize = size(trainData);
                cellParams = initPoseCellCentres(imSize);
                
                [allParticles{i},probOn{i},msgs{i}] = doInfer(trainData,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize);
                
            end
            
            % update here
            
            % rule probs
            ruleProbs = getNewRuleProbs(ruleStruct,msgs,probOn);
            ruleStruct.probs = ruleProbs;
            ruleStruct.probHist(:,end+1) = ruleProbs;
            
        end
end


