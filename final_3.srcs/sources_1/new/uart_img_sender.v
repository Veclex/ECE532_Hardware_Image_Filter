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

    // ���ͼ��256x256���� 65536 ����
    localparam IMG_WIDTH      = 256;
    localparam IMG_HEIGHT     = 256;
    localparam ORIGINAL_WIDTH = 320;

    // ͼ����ʼ�У����Ĳü���
    localparam COL_OFFSET = (ORIGINAL_WIDTH - IMG_WIDTH) / 2;

    // FSM ״̬����
    localparam IDLE  = 2'd0;
    localparam READ  = 2'd1;
    localparam SEND  = 2'd2;
    localparam DONE  = 2'd3;

    reg [1:0] state, next_state;

    // �������
    reg [8:0] col;  // ��� 255
    reg [8:0] row;

    // FSM ״̬ת��
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

    // ���������
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
            // Ĭ��
            uart_valid  <= 0;
            frame_rd_en <= 0;
            send_done   <= 0;

            case (state)
                IDLE: begin
                    col <= 0;
                    row <= 0;
                end
                READ: begin
                    if (row < 240) begin  // ����ʵͼ������
                        frame_addr  <= (row * ORIGINAL_WIDTH) + (col + COL_OFFSET);
                        frame_rd_en <= 1;
                    end
                end
                SEND: begin
                    if (uart_ready) begin
                        if (row < 240)
                            uart_data <= pixel_data;
                        else
                            uart_data <= 8'd0;  // ���ɫ

                        uart_valid <= 1;

                        // �е���
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
