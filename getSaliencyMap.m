function [salient] = getSaliencyMap(x,qParts)
    
    rot=0:pi/20:2*pi;
    
    bg = qParts{2};

    
    salient = zeros([size(x),numel(rot)]);
    
    for(i=1:numel(rot))
        
        q = imrotate(qParts{1},180*rot(i)/pi,'nearest');

        logQ = log(q);
        logQ_rev = log(1-q);

        bgMask = q;
        bgMask(bgMask>0) = bg;
        bgMask = double(bgMask);
        
        logBg = log(bgMask);
        logBg_rev = log(1-bgMask);
        
        logNet = logQ-logBg;
        logNet_rev = logQ_rev-logBg_rev;
        
        salient(:,:,i) = conv2(x,logNet,'same') + conv2(1-x,logNet_rev,'same');
        
    end
    salient = max(salient,[],3);
    
%     figure(100); imshow(x);
%     figure(101); imagesc(salient); colormap(gray); axis off;

end

