// Final top_ov7670_nexys.v with UART TX and RX, sw15=1 for photo, sw14=1 for UART input

module top_ov7670_nexys
  # (parameter
      c_img_cols    = 320,
      c_img_rows    = 240,
      c_img_pxls    = c_img_cols * c_img_rows,
      c_nb_img_pxls = 17,
      c_nb_buf_rgb  = 12,
      c_nb_buf      = 8
    )
    (input        rst,
     input        clk,
     input        sw0_sel7bits,
     input        sw14,            // NEW: UART input enable
     input        sw15,            // Mode select: 0 = VGA, 1 = Photo
     input        btnr,
     input        rx,
     output       ov7670_sioc,
     output       ov7670_siod,
     output       ov7670_rst_n,
     input        ov7670_vsync,
     input        ov7670_href,
     input        ov7670_pclk,
     output       ov7670_xclk,
     output       ov7670_pwdn,
     input  [4:0] ov7670_d_msb,
     input  [2:0] ov7670_d_in,
     output [10:0] led,
     input        proc_ctrl,
     output [3:0] vga_red_out,
     output [3:0] vga_green_out,
     output [3:0] vga_blue_out,
     output       vga_hsync,
     output       vga_vsync,
     output       tx
    );

    wire [7:0] ov7670_d = {ov7670_d_msb, (sw0_sel7bits ? ov7670_d_in : 3'b011)};
    wire [3:0] vga_red, vga_green, vga_blue;
    wire vga_visible, vga_new_pxl;
    wire [9:0] vga_col, vga_row;

    wire [c_nb_img_pxls-1:0] display_img_addr, capture_addr, orig_img_addr, proc_img_addr;
    wire [c_nb_buf-1:0] display_img_pxl, capture_data, orig_img_pxl, proc_img_pxl;
    wire [c_nb_buf+4-1:0] display_img_pxl_12 = {4'b0, display_img_pxl};
    wire [c_nb_buf_rgb-1:0] capture_data_12;
    wire capture_we, proc_we, config_finished, sdat_on, sdat_out;
    wire clk100mhz = clk;

    assign rgbmode = 1'b0;
    assign resend = 1'b0;
    assign ov7670_pwdn = 1'b0;
    assign ov7670_siod = sdat_on ? sdat_out : 1'bz;

    assign vga_red_out[3:2]   = vga_red[3:2];
    assign vga_green_out[3:2] = vga_green[3:2];
    assign vga_blue_out[3:2]  = vga_blue[3:2];
    assign vga_red_out[1:0]   = sw0_sel7bits ? vga_red[1:0]   : 2'b00;
    assign vga_green_out[1:0] = sw0_sel7bits ? vga_green[1:0] : 2'b00;
    assign vga_blue_out[1:0]  = sw0_sel7bits ? vga_blue[1:0]  : 2'b00;

    wire filter_on, test_mode;
    wire [1:0] vfilter;

    reg btnr_prev;
    always @(posedge clk100mhz) btnr_prev <= btnr;
    wire btnr_rise = ~btnr_prev & btnr;

    wire vga_en = (sw15 == 1'b0);
    wire start_send = (sw15 == 1'b1) && btnr_rise;

    wire [16:0] uart_frame_addr;
    wire        uart_rd_en;
    wire        uart_valid;
    wire [7:0]  uart_data;
    wire        send_done;
    wire        uart_ready;

    wire [7:0] uart_rx_data;
    wire       uart_rx_valid;

    wire [16:0] uart_wr_addr;
    wire [7:0]  uart_wr_data;
    wire        uart_wr_en;
    wire        uart_recv_done;

    uart_img_sender uart_sender (
      .clk(clk100mhz), .rst(rst), .start_send(start_send),
      .pixel_data(display_img_pxl), .uart_ready(uart_ready),
      .frame_addr(uart_frame_addr), .frame_rd_en(uart_rd_en),
      .uart_data(uart_data), .uart_valid(uart_valid),
      .send_done(send_done)
    );

    uart_tx #( .CLK_FREQ(100_000_000), .BAUD_RATE(115200) ) uart_tx_inst (
      .clk(clk100mhz), .rst(rst), .tx_data(uart_data),
      .tx_valid(uart_valid), .tx(tx), .tx_ready(uart_ready)
    );

    uart_rx #( .CLK_FREQ(100_000_000), .BAUD_RATE(115200) ) uart_rx_inst (
      .clk(clk100mhz), .rst(rst), .rx(rx),
      .rx_data(uart_rx_data), .rx_valid(uart_rx_valid)
    );

    uart_img_loader uart_loader (
      .clk(clk100mhz), .rst(rst),
      .uart_valid(uart_rx_valid), .uart_data(uart_rx_data),
      .frame_addr(uart_wr_addr), .frame_data(uart_wr_data),
      .frame_we(uart_wr_en), .recv_done(uart_recv_done)
    );
    
    wire [2:0] filter_led;
    mode_sel I_mode_sel (
      .rst(rst), .clk(clk100mhz), .btn_in(proc_ctrl),
      .filter_on(filter_on), .vfilter(vfilter), .test_mode(test_mode), .filter_led(filter_led)
    );
    assign led[10:8] = filter_led;  // 显示在 LED13~15

    vga_sync I_vga (
      .rst(rst), .clk(clk100mhz),
      .visible(vga_visible), .new_pxl(vga_new_pxl),
      .hsync(vga_hsync), .vsync(vga_vsync),
      .col(vga_col), .row(vga_row)
    );

    vga_display I_ov_display (
      .rst(rst), .clk(clk100mhz),
      .visible(vga_visible), .new_pxl(vga_new_pxl),
      .hsync(vga_hsync), .vsync(vga_vsync),
      .rgbmode(rgbmode), .col(vga_col), .row(vga_row),
      .frame_pixel(display_img_pxl_12), .frame_addr(display_img_addr),
      .vga_red(vga_red), .vga_green(vga_green), .vga_blue(vga_blue),
      .vga_en(vga_en)
    );

    // 摄像头输入 vs UART 输入
    wire cam_we      = (~sw14) & capture_we;
    wire [16:0] cam_addr  = capture_addr;
    wire [7:0]  cam_data  = capture_data;

    wire uart_we     = sw14 & uart_wr_en;
    wire [16:0] uart_addr = uart_wr_addr;
    wire [7:0]  uart_data_in = uart_wr_data;

    wire [16:0] camfb_wr_addr = sw14 ? uart_addr : cam_addr;
    wire [7:0]  camfb_wr_data = sw14 ? uart_data_in : cam_data;
    wire        camfb_we      = sw14 ? uart_we : cam_we;

    frame_buffer I_cam_fb (
      .clk(clk100mhz), .wea(camfb_we),
      .addra(camfb_wr_addr), .dina(camfb_wr_data),
      .addrb(orig_img_addr), .doutb(orig_img_pxl)
    );

    edge_proc I_edge_proc (
      .rst(rst), .clk(clk100mhz), .filter_on(filter_on), .vfilter(vfilter),
      .orig_pxl(orig_img_pxl), .orig_addr(orig_img_addr),
      .proc_we(proc_we), .proc_pxl(proc_img_pxl), .proc_addr(proc_img_addr)
    );

    wire [c_nb_img_pxls-1:0] fb_read_addr = (sw15 == 1'b1) ? uart_frame_addr : display_img_addr;
    wire fb_read_en = (sw15 == 1'b1) ? uart_rd_en : vga_en;

    frame_buffer I_fb_proc (
      .clk(clk100mhz), .wea(proc_we),
      .addra(proc_img_addr), .dina(proc_img_pxl),
      .addrb(fb_read_addr), .doutb(display_img_pxl)
    );

    ov7670_capture I_capture_yuv (
      .rst(rst), .clk(clk100mhz),
      .pclk(ov7670_pclk), .vsync(ov7670_vsync), .href(ov7670_href),
      .rgbmode(rgbmode), .data(ov7670_d),
      .addr(capture_addr), .dout(capture_data_12), .we(capture_we)
    );

    assign capture_data = capture_data_12[7:0];

    ov7670_top_ctrl I_controller (
      .rst(rst), .clk(clk100mhz), .test_mode(test_mode), .resend(resend),
      .cnt_reg_test(led[5:0]), .done(config_finished),
      .sclk(ov7670_sioc), .sdat_on(sdat_on), .sdat_out(sdat_out),
      .ov7670_rst_n(ov7670_rst_n), .ov7670_clk(ov7670_xclk),
      .ov7670_pwdn(ov7670_pwdn)
    );

    assign led[7] = config_finished;
    assign led[6] = sw15;  // LED6: photo mode indicator

endmodule