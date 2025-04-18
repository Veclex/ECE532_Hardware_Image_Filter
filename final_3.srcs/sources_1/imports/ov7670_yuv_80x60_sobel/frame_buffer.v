module frame_buffer
  #(parameter
    // VGA
    //c_img_cols    = 640, // 10 bits
    //c_img_rows    = 480, //  9 bits
    // QQVGA
    //c_img_cols    = 160, // 8 bits
    //c_img_rows    = 120, //  7 bits
    //c_img_pxls    = c_img_cols * c_img_rows,
    // c_nb_img_pxls = log2i(c_img_pxls-1) + 1
    // VGA
    //c_nb_img_pxls =  19,  //640*480=307,200 -> 2^19=524,288
    // QQVGA
    //c_nb_img_pxls =  15,  //160*120=19.200 -> 2^15
    // QQVGA /2
    c_img_cols    = 320, // 7 bits
    c_img_rows    = 240, //  6 bits
    c_img_pxls    = c_img_cols * c_img_rows,
    c_nb_img_pxls =  17,  //80*60=4800 -> 2^13

    // word width of the memory (buffer)
    c_nb_buf       =  8  // n bits for gray level 
  )
  (
   input                          clk,
   input                          wea,
   input      [c_nb_img_pxls-1:0] addra,
   input      [c_nb_buf-1:0]             dina,
   input      [c_nb_img_pxls-1:0] addrb,
   output reg [c_nb_buf-1:0]             doutb
   );

  reg  [c_nb_buf-1:0] ram[c_img_pxls-1:0];

  always @ (posedge clk)
  begin
    if (wea)
        ram[addra] <= dina;
    doutb <= ram[addrb];
  end

endmodule

