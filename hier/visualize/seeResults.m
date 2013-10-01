close all;

nParticles = numel(allParticles);

figure(1);
subplot(1,3,1); imshow(testData);

for (i=1:nParticles)
    st= viewAllParticles(allParticles{i},templateStruct,params);
    subplot(1,3,2);
    imshow(st); title(int2str(i));
    
    % specific example
    st2= viewAllParticles(allParticles{i}(1),templateStruct,params);
    st3= viewConnectivity(allParticles{i}{1},allConnPars{i}{1},params.imSize, st2);
    subplot(1,3,3);
    imshow(st3); title(int2str(i));
    pause(0.5);
end