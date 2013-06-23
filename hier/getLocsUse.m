function res = getLocsUse(strides,cellDims,imSize)
    % locations in column-major

    temp = 1:strides(1):(imSize(1)+1)-cellDims(1);
    temp2 = 1:strides(2):(imSize(2)+1)-cellDims(2);
    
    % cellBoundary angles start are [-pi:pi)
    temp3 = -pi:strides(3):pi-0.00001;
    [temp2,temp,temp3] = meshgrid(temp2,temp,temp3);
    res = [temp(:),temp2(:),temp3(:)];
    % re-centre
    res(:,1:2) = bsxfun(@plus,res(:,1:2),((cellDims(1:2))-1)/2);
    res(:,3) = mod(bsxfun(@plus,res(:,3),cellDims(3)/2),2*pi)-pi;

end

