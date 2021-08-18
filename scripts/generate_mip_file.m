% Creates a .mif file from an image,
% containing the image in grayscale.

write_mif('jardim_botanico.jpg', 'jardim_botanico_gray.mif', [100 NaN], true);
write_mif('jardim_botanico.jpg', 'jardim_botanico.mif', [60 NaN], false);

function write_mif(filename, out_filename, target_size, is_grayscale)

    if (strcmp(filename, out_filename) == 1)
        error('Output file must be different from input file.');
    end

    path = '../images/';
    maximum_bits = 276480; % Maximum memory size on the FPGA board

    pixel_depth = 24; % Full color

    img = imread(strcat(path, filename));

    if (is_grayscale)
        pixel_depth = 8; % Grayscale
        img = im2gray(img);
    end

    resized = imresize(img, target_size);

    required_bits = size(resized, 1) * size(resized, 2) * pixel_depth;

    if (required_bits > maximum_bits)
        error('Target image size too large for FPGA memory (%d bits, maximum %d bits)', required_bits, maximum_bits);
    end

    % Size of picture
    [height, width, ~] = size(resized);

    data = resized;

    depth = height * width;
    word_length = pixel_depth;

    fid = fopen(strcat(path, out_filename), 'w');
    fprintf(fid, 'DEPTH=%d;\n', depth);
    fprintf(fid, 'WIDTH=%d;\n', word_length);

    fprintf(fid, 'ADDRESS_RADIX = UNS;\n');
    fprintf(fid, 'DATA_RADIX = HEX;\n');
    fprintf(fid, 'CONTENT\t');
    fprintf(fid, 'BEGIN\n');

    for col = 1:width

        for row = 1:height

            if (is_grayscale)
                hex = sprintf('%02x', data(row, col));
            else
                r = data(row, col, 1);
                g = data(row, col, 2);
                b = data(row, col, 3);
                hex = sprintf('%02x%02x%02x', r, g, b);
            end

            index = (row - 1) + (col - 1) * height;
            fprintf(fid, '\t%d\t:\t%s;\n', index, hex);
        end

    end

    fprintf(fid, 'END;\n');
    fclose(fid);

    fprintf('[%s] Height: %d, Width: %d, Depth: %d, Pixel depth: %db. Using %d bits\n', out_filename, height, width, depth, pixel_depth, required_bits);
end
