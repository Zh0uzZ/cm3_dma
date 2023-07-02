//------------------------------------------------------------------------------
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//         (C) COPYRIGHT 2013,2017 ARM Limited or its affiliates.
//             ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//  Release Information : CM3DesignStart-r0p0-02rel0
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


module fpga_top (
    input wire fpga_clk,     // Free running clock
    input wire fpga_reset_n, // system reset

    // --------------------------------------------------------------------
    // UART
    // --------------------------------------------------------------------
    input wire uart_rxd_mcu,  // Microcontroller UART receive data
    input wire uart_rxd,      // UART receive data (uart1)

    // User expansion ports
    inout       [31:0] GPIO,
    // --------------------------------------------------------------------
    // UART
    // --------------------------------------------------------------------
    output wire        uart_txd_mcu,  // Microcontroller UART transmit data
    output wire        uart_txd       // UART transmit data (Uart1)

    // // ----------------------------------------------------------------------------
    // // Debug and Trace
    // // ----------------------------------------------------------------------------
    // input  wire          nTRST,                     // Test reset
    // input  wire          SWDITMS,                   // Test Mode Select/SWDIN
    // input  wire          SWCLKTCK,                  // Test clock / SWCLK
    // input  wire          TDI,                       // Test Data In

    // // Debug
    // output wire          TDO,                       // Test Data Out
    // output wire          nTDOEN,                    // Test Data Out Enable

    // // Single Wire
    // output wire          SWDO,                      // SingleWire data out
    // output wire          SWDOEN,                    // SingleWire output enable
    // output wire          JTAGNSW,                   // JTAG mode(1) or SW mode(0)

    // // Single Wire Viewer
    // output wire          SWV,                       // SingleWire Viewer Data

    // // TracePort Output
    // output wire          TRACECLK,                  // TracePort clock reference
    // output wire    [3:0] TRACEDATA                  // TracePort Data

);
  parameter CLK_FREQ = 100;
  parameter UART_SPEED = 20;

  parameter GPIO_ADDRESS = 32'hf0000000;
  parameter STS_ADDRESS = 32'hf0000004;


  //UART 1
  wire         uart_rxd;  // UART receive data (uart1)
  // User expansion ports
  // wire  [31:16]  GPIO;
  wire         uart_txd;  // UART transmit data (Uart1)


  // ----------------------------------------------------------------------------
  // Debug and Trace
  // ----------------------------------------------------------------------------
  wire         nTRST;  // Test reset
  wire         SWDITMS;  // Test Mode Select/SWDIN
  wire         SWCLKTCK;  // Test clock / SWCLK
  wire         TDI;  // Test Data In

  // Debug
  wire         TDO;  // Test Data Out
  wire         nTDOEN;  // Test Data Out Enable

  // Single Wire
  wire         SWDO;  // SingleWire data out
  wire         SWDOEN;  // SingleWire output enable
  wire         JTAGNSW;  // JTAG mode(1) or SW m

  // Single Wire Viewer
  wire         SWV;  // SingleWire Viewer Data

  // TracePort Output
  wire         TRACECLK;  // TracePort clock reference
  wire [  3:0] TRACEDATA;  // TracePort Data

  // --------------------------------------------------------------------
  // Integration signals
  // --------------------------------------------------------------------

  // Expansion AHB master
  wire         targexp0hsel;
  wire [ 31:0] targexp0haddr;
  wire [  1:0] targexp0htrans;
  wire         targexp0hwrite;
  wire [  2:0] targexp0hsize;
  wire [  2:0] targexp0hburst;
  wire [  3:0] targexp0hprot;
  wire [  1:0] targexp0memattr;
  wire         targexp0exreq;
  wire [  3:0] targexp0hmaster;
  wire [ 31:0] targexp0hwdata;
  wire         targexp0hmastlock;
  wire         targexp0hreadymux;
  wire         targexp0hauser;
  wire [  3:0] targexp0hwuser;
  wire [ 31:0] targexp0hrdata;
  wire         targexp0hreadyout;
  wire         targexp0hresp;
  wire         targexp0exresp;
  wire [  2:0] targexp0hruser;

  wire         targexp1hsel;
  wire [ 31:0] targexp1haddr;
  wire [  1:0] targexp1htrans;
  wire         targexp1hwrite;
  wire [  2:0] targexp1hsize;
  wire [  2:0] targexp1hburst;
  wire [  3:0] targexp1hprot;
  wire [  1:0] targexp1memattr;
  wire         targexp1exreq;
  wire [  3:0] targexp1hmaster;
  wire [ 31:0] targexp1hwdata;
  wire         targexp1hmastlock;
  wire         targexp1hreadymux;
  wire         targexp1hauser;
  wire [  3:0] targexp1hwuser;
  wire [ 31:0] targexp1hrdata;
  wire         targexp1hreadyout;
  wire         targexp1hresp;
  wire         targexp1exresp;
  wire [  2:0] targexp1hruser;

  // AHB slave input driven from dma read
  wire         initexp0hsel;
  wire [ 31:0] initexp0haddr;
  wire [  1:0] initexp0htrans;
  wire         initexp0hwrite;
  wire [  2:0] initexp0hsize;
  wire [  2:0] initexp0hburst;
  wire [ 31:0] initexp0hwdata;
  wire [  3:0] initexp0hprot;
  wire [  1:0] initexp0memattr;
  wire         initexp0exreq;
  wire [  3:0] initexp0hmaster;
  wire         initexp0hauser;
  wire [  3:0] initexp0hwuser;
  wire         initexp0exresp;
  wire [  2:0] initexp0hruser;
  wire         initexp0hmastlock;
  wire [ 31:0] initexp0hrdata;
  wire         initexp0hready;
  wire         initexp0hresp;

  // AHB slave input driven from dma write
  wire         initexp1hsel;
  wire [ 31:0] initexp1haddr;
  wire [  1:0] initexp1htrans;
  wire         initexp1hwrite;
  wire [  2:0] initexp1hsize;
  wire [  2:0] initexp1hburst;
  wire [ 31:0] initexp1hwdata;
  wire [  3:0] initexp1hprot;
  wire [  1:0] initexp1memattr;
  wire         initexp1exreq;
  wire [  3:0] initexp1hmaster;
  wire         initexp1hauser;
  wire [  3:0] initexp1hwuser;
  wire         initexp1exresp;
  wire [  2:0] initexp1hruser;
  wire         initexp1hmastlock;
  wire [ 31:0] initexp1hrdata;
  wire         initexp1hready;
  wire         initexp1hresp;

  // AHB slave input driven  from uart debug bridge
  wire         initexp2hsel;
  wire [ 31:0] initexp2haddr;
  wire [  1:0] initexp2htrans;
  wire         initexp2hwrite;
  wire [  2:0] initexp2hsize;
  wire [  2:0] initexp2hburst;
  wire [ 31:0] initexp2hwdata;
  wire [  3:0] initexp2hprot;
  wire [  1:0] initexp2memattr;
  wire         initexp2exreq;
  wire [  3:0] initexp2hmaster;
  wire         initexp2hauser;
  wire [  3:0] initexp2hwuser;
  wire         initexp2exresp;
  wire [  2:0] initexp2hruser;
  wire         initexp2hmastlock;
  wire [ 31:0] initexp2hrdata;
  wire         initexp2hready;
  wire         initexp2hresp;


  wire         apbtargexp2psel;
  wire         apbtargexp2penable;
  wire [ 11:0] apbtargexp2paddr;
  wire         apbtargexp2pwrite;
  wire [ 31:0] apbtargexp2pwdata;
  wire [ 31:0] apbtargexp2prdata;
  wire         apbtargexp2pready;
  wire         apbtargexp2pslverr;
  wire [  3:0] apbtargexp2pstrb;
  wire [  2:0] apbtargexp2pprot;
  wire         apbtargexp3psel;
  wire         apbtargexp3penable;
  wire [ 11:0] apbtargexp3paddr;
  wire         apbtargexp3pwrite;
  wire [ 31:0] apbtargexp3pwdata;
  wire [ 31:0] apbtargexp3prdata;
  wire         apbtargexp3pready;
  wire         apbtargexp3pslverr;
  wire [  3:0] apbtargexp3pstrb;
  wire [  2:0] apbtargexp3pprot;
  wire         apbtargexp4psel;
  wire         apbtargexp4penable;
  wire [ 11:0] apbtargexp4paddr;
  wire         apbtargexp4pwrite;
  wire [ 31:0] apbtargexp4pwdata;
  wire [ 31:0] apbtargexp4prdata;
  wire         apbtargexp4pready;
  wire         apbtargexp4pslverr;
  wire [  3:0] apbtargexp4pstrb;
  wire [  2:0] apbtargexp4pprot;
  wire         apbtargexp5psel;
  wire         apbtargexp5penable;
  wire [ 11:0] apbtargexp5paddr;
  wire         apbtargexp5pwrite;
  wire [ 31:0] apbtargexp5pwdata;
  wire [ 31:0] apbtargexp5prdata;
  wire         apbtargexp5pready;
  wire         apbtargexp5pslverr;
  wire [  3:0] apbtargexp5pstrb;
  wire [  2:0] apbtargexp5pprot;
  wire         apbtargexp6psel;
  wire         apbtargexp6penable;
  wire [ 11:0] apbtargexp6paddr;
  wire         apbtargexp6pwrite;
  wire [ 31:0] apbtargexp6pwdata;
  wire [ 31:0] apbtargexp6prdata;
  wire         apbtargexp6pready;
  wire         apbtargexp6pslverr;
  wire [  3:0] apbtargexp6pstrb;
  wire [  2:0] apbtargexp6pprot;
  wire         apbtargexp7psel;
  wire         apbtargexp7penable;
  wire [ 11:0] apbtargexp7paddr;
  wire         apbtargexp7pwrite;
  wire [ 31:0] apbtargexp7pwdata;
  wire [ 31:0] apbtargexp7prdata;
  wire         apbtargexp7pready;
  wire         apbtargexp7pslverr;
  wire [  3:0] apbtargexp7pstrb;
  wire [  2:0] apbtargexp7pprot;
  wire         apbtargexp8psel;
  wire         apbtargexp8penable;
  wire [ 11:0] apbtargexp8paddr;
  wire         apbtargexp8pwrite;
  wire [ 31:0] apbtargexp8pwdata;
  wire [ 31:0] apbtargexp8prdata;
  wire         apbtargexp8pready;
  wire         apbtargexp8pslverr;
  wire [  3:0] apbtargexp8pstrb;
  wire [  2:0] apbtargexp8pprot;
  wire         apbtargexp9psel;
  wire         apbtargexp9penable;
  wire [ 11:0] apbtargexp9paddr;
  wire         apbtargexp9pwrite;
  wire [ 31:0] apbtargexp9pwdata;
  wire [ 31:0] apbtargexp9prdata;
  wire         apbtargexp9pready;
  wire         apbtargexp9pslverr;
  wire [  3:0] apbtargexp9pstrb;
  wire [  2:0] apbtargexp9pprot;
  wire         apbtargexp10psel;
  wire         apbtargexp10penable;
  wire [ 11:0] apbtargexp10paddr;
  wire         apbtargexp10pwrite;
  wire [ 31:0] apbtargexp10pwdata;
  wire [ 31:0] apbtargexp10prdata;
  wire         apbtargexp10pready;
  wire         apbtargexp10pslverr;
  wire [  3:0] apbtargexp10pstrb;
  wire [  2:0] apbtargexp10pprot;
  wire         apbtargexp11psel;
  wire         apbtargexp11penable;
  wire [ 11:0] apbtargexp11paddr;
  wire         apbtargexp11pwrite;
  wire [ 31:0] apbtargexp11pwdata;
  wire [ 31:0] apbtargexp11prdata;
  wire         apbtargexp11pready;
  wire         apbtargexp11pslverr;
  wire [  3:0] apbtargexp11pstrb;
  wire [  2:0] apbtargexp11pprot;
  wire         apbtargexp12psel;
  wire         apbtargexp12penable;
  wire [ 11:0] apbtargexp12paddr;
  wire         apbtargexp12pwrite;
  wire [ 31:0] apbtargexp12pwdata;
  wire [ 31:0] apbtargexp12prdata;
  wire         apbtargexp12pready;
  wire         apbtargexp12pslverr;
  wire [  3:0] apbtargexp12pstrb;
  wire [  2:0] apbtargexp12pprot;
  wire         apbtargexp13psel;
  wire         apbtargexp13penable;
  wire [ 11:0] apbtargexp13paddr;
  wire         apbtargexp13pwrite;
  wire [ 31:0] apbtargexp13pwdata;
  wire [ 31:0] apbtargexp13prdata;
  wire         apbtargexp13pready;
  wire         apbtargexp13pslverr;
  wire [  3:0] apbtargexp13pstrb;
  wire [  2:0] apbtargexp13pprot;
  wire         apbtargexp14psel;
  wire         apbtargexp14penable;
  wire [ 11:0] apbtargexp14paddr;
  wire         apbtargexp14pwrite;
  wire [ 31:0] apbtargexp14pwdata;
  wire [ 31:0] apbtargexp14prdata;
  wire         apbtargexp14pready;
  wire         apbtargexp14pslverr;
  wire [  3:0] apbtargexp14pstrb;
  wire [  2:0] apbtargexp14pprot;
  wire         apbtargexp15psel;
  wire         apbtargexp15penable;
  wire [ 11:0] apbtargexp15paddr;
  wire         apbtargexp15pwrite;
  wire [ 31:0] apbtargexp15pwdata;
  wire [ 31:0] apbtargexp15prdata;
  wire         apbtargexp15pready;
  wire         apbtargexp15pslverr;
  wire [  3:0] apbtargexp15pstrb;
  wire [  2:0] apbtargexp15pprot;

  // peripheral interconnections
  wire [239:0] cpu0intisr;
  wire         cpu0intnmi;

  wire w_uart0_rxint, w_uart0_rxovrint;
  wire w_uart0_txint, w_uart0_txovrint;
  wire w_uart1_rxint, w_uart1_rxovrint;
  wire w_uart1_txint, w_uart1_txovrint;
  wire [15:0] w_gpio0_portint, w_gpio1_portint;

  wire       DEBUG_ALLOWED;  // When 1, debug is allowed. Controlled by emulated e-fuse.
                             // Can be override using TESTMODE
  wire       w_DEBUG_CONNECTED;
  wire       cpu0edbgrq;  // Debug request to CPU

  wire       cpu0halted;  // CPU halted
  wire       trcena;  // Trace Enable


  wire [3:1] mtx_remap;

  wire       cpu0lockup;
  wire       wdog_reset_req;

  wire       cpu0sysresetreq;
  wire       cpu0cdbgpwrupreq;  // Debug Power Domain up request
  wire       cpu0cdbgpwrupack;  // Debug Power Domain up acknowledge

  wire       cpu0_bigend;


  //---------------------------------------------------
  // Clock
  //---------------------------------------------------

  // There are no gated clocks.
  wire       fclk;
  wire       PCLKG;
  // wire UART0_CLK;
  pll u_clock (
      .reset(~fpga_reset_n),


      .fpga_clk(fpga_clk),
      .CPU_CLK (fclk),
      .APB_CLK (PCLKG),
      .UART_CLK(),
      .locked  (cpu_reset_n)
  );


  wire MTXHCLK = fclk;
  wire FLASHHCLK = fclk;
  wire SYSCTRLHCLK = fclk;
  wire TIMER0PCLK = fclk;
  wire TIMER0PCLKG = fclk;
  wire TIMER1PCLK = fclk;
  wire TIMER1PCLKG = fclk;
  wire PCLK = fclk;
  // wire PCLKG         = fclk;
  wire AHB2APBHCLK = fclk;
  wire CPU0FCLK = fclk;
  wire CPU0HCLK = fclk;
  wire TPIUTRACECLKIN = fclk;
  wire DTIMER_CLK = fclk;
  wire UART0_CLK = fclk;
  wire UART1_CLK = fclk;
  wire RTC_CLK = fclk;
  wire I2C0_CLK = fclk;
  wire I2C1_CLK = fclk;
  wire WDOG_CLK = fclk;
  wire SPI0_CLK = fclk;
  wire SPI1_CLK = fclk;
  wire TRNG_CLK = fclk;
  wire GPIO0_FCLK = fclk;
  wire GPIO1_FCLK = fclk;
  wire GPIO2_FCLK = fclk;
  wire GPIO3_FCLK = fclk;
  wire GPIO0_HCLK = fclk;
  wire GPIO1_HCLK = fclk;
  wire GPIO2_HCLK = fclk;
  wire GPIO3_HCLK = fclk;
  wire SYSCTRL_FCLK = fclk;

  //
  reg  reg_sys_rst_n;  // System reset
  reg  reg_cpu0_rst_n;  // CPU reset

  wire sys_reset_req = cpu0sysresetreq;
  // FPGA system level reset
  // This is controlled by fpga_npor because we want to download code
  // to ZBTRAM via SPI after CB_nPOR released, and before CB_nRST is released.
  always @(posedge fclk or negedge reg_cpu0_rst_n) begin
    if (~reg_cpu0_rst_n) reg_sys_rst_n <= 1'b0;
    else if (sys_reset_req | wdog_reset_req | (cpu0lockup)) reg_sys_rst_n <= 1'b0;
    else reg_sys_rst_n <= 1'b1;
  end

  // RESETn for CPU #0 - This is released after CB_nRST deasserted.
  // You can also add addition reset control here.
  always @(posedge fclk or negedge cpu_reset_n) begin
    if (~cpu_reset_n) reg_cpu0_rst_n <= 1'b0;
    else if (sys_reset_req | wdog_reset_req | (cpu0lockup)) reg_cpu0_rst_n <= 1'b0;
    else reg_cpu0_rst_n <= 1'b1;
  end

  // Explicit reset connections for each peripheral
  wire        CPU0SYSRESETn = reg_cpu0_rst_n;  // For CPU only - release after CB_nRST
  wire        CPU0PORESETn = cpu_reset_n;  // For CPU only - release after CB_nRST
  wire        MTXHRESETn = reg_sys_rst_n;
  wire        TIMER0PRESETn = reg_sys_rst_n;
  wire        TIMER1PRESETn = reg_sys_rst_n;

  wire        DTIMERPRESETn = reg_sys_rst_n;
  wire        UART0PRESETn = reg_sys_rst_n;
  wire        UART1PRESETn = reg_sys_rst_n;
  wire        WDOGPRESETn = reg_sys_rst_n;
  wire        WDOGRESn = reg_sys_rst_n;

  wire        GPIO0PRESETn = reg_sys_rst_n;
  wire        GPIO1PRESETn = reg_sys_rst_n;
  wire        AHBPRESETn = reg_sys_rst_n;


  // --------------------------------------------------------------------
  // Tie-offs and configuration for Cortex-M3
  // --------------------------------------------------------------------

  // SysTick Calibration for 25 MHz FCLK (STCLK is an enable, must be synchronous to FCLK or tied)
  wire        CPU0STCLK = 1'b1;  // No alternative clock source
  wire [25:0] CPU0STCALIB;
  assign CPU0STCALIB[25]   = 1'b1;  // No alternative clock source
  assign CPU0STCALIB[24]   = 1'b0;  // Exact multiple of 10ms from FCLK
  assign CPU0STCALIB[23:0] = 24'h03D08F;  // calibration value for 25 MHz source

  wire        CPU0DBGRESTART = 1'b0;  // Not needed in a single CPU system.

  // AUXFAULT: Connect to fault status generating logic if required.
  //Result appears in the Auxiliary Fault Status
  //Register at address 0xE000ED3C. A one-cycle pulse of
  //information results in the information being stored
  //in the corresponding bit until a write-clear occurs.
  wire [31:0] CPU0AUXFAULT = {32{1'b0}};

  // Active HIGH signal to the PMU that indicates a wake-up event has occurred and the system
  // requires clocks and power
  wire        CPU0WAKEUP;
  // Active HIGH request for deep sleep to be WIC-based deep sleep. This should be driven from a PMU.
  wire        CPU0WICENREQ = 1'b0;

  // WIC status
  wire        CPU0WICENACK;  // For observation only. WIC is within the sybsystem
  wire [66:0] CPU0WICSENSE;  // For observation only. WIC is within the sybsystem


  // CoreSight requires a loopback from REQ to ACK for a minimal
  // debug power control implementation
  assign cpu0cdbgpwrupack = cpu0cdbgpwrupreq;

  wire [ 2:0] TEST_CTRL;
  wire [31:0] ahbper0_reg;
  wire [31:0] apbper0_reg;
  wire        timer0extin = io_exp_port_i[1];
  wire        timer0privmoden = apbper0_reg[0];  // Timer0 secure
  wire        timer1extin = io_exp_port_i[6];
  wire        timer1privmoden = apbper0_reg[1];  // Timer1 secure
  wire        wdog_interrupt;
  wire        i2s_interrupt;
  wire [11:0] uart_interrupts;
  wire        eth_interrupt;
  wire [15:0] GPIO0PORTIN_i;
  wire [15:0] GPIO0PORTOUT_o;
  wire [15:0] GPIO0PORTEN_o;
  wire [15:0] GPIO1PORTIN_i;
  wire [15:0] GPIO1PORTOUT_o;
  wire [15:0] GPIO1PORTEN_o;


  // Tie-off configuration inputs to IoT subsystem
  wire        cpu0mpudisable = 1'b0;  // Tie high to emulate processor with no MPU
  wire        cpu0fixmastertype = 1'b0;
  wire        cpu0isolaten = 1'b1;
  wire        cpu0retainn = 1'b1;
  assign mtx_remap = {3{1'b0}};

  // DFT is tied off in this example
  // Typically routed to top level in ASIC
  wire DFTSCANMODE = 1'b0;
  wire DFTCGEN = 1'b0;
  wire DFTSE = 1'b0;
  // Power and sleep management
  wire cpu0sleepholdreqn = 1'b1;
  wire cpu0rxev = 1'b0;
  assign cpu0edbgrq = 1'b0;
  // Debug Authentication
  wire cpu0dbgen = 1'b1;  // Enable for Halting Debug
  wire cpu0niden = 1'b1;  // Must be high to access non-invasive debug


  //

  wire dma_int;
  // --------------------------------------------------------------------
  // Map individual interrupts to processor interrupt inputs
  // --------------------------------------------------------------------
  assign cpu0intisr[0] = w_uart0_txint | w_uart0_rxint;
  assign cpu0intisr[1] = 1'b0;
  assign cpu0intisr[2] = w_uart1_txint | w_uart1_rxint;
  assign cpu0intisr[3] = 1'b0;  // unused
  assign cpu0intisr[4] = 1'b0;  // unused
  assign cpu0intisr[11] = 1'b0;  // unused
  assign      cpu0intisr[12]    = w_uart0_txovrint   | w_uart0_rxovrint   |
                                  w_uart1_txovrint   | w_uart1_rxovrint   |
                                  uart_interrupts[7] | uart_interrupts[6] |
                                  uart_interrupts[9] | uart_interrupts[8] |
                                  uart_interrupts[11] | uart_interrupts[10];// UART 0,1,2,3,4 overflow
  assign cpu0intisr[13] = 1'b0;  //Unused
  assign cpu0intisr[14] = 1'b0;  //Unused
  assign cpu0intisr[15] = dma_int;  // DMA INT
  assign cpu0intisr[31:16] = w_gpio0_portint;
  assign cpu0intisr[41:34] = {8{1'b0}};  //Reserved for CORDIO
  assign cpu0intisr[45] = uart_interrupts[0] | uart_interrupts[1];  // UART2 TX and RX
  assign cpu0intisr[46] = uart_interrupts[2] | uart_interrupts[3];  // UART3 TX and RX
  assign cpu0intisr[47] = eth_interrupt;  // MPS2 Ethernet interrupt
  assign cpu0intisr[48] = i2s_interrupt;  // MPS2 I2C interrupt
  assign cpu0intisr[56] = uart_interrupts[4] | uart_interrupts[5];  // UART4 TX and RX
  assign cpu0intisr[239:57] = {183{1'b0}};

  // --------------------------------------------------------------------
  // Tie-off the AHB Slave expansion reserved for communication interface/DMA
  // --------------------------------------------------------------------
  // assign initexp0hsel      = 1'b0;
  // assign initexp0htrans    = 2'b00;
  assign initexp0hwrite = 1'b0;
  // assign initexp0haddr     = {32{1'b0}};
  // assign initexp0hsize     = {3{1'b0}};
  // assign initexp0hburst    = {3{1'b0}};
  assign initexp0hprot = {4{1'b0}};
  assign initexp0memattr = {2{1'b0}};
  assign initexp0exreq = 1'b0;
  assign initexp0hmaster = {4'b0};
  assign initexp0hwdata = {32{1'b0}};
  assign initexp0hmastlock = 1'b0;
  assign initexp0hauser = 1'b0;
  assign initexp0hwuser = {4{1'b0}};



  // assign initexp1hsel      = 1'b0;
  // assign initexp1htrans    = 2'b00;
  // assign initexp1hwrite    = 1'b0;

  assign initexp1hprot = {4{1'b0}};
  assign initexp1memattr = {2{1'b0}};
  assign initexp1exreq = 1'b0;
  assign initexp1hmaster = {4'b0};
  // assign initexp1hwdata    = {32{1'b0}};
  assign initexp1hmastlock = 1'b0;
  assign initexp1hauser = 1'b0;
  assign initexp1hwuser = {4{1'b0}};
  assign initexp1hauser = 1'b0;
  assign initexp1hwuser = {4{1'b0}};


  // AHB MTX (<-> SRAM2)
  wire        targsram2hsel;
  wire [31:0] targsram2haddr;
  wire [ 1:0] targsram2htrans;
  wire        targsram2hwrite;
  wire [ 2:0] targsram2hsize;
  wire [31:0] targsram2hwdata;
  wire        targsram2hreadymux;
  wire        targsram2hreadyout;
  wire [31:0] targsram2hrdata;
  wire        targsram2hresp;
  wire        targsram2exresp_int;

  wire [ 2:0] targsram2hruser_int;

  // AHB MTX (<-> SRAM3)
  wire        targsram3hsel;
  wire [31:0] targsram3haddr;
  wire [ 1:0] targsram3htrans;
  wire        targsram3hwrite;
  wire [ 2:0] targsram3hsize;
  wire [31:0] targsram3hwdata;
  wire        targsram3hreadymux;
  wire        targsram3hreadyout;
  wire [31:0] targsram3hrdata;
  wire        targsram3hresp;
  wire        targsram3exresp_int;

  wire [ 2:0] targsram3hruser_int;

  // // --------------------------------------------------------------------
  // // Code Download from external MCU over SPI
  // // This drives one of the AHB slave ports on the IoT subsystem
  // // --------------------------------------------------------------------
  // fpga_spi_ahb u_fpga_spi_ahb (

  //   .HCLK                 (fclk),
  //   .nPOR                 (reg_sys_rst_n),
  //   .CONFIG_SPICLK        (config_spiclk),
  //   .CONFIG_SPIDI         (config_spidi),
  //   .CONFIG_SPIDO         (config_spido),

  //   .HSELM                (initexp1hsel),
  //   .HADDRM               (initexp1haddr),
  //   .HTRANSM              (initexp1htrans),
  //   .HMASTERM             (initexp1hmaster),
  //   .HWRITEM              (initexp1hwrite),
  //   .HSIZEM               (initexp1hsize),
  //   .HMASTLOCKM           (initexp1hmastlock),
  //   .HWDATAM              (initexp1hwdata),
  //   .HBURSTM              (initexp1hburst),
  //   .HPROTM               (initexp1hprot),
  //   .MEMATTRM             (initexp1memattr),
  //   .EXREQM               (initexp1exreq),
  //   .HREADYM              (initexp1hready),
  //   .HRDATAM              (initexp1hrdata),
  //   .HRESPM               (initexp1hresp),
  //   .EXRESPM              (initexp1exresp)
  // );

  // --------------------------------------------------------------------
  // Tie-off unused APB master ports 7, 11,12,13,14
  // --------------------------------------------------------------------
  // assign apbtargexp7pready  = 1'b1;
  assign apbtargexp11prdata = {32{1'b0}};
  assign apbtargexp11pready = 1'b1;
  assign apbtargexp11pslverr = 1'b0;
  assign apbtargexp12prdata = {32{1'b0}};
  assign apbtargexp12pready = 1'b1;
  assign apbtargexp12pslverr = 1'b0;
  assign apbtargexp13prdata = {32{1'b0}};
  assign apbtargexp13pready = 1'b1;
  assign apbtargexp13pslverr = 1'b0;
  assign apbtargexp14prdata = {32{1'b0}};
  assign apbtargexp14pready = 1'b1;
  assign apbtargexp14pslverr = 1'b0;


  // --------------------------------------------------------------------
  // Tie-off unused expansion master port signals
  // --------------------------------------------------------------------
  assign targexp1exresp = 1'b0;
  assign targexp1hruser = {3{1'b0}};


  assign apbtargexp7pslverr = 1'b0;
  DMA u_dma (
      .PCLK(PCLK),
      .PRESETn(reg_sys_rst_n),
      .PSEL(apbtargexp7psel),
      .PADDR(apbtargexp7paddr),
      .PWRITE(apbtargexp7pwrite),
      .PWDATA(apbtargexp7pwdata),
      .PREADY(apbtargexp7pready),
      .PRDATA(apbtargexp7prdata),

      .HSEL_R  (initexp0hsel),
      .HADDR_R (initexp0haddr),
      .HBURST_R(initexp0hburst),
      .HSIZE_R (initexp0hsize),
      .HTRANS_R(initexp0htrans),
      .HRDATA_R(initexp0hrdata),
      .HREADY_R(initexp0hready),

      .HSEL_W  (initexp1hsel),
      .HADDR_W (initexp1haddr),
      .HBURST_W(initexp1hburst),
      .HSIZE_W (initexp1hsize),
      .HTRANS_W(initexp1htrans),
      .HWRITE_W(initexp1hwrite),
      .HWDATA_W(initexp1hwdata),
      .HREADY_W(initexp1hready),

      .DMA_INT(dma_int)

  );


  // Debug Bridge with Uart

  dbg_bridge #(
      .CLK_FREQ(CLK_FREQ),
      .UART_SPEED(UART_SPEED),
      .GPIO_ADDRESS(GPIO_ADDRESS),
      .STS_ADDRESS(STS_ADDRESS)
  ) u_dbg_bridge (
      .clk_i(PCLK),
      .rst_i(reg_sys_rst_n),

      // input/output
      .uart_rxd_i(uart_rxd),
      .uart_txd_o(uart_txd),
      .gpio_inputs_i(),
      .gpio_outputs_o(),

      // AHB signals
      // output signals
      .dbg_hsel  (initexp2hsel),
      .dbg_haddr (initexp2haddr),
      .dbg_htrans(initexp2htrans),
      .dbg_hwrite(initexp2hwrite),
      .dbg_hsize (initexp2hsize),
      .dbg_hburst(initexp2hburst),
      .dbg_hwdata(initexp2hwdata),
      .dbg_hwuser(initexp2hwuser),

      // input signals
      .dbg_hrdata(initexp2hrdata),
      .dbg_hready(1'b1),
      .dbg_hresp (initexp2hresp)
  );

  // --------------------------------------------------------------------
  // Simplified SSE-050 subsystem
  //
  // An ASIC design can replace this module with SSE-050
  // --------------------------------------------------------------------

  cm3_top u_cm3_top (
      .CPU0FCLK       (CPU0FCLK),
      .CPU0HCLK       (CPU0HCLK),
      .TPIUTRACECLKIN (TPIUTRACECLKIN),
      .CPU0PORESETn   (CPU0PORESETn),
      .CPU0SYSRESETn  (CPU0SYSRESETn),
      .CPU0STCLK      (CPU0STCLK),
      .CPU0STCALIB    (CPU0STCALIB),
      .MTXHCLK        (MTXHCLK),
      .MTXHRESETn     (MTXHRESETn),
      .AHB2APBHCLK    (AHB2APBHCLK),
      .PCLKEN         (1'b1),
      .TIMER0PCLK     (TIMER0PCLK),
      .TIMER0PCLKG    (TIMER0PCLKG),
      .TIMER0PRESETn  (TIMER0PRESETn),
      .TIMER1PCLK     (TIMER1PCLK),
      .TIMER1PCLKG    (TIMER1PCLKG),
      .TIMER1PRESETn  (TIMER1PRESETn),
      .TIMER0EXTIN    (timer0extin),
      .TIMER0PRIVMODEN(timer0privmoden),
      .TIMER1EXTIN    (timer1extin),
      .TIMER1PRIVMODEN(timer1privmoden),
      .TIMER0TIMERINT (cpu0intisr[8]),
      .TIMER1TIMERINT (cpu0intisr[9]),

      .TARGEXP0HSEL     (targexp0hsel),
      .TARGEXP0HADDR    (targexp0haddr),
      .TARGEXP0HTRANS   (targexp0htrans),
      .TARGEXP0HWRITE   (targexp0hwrite),
      .TARGEXP0HSIZE    (targexp0hsize),
      .TARGEXP0HBURST   (targexp0hburst),
      .TARGEXP0HPROT    (targexp0hprot),
      .TARGEXP0MEMATTR  (targexp0memattr),
      .TARGEXP0EXREQ    (targexp0exreq),
      .TARGEXP0HMASTER  (targexp0hmaster),
      .TARGEXP0HWDATA   (targexp0hwdata),
      .TARGEXP0HMASTLOCK(targexp0hmastlock),
      .TARGEXP0HREADYMUX(targexp0hreadymux),
      .TARGEXP0HAUSER   (targexp0hauser),
      .TARGEXP0HWUSER   (targexp0hwuser),
      .TARGEXP0HRDATA   (targexp0hrdata),
      .TARGEXP0HREADYOUT(targexp0hreadyout),
      .TARGEXP0HRESP    (targexp0hresp),
      .TARGEXP0EXRESP   (targexp0exresp),
      .TARGEXP0HRUSER   (targexp0hruser),
      .TARGEXP1HSEL     (targexp1hsel),
      .TARGEXP1HADDR    (targexp1haddr),
      .TARGEXP1HTRANS   (targexp1htrans),
      .TARGEXP1HWRITE   (targexp1hwrite),
      .TARGEXP1HSIZE    (targexp1hsize),
      .TARGEXP1HBURST   (targexp1hburst),
      .TARGEXP1HPROT    (targexp1hprot),
      .TARGEXP1MEMATTR  (targexp1memattr),
      .TARGEXP1EXREQ    (targexp1exreq),
      .TARGEXP1HMASTER  (targexp1hmaster),
      .TARGEXP1HWDATA   (targexp1hwdata),
      .TARGEXP1HMASTLOCK(targexp1hmastlock),
      .TARGEXP1HREADYMUX(targexp1hreadymux),
      .TARGEXP1HAUSER   (targexp1hauser),
      .TARGEXP1HWUSER   (targexp1hwuser),
      .TARGEXP1HRDATA   (targexp1hrdata),
      .TARGEXP1HREADYOUT(targexp1hreadyout),
      .TARGEXP1HRESP    (targexp1hresp),
      .TARGEXP1EXRESP   (targexp1exresp),
      .TARGEXP1HRUSER   (targexp1hruser),


      .INITEXP0HSEL     (initexp0hsel),
      .INITEXP0HADDR    (initexp0haddr),
      .INITEXP0HTRANS   (initexp0htrans),
      .INITEXP0HWRITE   (initexp0hwrite),
      .INITEXP0HSIZE    (initexp0hsize),
      .INITEXP0HBURST   (initexp0hburst),
      .INITEXP0HPROT    (initexp0hprot),
      .INITEXP0MEMATTR  (initexp0memattr),
      .INITEXP0EXREQ    (initexp0exreq),
      .INITEXP0HMASTER  (initexp0hmaster),
      .INITEXP0HWDATA   (initexp0hwdata),
      .INITEXP0HMASTLOCK(initexp0hmastlock),
      .INITEXP0HAUSER   (initexp0hauser),
      .INITEXP0HWUSER   (initexp0hwuser),
      .INITEXP0HRDATA   (initexp0hrdata),
      .INITEXP0HREADY   (initexp0hready),
      .INITEXP0HRESP    (initexp0hresp),
      .INITEXP0EXRESP   (initexp0exresp),
      .INITEXP0HRUSER   (initexp0hruser),


      .INITEXP1HSEL     (initexp1hsel),
      .INITEXP1HADDR    (initexp1haddr),
      .INITEXP1HTRANS   (initexp1htrans),
      .INITEXP1HWRITE   (initexp1hwrite),
      .INITEXP1HSIZE    (initexp1hsize),
      .INITEXP1HBURST   (initexp1hburst),
      .INITEXP1HPROT    (initexp1hprot),
      .INITEXP1MEMATTR  (initexp1memattr),
      .INITEXP1EXREQ    (initexp1exreq),
      .INITEXP1HMASTER  (initexp1hmaster),
      .INITEXP1HWDATA   (initexp1hwdata),
      .INITEXP1HMASTLOCK(initexp1hmastlock),
      .INITEXP1HAUSER   (initexp1hauser),
      .INITEXP1HWUSER   (initexp1hwuser),
      .INITEXP1HRDATA   (initexp1hrdata),
      .INITEXP1HREADY   (initexp1hready),
      .INITEXP1HRESP    (initexp1hresp),
      .INITEXP1EXRESP   (initexp1exresp),
      .INITEXP1HRUSER   (initexp1hruser),


      .INITEXP2HSEL     (initexp2hsel),
      .INITEXP2HADDR    (initexp2haddr),
      .INITEXP2HTRANS   (initexp2htrans),
      .INITEXP2HWRITE   (initexp2hwrite),
      .INITEXP2HSIZE    (initexp2hsize),
      .INITEXP2HBURST   (initexp2hburst),
      .INITEXP2HPROT    (initexp2hprot),
      .INITEXP2MEMATTR  (initexp2memattr),
      .INITEXP2EXREQ    (initexp2exreq),
      .INITEXP2HMASTER  (initexp2hmaster),
      .INITEXP2HWDATA   (initexp2hwdata),
      .INITEXP2HMASTLOCK(initexp2hmastlock),
      .INITEXP2HAUSER   (initexp2hauser),
      .INITEXP2HWUSER   (initexp2hwuser),
      .INITEXP2HRDATA   (initexp2hrdata),
      .INITEXP2HREADY   (initexp2hready),
      .INITEXP2HRESP    (initexp2hresp),
      .INITEXP2EXRESP   (initexp2exresp),
      .INITEXP2HRUSER   (initexp2hruser),


      .TARGSRAM2HSEL     (targsram2hsel),
      .TARGSRAM2HADDR    (targsram2haddr),
      .TARGSRAM2HTRANS   (targsram2htrans),
      .TARGSRAM2HMASTER  (  /*Not supported*/),
      .TARGSRAM2HWRITE   (targsram2hwrite),
      .TARGSRAM2HSIZE    (targsram2hsize),
      .TARGSRAM2HMASTLOCK(  /*Not supported*/),
      .TARGSRAM2HWDATA   (targsram2hwdata),
      .TARGSRAM2HBURST   (  /*Not supported*/),
      .TARGSRAM2HPROT    (  /*Not supported*/),
      .TARGSRAM2MEMATTR  (  /*Not supported*/),
      .TARGSRAM2EXREQ    (  /*Not supported*/),
      .TARGSRAM2HREADYMUX(targsram2hreadymux),
      .TARGSRAM2HREADYOUT(targsram2hreadyout),
      .TARGSRAM2HRDATA   (targsram2hrdata),
      .TARGSRAM2HRESP    (targsram2hresp),
      .TARGSRAM2EXRESP   (targsram2exresp_int),
      .TARGSRAM2HAUSER   (  /*Not supported*/),
      .TARGSRAM2HWUSER   (  /*Not supported*/),
      .TARGSRAM2HRUSER   (targsram2hruser_int),

      .TARGSRAM3HSEL     (targsram3hsel),
      .TARGSRAM3HADDR    (targsram3haddr),
      .TARGSRAM3HTRANS   (targsram3htrans),
      .TARGSRAM3HMASTER  (  /*Not supported*/),
      .TARGSRAM3HWRITE   (targsram3hwrite),
      .TARGSRAM3HSIZE    (targsram3hsize),
      .TARGSRAM3HMASTLOCK(  /*Not supported*/),
      .TARGSRAM3HWDATA   (targsram3hwdata),
      .TARGSRAM3HBURST   (  /*Not supported*/),
      .TARGSRAM3HPROT    (  /*Not supported*/),
      .TARGSRAM3MEMATTR  (  /*Not supported*/),
      .TARGSRAM3EXREQ    (  /*Not supported*/),
      .TARGSRAM3HREADYMUX(targsram3hreadymux),
      .TARGSRAM3HREADYOUT(targsram3hreadyout),
      .TARGSRAM3HRDATA   (targsram3hrdata),
      .TARGSRAM3HRESP    (targsram3hresp),
      .TARGSRAM3EXRESP   (targsram3exresp_int),
      .TARGSRAM3HAUSER   (  /*Not supported*/),
      .TARGSRAM3HWUSER   (  /*Not supported*/),
      .TARGSRAM3HRUSER   (targsram3hruser_int),



      .APBTARGEXP2PSEL    (apbtargexp2psel),
      .APBTARGEXP2PENABLE (apbtargexp2penable),
      .APBTARGEXP2PADDR   (apbtargexp2paddr),
      .APBTARGEXP2PWRITE  (apbtargexp2pwrite),
      .APBTARGEXP2PWDATA  (apbtargexp2pwdata),
      .APBTARGEXP2PRDATA  (apbtargexp2prdata),
      .APBTARGEXP2PREADY  (apbtargexp2pready),
      .APBTARGEXP2PSLVERR (apbtargexp2pslverr),
      .APBTARGEXP2PSTRB   (apbtargexp2pstrb),
      .APBTARGEXP2PPROT   (apbtargexp2pprot),
      .APBTARGEXP3PSEL    (apbtargexp3psel),
      .APBTARGEXP3PENABLE (apbtargexp3penable),
      .APBTARGEXP3PADDR   (apbtargexp3paddr),
      .APBTARGEXP3PWRITE  (apbtargexp3pwrite),
      .APBTARGEXP3PWDATA  (apbtargexp3pwdata),
      .APBTARGEXP3PRDATA  (apbtargexp3prdata),
      .APBTARGEXP3PREADY  (apbtargexp3pready),
      .APBTARGEXP3PSLVERR (apbtargexp3pslverr),
      .APBTARGEXP3PSTRB   (apbtargexp3pstrb),
      .APBTARGEXP3PPROT   (apbtargexp3pprot),
      .APBTARGEXP4PSEL    (apbtargexp4psel),
      .APBTARGEXP4PENABLE (apbtargexp4penable),
      .APBTARGEXP4PADDR   (apbtargexp4paddr),
      .APBTARGEXP4PWRITE  (apbtargexp4pwrite),
      .APBTARGEXP4PWDATA  (apbtargexp4pwdata),
      .APBTARGEXP4PRDATA  (apbtargexp4prdata),
      .APBTARGEXP4PREADY  (apbtargexp4pready),
      .APBTARGEXP4PSLVERR (apbtargexp4pslverr),
      .APBTARGEXP4PSTRB   (apbtargexp4pstrb),
      .APBTARGEXP4PPROT   (apbtargexp4pprot),
      .APBTARGEXP5PSEL    (apbtargexp5psel),
      .APBTARGEXP5PENABLE (apbtargexp5penable),
      .APBTARGEXP5PADDR   (apbtargexp5paddr),
      .APBTARGEXP5PWRITE  (apbtargexp5pwrite),
      .APBTARGEXP5PWDATA  (apbtargexp5pwdata),
      .APBTARGEXP5PRDATA  (apbtargexp5prdata),
      .APBTARGEXP5PREADY  (apbtargexp5pready),
      .APBTARGEXP5PSLVERR (apbtargexp5pslverr),
      .APBTARGEXP5PSTRB   (apbtargexp5pstrb),
      .APBTARGEXP5PPROT   (apbtargexp5pprot),
      .APBTARGEXP6PSEL    (apbtargexp6psel),
      .APBTARGEXP6PENABLE (apbtargexp6penable),
      .APBTARGEXP6PADDR   (apbtargexp6paddr),
      .APBTARGEXP6PWRITE  (apbtargexp6pwrite),
      .APBTARGEXP6PWDATA  (apbtargexp6pwdata),
      .APBTARGEXP6PRDATA  (apbtargexp6prdata),
      .APBTARGEXP6PREADY  (apbtargexp6pready),
      .APBTARGEXP6PSLVERR (apbtargexp6pslverr),
      .APBTARGEXP6PSTRB   (apbtargexp6pstrb),
      .APBTARGEXP6PPROT   (apbtargexp6pprot),
      .APBTARGEXP7PSEL    (apbtargexp7psel),
      .APBTARGEXP7PENABLE (apbtargexp7penable),
      .APBTARGEXP7PADDR   (apbtargexp7paddr),
      .APBTARGEXP7PWRITE  (apbtargexp7pwrite),
      .APBTARGEXP7PWDATA  (apbtargexp7pwdata),
      .APBTARGEXP7PRDATA  (apbtargexp7prdata),
      .APBTARGEXP7PREADY  (apbtargexp7pready),
      .APBTARGEXP7PSLVERR (apbtargexp7pslverr),
      .APBTARGEXP7PSTRB   (apbtargexp7pstrb),
      .APBTARGEXP7PPROT   (apbtargexp7pprot),
      .APBTARGEXP8PSEL    (apbtargexp8psel),
      .APBTARGEXP8PENABLE (apbtargexp8penable),
      .APBTARGEXP8PADDR   (apbtargexp8paddr),
      .APBTARGEXP8PWRITE  (apbtargexp8pwrite),
      .APBTARGEXP8PWDATA  (apbtargexp8pwdata),
      .APBTARGEXP8PRDATA  (apbtargexp8prdata),
      .APBTARGEXP8PREADY  (apbtargexp8pready),
      .APBTARGEXP8PSLVERR (apbtargexp8pslverr),
      .APBTARGEXP8PSTRB   (apbtargexp8pstrb),
      .APBTARGEXP8PPROT   (apbtargexp8pprot),
      .APBTARGEXP9PSEL    (apbtargexp9psel),
      .APBTARGEXP9PENABLE (apbtargexp9penable),
      .APBTARGEXP9PADDR   (apbtargexp9paddr),
      .APBTARGEXP9PWRITE  (apbtargexp9pwrite),
      .APBTARGEXP9PWDATA  (apbtargexp9pwdata),
      .APBTARGEXP9PRDATA  (apbtargexp9prdata),
      .APBTARGEXP9PREADY  (apbtargexp9pready),
      .APBTARGEXP9PSLVERR (apbtargexp9pslverr),
      .APBTARGEXP9PSTRB   (apbtargexp9pstrb),
      .APBTARGEXP9PPROT   (apbtargexp9pprot),
      .APBTARGEXP10PSEL   (apbtargexp10psel),
      .APBTARGEXP10PENABLE(apbtargexp10penable),
      .APBTARGEXP10PADDR  (apbtargexp10paddr),
      .APBTARGEXP10PWRITE (apbtargexp10pwrite),
      .APBTARGEXP10PWDATA (apbtargexp10pwdata),
      .APBTARGEXP10PRDATA (apbtargexp10prdata),
      .APBTARGEXP10PREADY (apbtargexp10pready),
      .APBTARGEXP10PSLVERR(apbtargexp10pslverr),
      .APBTARGEXP10PSTRB  (apbtargexp10pstrb),
      .APBTARGEXP10PPROT  (apbtargexp10pprot),
      .APBTARGEXP11PSEL   (apbtargexp11psel),
      .APBTARGEXP11PENABLE(apbtargexp11penable),
      .APBTARGEXP11PADDR  (apbtargexp11paddr),
      .APBTARGEXP11PWRITE (apbtargexp11pwrite),
      .APBTARGEXP11PWDATA (apbtargexp11pwdata),
      .APBTARGEXP11PRDATA (apbtargexp11prdata),
      .APBTARGEXP11PREADY (apbtargexp11pready),
      .APBTARGEXP11PSLVERR(apbtargexp11pslverr),
      .APBTARGEXP11PSTRB  (apbtargexp11pstrb),
      .APBTARGEXP11PPROT  (apbtargexp11pprot),
      .APBTARGEXP12PSEL   (apbtargexp12psel),
      .APBTARGEXP12PENABLE(apbtargexp12penable),
      .APBTARGEXP12PADDR  (apbtargexp12paddr),
      .APBTARGEXP12PWRITE (apbtargexp12pwrite),
      .APBTARGEXP12PWDATA (apbtargexp12pwdata),
      .APBTARGEXP12PRDATA (apbtargexp12prdata),
      .APBTARGEXP12PREADY (apbtargexp12pready),
      .APBTARGEXP12PSLVERR(apbtargexp12pslverr),
      .APBTARGEXP12PSTRB  (apbtargexp12pstrb),
      .APBTARGEXP12PPROT  (apbtargexp12pprot),
      .APBTARGEXP13PSEL   (apbtargexp13psel),
      .APBTARGEXP13PENABLE(apbtargexp13penable),
      .APBTARGEXP13PADDR  (apbtargexp13paddr),
      .APBTARGEXP13PWRITE (apbtargexp13pwrite),
      .APBTARGEXP13PWDATA (apbtargexp13pwdata),
      .APBTARGEXP13PRDATA (apbtargexp13prdata),
      .APBTARGEXP13PREADY (apbtargexp13pready),
      .APBTARGEXP13PSLVERR(apbtargexp13pslverr),
      .APBTARGEXP13PSTRB  (apbtargexp13pstrb),
      .APBTARGEXP13PPROT  (apbtargexp13pprot),
      .APBTARGEXP14PSEL   (apbtargexp14psel),
      .APBTARGEXP14PENABLE(apbtargexp14penable),
      .APBTARGEXP14PADDR  (apbtargexp14paddr),
      .APBTARGEXP14PWRITE (apbtargexp14pwrite),
      .APBTARGEXP14PWDATA (apbtargexp14pwdata),
      .APBTARGEXP14PRDATA (apbtargexp14prdata),
      .APBTARGEXP14PREADY (apbtargexp14pready),
      .APBTARGEXP14PSLVERR(apbtargexp14pslverr),
      .APBTARGEXP14PSTRB  (apbtargexp14pstrb),
      .APBTARGEXP14PPROT  (apbtargexp14pprot),
      .APBTARGEXP15PSEL   (apbtargexp15psel),
      .APBTARGEXP15PENABLE(apbtargexp15penable),
      .APBTARGEXP15PADDR  (apbtargexp15paddr),
      .APBTARGEXP15PWRITE (apbtargexp15pwrite),
      .APBTARGEXP15PWDATA (apbtargexp15pwdata),
      .APBTARGEXP15PRDATA (apbtargexp15prdata),
      .APBTARGEXP15PREADY (apbtargexp15pready),
      .APBTARGEXP15PSLVERR(apbtargexp15pslverr),
      .APBTARGEXP15PSTRB  (apbtargexp15pstrb),
      .APBTARGEXP15PPROT  (apbtargexp15pprot),    //
      .CPU0EDBGRQ         (cpu0edbgrq),
      .CPU0DBGRESTART     (CPU0DBGRESTART),
      .CPU0DBGRESTARTED   (  /*unused*/),         // Not used here in single core system
      .CPU0HTMDHADDR      (  /*unused*/),         // HTM not used in typical systems
      .CPU0HTMDHTRANS     (  /*unused*/),         // Sometimes used in FPGA for debug
      .CPU0HTMDHSIZE      (  /*unused*/),
      .CPU0HTMDHBURST     (  /*unused*/),
      .CPU0HTMDHPROT      (  /*unused*/),
      .CPU0HTMDHWDATA     (  /*unused*/),
      .CPU0HTMDHWRITE     (  /*unused*/),
      .CPU0HTMDHRDATA     (  /*unused*/),
      .CPU0HTMDHREADY     (  /*unused*/),
      .CPU0HTMDHRESP      (  /*unused*/),
      .CPU0TSVALUEB       ({48{1'b0}}),
      .CPU0ETMINTNUM      (  /*unused*/),         // Exception state visibility
      .CPU0ETMINTSTAT     (  /*unused*/),         // Exception state visibility
      .CPU0HALTED         (cpu0halted),
      .CPU0MPUDISABLE     (cpu0mpudisable),
      .CPU0SLEEPING       (  /*unused*/),         // Not used without power management
      .CPU0SLEEPDEEP      (  /*unused*/),         // Not used without power management
      .CPU0SLEEPHOLDREQn  (cpu0sleepholdreqn),
      .CPU0SLEEPHOLDACKn  (  /*unused*/),         // Not used without power management
      .CPU0WAKEUP         (CPU0WAKEUP),
      .CPU0WICENACK       (CPU0WICENACK),
      .CPU0WICSENSE       (CPU0WICSENSE),
      .CPU0WICENREQ       (CPU0WICENREQ),
      .CPU0SYSRESETREQ    (cpu0sysresetreq),
      .CPU0LOCKUP         (cpu0lockup),
      .CPU0CDBGPWRUPREQ   (cpu0cdbgpwrupreq),     // Debug Power Domain up request
      .CPU0CDBGPWRUPACK   (cpu0cdbgpwrupack),     // Debug Power Domain up acknowledge
      .CPU0BRCHSTAT       (  /*unused*/),         // CPU Pipeline visibility
      .MTXREMAP           (mtx_remap),
      .CPU0RXEV           (cpu0rxev),
      .CPU0TXEV           (  /*unused*/),
      .CPU0INTISR         (cpu0intisr),
      .CPU0INTNMI         (cpu0intnmi),
      .CPU0CURRPRI        (  /*unused*/),
      .CPU0AUXFAULT       (CPU0AUXFAULT),
      .APBQACTIVE         (  /*unused*/),
      .TIMER0PCLKQACTIVE  (  /*unused*/),
      .TIMER1PCLKQACTIVE  (  /*unused*/),
      .CPU0DBGEN          (cpu0dbgen),
      .CPU0NIDEN          (cpu0niden),
      .CPU0FIXMASTERTYPE  (cpu0fixmastertype),
      .CPU0ISOLATEn       (cpu0isolaten),
      .CPU0RETAINn        (cpu0retainn),
      .DFTSCANMODE        (DFTSCANMODE),
      .DFTCGEN            (DFTCGEN),
      .DFTSE              (DFTSE),
      .CPU0GATEHCLK       (  /*unused*/),
      .nTRST              (nTRST),                // JTAG TAP Reset
      .SWCLKTCK           (SWCLKTCK),             // SW/JTAG Clock
      .SWDITMS            (SWDITMS),              // SW Debug Data In / JTAG Test Mode Select
      .TDI                (TDI),                  // JTAG TAP Data In / Alternative input function
      .TDO                (TDO),                  // JTAG TAP Data Out
      .nTDOEN             (nTDOEN),               // TDO enable
      .SWDO               (SWDO),                 // SW Data Out
      .SWDOEN             (SWDOEN),               // SW Data Out Enable
      .JTAGNSW            (JTAGNSW),              // JTAG/not Serial Wire Mode
      .SWV                (SWV),                  // SingleWire Viewer Data
      .TRACECLK           (TRACECLK),             // TRACECLK output
      .TRACEDATA          (TRACEDATA),            // Trace Data
      .TRCENA             (trcena),               // Trace Enable

      .CPU0BIGEND(cpu0_bigend)
  );

  // All peripherals and memories


  // ------------------------------------------------------------
  // u_cmsdk_ahb_to_sram2 - AHB to SRAM bridge
  // ------------------------------------------------------------

  wire        SRAM2HCLK;
  wire [31:0] SRAM2RDATA;  // SRAM Read data bus
  wire [12:0] SRAM2ADDR;  // SRAM address
  wire [ 3:0] SRAM2WREN;  // SRAM Byte write enable
  wire [31:0] SRAM2WDATA;  // SRAM Write data
  wire        SRAM2CS;  // SRAM Chip select

  wire        SRAM3HCLK;
  wire [31:0] SRAM3RDATA;  // SRAM Read data bus
  wire [12:0] SRAM3ADDR;  // SRAM address
  wire [ 3:0] SRAM3WREN;  // SRAM Byte write enable
  wire [31:0] SRAM3WDATA;  // SRAM Write data
  wire        SRAM3CS;  // SRAM Chip select


  assign SRAM2HCLK = MTXHCLK;
  assign SRAM3HCLK = MTXHCLK;

  // Connection
  assign targsram2exresp_int = 1'b0;
  assign targsram2hruser_int = 3'b000;

  // module instantiation
  cmsdk_ahb_to_sram #(
      .AW(15)
  ) u_cmsdk_ahb_to_sram2 (
      .HCLK     (SRAM2HCLK),
      .HRESETn  (MTXHRESETn),
      .HSEL     (targsram2hsel),
      .HREADY   (targsram2hreadymux),
      .HTRANS   (targsram2htrans),
      .HSIZE    (targsram2hsize),
      .HWRITE   (targsram2hwrite),
      .HADDR    (targsram2haddr[14:0]),
      .HWDATA   (targsram2hwdata),
      .HREADYOUT(targsram2hreadyout),
      .HRESP    (targsram2hresp),
      .HRDATA   (targsram2hrdata),

      .SRAMRDATA(SRAM2RDATA),
      .SRAMADDR (SRAM2ADDR),
      .SRAMWEN  (SRAM2WREN),
      .SRAMWDATA(SRAM2WDATA),
      .SRAMCS   (SRAM2CS)
  );

  // ------------------------------------------------------------
  // u_cmsdk_ahb_to_sram3 - AHB to SRAM bridge
  // ------------------------------------------------------------

  // Connection
  assign targsram3exresp_int = 1'b0;
  assign targsram3hruser_int = 3'b000;

  // module instantiation
  cmsdk_ahb_to_sram #(
      .AW(15)
  ) u_cmsdk_ahb_to_sram3 (
      .HCLK     (SRAM3HCLK),
      .HRESETn  (MTXHRESETn),
      .HSEL     (targsram3hsel),
      .HREADY   (targsram3hreadymux),
      .HTRANS   (targsram3htrans),
      .HSIZE    (targsram3hsize),
      .HWRITE   (targsram3hwrite),
      .HADDR    (targsram3haddr[14:0]),
      .HWDATA   (targsram3hwdata),
      .HREADYOUT(targsram3hreadyout),
      .HRESP    (targsram3hresp),
      .HRDATA   (targsram3hrdata),

      .SRAMRDATA(SRAM3RDATA),
      .SRAMADDR (SRAM3ADDR),
      .SRAMWEN  (SRAM3WREN),
      .SRAMWDATA(SRAM3WDATA),
      .SRAMCS   (SRAM3CS)
  );


  csram_subsystem u_csram_subsystem (
      .SRAMHRESETn(MTXHRESETn),
      .SRAM2HCLK  (SRAM2HCLK),
      .SRAM2RDATA (SRAM2RDATA),
      .SRAM2ADDR  (SRAM2ADDR),
      .SRAM2WREN  (SRAM2WREN),
      .SRAM2WDATA (SRAM2WDATA),
      .SRAM2CS    (SRAM2CS),

      .SRAM3HCLK  (SRAM3HCLK),
      .SRAM3RDATA (SRAM3RDATA),
      .SRAM3ADDR  (SRAM3ADDR),
      .SRAM3WREN  (SRAM3WREN),
      .SRAM3WDATA (SRAM3WDATA),
      .SRAM3CS    (SRAM3CS)
  );


  wire [15:0] gpio0_altfunc_o;  // Alternate function control
  wire [15:0] gpio1_altfunc_o;  // Alternate function control
  wire        uart_txd_mcu_en;  // TX enable (enable 3-state buffer)


  wire [31:0] io_exp_port_i;
  wire [31:0] io_exp_port_o, io_exp_port_oen;
  generate
    genvar gpio_i;
    for (gpio_i = 0; gpio_i < 32; gpio_i = gpio_i + 1) begin : gpio_logic
      // assign GPIO[gpio_i] = io_exp_port_oen[gpio_i] ? io_exp_port_o : 1'bz;
      IOBUF u_GPIO (
          .O (io_exp_port_i[gpio_i]),
          .IO(GPIO[gpio_i]),
          .I (~io_exp_port_o[gpio_i]),
          .T (io_exp_port_oen[gpio_i])
      );
    end
  endgenerate

  m3ds_peripherals_wrapper u_m3ds_peripherals_wrapper (
      //-----------------------------
      //Resets
      .AHBRESETn    (AHBPRESETn),
      .DTIMERPRESETn(DTIMERPRESETn),
      .UART0PRESETn (UART0PRESETn),
      .UART1PRESETn (UART1PRESETn),
      .WDOGPRESETn  (WDOGPRESETn),
      .WDOGRESn     (WDOGRESn),
      .GPIO0HRESETn (GPIO0PRESETn),
      .GPIO1HRESETn (GPIO1PRESETn),

      //-----------------------------
      //Clocks
      .AHB_CLK   (CPU0HCLK),    //HCLK from top
      .APB_CLK   (PCLKG),       //PCLKG from top
      .DTIMER_CLK(DTIMER_CLK),
      .UART0_CLK (UART0_CLK),
      .UART1_CLK (UART1_CLK),
      .WDOG_CLK  (WDOG_CLK),
      .GPIO0_FCLK(GPIO0_FCLK),
      .GPIO1_FCLK(GPIO1_FCLK),
      .GPIO0_HCLK(GPIO0_HCLK),
      .GPIO1_HCLK(GPIO1_HCLK),

      //-----------------------------
      //AHB interface
      //AHB Master Slave
      .PERIPHHSEL_i    (targexp1hsel),       //AHB peripheral select
      .PERIPHHREADYIN_i(targexp1hreadymux),  //AHB ready input
      .PERIPHHTRANS_i  (targexp1htrans),     //AHB transfer type
      .PERIPHHSIZE_i   (targexp1hsize),      //AHB hsize
      .PERIPHHWRITE_i  (targexp1hwrite),     //AHB hwrite
      .PERIPHHADDR_i   (targexp1haddr),      //AHB address bus
      .PERIPHHWDATA_i  (targexp1hwdata),     //AHB write data bus

      .PERIPHHPROT_i(targexp1hprot),

      .PERIPHHREADYMUXOUT_o(targexp1hreadyout),  //AHB ready output from S->M mux
      .PERIPHHRESP_o       (targexp1hresp),      //AHB response output from S->M mux
      .PERIPHHRDATA_o      (targexp1hrdata),     //AHB read data from S->M mux


      //-----------------------------
      //APB interfaces
      //D(ual)Timer
      .DTIMERPSEL_i   (apbtargexp2psel),
      .DTIMERPENABLE_i(apbtargexp2penable),
      .DTIMERPADDR_i  ({20'h0, apbtargexp2paddr}),
      .DTIMERPWRITE_i (apbtargexp2pwrite),
      .DTIMERPWDATA_i (apbtargexp2pwdata),
      .DTIMERPSTRB_i  (apbtargexp2pstrb),
      .DTIMERPPROT_i  (apbtargexp2pprot[0]),        //using privileged access bit only
      .DTIMERPRDATA_o (apbtargexp2prdata),
      .DTIMERPREADY_o (apbtargexp2pready),
      .DTIMERPSLVERR_o(apbtargexp2pslverr),

      //UART0
      .UART0PSEL_i   (apbtargexp4psel),
      .UART0PENABLE_i(apbtargexp4penable),
      .UART0PADDR_i  ({20'h0, apbtargexp4paddr}),
      .UART0PWRITE_i (apbtargexp4pwrite),
      .UART0PWDATA_i (apbtargexp4pwdata),
      .UART0PSTRB_i  (apbtargexp4pstrb),
      .UART0PPROT_i  (apbtargexp4pprot[0]),
      .UART0PRDATA_o (apbtargexp4prdata),
      .UART0PREADY_o (apbtargexp4pready),
      .UART0PSLVERR_o(apbtargexp4pslverr),

      //UART1
      .UART1PSEL_i   (apbtargexp5psel),
      .UART1PENABLE_i(apbtargexp5penable),
      .UART1PADDR_i  ({20'h0, apbtargexp5paddr}),
      .UART1PWRITE_i (apbtargexp5pwrite),
      .UART1PWDATA_i (apbtargexp5pwdata),
      .UART1PSTRB_i  (apbtargexp5pstrb),
      .UART1PPROT_i  (apbtargexp5pprot[0]),
      .UART1PRDATA_o (apbtargexp5prdata),
      .UART1PREADY_o (apbtargexp5pready),
      .UART1PSLVERR_o(apbtargexp5pslverr),


      //W(atch)DOG
      .WDOGPSEL_i   (apbtargexp8psel),
      .WDOGPENABLE_i(apbtargexp8penable),
      .WDOGPADDR_i  ({20'h0, apbtargexp8paddr}),
      .WDOGPWRITE_i (apbtargexp8pwrite),
      .WDOGPWDATA_i (apbtargexp8pwdata),
      .WDOGPSTRB_i  (apbtargexp8pstrb),
      .WDOGPPROT_i  (apbtargexp8pprot[0]),
      .WDOGPRDATA_o (apbtargexp8prdata),
      .WDOGPREADY_o (apbtargexp8pready),
      .WDOGPSLVERR_o(apbtargexp8pslverr),

      //-----------------------------
      //Other/Functional peripheral module specific interfaces
      //-----------------------------
      //D(ual)TIMER
      .DTIMERECOREVNUM_i(4'd0),           // ECO revision number
      .DTIMERTIMCLKEN1_i(1'b1),           // Timer clock enable 1
      .DTIMERTIMCLKEN2_i(1'b1),           // Timer clock enable 2
      .DTIMERTIMINT1_o  (),               // Counter 1 interrupt
      .DTIMERTIMINT2_o  (),               // Counter 2 interrupt
      .DTIMERTIMINTC_o  (cpu0intisr[10]), // Counter combined interrupt

      //-----------------------------
      //UART0
      .UART0ECOREVNUM_i(4'd0),              // Engineering-change-order revision bits
      .UART0RXD_i      (uart_rxd_mcu),      // Serial input
      .UART0TXD_o      (uart_txd_mcu),      // Transmit data output
      .UART0TXEN_o     (uart_txd_mcu_en),   // Transmit enabled
      .UART0BAUDTICK_o (),                  // x16 Tick
      .UART0TXINT_o    (w_uart0_txint),     // Transmit Interrupt
      .UART0RXINT_o    (w_uart0_rxint),     // Receive Interrupt
      .UART0TXOVRINT_o (w_uart0_txovrint),  // Transmit overrun Interrupt
      .UART0RXOVRINT_o (w_uart0_rxovrint),  // Receive overrun Interrupt
      .UART0UARTINT_o  (),                  // Combined interrupt

      //-----------------------------
      //UART1
      .UART1ECOREVNUM_i(4'd0),                  // Engineering-change-order revision bits
      .UART1RXD_i      (),                      // Serial input
      .UART1TXD_o      (),                      // Transmit data output
      .UART1TXEN_o     (  /*Always driven */),  // Transmit enabled
      .UART1BAUDTICK_o (),                      // x16 Tick
      .UART1TXINT_o    (w_uart1_txint),         // Transmit Interrupt
      .UART1RXINT_o    (w_uart1_rxint),         // Receive Interrupt
      .UART1TXOVRINT_o (w_uart1_txovrint),      // Transmit overrun Interrupt
      .UART1RXOVRINT_o (w_uart1_rxovrint),      // Receive overrun Interrupt
      .UART1UARTINT_o  (),                      // Combined interrupt

      //-----------------------------
      //W(atch)DOG
      .WDOGECOREVNUM_i(4'd0),           // ECO revision number
      .WDOGCLKEN_i    (1'b1),           // Watchdog clock enable
      .WDOGINT_o      (cpu0intnmi),     // Watchdog interrupt
      .WDOGRES_o      (wdog_reset_req), // Watchdog timeout reset request

      //-----------------------------
      //GPIO0
      .GPIO0ECOREVNUM_i(4'd0),                   // Engineering-change-order revision bits
      .GPIO0PORTIN_i   (io_exp_port_i[15:0]),    // GPIO Interface input
      .GPIO0PORTOUT_o  (io_exp_port_o[15:0]),    // GPIO output
      .GPIO0PORTEN_o   (io_exp_port_oen[15:0]),  // GPIO output enable
      .GPIO0PORTFUNC_o (gpio0_altfunc_o),        // Alternate function control
      .GPIO0GPIOINT_o  (w_gpio0_portint),        // Interrupt output for each pin
      .GPIO0COMBINT_o  (cpu0intisr[6]),          // Combined interrupt

      //-----------------------------
      //GPIO1
      .GPIO1ECOREVNUM_i(4'd0),                    // Engineering-change-order revision bits
      .GPIO1PORTIN_i   (io_exp_port_i[31:16]),    // GPIO Interface input
      .GPIO1PORTOUT_o  (io_exp_port_o[31:16]),    // GPIO output
      .GPIO1PORTEN_o   (io_exp_port_oen[31:16]),  // GPIO output enable
      .GPIO1PORTFUNC_o (gpio1_altfunc_o),         // Alternate function control
      .GPIO1GPIOINT_o  (w_gpio1_portint),         // Interrupt output for each pin
      .GPIO1COMBINT_o  (cpu0intisr[7])            // Combined interrupt
  );



  // --------------------------------------------------------------------
  // Default Slave for AHB Expansion master port
  // --------------------------------------------------------------------

  cmsdk_ahb_default_slave u_cmsdk_ahb_default_slave (
      // Inputs
      .HCLK   (CPU0HCLK),          // Clock
      .HRESETn(CPU0SYSRESETn),     // Reset
      .HSEL   (targexp0hsel),      // Slave select
      .HTRANS (targexp0htrans),    // Transfer type
      .HREADY (targexp0hreadymux), // System ready

      // Outputs
      .HREADYOUT(targexp0hreadyout),  // Slave ready
      .HRESP    (targexp0hresp)
  );  // Slave response

  assign targexp0hrdata = 32'h00000000;
  assign targexp0exresp = 1'b0;
  assign targexp0hruser = {3{1'b0}};


endmodule
