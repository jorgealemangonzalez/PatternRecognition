function [ accuracy confusionMatrix ] = testMethod( data , labels, labelsUsed , errorMeasure, indexesCrossVal )
% TESTMETHOD This function estimates the accuracy and confusion over the dataset samples in data by using Cross Validation 
% the input template matching method and the error measure method.
% INPUTS:
% data: NxDxD , matrix with the images or shape data of the dataset
% labels: 1xN vector with the emotion labels for each sample in the matrix data.
% labelsUsed: labels used to train and classify.
% templateMethod: string with the method used to generate the template.
% errorMeasuse: string with the error measure method used to compare the template with the samples.
% indexesCrossVal: indexes used to perform the performance evaluation with cross validation

indexes = indexesCrossVal;
K = max(indexes);

confusionMatrix = zeros(numel(labelsUsed));
for k = 1:K
    display(['Testing data subset: ' num2str(k) '/' num2str(K)]);
    %get train and test dataset with the indexes obtained with the KFold
    %cross validation
    train = data(indexes~=k,:);
    labelsTrain = labels(indexes~=k);
    test = data(indexes==k,:);
    labelsTest = labels(indexes==k);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %REDUCE DIMENSIONALITY OF TRAINNING AND TESTING DATA HERE %%%
    % USE ONLY TRAINNING TO GET THE PROJECTION BASIS AND MEAN %%%
    % AND THEN PROJECT THE TESTING DATA USING THEM            %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %TODO , LAS LABELS QUE SE LE PASAN A LDA TIENE QUE SER PARA CADA ROW
    %DEL TRAIN
    % si solo hacemos lda da out of memory
    [dataProjected, meanProjection1, vectorsProjection1] = reduceDimensionality( train, 'PCA',200, labelsTrain);
    [dataProjected, meanProjection2, vectorsProjection2] = reduceDimensionality( dataProjected, 'LDA', 75, labelsTrain);

    train = dataProjected;
    test = projectData(  projectData(test, meanProjection1, vectorsProjection1)...
        , meanProjection2, vectorsProjection2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %reserve memory to store the template for each emotion
    c= 1;
    for e = labelsUsed
        trainEmotion = train(labelsTrain==e,:);
        templates{c} = createTemplate(trainEmotion, errorMeasure);
        c = c+1;
    end
    
    %Create confusion matrix evaluating the templates with the test data
    estimatedLabels = classifyWithTemplateMatching(templates , test , errorMeasure, labelsUsed);
    confusionMatrix = confusionMatrix + confusionmat(estimatedLabels,labelsTest,'ORDER',labelsUsed);
end
    %get the total accuracy of the system
    accuracy = sum(diag(confusionMatrix)) / sum(confusionMatrix(:));
end

