function [templateStruct] = initTemplates()
    
    templateStruct.mix = [0.1,1,10,100]';
    templateStruct.mix(end+1) = 0.00001;
    %templateStruct.bg = 0.1;
       
    templateStruct.sizes = [25,9; ...
                            13,5; ...
                            7,3; ...
                            3,1];

    templateStruct.doLearning = 1;
    templateStruct.SIGMA=1;
    templateStruct.toString = @toString;
end

function [res] = toString(templateStruct)
    res = 'templates-';
    for (i=1:size(templateStruct.sizes,1))
       res = [res,int2str(templateStruct.sizes(i,1)),'x',int2str(templateStruct.sizes(i,2))];
       if (i ~= size(templateStruct.sizes,1))
           res = [res,'_'];
       end
    end
end

