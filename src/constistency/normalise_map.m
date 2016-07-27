function [map]= normalise_map(map)
%USED TO BE JUST DIVIDING BY MAX!
map = im2double(map);
if max(map(:))==0 && min(map(:))==0 % to avoid dividing by zero if zero image
    map(100, 100)=1;
else
    map= (map-min(map(:)))/(max(map(:))-min(map(:)));
end
end
