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
            
        case 'raw'
            pattern.raw = data;
            
        case 'hist'
            pattern.samples = size(data,1);
            pattern.minValue = min(data(:))+1;
            data = data + pattern.minValue; % Rescale to avoid negative values
            pattern.maxValue = max(data(:));
            pattern.difValues = pattern.maxValue - pattern.minValue;
            pattern.histSize = 50;
            pattern.hist = hist(data(:,:),pattern.histSize) / pattern.samples;
    end
end

