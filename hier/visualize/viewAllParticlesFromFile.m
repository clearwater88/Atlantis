function  probPixel= viewAllParticlesFromFile(file)
% View particles as given from a file. Returns prob. of a pixel being on
    load(file,'cleanTestData','allParticles','params','templateStruct');

    imSize = size(cleanTestData);
    [rotTemplates,~] = getRotTemplates(params,templateStruct);
    
    probPixel = viewAllParticles(allParticles{end},rotTemplates,params,imSize);

end

