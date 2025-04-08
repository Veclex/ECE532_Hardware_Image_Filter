module uart_img_sender(
    input  wire        clk,
    input  wire        rst,
    input  wire        start_send,
    input  wire [7:0]  pixel_data,
    input  wire        uart_ready,

    output reg  [16:0] frame_addr,
    output reg         frame_rd_en,

    output reg  [7:0]  uart_data,
    output reg         uart_valid,
    output reg         send_done
);

    // 输出图像：256x256，总 65536 像素
    localparam IMG_WIDTH      = 256;
    localparam IMG_HEIGHT     = 256;
    localparam ORIGINAL_WIDTH = 320;

    // 图像起始列（中心裁剪）
    localparam COL_OFFSET = (ORIGINAL_WIDTH - IMG_WIDTH) / 2;

    // FSM 状态定义
    localparam IDLE  = 2'd0;
    localparam READ  = 2'd1;
    localparam SEND  = 2'd2;
    localparam DONE  = 2'd3;

    reg [1:0] state, next_state;

    // 坐标计数
    reg [8:0] col;  // 最大到 255
    reg [8:0] row;

    // FSM 状态转移
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:  if (start_send) next_state = READ;
            READ:  next_state = SEND;
            SEND: begin
                if (row == IMG_HEIGHT && uart_ready)
                    next_state = DONE;
                else if (uart_ready)
                    next_state = READ;
            end
            DONE:  next_state = IDLE;
        endcase
    end

    // 控制与输出
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            col         <= 0;
            row         <= 0;
            frame_addr  <= 0;
            uart_data   <= 0;
            uart_valid  <= 0;
            frame_rd_en <= 0;
            send_done   <= 0;
        end else begin
            // 默认
            uart_valid  <= 0;
            frame_rd_en <= 0;
            send_done   <= 0;

            case (state)
                IDLE: begin
                    col <= 0;
                    row <= 0;
                end
                READ: begin
                    if (row < 240) begin  // 有真实图像数据
                        frame_addr  <= (row * ORIGINAL_WIDTH) + (col + COL_OFFSET);
                        frame_rd_en <= 1;
                    end
                end
                SEND: begin
                    if (uart_ready) begin
                        if (row < 240)
                            uart_data <= pixel_data;
                        else
                            uart_data <= 8'd0;  // 填黑色

                        uart_valid <= 1;

                        // 列递增
                        if (col == IMG_WIDTH - 1) begin
                            col <= 0;
                            row <= row + 1;
                        end else begin
                            col <= col + 1;
                        end
                    end
                end
                DONE: begin
                    send_done <= 1;
                end
            endcase
        end
    end

endmodule
