module ov7670_ctrl_reg
  (
    input         rst,          //reset, active high
    input         clk,          //fpga clock
    input         test_mode,    //if '1': in test mode (8 color test bar)
    input         resend,       //resend all the sequence
    input         sccb_ready,   //SCCB ready to transmit
    output [5:0]  cnt_reg_test, //to test the count
    output        start_tx,     //start transmission
    output        done,         //all the registers written
    output [6:0]  id,           //id of the slave
    output [7:0]  addr,         //address to be written
    output [7:0]  data_wr,      //data to write to slave
    output        ov7670_rst_n, //camera reset
    output        ov7670_clk,   //camera system clock
    output        ov7670_pwdn   //camera power down
  );



  // frequency divider for camera clk (divide by 4) 
  //signal cnt_cam_clk : unsigned (1 downto 0);
  // frequency divider for camera clk (divide by 8) 
  reg  [2:0]   cnt_cam_clk;

  // 6 bits: less than 64 registers to be written, change if the number
  // of registers to be written change
  reg  [5:0]   cnt_reg;

  // auxiliary signal, connected to output port done
  wire         alltx_done;

  // auxiliary signal connected to output port ov7670_rst_n
  reg          cam_rst_n;

  // auxiliary signal, connected to start_tx
  reg          start_tx_aux;

  reg [25-1:0] cnt300ms;
  wire         end300ms;
  reg          ena_cnt300ms;
  parameter    c_end300ms = 30000000;
  //parameter    c_end300ms = 30;



  //id of the slave; 0x21.
  // if adding the write bit, would be 0x42 for writing and 0x43 for reading
  parameter c_id_write  = 7'b0100_001;
  wire  [7:0]   addr_aux; //address to be written
  //wire  [7:0]   data_aux; //data to write to slave
  // register from the register memory: address & data
  reg  [15:0]   reg_i;

  parameter RSTCAM_ST      = 0,  // Reset camera during 300ms
            WAIT_RSTCAM_ST = 1,  // Wait 300ms for the camera to be ready
            WAIT_ST        = 2,  // waiting to send, until not busy
            WRITE_REG_ST   = 3,  // sending the initial sequence
            DONE_ST        = 4;  // all the registers written

  // present state, next state
  reg  [2:0]  pr_ctrl_st, nx_ctrl_st;  // present state, next state


  // save the switch values to see if the have changed
  reg       test_mode_rg;
  wire      test_mode_change;

  reg [15:0] reg_yuv422, reg_yuv422_test;

  // msb 8 bits are the address (15 downto 8)
  // lsb 8 bits are the register value to be written

  assign cnt_reg_test = cnt_reg;

  always @ (cnt_reg) begin
    // *IG means Implementation guide
    case (cnt_reg)
      6'h00:
        reg_yuv422_test <= 16'h1280;
               // 12: COM7 Common Control 7
               // [7]=1: Reset all registers to default values
      6'h01:
        reg_yuv422_test <= 16'h1280;
               // 12: COM7 Common Control 7
               // [7]=1: Reset all registers to default values
      6'h02:
        reg_yuv422_test <= 16'h1200;
               // 12: COM7 Common Control 7
               // [2,0]= 00 : Output format YUV 
      6'h03:
        reg_yuv422_test <= 16'h0901; //works much better with 00
               // 09:COM2 Common Control 2. Default: 01 
               // [7:5] : Reserved
               // [4]   : Soft sleep mode
               // [3:2] : Reserved
               // [1:0] : output drive capability, to increase IOL/OH drive
               //   00: 1x
               //   01: 2x
               //   10: 3x
               //   11: 4x
      6'h04:
        reg_yuv422_test <= 16'h40C0;
               // 40: COM15 Full 0-255 output, RGB 444
               // [7:6] = 11 : Full output range
               // [5:4] = x0 : Normal RGB output and YUV
               // [5:4] = 11: RGB 55 only if RGB444 is low
               // [3:0] = 0:  Reserved 
      6'h05:
        reg_yuv422_test <= 16'h8C00;
               // 8C: RGB444
               // [7:2]=0: Reserved
               // [1]=1: Enable RGB444
               // [0]=0: word format: xR GB
      6'h06:
        reg_yuv422_test <= 16'h1180;
               // 11: CLKRC Internal Clock
               // [7]=1: Reserved  **IG says 0, but 1 seems stable
               // [6]=0: Use pre-scale
               // [5:0]: Interal clock pre-scalar
               //    F(internal clk) = F(input clk)/([5:0]+1)
               // [5:0]= 0: No prescale (internal clk)

      6'h07:
        //reg_yuv422_test <= 16'h0F43; // 0F: COM6 Common Control 6
        reg_yuv422_test <= 16'h0F4B;  //** check 0F4B
               // 0F: COM6 Common Control 6
               // [7]=0: Disable HREF at optical blank
               // [1]=1: Resets timming when format changes
               // others reserved
               // [3] = 1 (reserved) hamster

      // check
      6'h08:
        reg_yuv422_test <= 16'h1E37;
             // MVFP Mirror/flip enable. Default 00
             // [7:6]= 00 : reserved
             // [5]= 1 : Mirror image
             // [4]= 1 : Flip image
             // [3] : Reserved
             // [2] : Black Sun Enable
             // [1:0] : Reserved

      // check

      // check
      6'h09:
        reg_yuv422_test <= 16'h3DC0; // COM13: default 88
              // [7]=1 : Gamma enable (defaul)
              // [6]=1 : UV Saturation Level - UV autoadjustment
              // [5:1]: Reserved
              // [0]: UV swap

      // ---------

      6'h0A:
        reg_yuv422_test <= 16'h1520; // 15: COM10 Common Control 10
                             // [7]=0: Reserved
                             // [6]=0: Use HREF not HSYNC
                             // [5]=1: PCLK doesnt toggle during horizontl blank
                             // others default
      6'h0B:
        reg_yuv422_test <= 16'h1711; // HSTART HREF start high 8-bit.
              // The first pixels flicker
              // 1700; // HSTART HREF start high 8-bit.
              // For windowing. Dont want to do
      6'h0C:
        reg_yuv422_test <= 16'h1800; // HSTOP HREF end high 8-bit.
             // For windowing. Dont want to do
      6'h0D:
        reg_yuv422_test <= 16'h1900; // VSTRT VREF start high 8-bit.
             // For windowing. Dont want to do
      6'h0E:
        reg_yuv422_test <= 16'h1A00; // VSTOP VREF end high 8-bit.
             // For windowing. Dont want to do
      6'h0F:
        reg_yuv422_test <= 16'h3200; // HREF Control
             // [7:6] : HREF edge offset to data ouput
             // [5:3] : HREF end LSB (high 8MSB at HSTOP)
             // [2:0] : HREF start LSB (high 8MSB at HSTART

      6'h10:
        reg_yuv422_test <= 16'h3A04; // TLSB: Line buffer test option
             // (default 0C (1100) implementation guide -0D in datasheet)
             // [7:6] : reserved
             // [5]   : negative image enable
             // [5]=0 : Normal image 
             // [4]=0 : Use normal UV output
             // [3]   : Output sequence with COM13[1]
             //      TSLB[3], COM13[1]:
             //    00: Y U Y V
             //    01: Y U Y V
             //    10: U Y V Y
             //    11: V Y U Y
             // [2:1] : Reserved
             // [0]   : Auto output window
             //     0: Sensor does not automatically set window after
             //        resolution change



      // -- QVGA2
      6'h11:
        reg_yuv422_test <= 16'h0C04; // 0C: COM3 Common Control 3
                             // [3]=1: Enable scale (for QQVGA/2)
                             // [2]=0: Disable DCW
                             // others default
      6'h12:
        reg_yuv422_test <= 16'h3E19; // 3E: COM14 Common Control 14
                             //    Scaling can be adjusted manually
                             // [7:5]: Reserved
                             // [4]=1: Scaling PCLK and DCW enabled
                             //        Controlled by [2:0] and SCALING_PCLK_DIV
                             // [3]=1: Manual scaling enabled for predefined
                             //        modes such QVGA
                             // [2:0] PCLK divided when COM14[4]=1
                             // [2:0]=011: Divided by 8-> QQVGA/2: 80x60
      6'h13:
        reg_yuv422_test <= 16'h703A; // 70: SCALING_XSC
                             // [7]: test_pattern[0], works with test_pattern[1]
                             //  00: No test output                            
                             //  01: Shifting "1"
                             //  10: 8-bar color bar
                             //  11: Fade to gray color bar
                             // [7]= 0 -> 8-bar color bar (test_pattern[1]=1)
                             // [6:0]: default horizontal scale factor
      6'h14:
        reg_yuv422_test <= 16'h71B5; // 71: SCALING_YSC
                             // [7]: test_pattern[1], works with test_pattern[0]
                             //  00: No test output                            
                             //  01: Shifting "1"
                             //  10: 8-bar color bar
                             //  11: Fade to gray color bar
                             // [7]= 1 -> 8-bar color bar (test_pattern[0]=0)
                             // [6:0]: default vertical scale factor
      6'h15:
        reg_yuv422_test <= 16'h7211; // 72: SCALING_DCWCTR DCW Control
                             // [7]=0: Vertical average calc truncation(default)
                             // [6]=0: Vertical truncation downsampling(default)
                             // [5:4]: Vertical down sampling rate
                             // [5:4]=11: Vertical down sampling by 8->QQVGA/2
                             // [3]=0: Horztal average calc truncation(default)
                             // [2]=0: Horztal truncation downsampling(default)
                             // [1:0]: Horztal down sampling rate
                             // [1:0]=11: Horztal down sampling by 8->QQVGA/2
      6'h16:
        reg_yuv422_test <= 16'h73F1; // 73: SCALING_PCLK_DIV
                             // [7:4]=F: Reserved, and manual says default is 0
                             //          but IG says F
                             // [3]=0: Enable clk divider for DSP scale control
                             // [2:0]=011: Divided by 8 -> QQVGA/2
      6'h17:
        reg_yuv422_test <= 16'hA202; // A2: SCALING_PCLK_DELAY Pixel Clock Delay
                             // [7]: Reserved
                             // [6:0]=02: Default scaling ouput delay
      //  end QQVGA
      6'h18:
        reg_yuv422_test <= 16'hFFFF;  // FINISH CONDITION, register FF doesnt exist
      default:
        reg_yuv422_test <= 16'hFFFF;  // FINISH CONDITION
    endcase
  end





  always @ (cnt_reg) begin
    // *IG means Implementation guide
    case (cnt_reg)
      6'h00:
        reg_yuv422 <= 16'h1280;
               // 12: COM7 Common Control 7
               // [7]=1: Reset all registers to default values
      6'h01:
        reg_yuv422 <= 16'h1280;
               // 12: COM7 Common Control 7
               // [7]=1: Reset all registers to default values
      6'h02:
        reg_yuv422 <= 16'h1200;
               // 12: COM7 Common Control 7
               // [2,0]= 00 : Output format YUV 
      6'h03:
        reg_yuv422 <= 16'h0901;  //works much better with 00
               // 09:COM2 Common Control 2. Default: 01 
               // [7:5] : Reserved
               // [4]   : Soft sleep mode
               // [3:2] : Reserved
               // [1:0] : output drive capability, to increase IOL/OH drive
               //   00: 1x
               //   01: 2x
               //   10: 3x
               //   11: 4x
      6'h04:
        reg_yuv422 <= 16'h40C0;
               // 40: COM15 Full 0-255 output, RGB 444
               // [7:6] = 11 : Full output range
               // [5:4] = x0 : Normal RGB output and YUV
               // [5:4] = 11: RGB 55 only if RGB444 is low
               // [3:0] = 0:  Reserved 
      6'h05:
        reg_yuv422 <= 16'h8C00;
               // 8C: RGB444
               // [7:2]=0: Reserved
               // [1]=1: Enable RGB444
               // [0]=0: word format: xR GB
      6'h06:
        reg_yuv422 <= 16'h1180;
               // 11: CLKRC Internal Clock
               // [7]=1: Reserved  **IG says 0, but 1 seems stable
               // [6]=0: Use pre-scale
               // [5:0]: Interal clock pre-scalar
               //    F(internal clk) = F(input clk)/([5:0]+1)
               // [5:0]= 0: No prescale (internal clk)

      6'h07:
        //reg_yuv422 <= 16'h0F43; // 0F: COM6 Common Control 6
        reg_yuv422 <= 16'h0F4B;  //** check 0F4B
               // 0F: COM6 Common Control 6
               // [7]=0: Disable HREF at optical blank
               // [1]=1: Resets timming when format changes
               // others reserved
               // [3] = 1 (reserved) hamster

      6'h08:
        reg_yuv422 <= 16'h1E37;
             // MVFP Mirror/flip enable. Default 00
             // [7:6]= 00 : reserved
             // [5]= 1 : Mirror image
             // [4]= 1 : Flip image
             // [3] : Reserved
             // [2] : Black Sun Enable
             // [1:0] : Reserved

      6'h09:
        reg_yuv422 <= 16'h3DC0; // COM13: default 88
              // [7]=1 : Gamma enable (defaul)
              // [6]=1 : UV Saturation Level - UV autoadjustment
              // [5:1]: Reserved
              // [0]: UV swap


      // ---------

      6'h0A:
        reg_yuv422 <= 16'h1520; // 15: COM10 Common Control 10
                             // [7]=0: Reserved
                             // [6]=0: Use HREF not HSYNC
                             // [5]=1: PCLK doesnt toggle during horizontl blank
                             // others default
      6'h0B:
        reg_yuv422 <= 16'h1711; // HSTART HREF start high 8-bit.
              // The first pixels flicker
              // 1700; // HSTART HREF start high 8-bit.
              // For windowing. Dont want to do
      6'h0C:
        reg_yuv422 <= 16'h1800; // HSTOP HREF end high 8-bit.
             // For windowing. Dont want to do
      6'h0D:
        reg_yuv422 <= 16'h1900; // VSTRT VREF start high 8-bit.
             // For windowing. Dont want to do
      6'h0E:
        reg_yuv422 <= 16'h1A00; // VSTOP VREF end high 8-bit.
             // For windowing. Dont want to do
      6'h0F:
        reg_yuv422 <= 16'h3200; // HREF Control
             // [7:6] : HREF edge offset to data ouput
             // [5:3] : HREF end LSB (high 8MSB at HSTOP)
             // [2:0] : HREF start LSB (high 8MSB at HSTART

      6'h10:
        reg_yuv422 <= 16'h3A04; // TLSB: Line buffer test option
             // (default 0C (1100) implementation guide -0D in datasheet)
             // [7:6] : reserved
             // [5]   : negative image enable
             // [5]=0 : Normal image 
             // [4]=0 : Use normal UV output
             // [3]   : Output sequence with COM13[1]
             //      TSLB[3], COM13[1]:
             //    00: Y U Y V
             //    01: Y U Y V
             //    10: U Y V Y
             //    11: V Y U Y
             // [2:1] : Reserved
             // [0]   : Auto output window
             //     0: Sensor does not automatically set window after
             //        resolution change




      // -- QVGA2
      6'h11:
        reg_yuv422 <= 16'h0C04; // 0C: COM3 Common Control 3
                             // [3]=1: Enable scale (for QQVGA/2)
                             // [2]=0: Disable DCW
                             // others default
      6'h12:
        reg_yuv422 <= 16'h3E19; // 3E: COM14 Common Control 14
                             //    Scaling can be adjusted manually
                             // [7:5]: Reserved
                             // [4]=1: Scaling PCLK and DCW enabled
                             //        Controlled by [2:0] and SCALING_PCLK_DIV
                             // [3]=1: Manual scaling enabled for predefined
                             //        modes such QVGA
                             // [2:0] PCLK divided when COM14[4]=1
                             // [2:0]=011: Divided by 8-> QQVGA/2: 80x60
      6'h13:
        reg_yuv422 <= 16'h703A; // 70: SCALING_XSC
                             // [7]: test_pattern[0], works with test_pattern[1]
                             //  00: No test output <-
                             //  01: Shifting "1"
                             //  10: 8-bar color bar
                             //  11: Fade to gray color bar
                             // [7]= 0 -> 8-bar color bar (test_pattern[1]=1)
                             // [6:0]: default horizontal scale factor
      6'h14:
        reg_yuv422 <= 16'h7135; // 71: SCALING_YSC
                             // [7]: test_pattern[1], works with test_pattern[0]
                             //  00: No test output  <-
                             //  01: Shifting "1"
                             //  10: 8-bar color bar
                             //  11: Fade to gray color bar
                             // [7]= 1 -> 8-bar color bar (test_pattern[0]=0)
                             // [6:0]: default vertical scale factor
      6'h15:
        reg_yuv422 <= 16'h7211; // 72: SCALING_DCWCTR DCW Control
                             // [7]=0: Vertical average calc truncation(default)
                             // [6]=0: Vertical truncation downsampling(default)
                             // [5:4]: Vertical down sampling rate
                             // [5:4]=11: Vertical down sampling by 8->QQVGA/2
                             // [3]=0: Horztal average calc truncation(default)
                             // [2]=0: Horztal truncation downsampling(default)
                             // [1:0]: Horztal down sampling rate
                             // [1:0]=11: Horztal down sampling by 8->QQVGA/2
      6'h16:
        reg_yuv422 <= 16'h73F1; // 73: SCALING_PCLK_DIV
                             // [7:4]=F: Reserved, and manual says default is 0
                             //          but IG says F
                             // [3]=0: Enable clk divider for DSP scale control
                             // [2:0]=011: Divided by 8 -> QQVGA/2
      6'h17:
        reg_yuv422 <= 16'hA202; // A2: SCALING_PCLK_DELAY Pixel Clock Delay
                             // [7]: Reserved
                             // [6:0]=02: Default scaling ouput delay
      //  end QQVGA
      6'h18:
        reg_yuv422 <= 16'hFFFF;  // FINISH CONDITION, register FF doesnt exist
      default:
        reg_yuv422 <= 16'hFFFF;  // FINISH CONDITION
    endcase
  end



  // camera system clock:
  //     freq   :  min: 10 MHz  -- typ: 24 MHz  -- Max: 48 MHz
  //     Period : max: 100 ns   -- typ: 42 ns   -- Max: 21 ns
  // duty cycle between 45% and 55%
  // Since our clock is 10 ns (100 MHz), we have to divide frequency by:
  //  4: 25 MHz - 40 ns
  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      cnt_cam_clk <= 0;
    else begin
      if (cnt_cam_clk == 3'b011)
        cnt_cam_clk <= 0;
      else
        cnt_cam_clk <= cnt_cam_clk + 1;
    end
  end

  // when cnt_cam_clk = 0 | 1 => '0', when 2 | 3 => '1'
  assign ov7670_clk = cnt_cam_clk[1];

  // camera reset and power down
  assign ov7670_pwdn  = 1'b0;

  //------ controlling the registers to be sent ------------

  assign id        = c_id_write; // 0x21
  assign addr_aux  = reg_i[15:8];
  assign addr      = addr_aux;
  assign data_wr   = reg_i[7:0];


  assign ov7670_rst_n   = cam_rst_n;
  assign done      = alltx_done;
  assign start_tx  = start_tx_aux;

  // sequentially counts the registers to be sent to the SCCB
  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      cnt_reg <= 0;
    else begin
      if (resend || test_mode_change)
        cnt_reg <= 0; // start again sending the sequence
      else if (~alltx_done) begin
        if (start_tx_aux)
          cnt_reg <= cnt_reg + 1;
      end
    end
  end
        
  // instead of comparing addr_aux = 16'hFF, to simplify, since there is no
  // address in F ("1111"), it can be compared
  assign alltx_done = (addr_aux[7:4] == 4'b1111) ? 1'b1 : 1'b0; 

  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      test_mode_rg <= 1'b0;
    else
      test_mode_rg <= test_mode;
  end

  assign test_mode_change = test_mode_rg ^ test_mode; // change in testmode

  // without clk -> Distributed CLBS
  // reg_i <= registers(to_integer(unsigned(cnt_reg));
  // process with clk -> BRAM
  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      reg_i <= 16'h1280; // reset
    else begin
      if (test_mode)
          reg_i <= reg_yuv422_test;
      else
          reg_i <= reg_yuv422;
    end
  end

  // FSM sequential process
  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      pr_ctrl_st <= RSTCAM_ST;
    else
      pr_ctrl_st <= nx_ctrl_st;
  end

  // FSM combinatorial process
  always @ (pr_ctrl_st or alltx_done or sccb_ready or end300ms)
  begin
    // default values
    nx_ctrl_st <= pr_ctrl_st;
    start_tx_aux <= 1'b0;
    cam_rst_n <= 1'b1; //camera reset inactive
    ena_cnt300ms <= 1'b0;
    case  (pr_ctrl_st)
      RSTCAM_ST: begin // Reset camera during 300ms
        cam_rst_n <= 1'b0; //activate reset
        ena_cnt300ms <= 1'b1;
        if (end300ms) begin
          nx_ctrl_st <= WAIT_RSTCAM_ST;
        end
      end
      WAIT_RSTCAM_ST: begin // wait 300ms for the camera to be ready to receive
        ena_cnt300ms <= 1'b1;
        if (end300ms) begin
          nx_ctrl_st <= WAIT_ST;
        end
      end
      WAIT_ST: begin // waiting for the SCCB to be available
        if (alltx_done)
          nx_ctrl_st <= DONE_ST;
        else if (sccb_ready) begin
          nx_ctrl_st <= WRITE_REG_ST;
          start_tx_aux <= 1'b1;
        end
      end
      WRITE_REG_ST: begin // writting a new register (maybe not necessary)
        ena_cnt300ms <= 1'b1;
        if (end300ms) begin
          nx_ctrl_st <= WAIT_ST;
        end
      end
      DONE_ST: // writting a new register
        if (~alltx_done) // in case of resend = '1'
          nx_ctrl_st <= RSTCAM_ST;
    endcase
  end


  // counting 300 ms at 100MHz clk: 30 million. 25 bits
  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      cnt300ms <= 25'd0;
    else begin
      if (ena_cnt300ms) begin
        if (end300ms) 
            cnt300ms <= 25'd0;
        else
            cnt300ms <= cnt300ms + 1;
      end
      else
        cnt300ms <= 25'd0;
    end
  end 

  assign end300ms =  (cnt300ms == c_end300ms) ? 1'b1 : 1'b0;




endmodule
