function [templateStruct] = initTemplates()
    
    templateStruct.mix = [0.1,0.5]';
    templateStruct.mix(end+1) = 0.001;
    %templateStruct.bg = 0.1;
                         
    templateStruct.sizes = [11,1; ...
                            7,1];
                        
    templateStruct.doLearning = 1;
    templateStruct.SIGMA = 1;
    %templateStruct.angles = 0:pi/8:pi;
    templateStruct.toString = @toString;
end

function [res] = toString(templateStruct)
    res = ['LearnTemplates-', int2str(templateStruct.doLearning), '_bg', int2str(templateStruct.bg*100)];
end

