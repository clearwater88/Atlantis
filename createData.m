function [res,gtBrick] = createData(params,appParam,imSize,locs)
    %appParam(end) must be background appearance param
    % gtBrick = -1 is flag to mean invalid

    nIm = 1000;
    maxPartsPer = 2;
    parts = params.partSizes;
   
    res = zeros([imSize,nIm]);

    gtBrick = -1*ones(nIm,params.nParts,maxPartsPer,3);
    
    for (nn=1:nIm)
        nParts = randi(maxPartsPer,[size(parts,1),1]);
        im = zeros(imSize);
        
        fg = zeros(imSize);
        
        for (n=1:params.nParts)
            clear temp;
            for (i=1:nParts(n))
                
                partDim = parts(n,:);

                ind = randi(size(locs,1),1);
                y = locs(ind,1);
                x = locs(ind,2);
                rot = pi*rand(1,1);

                yPts = max(1,y-partDim(1)):min(y+partDim(1),imSize(1));
                xPts = max(1,x-partDim(2)):min(x+partDim(2),imSize(2));
                       
                [pts] = meshgridRaster(yPts,xPts);
                
                [ptsRot,corresPts] = rotatePts(pts,[y,x],rot,0);
                ptsRotInd = sub2ind(imSize,ptsRot(:,1),ptsRot(:,2));  
                
                corresPtsInd = sub2ind(imSize,corresPts(:,1),corresPts(:,2));
                ptsInd = sub2ind(imSize,pts(:,1),pts(:,2));
                [~,ind] = ismember(corresPtsInd,ptsInd);
                
                ptsOn = rand(size(ptsInd,1),1) < appParam{n}(:);
                ptsOn = ptsOn(ind);
                
                im(ptsRotInd) = ptsOn;
                fg(ptsRotInd) = 1;
                gtBrick(nn,n,i,:) = [y,x,rot];
                
            end
            
        end
        bg = find(fg == 0);
        bgOn = rand(size(bg,1),1) < appParam{end};
        
        im(bg) = bgOn;
        res(:,:,nn) = im;
    end
end

