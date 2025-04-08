% === 配置参数 ===
port = "COM6";              % 串口号（根据实际修改）
baud = 115200;              % 波特率（与 FPGA 保持一致）
img_width = 320;
img_height = 240;
img_path = "D:\Desktop\Vivado\test_img\Lena.png";  % 输入图像路径

% === 加载图像并转换为灰度 ===
img = imread(img_path);
if size(img, 3) == 3
    img = rgb2gray(img);  % 若为彩色图像，转为灰度
end

% === 图像处理：从 256×256 → 320×240 ===

% Step 1: 裁剪垂直方向，保留中间 240 行
if size(img, 1) > 240
    top_crop = floor((size(img,1) - 240) / 2);
    img = img(top_crop+1 : top_crop+240, :);
end

% Step 2: 左右填充黑边，使列数变成 320
if size(img, 2) < 320
    pad = 320 - size(img,2);
    pad_left = floor(pad/2);
    pad_right = ceil(pad/2);
    img = padarray(img, [0 pad_left], 0, 'pre');
    img = padarray(img, [0 pad_right], 0, 'post');
end

% Step 3: 截断或补齐，确保尺寸正确
img = img(1:240, 1:320);

% === 展示预览图像（可选）===
figure;
imshow(img, []);
title("即将上传的图像（320×240）");

% === 数据打包为行优先向量 ===
img = uint8(img);
img_data = reshape(img', 1, []);  % 行优先展开

% === 初始化串口 ===
s = serialport(port, baud);
configureTerminator(s, "LF");
flush(s);
pause(0.5);  % 等待串口稳定

% === 开始上传 ===
disp("⚡ 开始传输图像...");
tic;

chunk_size = 256;
total_bytes = length(img_data);
sent_bytes = 0;
h = waitbar(0, "上传中...");

while sent_bytes < total_bytes
    to_send = min(chunk_size, total_bytes - sent_bytes);
    write(s, img_data(sent_bytes+1 : sent_bytes+to_send), "uint8");
    sent_bytes = sent_bytes + to_send;

    % 更新进度条
    waitbar(sent_bytes / total_bytes, h, ...
        sprintf("已发送 %d / %d 字节", sent_bytes, total_bytes));
end

close(h);
elapsed = toc;
fprintf("✅ 图像上传完成，用时 %.2f 秒。\n", elapsed);

% === 清理串口资源 ===
clear s;
