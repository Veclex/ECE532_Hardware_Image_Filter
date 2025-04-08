module median_3x3 (
    input  wire        clk,
    input  wire [7:0] p00, p01, p02,
    input  wire [7:0] p10, p11, p12,
    input  wire [7:0] p20, p21, p22,
    output wire [7:0] median
);

    wire [7:0] pix[8:0];

    assign pix[0] = p00;
    assign pix[1] = p01;
    assign pix[2] = p02;
    assign pix[3] = p10;
    assign pix[4] = p11;
    assign pix[5] = p12;
    assign pix[6] = p20;
    assign pix[7] = p21;
    assign pix[8] = p22;

    // Sorting array
    reg [7:0] sorted[8:0];
    integer i, j;
    always @(*) begin
        for (i = 0; i < 9; i = i + 1) begin
            sorted[i] = pix[i];
        end
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8 - i; j = j + 1) begin
                if (sorted[j] > sorted[j+1]) begin
                    {sorted[j], sorted[j+1]} = {sorted[j+1], sorted[j]};
                end
            end
        end
    end

    // One clock delayed output
    reg [7:0] median_reg;
    assign median = median_reg;

    always @(posedge clk) begin
        median_reg <= sorted[4];
    end

endmodule
