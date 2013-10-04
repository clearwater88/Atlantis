function [probMapStruct] = initProbMaps(ruleStruct,templateSizes)
    % simple initialization for line model

    parents = ruleStruct.parents;
    offset = cell(numel(parents),1);
    vonM = zeros(numel(parents),1);
    covCentres = cell(numel(parents),1); % covariances for each slot

    covCentresParents(:,:,1) = [0.2^2,0; ...
                                0,0.2^2];
    covCentresParents(:,:,2) = [0.2^2,0; ...
                                0,0.2^2];
    covCentresParents(:,:,3) = [0.2^2,0; ...
                                0,0.2^2];
    covCentresParents(:,:,4) = [0.2^2,0; ...
                                0,0.2^2];
                            
    vonMisesConcParents = [100,100,100,100];
    
    for (i=1:size(parents,1))
        tp = templateSizes(parents(i),:);
        ch = ruleStruct.children(i,:);
        
        validChildren = ch(ch~=0);
        
        totCh = numel(validChildren);
        for (j=1:totCh)
            % split up probMap top to bottom, use middle for width
            
            % x,y,angle
            centre=(tp+1)/2;
            
            offset{i}(j,1) = 2*(round(j*(1+tp(1))/(1+totCh))-(1+tp(1))/2); % offset along length of template
            offset{i}(j,2) = 0;
            offset{i}(j,3) = 0;
            
            covCentres{i}(:,:,j) = covCentresParents(:,:,parents(i));
            vonM(i) = vonMisesConcParents(parents(i));
        end
    end

    probMapStruct.strat = 1; %0 no line contig; 1 = line contig
    probMapStruct.offset=offset;
    probMapStruct.cov=covCentres;
    probMapStruct.vonM = vonM;
    probMapStruct.toString = @toString;
end

function [ res ] = toString(probMapStruct)

    res = ['probMap-cov'];
    for (i=1:numel(probMapStruct.cov))
        if(~isempty(probMapStruct.cov{i}))
            xCov =  probMapStruct.cov{i}(1,1);
            yCov =  probMapStruct.cov{i}(2,2);
            res = [res, int2str(100*xCov),'x',int2str(100*yCov)];
            if (i~= numel(probMapStruct.cov))
                res = [res,'_'];
            end
        end
    end
end

