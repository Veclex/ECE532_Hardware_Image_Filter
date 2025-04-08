% config
img_width = 256;
img_height = 256;
total_bytes = img_width * img_height;
chunk = 256;

% com port
s = serialport("COM6", 115200);
set(s, "Timeout", 30);
flush(s);

% init & timer
buffer = zeros(1, total_bytes, 'uint8');
index = 1;

disp("📷 Waiting for image transfer...");
pause(0.1);
tic;

h = waitbar(0, "Receiving Image...");

try
    while index <= total_bytes
        to_read = min(chunk, total_bytes - index + 1);
        if s.NumBytesAvailable >= to_read
            data = read(s, to_read, "uint8");
            buffer(index:index + length(data) - 1) = data;
            index = index + length(data);
            waitbar(index / total_bytes, h, ...
                sprintf("Received %d / %d bytes", index - 1, total_bytes));
        end
    end

    close(h);
    elapsed_time = toc;
    fprintf("✅ Image received in %.2f seconds\n", elapsed_time);

    % visulizer
    img = reshape(buffer, [img_width, img_height])';
    imshow(img, []);
    title("Received Image");

    % save image
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    save_folder = "D:\Desktop\Vivado\test_img\output";  % ⚠️ change path
    filename = sprintf("captured_img_%s.pgm", timestamp);
    full_path = fullfile(save_folder, filename);
    imwrite(img, full_path,'pgm');
    fprintf("💾 Save To: %s\n", full_path);

catch ME
    close(h);
    warning(ME.identifier, "%s", ME.message);
    fprintf("Received %d bytes before error\n", index - 1);
end

clear s;
