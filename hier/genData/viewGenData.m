function viewGenData(imSize)
    
    genDataFolder = 'genDataEx/';
    str = [genDataFolder,'ex%d_imSize%d-%d_noiseParam-%d'];
    
    nEx = 20;
    noiseTry = [5:5:25];
    
    for(n=1:nEx)
        
        figure(1);
        for(nt=1:numel(noiseTry))
            load(sprintf(str,n,imSize(1),imSize(2),noiseTry(nt)),'data');
            subplot(1,numel(noiseTry),nt); imshow(data);            
        end
        pause
    end
    
end

