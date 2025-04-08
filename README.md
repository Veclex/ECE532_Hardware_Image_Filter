# Hardware Image Filter

## Overview
This project implements a real-time image capture, processing, and display pipeline on the Nexys4 DDR board using the OV7670 camera. The design features UART communication for both image upload and download, supports grayscale and edge filtering (Sobel/median), and displays images via VGA at 320×240 resolution.

## Features
- **OV7670 Camera Support**: Captures real-time grayscale video at 320×240 resolution using the OV7670 CMOS camera module.
- **VGA Display Output**: Displays processed images at 640×480 VGA timing with active resolution of 320×240.
- **Real-Time Image Processing**: Includes 4 modes of processing: Raw grayscale, Sobel edge detection (horizontal / vertical / combined), and 3×3 median filtering (noise reduction).
- **Bi-directional UART Interface**: User-friendly script for image upload/download

## Switch & Button Control
- sw14: UART image input mode
- sw15: UART image output (transmit)
- btnr: capture/send trigger
- btnl: switch image processing mode
- btnc: reset

## Structure
```
├── /final_3.srcs
│   └── constrs_1/                           # constraints file
│       └── new/
│           └── nexys4ddr_filter.xdc
│   └── sources_1/                           # source file
│       └── imports/
│           └── nexys/
│               ├── top_ov7670_nexys.v       # Top-level module
│               └─── ov7670_ctrl_reg.v       # register  configuration 
│           └── ov7670_yuv_80x60_sobel/
│               ├── mode_sel.v               # model selection
│               ├── edge_proc.v              # edge_processing filter
│               ├── sccb_master.v            # initialization
│               ├── ov7670_top_ctrl.v        # camera configuration top
│               ├── ov7670_capture.v         # capture logic
│               ├── frame_buffer.v           # Frame_buffer
│               ├── vga_display.v            # rendering data
│               └── vga_sync.v               # synchronization 
│       └── new/
│           └── median_3x3.v                 # median filter
│           └── uart_img_sender.v         
│           └── uart_rx.v                    # RX
│           └── uart_img_loader.v
│           └── uart_tx.v                    # TX
│
├── /matlab
│   ├── uart_to_board.m                      # MATLAB script for uploading image to board
│   ├── uart_out_board.m                     # MATLAB script for recive image from board
│   ├── uart_loop.m                          # Main interactive loop: upload + receive + resend
│
├── /doc
│   └── report.pdf                           # Group report (NOT individual reports)
│
├── /test_img
│   ├── Lena.png                             # Test image used for upload
│   └── output/                              # Folder to save received images
│       └── median_only.png
│       └── median+sobel.png
│       └── sobel_only.png
│
├── README.md                                # This description file
```
# Notes
- The /final_3.srcs directory contains all synthesizable and behavioral modules for FPGA synthesis.
- The system is driven by a 100 MHz input clock. VGA display resolution is 640x480 (timing), with active image region of 320×240.
- MATLAB handles image upload/download via UART