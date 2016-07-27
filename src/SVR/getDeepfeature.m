function [feat] = getDeepfeature(feature_path)
%getDeepfeature(feature_path) Reads a deep features stored at feature_path
% into a vector
    fid=fopen(feature_path,'r');
    feat=fscanf(fid,'%f');
    fclose(fid);
end
