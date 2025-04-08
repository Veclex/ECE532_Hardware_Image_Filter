module uart_rx #(
    parameter CLK_FREQ = 100_000_000,   // FPGA Ö÷Æµ Hz
    parameter BAUD_RATE = 115200        // UART ²¨ÌØÂÊ
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,

    output reg  [7:0] rx_data,
    output reg        rx_valid
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CTR_WIDTH = $clog2(CLKS_PER_BIT);

    localparam IDLE  = 3'd0,
               START = 3'd1,
               DATA  = 3'd2,
               STOP  = 3'd3,
               DONE  = 3'd4;

    reg [2:0] state = IDLE;
    reg [CTR_WIDTH-1:0] clk_cnt = 0;
    reg [2:0] bit_idx = 0;
    reg [7:0] rx_shift = 0;
    reg       rx_sync1 = 1, rx_sync2 = 1;

    always @(posedge clk) begin
        if (rst) begin
            rx_sync1 <= 1;
            rx_sync2 <= 1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    wire rx_sample = rx_sync2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            rx_shift  <= 0;
            rx_valid  <= 0;
            rx_data   <= 0;
        end else begin
            rx_valid <= 0;
            case (state)
                IDLE: begin
                    if (~rx_sample) begin // start bit detected
                        state   <= START;
                        clk_cnt <= CLKS_PER_BIT >> 1; // sample in middle
                    end
                end
                START: begin
                    if (clk_cnt == 0) begin
                        state   <= DATA;
                        clk_cnt <= CLKS_PER_BIT - 1;
                        bit_idx <= 0;
                    end else begin
                        clk_cnt <= clk_cnt - 1;
                    end
                end
                DATA: begin
                    if (clk_cnt == 0) begin
                        rx_shift[bit_idx] <= rx_sample;
                        if (bit_idx == 7) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                        clk_cnt <= CLKS_PER_BIT - 1;
                    end else begin
                        clk_cnt <= clk_cnt - 1;
                    end
                end
                STOP: begin
                    if (clk_cnt == 0) begin
                        state    <= DONE;
                        rx_data  <= rx_shift;
                        rx_valid <= 1;
                    end else begin
                        clk_cnt <= clk_cnt - 1;
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
