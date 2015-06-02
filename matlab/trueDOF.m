clear all;
close all;

imgDir = 'images/apertureSamples/1/';
imgFiles = dir([imgDir '*.png']);

tempImg = im2double(imread([imgDir imgFiles(1).name]));
apSample = zeros([size(tempImg) size(imgFiles)]);
for i = 1:size(imgFiles,1)
    apSample(:,:,:,i) = im2double(imread([imgDir imgFiles(i).name])); 
end

reference = sum(apSample,4)/size(apSample,4);
figure; imshow(reference);