// -----------------------------------------------------------------------------
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
// Checked In : $Date: 2015-06-30 10:21:40 +0100 (Tue, 30 Jun 2015) $
// Revision : $Revision: 365823 $
//
// Release Information : CM3DesignStart-r0p0-02rel0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------
// Purpose : Closely coupled APB peripherals for M3 Designstart
//           MPS2-platform specific peripherals
// -----------------------------------------------------------------------------

`include "fpga_options_defs.h"

module m3ds_peripherals_wrapper
(
  //-----------------------------
  //Resets
    input  wire          AHBRESETn,                 // AHB domain reset for slave_mux and default_slave
    input  wire          DTIMERPRESETn,             // APB domain + System (functional) clock domain (global reset)
    input  wire          UART0PRESETn,              // APB domain = System (functional) clock
    input  wire          UART1PRESETn,              // APB domain = System (functional) clock
    input  wire          WDOGPRESETn,               // APB domain of WDOG
    input  wire          WDOGRESn,                  // WDOG_CLK domain
    input  wire          GPIO0HRESETn,              // AHB domain + System (functional) clock domain (global reset)
    input  wire          GPIO1HRESETn,              // AHB domain + System (functional) clock domain (global reset)

  //-----------------------------
  //Clocks
    input  wire          AHB_CLK,                   // HCLK from top
    input  wire          APB_CLK,                   // PCLKG from top
    input  wire          DTIMER_CLK,
    input  wire          UART0_CLK,
    input  wire          UART1_CLK,
    input  wire          WDOG_CLK,
    input  wire          GPIO0_FCLK,                // System Clock (Functional IF)
    input  wire          GPIO1_FCLK,                // System Clock (Functional IF)
    input  wire          GPIO0_HCLK,                // System Clock (APB IF)
    input  wire          GPIO1_HCLK,                // System Clock (APB IF)

  //-----------------------------
  //AHB interface
  //AHB Master Slave
    input  wire          PERIPHHSEL_i,              // AHB peripheral select
    input  wire          PERIPHHREADYIN_i,          // AHB ready input
    input  wire [1:0]    PERIPHHTRANS_i,            // AHB transfer type
    input  wire [2:0]    PERIPHHSIZE_i,             // AHB hsize
    input  wire          PERIPHHWRITE_i,            // AHB hwrite
    input  wire [31:0]   PERIPHHADDR_i,             // AHB address bus
    input  wire [31:0]   PERIPHHWDATA_i,            // AHB write data bus

    input  wire [3:0]    PERIPHHPROT_i,

    output wire          PERIPHHREADYMUXOUT_o,      // AHB ready output from S->M mux
    output wire          PERIPHHRESP_o,             // AHB response output from S->M mux
    output wire [31:0]   PERIPHHRDATA_o,            // AHB read data from S->M mux

  //-----------------------------
  //APB interfaces
  //D(ual)Timer
    input  wire          DTIMERPSEL_i,              // APBTARGEXP2PSEL
    input  wire          DTIMERPENABLE_i,           // APBTARGEXP2PENABLE
    input  wire [31:0]   DTIMERPADDR_i,             // APBTARGEXP2PADDR
    input  wire          DTIMERPWRITE_i,            // APBTARGEXP2PWRITE
    input  wire [31:0]   DTIMERPWDATA_i,            // APBTARGEXP2PWDATA
    input  wire [3:0]    DTIMERPSTRB_i,             // APBTARGEXP2PSTRB
    input  wire          DTIMERPPROT_i,             // APBTARGEXP2PPROT
    output wire [31:0]   DTIMERPRDATA_o,            // APBTARGEXP2PRDATA
    output wire          DTIMERPREADY_o,            // APBTARGEXP2PREADY
    output wire          DTIMERPSLVERR_o,           // APBTARGEXP2PSLVERR

  //UART0
    input  wire          UART0PSEL_i,               // APBTARGEXP4PSEL
    input  wire          UART0PENABLE_i,            // APBTARGEXP4PENABLE
    input  wire [31:0]   UART0PADDR_i,              // APBTARGEXP4PADDR
    input  wire          UART0PWRITE_i,             // APBTARGEXP4PWRITE
    input  wire [31:0]   UART0PWDATA_i,             // APBTARGEXP4PWDATA
    input  wire [3:0]    UART0PSTRB_i,              // APBTARGEXP4PSTRB
    input  wire          UART0PPROT_i,              // APBTARGEXP4PPROT
    output wire [31:0]   UART0PRDATA_o,             // APBTARGEXP4PRDATA
    output wire          UART0PREADY_o,             // APBTARGEXP4PREADY
    output wire          UART0PSLVERR_o,            // APBTARGEXP4PSLVERR

  //UART1
    input  wire          UART1PSEL_i,               // APBTARGEXP5PSEL
    input  wire          UART1PENABLE_i,            // APBTARGEXP5PENABLE
    input  wire [31:0]   UART1PADDR_i,              // APBTARGEXP5PADDR
    input  wire          UART1PWRITE_i,             // APBTARGEXP5PWRITE
    input  wire [31:0]   UART1PWDATA_i,             // APBTARGEXP5PWDATA
    input  wire [3:0]    UART1PSTRB_i,              // APBTARGEXP5PSTRB
    input  wire          UART1PPROT_i,              // APBTARGEXP5PPROT
    output wire [31:0]   UART1PRDATA_o,             // APBTARGEXP5PRDATA
    output wire          UART1PREADY_o,             // APBTARGEXP5PREADY
    output wire          UART1PSLVERR_o,            // APBTARGEXP5PSLVERR

  //W(atch)DOG
    input  wire          WDOGPSEL_i,                // APBTARGEXP8PSEL
    input  wire          WDOGPENABLE_i,             // APBTARGEXP8PENABLE
    input  wire [31:0]   WDOGPADDR_i,               // APBTARGEXP8PADDR
    input  wire          WDOGPWRITE_i,              // APBTARGEXP8PWRITE
    input  wire [31:0]   WDOGPWDATA_i,              // APBTARGEXP8PWDATA
    input  wire [3:0]    WDOGPSTRB_i,               // APBTARGEXP8PSTRB
    input  wire          WDOGPPROT_i,               // APBTARGEXP8PPROT
    output wire [31:0]   WDOGPRDATA_o,              // APBTARGEXP8PRDATA
    output wire          WDOGPREADY_o,              // APBTARGEXP8PREADY
    output wire          WDOGPSLVERR_o,             // APBTARGEXP8PSLVERR

  //-----------------------------
  //Other/Functional peripheral module specific interfaces
  //-----------------------------
  //D(ual)TIMER
    input  wire [3:0]    DTIMERECOREVNUM_i,         // ECO revision number
    input  wire          DTIMERTIMCLKEN1_i,         // Timer clock enable 1
    input  wire          DTIMERTIMCLKEN2_i,         // Timer clock enable 2
    output wire          DTIMERTIMINT1_o,           // Counter 1 interrupt
    output wire          DTIMERTIMINT2_o,           // Counter 2 interrupt
    output wire          DTIMERTIMINTC_o,           // Counter combined interrupt

  //-----------------------------
  //UART0
    input  wire [3:0]    UART0ECOREVNUM_i,          // Engineering-change-order revision bits
    input  wire          UART0RXD_i,                // Serial input
    output wire          UART0TXD_o,                // Transmit data output
    output wire          UART0TXEN_o,               // Transmit enabled
    output wire          UART0BAUDTICK_o,           // Baud rate (x16) Tick
    output wire          UART0TXINT_o,              // Transmit Interrupt
    output wire          UART0RXINT_o,              // Receive Interrupt
    output wire          UART0TXOVRINT_o,           // Transmit overrun Interrupt
    output wire          UART0RXOVRINT_o,           // Receive overrun Interrupt
    output wire          UART0UARTINT_o,            // Combined interrupt

  //-----------------------------
  //UART1
    input  wire [3:0]    UART1ECOREVNUM_i,          // Engineering-change-order revision bits
    input  wire          UART1RXD_i,                // Serial input
    output wire          UART1TXD_o,                // Transmit data output
    output wire          UART1TXEN_o,               // Transmit enabled
    output wire          UART1BAUDTICK_o,           // Baud rate (x16) Tick
    output wire          UART1TXINT_o,              // Transmit Interrupt
    output wire          UART1RXINT_o,              // Receive Interrupt
    output wire          UART1TXOVRINT_o,           // Transmit overrun Interrupt
    output wire          UART1RXOVRINT_o,           // Receive overrun Interrupt
    output wire          UART1UARTINT_o,            // Combined interrupt


  //-----------------------------
  //W(atch)DOG
    input  wire [3:0]    WDOGECOREVNUM_i,           // ECO revision number
    input  wire          WDOGCLKEN_i,               // Watchdog clock enable
    output wire          WDOGINT_o,                 // Watchdog interrupt
    output wire          WDOGRES_o,                 // Watchdog timeout reset
  //-----------------------------
  //GPIO0
    input  wire [3:0]    GPIO0ECOREVNUM_i,          // Engineering-change-order revision bits
    input  wire [15:0]   GPIO0PORTIN_i,             // GPIO Interface input
    output wire [15:0]   GPIO0PORTOUT_o,            // GPIO output
    output wire [15:0]   GPIO0PORTEN_o,             // GPIO output enable
    output wire [15:0]   GPIO0PORTFUNC_o,           // Alternate function control
    output wire [15:0]   GPIO0GPIOINT_o,            // Interrupt output for each pin
    output wire          GPIO0COMBINT_o,            // Combined interrupt

  //-----------------------------
  //GPIO1
    input  wire [3:0]    GPIO1ECOREVNUM_i,          // Engineering-change-order revision bits
    input  wire [15:0]   GPIO1PORTIN_i,             // GPIO Interface input
    output wire [15:0]   GPIO1PORTOUT_o,            // GPIO output
    output wire [15:0]   GPIO1PORTEN_o,             // GPIO output enable
    output wire [15:0]   GPIO1PORTFUNC_o,           // Alternate function control
    output wire [15:0]   GPIO1GPIOINT_o,            // Interrupt output for each pin
    output wire          GPIO1COMBINT_o            // Combined interrupt

);

  wire w_beetle_hsel;
  wire w_beetle_hreadyout;
  wire w_beetle_hresp;
  wire [31:0] w_beetle_hrdata;

  wire w_defslave_hsel;
  wire w_defslave_hreadyout;
  wire w_defslave_hresp;
  wire [31:0] w_defslave_hrdata;

  wire w_fpga_hsel;
  wire w_fpga_hreadyout;
  wire w_fpga_hresp;
  wire [31:0] w_fpga_hrdata;

  wire w_mps2_hsel;
  wire w_mps2_hreadyout;
  wire w_mps2_hresp;
  wire [31:0] w_mps2_hrdata;

  //-------------------------------
  //AHB Decoder, Mux, default slave
  //-------------------------------
  m3ds_ahb_decoder u_m3ds_ahb_decoder (
    .HSEL_i             (PERIPHHSEL_i),
    .decode_address_i   (PERIPHHADDR_i[31:16]),  //lower 10 bits are not compared
    .BEETLE_HSEL_o      (w_beetle_hsel),
    .DEFSLAVE_HSEL_o    (w_defslave_hsel),
    .FPGA_HSEL_o        (w_fpga_hsel),
    .MPS2_HSEL_o        (w_mps2_hsel),
    .CFG_BOOT           (1'b0)
  );

  cmsdk_ahb_slave_mux
  #(
    .PORT0_ENABLE(1'b1),  //beetle_peripheral
    .PORT1_ENABLE(1'b0),  //fpga_apb_subsystem
    .PORT2_ENABLE(1'b0),  //mps2_external_subsystem
    .PORT3_ENABLE(1'b0),  //default slave
    .PORT4_ENABLE(1'b0),  //unused
    .PORT5_ENABLE(1'b0),  //unused
    .PORT6_ENABLE(1'b0),  //unused
    .PORT7_ENABLE(1'b0),  //unused
    .PORT8_ENABLE(1'b0),  //unused
    .PORT9_ENABLE(1'b0),  //unused
    .DW(32)               //32bits
  ) u_mps2_ahb_slave_mux (
    .HCLK(AHB_CLK),                   // Top Clock
    .HRESETn(AHBRESETn),              // Top Reset
    .HREADY(PERIPHHREADYIN_i),        // Top Bus ready
    .HSEL0(w_beetle_hsel),            // HSEL for AHB Slave #0 -> Default slave
    .HREADYOUT0(w_beetle_hreadyout),  // HREADY for Slave connection #0
    .HRESP0(w_beetle_hresp),          // HRESP  for slave connection #0
    .HRDATA0(w_beetle_hrdata),        // HRDATA for slave connection #0
    .HSEL1(w_fpga_hsel),              // HSEL for AHB Slave #1 -> BEETLE AHB
    .HREADYOUT1(w_fpga_hreadyout),    // HREADY for Slave connection #1
    .HRESP1(w_fpga_hresp),            // HRESP  for slave connection #1
    .HRDATA1(w_fpga_hrdata),          // HRDATA for slave connection #1
    .HSEL2(w_mps2_hsel),              // HSEL for AHB Slave #2
    .HREADYOUT2(w_mps2_hreadyout),    // HREADY for Slave connection #2 -> FPGA
    .HRESP2(w_mps2_hresp),            // HRESP  for slave connection #2
    .HRDATA2(w_mps2_hrdata),          // HRDATA for slave connection #2
    .HSEL3(w_defslave_hsel),          // HSEL for AHB Slave #3
    .HREADYOUT3(w_defslave_hreadyout),// HREADY for Slave connection #3
    .HRESP3(w_defslave_hresp),        // HRESP  for slave connection #3
    .HRDATA3(w_defslave_hrdata),      // HRDATA for slave connection #3
    .HSEL4(1'b0),         // HSEL for AHB Slave #4
    .HREADYOUT4(1'b0),    // HREADY for Slave connection #4
    .HRESP4(1'b1),        // HRESP  for slave connection #4
    .HRDATA4({32{1'b0}}), // HRDATA for slave connection #4
    .HSEL5(1'b0),         // HSEL for AHB Slave #5
    .HREADYOUT5(1'b0),    // HREADY for Slave connection #5
    .HRESP5(1'b1),        // HRESP  for slave connection #5
    .HRDATA5({32{1'b0}}), // HRDATA for slave connection #5
    .HSEL6(1'b0),         // HSEL for AHB Slave #6
    .HREADYOUT6(1'b0),    // HREADY for Slave connection #6
    .HRESP6(1'b1),        // HRESP  for slave connection #6
    .HRDATA6({32{1'b0}}), // HRDATA for slave connection #6
    .HSEL7(1'b0),         // HSEL for AHB Slave #7
    .HREADYOUT7(1'b0),    // HREADY for Slave connection #7
    .HRESP7(1'b1),        // HRESP  for slave connection #7
    .HRDATA7({32{1'b0}}), // HRDATA for slave connection #7
    .HSEL8(1'b0),         // HSEL for AHB Slave #8
    .HREADYOUT8(1'b0),    // HREADY for Slave connection #8
    .HRESP8(1'b1),        // HRESP  for slave connection #8
    .HRDATA8({32{1'b0}}), // HRDATA for slave connection #8
    .HSEL9(1'b0),         // HSEL for AHB Slave #9
    .HREADYOUT9(1'b0),    // HREADY for Slave connection #9
    .HRESP9(1'b1),        // HRESP  for slave connection #9
    .HRDATA9({32{1'b0}}), // HRDATA for slave connection #9
    .HREADYOUT(PERIPHHREADYMUXOUT_o), // HREADY output to AHB master and AHB slaves
    .HRESP(PERIPHHRESP_o),            // HRESP to AHB master
    .HRDATA(PERIPHHRDATA_o)           // Read data to AHB master

  );

  // Default slave
  cmsdk_ahb_default_slave u_ahb_default_slave_0 (
    .HCLK         (AHB_CLK),
    .HRESETn      (AHBRESETn),
    .HSEL         (w_defslave_hsel),
    .HTRANS       (PERIPHHTRANS_i),
    .HREADY       (PERIPHHREADYIN_i),
    .HREADYOUT    (w_defslave_hreadyout),
    .HRESP        (w_defslave_hresp)
  );

  assign w_defslave_hrdata = {32{1'b0}};


wire [31:0] APBPER0_REG ;
assign APBPER0_REG = 32'hffff_ffff;

peripherals u_peripherals_subsystem
(
  //-----------------------------
  //Resets
  .AHBRESETn            (AHBRESETn    ),  //AHB domain reset for slave_mux and default_slave
  .DTIMERPRESETn        (DTIMERPRESETn),  //APB domain + System (functional) clock domain (global reset)
  .UART0PRESETn         (UART0PRESETn ),  //APB domain = System (functional) clock
  .UART1PRESETn         (UART1PRESETn ),  //APB domain = System (functional) clock
  .WDOGPRESETn          (WDOGPRESETn  ),  //APB domain of WDOG
  .WDOGRESn             (WDOGRESn     ),  //WDOG_CLK domain
  .GPIO0HRESETn         (GPIO0HRESETn ),  //AHB domain + System (functional) clock domain (global reset)
  .GPIO1HRESETn         (GPIO1HRESETn ),  //AHB domain + System (functional) clock domain (global reset)

  //-----------------------------
  //Clocks
  .AHB_CLK              (AHB_CLK   ),  //HCLK from top
  .APB_CLK              (APB_CLK   ),  //PCLKG from top
  .DTIMER_CLK           (DTIMER_CLK),
  .UART0_CLK            (UART0_CLK ),
  .UART1_CLK            (UART1_CLK ),
  .WDOG_CLK             (WDOG_CLK  ),
  .GPIO0_FCLK           (GPIO0_FCLK),  // System Clock (Functional IF)
  .GPIO1_FCLK           (GPIO1_FCLK),  // System Clock (Functional IF)
  .GPIO0_HCLK           (GPIO0_HCLK),  // System Clock (APB IF)
  .GPIO1_HCLK           (GPIO1_HCLK),  // System Clock (APB IF)

  //-----------------------------
  //AHB interface
  //AHB Master Slave
  .PERIPHHSEL_i         (w_beetle_hsel   ),  //AHB peripheral select
  .PERIPHHREADYIN_i     (PERIPHHREADYIN_i),  //AHB ready input
  .PERIPHHTRANS_i       (PERIPHHTRANS_i  ),  //AHB transfer type
  .PERIPHHSIZE_i        (PERIPHHSIZE_i   ),  //AHB hsize
  .PERIPHHWRITE_i       (PERIPHHWRITE_i  ),  //AHB hwrite
  .PERIPHHADDR_i        (PERIPHHADDR_i   ),  //AHB address bus
  .PERIPHHWDATA_i       (PERIPHHWDATA_i  ),  //AHB write data bus

  .PERIPHHREADYMUXOUT_o (w_beetle_hreadyout),  //AHB ready output from S->M mux
  .PERIPHHRESP_o        (w_beetle_hresp       ),  //AHB response output from S->M mux
  .PERIPHHRDATA_o       (w_beetle_hrdata      ),  //AHB read data from S->M mux

  .APBPER0_REG          (APBPER0_REG         ),  // Access permission for APB peripherals

  //-----------------------------
  //APB interfaces
  //D(ual)Timer
  .DTIMERPSEL_i         (DTIMERPSEL_i   ),  //APBTARGEXP2PSEL
  .DTIMERPENABLE_i      (DTIMERPENABLE_i),  //APBTARGEXP2PENABLE
  .DTIMERPADDR_i        (DTIMERPADDR_i  ),  //APBTARGEXP2PADDR
  .DTIMERPWRITE_i       (DTIMERPWRITE_i ),  //APBTARGEXP2PWRITE
  .DTIMERPWDATA_i       (DTIMERPWDATA_i ),  //APBTARGEXP2PWDATA
  .DTIMERPSTRB_i        (DTIMERPSTRB_i  ),  //APBTARGEXP2PSTRB
  .DTIMERPPROT_i        (DTIMERPPROT_i  ),  //APBTARGEXP2PPROT
  .DTIMERPRDATA_o       (DTIMERPRDATA_o ),  //APBTARGEXP2PRDATA
  .DTIMERPREADY_o       (DTIMERPREADY_o ),  //APBTARGEXP2PREADY
  .DTIMERPSLVERR_o      (DTIMERPSLVERR_o),  //APBTARGEXP2PSLVERR

  //UART0
  .UART0PSEL_i          (UART0PSEL_i    ),  //APBTARGEXP4PSEL
  .UART0PENABLE_i       (UART0PENABLE_i ),  //APBTARGEXP4PENABLE
  .UART0PADDR_i         (UART0PADDR_i   ),  //APBTARGEXP4PADDR
  .UART0PWRITE_i        (UART0PWRITE_i  ),  //APBTARGEXP4PWRITE
  .UART0PWDATA_i        (UART0PWDATA_i  ),  //APBTARGEXP4PWDATA
  .UART0PSTRB_i         (UART0PSTRB_i   ),  //APBTARGEXP4PSTRB
  .UART0PPROT_i         (UART0PPROT_i   ),  //APBTARGEXP4PPROT
  .UART0PRDATA_o        (UART0PRDATA_o  ),  //APBTARGEXP4PRDATA
  .UART0PREADY_o        (UART0PREADY_o  ),  //APBTARGEXP4PREADY
  .UART0PSLVERR_o       (UART0PSLVERR_o ),  //APBTARGEXP4PSLVERR

  //UART1
  .UART1PSEL_i          (UART1PSEL_i    ),  //APBTARGEXP5PSEL
  .UART1PENABLE_i       (UART1PENABLE_i ),  //APBTARGEXP5PENABLE
  .UART1PADDR_i         (UART1PADDR_i   ),  //APBTARGEXP5PADDR
  .UART1PWRITE_i        (UART1PWRITE_i  ),  //APBTARGEXP5PWRITE
  .UART1PWDATA_i        (UART1PWDATA_i  ),  //APBTARGEXP5PWDATA
  .UART1PSTRB_i         (UART1PSTRB_i   ),  //APBTARGEXP5PSTRB
  .UART1PPROT_i         (UART1PPROT_i   ),  //APBTARGEXP5PPROT
  .UART1PRDATA_o        (UART1PRDATA_o  ),  //APBTARGEXP5PRDATA
  .UART1PREADY_o        (UART1PREADY_o  ),  //APBTARGEXP5PREADY
  .UART1PSLVERR_o       (UART1PSLVERR_o ),  //APBTARGEXP5PSLVERR


  //W(atch)DOG
  .WDOGPSEL_i           (WDOGPSEL_i     ),  //APBTARGEXP8PSEL
  .WDOGPENABLE_i        (WDOGPENABLE_i  ),  //APBTARGEXP8PENABLE
  .WDOGPADDR_i          (WDOGPADDR_i    ),  //APBTARGEXP8PADDR
  .WDOGPWRITE_i         (WDOGPWRITE_i   ),  //APBTARGEXP8PWRITE
  .WDOGPWDATA_i         (WDOGPWDATA_i   ),  //APBTARGEXP8PWDATA
  .WDOGPSTRB_i          (WDOGPSTRB_i    ),  //APBTARGEXP8PSTRB
  .WDOGPPROT_i          (WDOGPPROT_i    ),  //APBTARGEXP8PPROT
  .WDOGPRDATA_o         (WDOGPRDATA_o   ),  //APBTARGEXP8PRDATA
  .WDOGPREADY_o         (WDOGPREADY_o   ),  //APBTARGEXP8PREADY
  .WDOGPSLVERR_o        (WDOGPSLVERR_o  ),  //APBTARGEXP8PSLVERR

  //-----------------------------
  //Other/Functional peripheral module specific interfaces
  //-----------------------------
  //D(ual)TIMER
  .DTIMERECOREVNUM_i    (DTIMERECOREVNUM_i),  // ECO revision number
  .DTIMERTIMCLKEN1_i    (DTIMERTIMCLKEN1_i),  // Timer clock enable 1
  .DTIMERTIMCLKEN2_i    (DTIMERTIMCLKEN2_i),  // Timer clock enable 2
  .DTIMERTIMINT1_o      (DTIMERTIMINT1_o  ),  // Counter 1 interrupt
  .DTIMERTIMINT2_o      (DTIMERTIMINT2_o  ),  // Counter 2 interrupt
  .DTIMERTIMINTC_o      (DTIMERTIMINTC_o  ),  // Counter combined interrupt

  //-----------------------------
  //UART0
  .UART0ECOREVNUM_i     (UART0ECOREVNUM_i),  // Engineering-change-order revision bits
  .UART0RXD_i           (UART0RXD_i      ),  // Serial input
  .UART0TXD_o           (UART0TXD_o      ),  // Transmit data output
  .UART0TXEN_o          (UART0TXEN_o     ),  // Transmit enabled
  .UART0BAUDTICK_o      (UART0BAUDTICK_o ),  // Baud rate (x16) Tick
  .UART0TXINT_o         (UART0TXINT_o    ),  // Transmit Interrupt
  .UART0RXINT_o         (UART0RXINT_o    ),  // Receive Interrupt
  .UART0TXOVRINT_o      (UART0TXOVRINT_o ),  // Transmit overrun Interrupt
  .UART0RXOVRINT_o      (UART0RXOVRINT_o ),  // Receive overrun Interrupt
  .UART0UARTINT_o       (UART0UARTINT_o  ),  // Combined interrupt

  //-----------------------------
  //UART1
  .UART1ECOREVNUM_i     (UART1ECOREVNUM_i),  // Engineering-change-order revision bits
  .UART1RXD_i           (UART1RXD_i      ),  // Serial input
  .UART1TXD_o           (UART1TXD_o      ),  // Transmit data output
  .UART1TXEN_o          (UART1TXEN_o     ),  // Transmit enabled
  .UART1BAUDTICK_o      (UART1BAUDTICK_o ),  // Baud rate (x16) Tick
  .UART1TXINT_o         (UART1TXINT_o    ),  // Transmit Interrupt
  .UART1RXINT_o         (UART1RXINT_o    ),  // Receive Interrupt
  .UART1TXOVRINT_o      (UART1TXOVRINT_o ),  // Transmit overrun Interrupt
  .UART1RXOVRINT_o      (UART1RXOVRINT_o ),  // Receive overrun Interrupt
  .UART1UARTINT_o       (UART1UARTINT_o  ),  // Combined interrupt

  //----------------------------------------
  //W(atch)DOG
  .WDOGECOREVNUM_i      (WDOGECOREVNUM_i     ),  // ECO revision number
  .WDOGCLKEN_i          (WDOGCLKEN_i         ),  // Watchdog clock enable
  .WDOGINT_o            (WDOGINT_o           ),  // Watchdog interrupt
  .WDOGRES_o            (WDOGRES_o           ),  // Watchdog timeout reset


  //----------------------------------------
  //GPIO0
  .GPIO0ECOREVNUM_i     (GPIO0ECOREVNUM_i    ),  // Engineering-change-order revision bits
  .GPIO0PORTIN_i        (GPIO0PORTIN_i       ),  // GPIO Interface input
  .GPIO0PORTOUT_o       (GPIO0PORTOUT_o      ),  // GPIO output
  .GPIO0PORTEN_o        (GPIO0PORTEN_o       ),  // GPIO output enable
  .GPIO0PORTFUNC_o      (GPIO0PORTFUNC_o     ),  // Alternate function control
  .GPIO0GPIOINT_o       (GPIO0GPIOINT_o      ),  // Interrupt output for each pin
  .GPIO0COMBINT_o       (GPIO0COMBINT_o      ),  // Combined interrupt

  //----------------------------------------
  //GPIO1
  .GPIO1ECOREVNUM_i     (GPIO1ECOREVNUM_i    ),  // Engineering-change-order revision bits
  .GPIO1PORTIN_i        (GPIO1PORTIN_i       ),  // GPIO Interface input
  .GPIO1PORTOUT_o       (GPIO1PORTOUT_o      ),  // GPIO output
  .GPIO1PORTEN_o        (GPIO1PORTEN_o       ),  // GPIO output enable
  .GPIO1PORTFUNC_o      (GPIO1PORTFUNC_o     ),  // Alternate function control
  .GPIO1GPIOINT_o       (GPIO1GPIOINT_o      ),  // Interrupt output for each pin
  .GPIO1COMBINT_o       (GPIO1COMBINT_o      )   // Combined interrupt

);

endmodule
