function [probMapStruct] = initProbMaps(ruleStruct,templates)
    % simple initialization for line model

    parents = ruleStruct.parents;
    offset = cell(numel(parents),1);
    vonM = cell(numel(parents),1);
    covCentres = cell(numel(parents),1); % covariances for each slot

    covCentresParents(:,:,1) = [5^2,0; ...
                                0,5^2];
    covCentresParents(:,:,2) = covCentresParents(:,:,1);
    covCentresParents(:,:,3) = covCentresParents(:,:,1);
    covCentresParents(:,:,4) = covCentresParents(:,:,1);
    
    vonMisesConcParents = [1,1,1,1];
    
    
%     covCentresParents(:,:,2) = [2,0,0; ...
%                                 0,1,0; ...
%                                 0,0,pi/16];
%     
%     covCentresParents(:,:,3) = [2,0,0; ...
%                                 0,2,0; ...
%                                 0,0,pi/16];
    
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
    
    probMapStruct.version=2;
    probMapStruct.strat = 1; %0 no line contig; 1 = line contig
    probMapStruct.offset=offset;
    probMapStruct.cov=covCentres;
    probMapStruct.vonM = vonM;
    probMapStruct.toString = @toString;
end

function [ res ] = toString(probMapStruct)
    res = ['probMap-','strat', int2str(probMapStruct.strat), '_v',int2str(probMapStruct.version)];
end

