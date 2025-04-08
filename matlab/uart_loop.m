% === Configuration ===
port = "COM6";
baud = 115200;
img_width = 320;
img_height = 240;
img_path = "D:\Desktop\Vivado\test_img\Lena.png";  % Initial upload image
save_folder = "D:\Desktop\Vivado\test_img\output"; % Save path

% === Initialize Serial ===
s = serialport(port, baud);
configureTerminator(s, "LF");
flush(s);
pause(0.5);  % Let the port stabilize

continue_loop = true;
input_img = [];

while continue_loop
    %% === Upload Phase ===
    if isempty(input_img)
        img = imread(img_path);
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
    else
        img = input_img;
    end

    % Step 1: Crop or pad to 320x240
    if size(img, 1) > 240
        top_crop = floor((size(img,1) - 240) / 2);
        img = img(top_crop+1 : top_crop+240, :);
    end
    if size(img, 2) > 320
        left_crop = floor((size(img,2) - 320) / 2);
        img = img(:, left_crop+1 : left_crop+320);
    end
    img = imresize(img, [240, 320]);  % Force resize if needed
    img = uint8(img);                 % Ensure 8-bit

    % Show upload image
    figure;
    imshow(img, []);
    title("🔼 Image to be uploaded");
    drawnow;

    % Upload to FPGA
    disp("⚡ Uploading image...");
    img_data = reshape(img', 1, []);
    chunk_size = 256;
    total_bytes = length(img_data);
    sent_bytes = 0;
    while sent_bytes < total_bytes
        to_send = min(chunk_size, total_bytes - sent_bytes);
        write(s, img_data(sent_bytes+1 : sent_bytes+to_send), "uint8");
        sent_bytes = sent_bytes + to_send;
    end
    disp("✅ Upload completed, waiting for image return...");

    %% === Receive Phase (320x240) ===
    recv_width = 320;
    recv_height = 240;
    total_recv = recv_width * recv_height;
    buffer = zeros(1, total_recv, 'uint8');
    index = 1;
    flush(s);
    pause(0.1);

    h = waitbar(0, "Receiving image...");
    t_recv = tic;
    while index <= total_recv
        to_read = min(256, total_recv - index + 1);
        if s.NumBytesAvailable >= to_read
            data = read(s, to_read, "uint8");
            buffer(index:index + length(data) - 1) = data;
            index = index + length(data);
            waitbar(index / total_recv, h, ...
                sprintf("Receiving %d / %d bytes", index-1, total_recv));
        end
    end
    close(h);
    elapsed_time = toc(t_recv);
    fprintf("✅ Image received in %.2f seconds\n", elapsed_time);

    % Display received image
    img_recv = reshape(buffer, [recv_width, recv_height])';
    figure;
    imshow(img_recv, []);
    title("⬇️ Received image");
    drawnow;

    % Save image
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf("looped_img_%s.png", timestamp);
    imwrite(img_recv, fullfile(save_folder, filename));
    fprintf("💾 Saved to %s\n", filename);

    %% === Ask user whether to continue ===
    choice = questdlg("Do you want to resend the received image to the FPGA?", ...
        "Continue?", ...
        "Yes", "No", "No");

    if strcmp(choice, "Yes")
        input_img = img_recv;
    else
        continue_loop = false;
        disp("🚪 Program exited.");
    end
end

clear s;
