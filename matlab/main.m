% Main script which runs all testing
clear;

bSize = 'small';
zClipNear   = 0.06;
zClipFar    = 50.0; 
dEye        = 0.004;
numScenes = 1;
numDepths = 3;
load('focusDistances.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load in reference images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if( ~exist('refSmall', 'var') || ~exist('refFull', 'var'))
    load('ref.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Definitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Converts from depth buffer to NDC
DepthToNDC = @(z) 2*z - 1; 
% Converts from depth buffer to World Coordinates
DepthToWorld = @(z, clipNear, clipFar) ...
            2*clipNear*clipFar ./ (clipNear + clipFar - DepthToNDC(z) * ...
            (clipFar - clipNear));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imgSmall = im2double(imread('apertureSamples/imageSmall.png'));
depthSmall = csvread('apertureSamples/depthSmall.txt', 0, 0, [0 0 360-1 640-1]);
depthSmall = DepthToWorld(depthSmall, zClipNear, zClipFar);

imgFull = im2double(imread('apertureSamples/imageFull.png'));
depthFull = csvread('apertureSamples/depthFull.txt', 0, 0, [0 0 1080-1 1920-1]);
depthFull = DepthToWorld(depthFull, zClipNear, zClipFar);

% Use small images (for testing) or full images (for performance checks)
if( strcmp(bSize,'small'))
   ref = refSmall;
   img = imgSmall;
   depth = depthSmall;    
elseif( strcmp(bSize, 'full'))
   ref = refFull;
   img = imgFull;
   depth = depthFull;    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algorithm Testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%psnr = @(img, ref) 10*log10(1^2/(norm(img(:) - ref(:))^2 / (size(img,1) * size(img,2))));


structForm = struct('img', {}, 'time', {}, 'psnr', {});

zhou    = structForm;
bilat   = structForm;
rec     = structForm;

tic
for scene = 1:numScenes
    for z = 1:1
        disp(['Computing Zhou Dof for z = ' num2str(z) ]);
        [zhou(scene,z).img zhou(scene,z).time] = ZhouFiltering(img, depth, focusDistances(z), dEye);
        zhou(scene,z).psnr = psnr(zhou(scene,z).img, ref{scene}{z}, 1);

        disp(['Computing Bilatral Dof for z = ' num2str(z) ]);
        [bilat(scene,z).img bilat(scene,z).time] = bilateralFiltering(img, depth, focusDistances(z), dEye);
        bilat(scene,z).psnr = psnr(bilat(scene,z).img, ref{scene}{z}, 1);

        disp(['Computing Recursive Dof for z = ' num2str(z) ]);
        [rec(scene,z).img rec(scene,z).time] = recursiveFiltering(img, depth, focusDistances(z), dEye, 500);
        rec(scene,z).psnr = psnr(rec(scene,z).img, ref{scene}{z}, 1);
    end
end
timeToGather = toc;

avgSceneTimeZhou = mean([zhou.time],2);
avgSceneTimeBilat = mean([bilat.time],2);
avgSceneTimeRec = mean([rec.time],2);

avgScenePSNRZhou = mean([zhou.psnr], 2);
avgScenePSNRBilat = mean([bilat.psnr], 2);
avgScenePSNRRec = mean([rec.psnr], 2);

% A = 100:100:500;
% for i = 1:size(A,2);
%     [incDOF(:,:,:,i) time(3,i)] = recursiveFiltering(img, depth, 0.062, dEye, A(i));
%     psnrDof(i) = psnr(incDOF(:,:,:,i), ref{1});
%     i
% end
% 
% figure; plot(A,psnrDof);