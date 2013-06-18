function [templateStruct] = initTemplates()
    
    templateStruct.mix = [0.1,0.5,1]';
    templateStruct.mix(end+1) = 0.001;
    templateStruct.bg = 0.1;

    %make dimensions odd
    templateStruct.app{1} = [0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9];
                
    templateStruct.app{2} = [0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9];

    templateStruct.app{3} = [0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9; ...
                             0.9];

                         
    templateStruct.app{end+1} = templateStruct.bg;
                         
    templateStruct.sizes = [15,15; ...
                            11,11; ...
                            7,7];
                        
    templateStruct.doLearning = 1;
    templateStruct.SIGMA = 1;
    templateStruct.angles = 0:pi/8:pi;
    templateStruct.toString = @toString;
end

function [res] = toString(templateStruct)
    res = ['LearnTemplates-', int2str(templateStruct.doLearning)];
end

