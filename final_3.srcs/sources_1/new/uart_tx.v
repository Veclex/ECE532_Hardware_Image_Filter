module uart_tx #(
    parameter CLK_FREQ  = 100_000_000,  // FPGA��Ƶ
    parameter BAUD_RATE = 115200        // ������
)(
    input  wire clk,
    input  wire rst,

    input  wire [7:0] tx_data,     // Ҫ���͵�����
    input  wire       tx_valid,    // ���������źţ�1��ʱ�����ڣ�

    output reg        tx,          // �������
    output reg        tx_ready     // ���б�־���ߵ�ƽ��ʾ�ɽ���������
);

    localparam BIT_CNT = CLK_FREQ / BAUD_RATE;

    reg [3:0]  bit_index;
    reg [9:0]  tx_shift;       // ֡�Ĵ�������ʼ + 8���� + ֹͣ
    reg [15:0] clk_cnt;
    reg        busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx        <= 1'b1;
            tx_ready  <= 1'b1;
            busy      <= 0;
            clk_cnt   <= 0;
            bit_index <= 0;
            tx_shift  <= 10'b1111111111;
        end else begin
            if (tx_valid && tx_ready) begin
                // �������䣺����֡
                tx_shift  <= {1'b1, tx_data, 1'b0}; // ֹͣλ + ���� + ��ʼλ
                tx_ready  <= 1'b0;
                busy      <= 1;
                clk_cnt   <= 0;
                bit_index <= 0;
            end else if (busy) begin
                if (clk_cnt < BIT_CNT - 1) begin
                    clk_cnt <= clk_cnt + 1;
                end else begin
                    clk_cnt <= 0;
                    tx      <= tx_shift[0];
                    tx_shift <= {1'b1, tx_shift[9:1]};
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        busy <= 0;
                        tx_ready <= 1;
                        tx <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
