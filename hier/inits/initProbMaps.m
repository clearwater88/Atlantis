function [probMapStruct] = initProbMaps(ruleStruct,templates)
    % simple initialization for line model

    parents = ruleStruct.parents;
    offset = cell(numel(parents),1);
    covCentres = cell(numel(parents),1); % covariances for each slot

    covCentresParents(:,:,1) = [1,0,0; ...
                                0,1,0; ...
                                0,0,pi/8];
    
    covCentresParents(:,:,2) = [1,0,0; ...
                                0,1,0; ...
                                0,0,pi/8];
    
    covCentresParents(:,:,3) = [1,0,0; ...
                                0,1,0; ...
                                0,0,pi/8];
    
    for (i=1:size(parents,1))
        tp = templates{parents(i)};
        ch = ruleStruct.children(i,:);
        
        validChildren = ch(ch~=0);
        
        totCh = numel(validChildren);
        for (j=1:totCh)
            % split up probMap top to bottom, use middle for width
            
            % x,y,angle
            offset{i}(j,1) = round(j*(1+size(tp,1))/(1+totCh)); % offset along length of template
            offset{i}(j,2) = (size(tp,2)+1)/2;
            offset{i}(j,3) = 0;
            
            covCentres{i}(:,:,j) = covCentresParents(:,:,parents(i));
        end
    end
    
    probMapStruct.version=5;
    probMapStruct.strat = 1; %0 no line contig; 1 = line contig
    probMapStruct.offset=offset;
    probMapStruct.cov=covCentres;
    probMapStruct.toString = @toString;
end

function [ res ] = toString(probMapStruct)
    res = ['probMap-','strat', int2str(probMapStruct.strat), '_v',int2str(probMapStruct.version)];
end

