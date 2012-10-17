function [particles] = infer(data,qParts,locs,params,bg,pOff)

    MAXP = size(locs,1);
    partSize =  params.partSizes(1,:);
    imSize = size(data);
    
    nParticles = 10000;

    % For now, iterate in order
    for (i=1:MAXP)
        % samples of p(x_i | all other samples) = p(x_i) for no composition
        % round to lattice
        samp_x = bsxfun(@plus,[locs(i,:),0],bsxfun(@times,params.brickStd,randn(nParticles,3)));
        samp_x(:,1:2) = round(samp_x(:,1:2));
        
        for (pp=1:nParticles)
            [imPtsInd,~,qInd] = doGetLikeInds(samp_x(pp,1),samp_x(pp,2),samp_x(pp,3),0,partSize,imSize,0);

            % now compute imlike....
            % only 1 part, so qParts{1}
            like2 = computeLike2(data,qParts{1},imPtsInd,qInd);
        end
    end


particles = 0;

end

