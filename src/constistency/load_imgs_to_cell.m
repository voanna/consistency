function [imgCell] = load_imgs_to_cell(imgfilesCell, idx)
% stores images indexed by idx from imgfilesCell in a cell array, imgCell
% imgCell           cell in which each element is an image (imread)
% imgfilesCell      cell array containing filepaths to images
% idx               array of images to be read in

M = length(idx);
imgCell = cell(1,M);
for i = 1:M
   imgCell{i} = imread(imgfilesCell{idx(i)});
end
end