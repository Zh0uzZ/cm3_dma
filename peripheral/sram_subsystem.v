// --------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//               (C) COPYRIGHT 2015,2017 ARM Limited.
//                   ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
// SVN Information
//
// Checked In : $Date: 2015-06-03 17:04:50 +0100 (Wed, 03 Jun 2015) $
// Revision : $Revision: 365823 $
//
// Release Information : CM3DesignStart-r0p0-02rel0
//
// -------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -------------------------------------------------------------------------------
//  Purpose : Cortex-M3 DesignStart SRAM Subsystem
//            Contains main IoT Subsystem SRAM instances for FPGA
// -------------------------------------------------------------------------------

`define SIMULATION

module sram_subsystem (
    input wire SRAMHRESETn,

    // ----------------------------------------------------------------------------
    // AHB2SRAM<0..3> Interfaces
    // ----------------------------------------------------------------------------
    input wire SRAM0HCLK,

    output wire [31:0] SRAM0RDATA,  // SRAM Read data bus
    input  wire [12:0] SRAM0ADDR,   // SRAM address
    input  wire [ 3:0] SRAM0WREN,   // SRAM Byte write enable
    input  wire [31:0] SRAM0WDATA,  // SRAM Write data
    input  wire        SRAM0CS,     // SRAM Chip select
    // ----------------------------------------------------------------------------

    input wire SRAM1HCLK,

    output wire [31:0] SRAM1RDATA,  // SRAM Read data bus
    input  wire [12:0] SRAM1ADDR,   // SRAM address
    input  wire [ 3:0] SRAM1WREN,   // SRAM Byte write enable
    input  wire [31:0] SRAM1WDATA,  // SRAM Write data
    input  wire        SRAM1CS      // SRAM Chip select
    // ----------------------------------------------------------------------------
);

  //local declarations
  wire        i_sram00_cen;
  wire        i_sram01_cen;
  wire [31:0] i_sram00_rdata;
  wire [31:0] i_sram01_rdata;

  wire        i_sram10_cen;
  wire        i_sram11_cen;
  wire [31:0] i_sram10_rdata;
  wire [31:0] i_sram11_rdata;



  reg         sram0_bank_select;
  reg         sram1_bank_select;

  // ----------------------------------------------------------------------------
  // AHB2SRAM<0..3> Interfaces
  // ----------------------------------------------------------------------------
  assign i_sram00_cen = ~SRAM0CS | SRAM0ADDR[12];
  assign i_sram01_cen = ~SRAM0CS | ~SRAM0ADDR[12];

  always @(negedge SRAMHRESETn or posedge SRAM0HCLK) begin
    if (!SRAMHRESETn) begin
      sram0_bank_select <= 1'b0;
    end else if (SRAM0CS) begin
      sram0_bank_select <= SRAM0ADDR[12];
    end
  end

  assign SRAM0RDATA = sram0_bank_select ? i_sram01_rdata : i_sram00_rdata;

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram0 (
      // Inputs
      .CLK  (SRAM0HCLK),
      .ADDR (SRAM0ADDR[11:0]),
      .WDATA(SRAM0WDATA),
      .WREN (SRAM0WREN),
      .CS   (~i_sram00_cen),

      // Outputs
      .RDATA(i_sram00_rdata)
  );

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram1 (
      // Inputs
      .CLK  (SRAM0HCLK),
      .ADDR (SRAM0ADDR[11:0]),
      .WDATA(SRAM0WDATA),
      .WREN (SRAM0WREN),
      .CS   (~i_sram01_cen),

      // Outputs
      .RDATA(i_sram01_rdata)
  );


  assign i_sram10_cen = ~SRAM1CS | SRAM1ADDR[12];
  assign i_sram11_cen = ~SRAM1CS | ~SRAM1ADDR[12];

  always @(negedge SRAMHRESETn or posedge SRAM1HCLK) begin
    if (!SRAMHRESETn) begin
      sram1_bank_select <= 1'b0;
    end else if (SRAM1CS) begin
      sram1_bank_select <= SRAM1ADDR[12];
    end
  end

  assign SRAM1RDATA = sram1_bank_select ? i_sram11_rdata : i_sram10_rdata;

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram2 (
      // Inputs
      .CLK  (SRAM1HCLK),
      .ADDR (SRAM1ADDR[11:0]),
      .WDATA(SRAM1WDATA),
      .WREN (SRAM1WREN),
      .CS   (~i_sram10_cen),

      // Outputs
      .RDATA(i_sram10_rdata)
  );

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram3 (
      // Inputs
      .CLK  (SRAM1HCLK),
      .ADDR (SRAM1ADDR[11:0]),
      .WDATA(SRAM1WDATA),
      .WREN (SRAM1WREN),
      .CS   (~i_sram11_cen),

      // Outputs
      .RDATA(i_sram11_rdata)
  );

endmodule


