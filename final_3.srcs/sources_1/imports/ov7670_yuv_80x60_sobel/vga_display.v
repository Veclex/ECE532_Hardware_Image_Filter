//   vga_display.vhd
//   Displays the image on the frambuffer to the VGA
//

module vga_display
  # (parameter
      // VGA
      //c_img_cols    = 640, // 10 bits
      //c_img_rows    = 480, //  9 bits
      //c_img_pxls    = c_img_cols * c_img_rows,
      //c_nb_line_pxls = 10, // log2i(c_img_cols-1) + 1;
      // c_nb_img_pxls = log2i(c_img_pxls-1) + 1
      //c_nb_img_pxls =  19,  //640*480=307,200 -> 2^19=524,288
      // QQVGA
      //c_img_cols    = 160, // 8 bits
      //c_img_rows    = 120, //  7 bits
      //c_img_pxls    = c_img_cols * c_img_rows,
      //c_nb_img_pxls =  15,  //160*120=19.200 -> 2^15
      // 320*240
      c_img_cols    = 320, // 9 bits
      c_img_rows    = 240, //  8 bits
      c_img_pxls    = c_img_cols * c_img_rows,
      c_nb_img_pxls =  17,  



    c_nb_buf_red   =  4,  // n bits for red in the buffer (memory)
    c_nb_buf_green =  4,  // n bits for green in the buffer (memory)
    c_nb_buf_blue  =  4,  // n bits for blue in the buffer (memory)
    // word width of the memory (buffer)
    c_nb_buf       =   c_nb_buf_red + c_nb_buf_green + c_nb_buf_blue
  )
  (
    input          rst,       //reset, active high
    input          clk,       //fpga cloc
    input          visible,
    input          new_pxl,
    input          hsync,
    input          vsync,
    input          rgbmode,
    input [10-1:0] col,
    input [10-1:0] row,
    input  [c_nb_buf-1:0] frame_pixel,
    output reg [c_nb_img_pxls-1:0] frame_addr,
    output reg [4-1:0] vga_red,
    output reg [4-1:0] vga_green,
    output reg [4-1:0] vga_blue,
    input vga_en  // 新增：允许 VGA 读取和地址更新
  );


  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      frame_addr <= 0;
    else begin
      if (row < c_img_rows) begin
        if (col < c_img_cols) begin
          if (new_pxl && vga_en)
            //it may have a simulation problem in the last pixel of the last row
            frame_addr <= frame_addr + 1;
        end
      end
      else
        frame_addr <= 0;
    end
  end


  always @ (*)
  begin
    vga_red   = 0;
    vga_green = 0;
    vga_blue  = 0;
    if (visible) begin
      vga_red   = {4{1'b0}};
      vga_green = {4{1'b0}};
      vga_blue  = {4{1'b0}};
      if ((col < c_img_cols) && (row < c_img_rows)) begin
          if (rgbmode) begin
            vga_red   = frame_pixel[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
            vga_green = frame_pixel[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
            vga_blue  = frame_pixel[c_nb_buf_blue-1:0];
          end
          else begin
            vga_red   = frame_pixel[7:4];
            vga_green = frame_pixel[7:4];
            vga_blue  = frame_pixel[7:4];
          end
      end
      else if (row > 256 && row < 384 && col < 512) begin
         vga_red   = {col[8:7],2'b00};
         vga_green = {col[6:5],2'b00};
         vga_blue  = {row[6:5],2'b00};
      end
      else if ((col == c_img_cols) || (row == c_img_rows)) begin
         vga_red   = 4'b0000;
         vga_green = 4'b1000;
         vga_blue  = 4'b1000;
      end
      else if ((col == 2*c_img_cols) || (row == 2*c_img_rows)) begin
         vga_red   = 4'b1000;
         vga_green = 4'b1000;
         vga_blue  = 4'b0000;
      end
      else if ((col == 4*c_img_cols) || (row == 4*c_img_rows)) begin
         vga_red   = 4'b1000;
         vga_green = 4'b0000;
         vga_blue  = 4'b1000;
      end
    end
  end

endmodule
