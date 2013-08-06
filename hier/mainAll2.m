ds = [4]';
noise = [0.1,0.2]';
context = [1]';
folder = ['res_sweep2', '/'];

tStart=0;
nTrials=3;

for (i=1:numel(ds))
    for(j=1:numel(noise))
       for (k=1:numel(context))
           mainBP(ds(i),noise(j),context(k),folder,tStart,nTrials);
       end
    end
end
