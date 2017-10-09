function [ pattern ] = createTemplate( data , namePattern )
%CREATETEMPLATE Given the samples in the data matrix, create a template
%using the namePattern method. 
    switch namePattern
        case 'grayscaleMean'
            %mean of the grayscale images
            pattern = squeeze(mean(data));
            
        case 'chamferMean'
            %Convert into a chamfer distance images
            for i = 1:size(data,1)
                image = squeeze(data(i,:,:));
                data(i,:,:) = bwdist(edge(image,'canny',0.4));
            end
            pattern = squeeze(mean(data));
           
        case 'grayscaleMeanDeviation'
            pattern.mean = squeeze(mean(data));
            pattern.std = squeeze(std(data));
        
                
    end
end
