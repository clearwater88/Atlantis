function [templateStruct,probMapStruct] = doLearning(trainInds,params,ruleStruct,templateStruct,probMapStruct)
        
        allParticles = cell(numel(trainInds),1);
        probOn = cell(numel(trainInds),1);
        msgs = cell(numel(trainInds),1);
            
        % learning
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
            newRuleProbs = getNewRuleProbs(ruleStruct,msgs,probOn);
            
        end
end


