//------------------------------------------------------------------------------
//   mode selection:
//     - Test mode: camera in 8 color bar
//     - Sobel filter on/off
//     - Vertical/Horizontal/sobel/median filter
//     - LED13~15 ÏÔÊ¾µ±Ç°ÂË²¨×´Ì¬
//------------------------------------------------------------------------------

module mode_sel
  #(parameter
    c_on = 1'b1
  )
  (
    input        rst,
    input        clk,
    input        btn_in,       // °´¼üÇÐ»»ÂË²¨×´Ì¬
    output reg   filter_on,
    output reg [1:0] vfilter,
    output reg   test_mode,
    output reg [2:0] filter_led  // <-- ÐÂÔöÊä³ö£¬Çý¶¯ LED15~13
  );

  reg [19:0] count_10ms;     // ~10ms debounce
  reg [7:0]  count_2sec;     // ~2.5s ³¤°´¼ì²â
  wire pulse_10ms;
  wire pulse_1sec;
  wire end1sec;

  // === 10ms debounce counter ===
  always @(posedge clk or posedge rst) begin
    if (rst)
      count_10ms <= 20'hF_FFFF;
    else if (btn_in) begin
      if (count_10ms == 0)
        count_10ms <= 20'hF_FFFF;
      else
        count_10ms <= count_10ms - 1;
    end else
      count_10ms <= 20'hF_FFFF;
  end

  assign pulse_10ms = (count_10ms == 0);

  // === 1s ³¤°´¼ì²â ===
  always @(posedge clk or posedge rst) begin
    if (rst)
      count_2sec <= 0;
    else if (btn_in) begin
      if (pulse_10ms) begin
        if (count_2sec == 8'hFF)
          count_2sec <= 0;
        else
          count_2sec <= count_2sec + 1;
      end
    end else
      count_2sec <= 0;
  end

  assign end1sec   = (count_2sec == 8'h7F);
  assign pulse_1sec = (end1sec && pulse_10ms);

  // === ÂË²¨×´Ì¬ÇÐ»»Âß¼­ ===
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      filter_on <= 1'b0;
      vfilter   <= 2'b00;
    end else if (pulse_10ms && count_2sec == 0) begin
      case ({filter_on, vfilter})
        3'b0_00: begin  // No filter ¡ú Sobel H
          filter_on <= 1'b1;
          vfilter   <= 2'b00;
        end
        3'b1_00: begin  // Sobel H ¡ú Sobel V
          filter_on <= 1'b1;
          vfilter   <= 2'b01;
        end
        3'b1_01: begin  // Sobel V ¡ú Edge
          filter_on <= 1'b1;
          vfilter   <= 2'b10;
        end
        3'b1_10: begin  // Edge ¡ú Median
          filter_on <= 1'b1;
          vfilter   <= 2'b11;
        end
        default: begin  // Median ¡ú No filter
          filter_on <= 1'b0;
          vfilter   <= 2'b00;
        end
      endcase
    end
  end

  // === Êä³ö LED ×´Ì¬ ===
  always @(*) begin
    if (filter_on == 1'b0)
      filter_led = 3'b000;             // NO FILTER
    else begin
      case (vfilter)
        2'b00: filter_led = 3'b001;    // SOBEL H
        2'b01: filter_led = 3'b010;    // SOBEL V
        2'b10: filter_led = 3'b011;    // EDGE
        2'b11: filter_led = 3'b100;    // MEDIAN
        default: filter_led = 3'b000;
      endcase
    end
  end

  // === ³¤°´ÇÐ»» test_mode ===
  always @(posedge clk or posedge rst) begin
    if (rst)
      test_mode <= 1'b0;
    else if (pulse_1sec)
      test_mode <= ~test_mode;
  end

endmodule
