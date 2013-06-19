function [res] = viewConnectivity(particle,connPar,imSize, particleView)
    
    if(nargin < 4)
        particleView = zeros(imSize);
    end
    res = particleView;
    res = repmat(res,[1,1,3]);
    
    for (i=1:numel(connPar))
       pose = getPose(particle,i);
       centre = pose(1:2);
       
       parentIds = connPar{i};
       parentPoses = getPose(particle,parentIds);
       
       for (j=1:size(parentPoses,2))
           parentCentre = parentPoses(1:2,j);
           
           m = (parentCentre(1)-centre(1))/(parentCentre(2)-centre(2));
           b = parentCentre(1)-m*parentCentre(2);
           
           if (~isinf(abs(m)))
               x=0:0.01:abs(parentCentre(2)-centre(2));
               x = x + min(parentCentre(2),pose(2));
               y = m*x+b;
           else
               y=0:0.01:abs(parentCentre(1)-centre(1));
               y = y + min(parentCentre(1),pose(1));
               x = centre(2)*ones(size(y));
           end
           
           x = round(x);
           y = round(y);
           
           inds = sub2ind(imSize,y,x);
           
           % dark end is parent
           if(parentCentre(2) <= pose(2))
               val=0:1/(numel(inds)-1):1;
           else
               val=1:-1/(numel(inds)-1):0;
           end
           
           % pick a channel: r or g
           ind = randi(2,1,1);
           for (k=1:2)
               temp = res(:,:,k);
               if (k==ind)
                   temp(inds) = val;
               else
                   temp(inds) = 0;
               end
               res(:,:,k) = temp;
           end
       end
    end
end

