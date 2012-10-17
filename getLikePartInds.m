function [stackedAllPInds,locAll] = getLikePartInds(params,data,gtBrick)
%GETLIKEPARTINDS Summary of this function goes here

    nImages = size(data,3);
    imSize = [size(data,1),size(data,2)];
    nParts = params.nParts;
    maxParts = size(gtBrick,3);

    stackedAllPInds = cell(params.nParts,1);
    locAll = cell(params.nParts,1);
    
    for (p=1:nParts)
        counter = 1;
        pSizeUse = params.partSizes(p,:);
        stackedInds = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
        loc = zeros(2,maxParts*nImages);
        
        for (mp=1:maxParts)
            for (n=1:nImages)
                br = gtBrick(n,p,mp,:); br = reshape(br,[1,numel(br)]);
                if(br(1) == -1) continue; end;

                imPtsInd = doGetLikeInds(br(1),br(2),br(3),br(4),pSizeUse,imSize,1);
                stackedInds(:,:,counter) = reshape(imPtsInd,2*[pSizeUse(1),pSizeUse(2)]+1);
                loc(:,counter) = [n,mp];
                
                counter = counter+1;
            end
        end
        stackedInds(:,:,counter:end) = [];
        loc(:,counter:end) = [];
        
        stackedAllPInds{p} = stackedInds;
        locAll{p} = loc;
    end

end

