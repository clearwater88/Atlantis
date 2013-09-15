function [res] = viewOverlayTest(testData,particles,templateStruct,params,imSize)
    st = viewAllParticles(particles,templateStruct,params,imSize);
    
    res = repmat(testData,[1,1,3]);

    mask = st~=0;
    res(:,:,1) = st.*mask + res(:,:,1).*(1-mask);
    
    res = double(res); % fuck you, matlab
end

