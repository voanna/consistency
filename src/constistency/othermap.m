function otherMap = othermap(fixPtfiles, M, index, s)
%Creates an othermap that is the union of M randomly selected other fixation
%maps.  M is usu. 10, as in Borji's work.
%fixPtfiles     A cell array containing paths to fixationmaps
%index          Index of image being scored, othermap should not contain
%               the fixations from this image
%M              Number of images to use to create othermap
%othermap       A union of M fixation maps.  Fixation maps should be binary
%               matrices
%s              to which size to rescale all fixPt images

% get indices of M other random fixpt images, not incl the one being scored
% files in fixptfiles should be binary images!
idx = rand_sample_with_exclusion(length(fixPtfiles), index, M);

% load all images into the cell
fixptCell = load_imgs_to_cell(fixPtfiles, idx);

% either resizes image or pads it with zeros to make it size s
fixptCell = cellfun(@(x)imresizepad(x,s, 'nearest', 0),fixptCell,'uni',false);

otherMap = uint8(zeros(s));

% take union of all images
for i = 1:M
    otherMap(fixptCell{i} > 0) = fixptCell{i}(fixptCell{i} > 0);
end

otherMap = im2double(otherMap);
end

