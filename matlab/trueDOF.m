clear all;
close all;

imgDir = 'apertureSamples/full/3/';
imgFiles = dir([imgDir '*.png']);

tempImg = im2double(imread([imgDir imgFiles(1).name]));
apSample = zeros(size(tempImg));
for i = 1:size(imgFiles,1)
    apSample = apSample + im2double(imread([imgDir imgFiles(i).name])); 
end

reference = apSample/size(imgFiles,1);
figure; imshow(reference);