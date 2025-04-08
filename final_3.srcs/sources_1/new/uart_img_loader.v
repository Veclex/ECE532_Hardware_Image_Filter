module uart_img_loader #(
    parameter IMG_SIZE = 76800  // For 320x240 image
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        uart_valid,    // 1 when a new byte is available
    input  wire [7:0]  uart_data,     // The received byte

    output reg  [16:0] frame_addr,    // Address to write into I_cam_fb
    output reg  [7:0]  frame_data,    // Pixel data to write
    output reg         frame_we,      // Write enable to I_cam_fb
    output reg         recv_done      // 1 when all image data is received
);

    localparam IDLE = 2'd0;
    localparam RECV = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state, next_state;
    reg [16:0] pixel_cnt;

    // FSM: State transition
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM: Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (uart_valid) next_state = RECV;
            RECV: if (pixel_cnt == IMG_SIZE - 1 && uart_valid) next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    // FSM: Output and control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            frame_addr <= 0;
            frame_data <= 0;
            frame_we   <= 0;
            recv_done  <= 0;
            pixel_cnt  <= 0;
        end else begin
            frame_we   <= 0;
            recv_done  <= 0;

            case (state)
                IDLE: begin
                    frame_addr <= 0;
                    pixel_cnt  <= 0;
                end
                RECV: begin
                    if (uart_valid) begin
                        frame_data <= uart_data;
                        frame_addr <= pixel_cnt;
                        frame_we   <= 1;
                        pixel_cnt  <= pixel_cnt + 1;
                    end
                end
                DONE: begin
                    recv_done <= 1;
                end
            endcase
        end
    end

endmodule
