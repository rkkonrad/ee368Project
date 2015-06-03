% imgDir = 'apertureSamples/scene1/small/1/';
% imgFiles = dir([imgDir '*.png']);
% 
% tempImg = im2double(imread([imgDir imgFiles(1).name]));
% apSample = zeros(size(tempImg));
% for i = 1:size(imgFiles,1)
%     apSample = apSample + im2double(imread([imgDir imgFiles(i).name])); 
% end
% 
% reference = apSample/size(imgFiles,1);
% figure; imshow(reference);



% Reads in all smaller res reference dof images
apDir = 'apertureSamples/';
numScenes = 1;
numZones = 3;
refSmall = cell(numScenes);
refFull = cell(numScenes);

for scene = 1:numScenes
    scenePathSmall = [apDir 'scene' num2str(scene) '/small/'];
    scenePathFull = [apDir 'scene' num2str(scene) '/full/'];
    referenceSmall = cell(1,numZones);
    referenceFull  = cell(1,numZones);
    for zone = 1:numZones
        
        % Load in smaller res
       imgPathSmall = [scenePathSmall num2str(zone) '/']; 
       imgFiles = dir([imgPathSmall '*.png']);
      
       tempImg = im2double(imread([imgPathSmall imgFiles(1).name]));
       apSample = zeros(size(tempImg));
       for i = 1:size(imgFiles,1)
           apSample = apSample + im2double(imread([imgPathSmall imgFiles(i).name])); 
       end
       referenceSmall{zone} = apSample/size(imgFiles,1);
        
       % Load in full res
       imgPathFull = [scenePathFull num2str(zone) '/']; 
       imgFiles = dir([imgPathFull '*.png']);
       
       tempImg = im2double(imread([imgPathFull imgFiles(1).name]));
       apSample = zeros(size(tempImg));
       for i = 1:size(imgFiles,1)
           apSample = apSample + im2double(imread([imgPathFull imgFiles(i).name])); 
       end
       referenceFull{zone} = apSample/size(imgFiles,1);
    end 
    refSmall{scene} = referenceSmall;
    refFull{scene} = referenceFull;
end