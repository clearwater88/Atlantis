function [probMapStruct] = initProbMaps(ruleStruct,templates)
    % simple initialization for line model

    parents = ruleStruct.parents;
    offset = cell(numel(parents),1);
    vonM = cell(numel(parents),1);
    covCentres = cell(numel(parents),1); % covariances for each slot

    covCentresParents(:,:,1) = [4^2,0; ...
                                0,4^2];
    covCentresParents(:,:,2) = [4^2,0; ...
                                0,4^2];
    covCentresParents(:,:,3) = [4^2,0; ...
                                0,4^2];
    
    vonMisesConcParents = [0.5,0.5,0.5];
    
    for (i=1:size(parents,1))
        tp = templates{parents(i)};
        ch = ruleStruct.children(i,:);
        
        validChildren = ch(ch~=0);
        
        totCh = numel(validChildren);
        for (j=1:totCh)
            % split up probMap top to bottom, use middle for width
            
            % x,y,angle
            offset{i}(j,1) = round(j*(1+size(tp,1))/(1+totCh))-(1+size(tp,1))/2; % offset along length of template
            offset{i}(j,2) = 0;
            offset{i}(j,3) = 0;
            
            covCentres{i}(:,:,j) = covCentresParents(:,:,parents(i));
            vonM{i} = vonMisesConcParents(parents(i));
        end
    end

    probMapStruct.strat = 1; %0 no line contig; 1 = line contig
    probMapStruct.offset=offset;
    probMapStruct.cov=covCentres;
    probMapStruct.vonM = vonM;
    probMapStruct.toString = @toString;
end

function [ res ] = toString(probMapStruct)
    res = ['probMap-','strat', int2str(probMapStruct.strat)];
end

