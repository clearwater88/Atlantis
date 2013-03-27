function [probMapStruct] = initProbMaps(ruleStruct,templates)
    % simple initialization for line model

    parents = ruleStruct.parents;
    offset = cell(numel(parents),1);
    covCentres = cell(numel(parents),1); % covariances for each slot

    for (i=1:size(parents,1))
        pa = parents(i);
        tp = templates{pa};
        ch = ruleStruct.children(i,:);
        
        validChildren = ch(ch~=0);
        
        totCh = numel(validChildren);
        for (j=1:totCh)
            % split up probMap top to bottom, use middle for width
            
            % x,y,angle
            offset{i}(j,1) = round(j*(1+size(tp,1))/(1+totCh));
            offset{i}(j,2) = (size(tp,2)+1)/2;
            offset{i}(j,3) = 0;
            
            covCentres{i}(:,:,j) = [10,0,0; ...
                                    0,10,0; ...
                                    0,0,pi/16];
        end
    end
    
    probMapStruct.offset=offset;
    probMapStruct.cov=covCentres;
end

