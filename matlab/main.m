% Main script which runs all testing
clear;

bSize = 'small';
zClipNear   = 0.06;
zClipFar    = 50.0; 
dEye        = 0.004;
load('focusDistances.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Definitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Converts from depth buffer to NDC
DepthToNDC = @(z) -2*z + 1; 
% Converts from depth buffer to World Coordinates
DepthToWorld = @(z, clipNear, clipFar) ...
            2*clipNear*clipFar ./ (clipNear + clipFar - DepthToNDC(z) * ...
            (clipNear - clipFar));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apDir = 'apertureSamples/';
for i = 1:3
    refSmall{:,:,:,i} = im2double(imread([apDir 'ref_small_' num2str(i) '.png']));
    refFull{:,:,:,i} = im2double(imread([apDir 'ref_full_' num2str(i) '.png']));
end

imgSmall = im2double(imread('apertureSamples/imageSmall.png'));
depthSmall = im2double(imread('apertureSamples/depthSmall.png'));
depthSmall = DepthToWorld(depthSmall(:,:,3), zClipNear, zClipFar);

imgFull = im2double(imread('apertureSamples/imageFull.png'));
depthFull = im2double(imread('apertureSamples/depthFull.png'));
depthFull = DepthToWorld(depthFull(:,:,3), zClipNear, zClipFar);

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
psnr = @(img, ref) 10*log10(1^2/(norm(img(:) - ref(:))^2 / (size(img,1) * size(img,2))));

% for i = 1:3
%     disp(['Computing Zhou Dof for i = ' num2str(i) ]);
% %     [incDOF(:,:,:,1) time(1,i)] = ZhouFiltering(img, depth, 0.062, dEye);
% %     psnrDof(1,i) = psnr(incDOF(:,:,:,i), ref{1});
%     
%     disp(['Computing Bilatral Dof for i = ' num2str(i) ]);
%     
%     disp(['Computing Recursive Dof for i = ' num2str(i) ]);
%     [incDOF(:,:,:,3) time(3,i)] = recursiveFiltering(img, depth, 0.062, dEye);
%     psnrDof(3,i) = psnr(incDOF(:,:,:,3), ref{1});
%     
%     dof{i} = incDOF;    
% end

A = 100:100:500;
for i = 1:size(A,2);
    [incDOF(:,:,:,i) time(3,i)] = recursiveFiltering(img, depth, 0.062, dEye, A(i));
    psnrDof(i) = psnr(incDOF(:,:,:,i), ref{1});
    i
end

figure; plot(A,psnrDof);