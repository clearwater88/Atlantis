function [totalLike,samp_x,countMask,likeIm] = samplePosteriorX(params,data,qParts,partSize,loc,likeBg,nParticles,countMaskOld)
    % Last drawLike is always brick = off
    
    imSize = size(data);    
    nParticleOn = rand(nParticles,1) < params.brickOn;
    nParticleOn = sum(nParticleOn);

    samp_x = bsxfun(@plus,[loc,0],bsxfun(@times,params.brickStd,randn(nParticleOn,3)));
    samp_x(:,1:2) = round(samp_x(:,1:2));

    totalLogLike = zeros(nParticleOn,1);
    oldMask = countMaskOld>0;
    
    countValid = 1;
    
    
    countMask = zeros([imSize,nParticleOn+1]);
    likeIm = zeros([imSize,nParticleOn+1]);
    for (pp=1:nParticleOn)
        if(mod(pp,1000) == 0)
            display(sprintf('On %d / %d particles', pp,nParticleOn));
        end
        [imPtsInd,~,qInd] = doGetLikeInds(samp_x(pp,1),samp_x(pp,2),samp_x(pp,3),0,partSize,imSize,0);

        if(any(imPtsInd<1) || any(imPtsInd>prod(imSize)))
            display('out of im range');
            continue;
        end;

        counts = countMaskOld;
        counts(imPtsInd) = counts(imPtsInd) + 1;
        countMask(:,:,pp) = counts;
        
        % now compute imlike....
        % only 1 part, so qParts{1}
        
        % NEED TO ADD IN BG FROM BEFORE
        likeTemp = computeLike(data,qParts{1},imPtsInd,qInd);
        likeTemp(oldMask) = likeTemp(oldMask) + likeBg(oldMask);
        
        mask = (counts > 0);
        likeTemp(mask) = likeTemp(mask)./counts(mask);
        likeIm(:,:,pp) = likeTemp.*mask + likeBg.*(1-mask);
        
        fgLogProb = log(likeTemp(mask));
        bgLogProb = log(likeBg(~mask(:)));
        
        totalLogLike(countValid) = sum(fgLogProb(:))+sum(bgLogProb(:));
        countValid = countValid+1;

    end
    
    % Append the brick = off element.
    totalLogLike = cat(1,totalLogLike,log(nParticles-nParticleOn)+sum(log(likeBg(:))));
    likeIm(:,:,end) = likeBg;
    countMask(:,:,end) = countMaskOld;
    % add in special "off" flags
    samp_x = cat(1,samp_x,-1*ones(1,size(samp_x,2)));
    
    totalLogLike = totalLogLike-logsum(totalLogLike);
    totalLike = exp(totalLogLike);
    

end

