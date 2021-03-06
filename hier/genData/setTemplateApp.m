function [app] = setTemplateApp(sizes)

    app=cell(size(sizes,1),1);

    for (i=1:size(sizes,1))
        app{i} = ones(sizes(i,:))/sizes(i,2);
    end


%     probRange=[0.5,0.9];
% 
%     stds(:,:,1) = diag([7,1]);
%     stds(:,:,2) = diag([3,0.5]);
%     stds(:,:,3) = diag([1,0.2]);
%     stds(:,:,4) = diag([0.5,0.1]);
%     
%     for (i=1:size(sizes,1))
%         st = floor(sizes(i,1)/2);
%         x = [-st:-st+sizes(i,1)-1];
%         
%         st = floor(sizes(i,2)/2);
%         y = [-st:-st+sizes(i,2)-1];
%         
%         [y,x] = meshgrid(y,x);
%         pts = [x(:),y(:)];
%         
%         f = mvnpdf(pts,[0,0],stds(:,:,i));
%         rangeF = [min(f(:)),max(f(:))];
%         m = (probRange(1)-probRange(2))/(rangeF(1)-rangeF(2));
%         
%         app{i} = m*reshape(f,sizes(i,:))+probRange(1);
%     end

end

