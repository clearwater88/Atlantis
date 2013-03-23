function [likeSingle] = computeLikeSingle(params,data,qParts,likeInds)
    % likeSingle = 0 also used to mean undefined. Because we're just using these for
    % sums

    imSize = [size(data,1), size(data,2)];
    
    maxParts = size(likeInds,4);
    nImages = size(likeInds,5);
    
    likeSingle = zeros([nImages,params.nParts,maxParts,imSize]);

    for (n=1:nImages)
        dataTemp = data(:,:,n);
        
        for (p=1:params.nParts)

            qPartUse = qParts{p};

            for (mp=1:maxParts)
                
                likeUse = likeInds(:,:,p,mp,n);
                
                idUse = find(likeUse ~= 0);
                qUse = qPartUse(likeUse(idUse));

                ent = (qUse.^dataTemp(idUse)).*((1-qUse).^(1-dataTemp(idUse)));
                likeSingle(n,p,mp,idUse) = ent;

            end
        end
    end
end

