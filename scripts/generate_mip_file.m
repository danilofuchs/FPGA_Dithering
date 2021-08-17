% Creates a .mif file from an image,
% containing the image in grayscale.

filename = 'lena.gif';

[~, name, ~] = fileparts(filename);

src = imread(strcat('../images/', filename));
gray = im2gray(src);
resized = imresize(gray, [NaN 100]);

% Size of picture
[height, width] = size(resized)

% Convert to 1xN vector
data = reshape(resized, 1, width * height);

content = data; %cat(2, header, uint16(data));

depth = length(content)
word_length = 8; % 8 bits per pixel (grayscale)

fid = fopen(strcat('../images/', name, '.mif'), 'w');
fprintf(fid, 'DEPTH=%d;\n', depth);
fprintf(fid, 'WIDTH=%d;\n', word_length);

fprintf(fid, 'ADDRESS_RADIX = UNS;\n');
fprintf(fid, 'DATA_RADIX = HEX;\n');
fprintf(fid, 'CONTENT\t');
fprintf(fid, 'BEGIN\n');

for i = 0:length(content) - 1
    fprintf(fid, '\t%d\t:\t%x;\n', i, content(i + 1));
end

fprintf(fid, 'END;\n');
fclose(fid);
