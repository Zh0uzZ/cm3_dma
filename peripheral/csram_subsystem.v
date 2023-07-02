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

module csram_subsystem (
    input wire SRAMHRESETn,

    // ----------------------------------------------------------------------------
    // AHB2CSRAM<2..3> Interfaces
    // ----------------------------------------------------------------------------
    input wire SRAM2HCLK,

    output wire [31:0] SRAM2RDATA,  // SRAM Read data bus
    input  wire [12:0] SRAM2ADDR,   // SRAM address
    input  wire [ 3:0] SRAM2WREN,   // SRAM Byte write enable
    input  wire [31:0] SRAM2WDATA,  // SRAM Write data
    input  wire        SRAM2CS,     // SRAM Chip select
    // ----------------------------------------------------------------------------

    input wire SRAM3HCLK,

    output wire [31:0] SRAM3RDATA,  // SRAM Read data bus
    input  wire [12:0] SRAM3ADDR,   // SRAM address
    input  wire [ 3:0] SRAM3WREN,   // SRAM Byte write enable
    input  wire [31:0] SRAM3WDATA,  // SRAM Write data
    input  wire        SRAM3CS      // SRAM Chip select
    // ----------------------------------------------------------------------------
);

  //local declarations
  wire        i_SRAM20_cen;
  wire        i_SRAM21_cen;
  wire [31:0] i_SRAM20_rdata;
  wire [31:0] i_SRAM21_rdata;

  wire        i_SRAM30_cen;
  wire        i_SRAM31_cen;
  wire [31:0] i_SRAM30_rdata;
  wire [31:0] i_SRAM31_rdata;



  reg         SRAM2_bank_select;
  reg         SRAM3_bank_select;

  // ----------------------------------------------------------------------------
  // AHB2SRAM<0..3> Interfaces
  // ----------------------------------------------------------------------------
  assign i_SRAM20_cen = ~SRAM2CS | SRAM2ADDR[12];
  assign i_SRAM21_cen = ~SRAM2CS | ~SRAM2ADDR[12];

  always @(negedge SRAMHRESETn or posedge SRAM2HCLK) begin
    if (!SRAMHRESETn) begin
      SRAM2_bank_select <= 1'b0;
    end else if (SRAM2CS) begin
      SRAM2_bank_select <= SRAM2ADDR[12];
    end
  end

  assign SRAM2RDATA = SRAM2_bank_select ? i_SRAM21_rdata : i_SRAM20_rdata;

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram0 (
      // Inputs
      .CLK  (SRAM2HCLK),
      .ADDR (SRAM2ADDR[11:0]),
      .WDATA(SRAM2WDATA),
      .WREN (SRAM2WREN),
      .CS   (~i_SRAM20_cen),

      // Outputs
      .RDATA(i_SRAM20_rdata)
  );

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram1 (
      // Inputs
      .CLK  (SRAM2HCLK),
      .ADDR (SRAM2ADDR[11:0]),
      .WDATA(SRAM2WDATA),
      .WREN (SRAM2WREN),
      .CS   (~i_SRAM21_cen),

      // Outputs
      .RDATA(i_SRAM21_rdata)
  );


  assign i_SRAM30_cen = ~SRAM3CS | SRAM3ADDR[12];
  assign i_SRAM31_cen = ~SRAM3CS | ~SRAM3ADDR[12];

  always @(negedge SRAMHRESETn or posedge SRAM3HCLK) begin
    if (!SRAMHRESETn) begin
      SRAM3_bank_select <= 1'b0;
    end else if (SRAM3CS) begin
      SRAM3_bank_select <= SRAM3ADDR[12];
    end
  end

  assign SRAM3RDATA = SRAM3_bank_select ? i_SRAM31_rdata : i_SRAM30_rdata;

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram2 (
      // Inputs
      .CLK  (SRAM3HCLK),
      .ADDR (SRAM3ADDR[11:0]),
      .WDATA(SRAM3WDATA),
      .WREN (SRAM3WREN),
      .CS   (~i_SRAM30_cen),

      // Outputs
      .RDATA(i_SRAM30_rdata)
  );

  cmsdk_fpga_sram #(
      // --------------------------------------------------------------------------
      // Parameter Declarations
      // --------------------------------------------------------------------------
      .AW(12)
  ) u_fpga_ahb2sram_ram3 (
      // Inputs
      .CLK  (SRAM3HCLK),
      .ADDR (SRAM3ADDR[11:0]),
      .WDATA(SRAM3WDATA),
      .WREN (SRAM3WREN),
      .CS   (~i_SRAM31_cen),

      // Outputs
      .RDATA(i_SRAM31_rdata)
  );

endmodule


