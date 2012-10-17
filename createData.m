function [res,gtBrick] = createData(params,appParam,imSize,locs)
    %appParam(end) must be background appearance param
    % gtBrick = -1 is flag to mean invalid

    nIm = 100;
    maxPartsPer = 5;
    parts = params.partSizes;
   
    res = zeros([imSize,nIm]);

    gtBrick = -1*ones(nIm,params.nParts,maxPartsPer,4);
    
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
                rot = 2*pi*rand(1,1);
                %rot = 0;
                %fs = (0.0+0.3*rand(1,1));
                fs = 0;
                
                yPts = y-partDim(1):y+partDim(1);
                xPts = x-partDim(2):x+partDim(2);
                       
                [pts] = meshgridRaster(yPts,xPts);
                
                [ptsRot,corresPts] = rotatePts(pts,[y,x],rot,fs,0);
                
                ptsRotInd = imSize(1)*(ptsRot(:,2)-1)+ptsRot(:,1);
                corresPtsInd = imSize(1)*(corresPts(:,2)-1)+corresPts(:,1);                
                ptsInd = imSize(1)*(pts(:,2)-1)+pts(:,1);

                [~,ind] = ismember(corresPtsInd,ptsInd);
                
                ptsOn = rand(size(ptsInd,1),1) < appParam{n}(:);
                ptsOn = ptsOn(ind);
                
                im(ptsRotInd) = ptsOn;
                fg(ptsRotInd) = 1;
                gtBrick(nn,n,i,:) = [y,x,rot,fs];
                
            end
            
        end
        bg = find(fg == 0);
        bgOn = rand(size(bg,1),1) < appParam{end};
        
        im(bg) = bgOn;
        res(:,:,nn) = im;
    end
end

