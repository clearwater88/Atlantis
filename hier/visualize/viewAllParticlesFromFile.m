function  probPixel= viewAllParticlesFromFile(file)
% View particles as given from a file. Returns prob. of a pixel being on
    load(file,'cleanData','allParticles','params','templateStruct');

    imSize = size(cleanData);
    [rotTemplates,~] = getRotTemplates(params,templateStruct);
    
    probPixel = viewAllParticles(allParticles{end},rotTemplates,params,imSize);

end

