% Creates a .mif file from an image,
% containing the image in grayscale.

write_mif('lena.gif', 'lena.mif', [140 100], true);

function write_mif(filename, out_filename, target_size, grayscale)
    path = '../images/';
    maximum_bits = 276480; % Maximum memory size on the FPGA board

    pixel_depth = 24; % Full color

    if (grayscale)
        pixel_depth = 8; % Grayscale
    end

    if (target_size(1) * target_size(2) * pixel_depth > maximum_bits)
        error('Target image size too large for FPGA memory');
    end

    img = imread(strcat(path, filename));

    if (grayscale)
        img = im2gray(img);
    end

    resized = imresize(img, target_size);

    % Size of picture
    [height, width] = size(resized);

    % Convert to 1xN vector
    data = reshape(resized, 1, width * height);

    depth = length(data);
    word_length = pixel_depth;

    fid = fopen(strcat(path, out_filename), 'w');
    fprintf(fid, 'DEPTH=%d;\n', depth);
    fprintf(fid, 'WIDTH=%d;\n', word_length);

    fprintf(fid, 'ADDRESS_RADIX = UNS;\n');
    fprintf(fid, 'DATA_RADIX = HEX;\n');
    fprintf(fid, 'CONTENT\t');
    fprintf(fid, 'BEGIN\n');

    for i = 0:length(data) - 1
        fprintf(fid, '\t%d\t:\t%x;\n', i, data(i + 1));
    end

    fprintf(fid, 'END;\n');
    fclose(fid);

    fprintf('[%s] Height: %d, Width: %d, Depth: %d\n', out_filename, height, width, depth);
end
