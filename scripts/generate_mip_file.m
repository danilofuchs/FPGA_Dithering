% Creates a .mif file from an image,
% containing the image in grayscale.

write_mif('jardim_botanico.jpg', 'jardim_botanico_gray.mif', [100 NaN], true);
%write_mif('jardim_botanico.jpg', 'jardim_botanico.mif', [80 NaN], false);

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
    [height, width] = size(resized);

    if (is_grayscale)
        % Convert to 1xN vector
        data = reshape(resized, 1, width * height);
    else
        size(resized)
        % Convert to 1xN vector with RGB values
        data = reshape(resized, 1, width * height, 3);
    end

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

        if (is_grayscale)
            output = sprintf('%x', data(i + 1));
        else
            [r, g, b] = data(i + 1);
            output = sprintf('%x%x%x', r, g, b);
        end

        fprintf(fid, '\t%d\t:\t%s;\n', i, output);
    end

    fprintf(fid, 'END;\n');
    fclose(fid);

    fprintf('[%s] Height: %d, Width: %d, Depth: %d, Pixel depth: %db. Using %d bits\n', out_filename, height, width, depth, pixel_depth, required_bits);
end
