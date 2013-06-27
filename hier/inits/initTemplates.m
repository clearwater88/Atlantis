function [templateStruct] = initTemplates()
    
    templateStruct.mix = [0.1,0.5,1]';
    templateStruct.mix(end+1) = 0.001;
    templateStruct.bg = 0.1;
                         
    templateStruct.sizes = [27,5; ...
                            21,5; ...
                            15,5; ...
                            9,5];
                        
    templateStruct.doLearning = 1;
    templateStruct.SIGMA = 1;
    templateStruct.angles = 0:pi/8:pi;
    templateStruct.toString = @toString;
end

function [res] = toString(templateStruct)
    res = ['LearnTemplates-', int2str(templateStruct.doLearning)];
end

