function viewGenData(nStart,nEnd,imSize)
    
    genDataFolder = 'genDataEx/';
    str = [genDataFolder,'ex%d_imSize%d-%d_noiseParam-%d'];
    %str = [genDataFolder,'exClean%d_imSize%d-%d'];

    noiseTry = [5:5:50];
    
    for(n=nStart:nEnd)

        ims = cell(numel(noiseTry),1);
        for(nt=1:numel(noiseTry))
            load(sprintf(str,n,imSize(1),imSize(2),noiseTry(nt)),'data');
            ims{nt} = data;
            subplot(1,numel(noiseTry),nt); imshow(data);            
        end
%         sz1 = ceil(sqrt(numel(noiseTry)));
%         sz2 = ceil(numel(noiseTry)/sz1);
%         
%         load(sprintf(str,n,imSize(1),imSize(2)),'cleanData');
%         ims{1} = cleanData;
%         sz1= 1; sz2= 1;
% 
%         figure(1);
%         imshow(makeCollage(ims,[sz1,sz2]));
        pause
    end
    
end

