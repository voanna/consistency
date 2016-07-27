function [filePathsCell] = filePaths(folder, endstring)
% Creates a cell in which each element is a string of the full path to a
% file in the folder dir, ending in endstring
% example, if dir is ~/predicting_consistency/MIT/ALLFIXATIONMAPS/
% and endstring is "_fixMap.jpeg"
% the first entry of the output will be
% ~/predicting_consistency/MIT/ALLFIXATIONMAPS/i05june05_static_street_boston_p1010764_fixMap.jpg

valid_endstrings = {
    '*.jpg';
    '*.jpeg';
	'*_Salmap.jpeg';
    '*_fixMap.jpg';
    '*_fixPts.jpg';
    '*.txt';
    '*.png'
    };

if ~ismember(endstring, valid_endstrings)
    disp('The endstring is not valid');
    return
end

% list of files within each folder
% files are sorted as returned by OS - so alphabetically
filePathsCell =  dir(fullfile([folder endstring]));

% takes only the name field
filePathsCell = {filePathsCell.name}';

% concatenates filename with dir
filePathsCell = cellfun(@(name)[folder name],filePathsCell,'uni',false);
end
