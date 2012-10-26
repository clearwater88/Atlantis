function [totalLike,samp_x,counts,like] = samplePosteriorX(params,data,qParts,partSize,loc,likeOld,nParticles,countsOld)
    % Last drawLike is always brick = off
    
    imSize = size(data);    
    nParticleOn = rand(nParticles,1) < params.brickOn;
    nParticleOn = sum(nParticleOn);

    samp_x = bsxfun(@plus,[loc,0],bsxfun(@times,params.brickStd,randn(nParticleOn,3)));
    samp_x(:,1:2) = round(samp_x(:,1:2));

    totalLogLike = zeros(nParticleOn,1);
    
    countValid = 1;
    
    
    counts = zeros([imSize,nParticleOn+1]);
    like = zeros([imSize,nParticleOn+1]);
    for (pp=1:nParticleOn)
        if(mod(pp,1000) == 0)
            display(sprintf('On %d / %d particles', pp,nParticleOn));
        end
        [imPtsInd,~,qInd] = doGetLikeInds(samp_x(pp,1),samp_x(pp,2),samp_x(pp,3),0,partSize,imSize,0);

        if(any(imPtsInd<1) || any(imPtsInd>prod(imSize)))
            display('out of im range');
            continue;
        end;

        
        % only 1 part, so qParts{1}
        % Overlay new Fg + old Fg parts
        likeTemp = computeLike(data,qParts{1},imPtsInd,qInd) ;
        like(:,:,pp) = likeTemp + likeOld;
        
        % Update mask of counts
        countsTemp = countsOld;
        countsTemp(imPtsInd) = countsTemp(imPtsInd) + 1;
        counts(:,:,pp) = countsTemp;
        
        % Compute full image likelihood at each pixel
        likeFull = like(:,:,pp)./counts(:,:,pp);        
        totalLogLike(countValid) = sum(log(likeFull(:)));
        countValid = countValid+1;

    end
    
    % Append the brick = off element.
    oldLike = likeOld./countsOld;
    totalLogLike = cat(1,totalLogLike,log(nParticles-nParticleOn)+sum(log(oldLike(:))));
    like(:,:,end) = likeOld;
    counts(:,:,end) = countsOld;
    % add in special "off" flags
    samp_x = cat(1,samp_x,-10*ones(1,size(samp_x,2)));
    
    totalLogLike = totalLogLike-logsum(totalLogLike,1);
    totalLike = exp(totalLogLike);
    
end

