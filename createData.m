function [res,gt,gtBrick] = createData(params,appParam,imSize,locs)
    %appParam(end) must be background appearance param
    % gtBrick = -1 is flag to mean invalid

    nIm = 1000;
    maxPartsPer = 3;
    parts = params.partSizes;
   
    res = zeros([imSize,nIm]);
    gt = zeros([imSize,nIm]);
    gtBrick = -1*ones(nIm,params.nParts,maxPartsPer,2);
    
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

                yPts = max(1,y-partDim(1)):min(y+partDim(1),imSize(1));
                xPts = max(1,x-partDim(2)):min(x+partDim(2),imSize(2));
                       
                [tempX,tempY] = meshgrid(xPts,yPts);
                pts= [tempY(:),tempX(:)];
                
                pts = sub2ind(imSize,pts(:,1),pts(:,2));                
                ptsOn = rand(size(pts,1),1) < appParam{n}(:);
                
                im(pts) = im(pts) | ptsOn;
                fg(pts) = 1;
                gtBrick(nn,n,i,:) = [y,x];

            end
            
        end
        bg = find(fg == 0);
        bgOn = rand(size(bg,1),1) < appParam{end};
        
        im(bg) = bgOn;
        res(:,:,nn) = im;
        gt(:,:,nn) = fg;
    end
end

