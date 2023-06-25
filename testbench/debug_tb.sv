module debug_tb;

  logic clk_i, rst_i;
  logic [31:0] data_hex[1023:0];
  logic [7:0] data[1023:0];
  parameter CLK_FREQ = 100;
  parameter UART_SPEED = 20;

  parameter AXI_ID = 4'd0;
  parameter GPIO_ADDRESS = 32'hf0000000;
  parameter STS_ADDRESS = 32'hf0000004;


  initial begin
    clk_i = 0;
    rst_i = 1;
    #20 rst_i = 0;
    #20 rst_i = 1;
  end
  always #5 clk_i = ~clk_i;

  integer file;
  initial begin
    data[0] = 8'h10;
    data[1] = 128;
    data[2] = 0;
    data[3] = 0;
    data[4] = 0;
    data[5] = 0;

    $readmemh("/home/hank/workspace/vivado/CM3/cm3_dma/debug/soc.hex", data_hex);
    for (int i = 6; i < 1024; i++) begin
      data[i] = ((i-6)%4 == 0) ? data_hex[(i-6)/4][31:24] :
        (((i-6)%4 == 1) ? data_hex[(i-6)/4][23:16] :
        (((i-6)%4 == 2) ? data_hex[(i-6)/4][15:8] : data_hex[(i-6)/4][7:0]));
    end
  end

  logic [10:0] count = 0;

  logic [7:0] tx_data_w;
  logic tx_valid_w;
  logic tx_accept_w;
  logic uart_wr_busy_w;
  logic [7:0] uart_wr_data_w;
  logic uart_wr_w;


  //unused
  logic uart_rx_w;
  logic [7:0] uart_rd_data_w;
  logic uart_rd_valid_w;
  logic uart_rx_error_w;
  logic uart_rxd_i;
  logic uart_txd_o;

  always_ff @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      count <= 0;
      tx_valid_w <= 1'b0;
    end else begin
      tx_data_w <= data[count];
      count <= count + 1;
      tx_valid_w <= 1'b1;
    end
  end


  dbg_bridge_uart #(
      .UART_DIVISOR_W(32)
  ) u_uart (
      .clk_i(clk_i),
      .rst_i(rst_i),

      // Control
      .bit_div_i(CLK_FREQ / UART_SPEED),
      .stop_bits_i(1'b0),  // 0 = 1, 1 = 2

      // Transmit
      .wr_i(uart_wr_w),
      .data_i(uart_wr_data_w),
      .tx_busy_o(uart_wr_busy_w),

      // Receive
      .rd_i(uart_rd_w),
      .data_o(uart_rd_data_w),
      .rx_ready_o(uart_rd_valid_w),

      .rx_err_o(uart_rx_error_w),

      // UART pins
      .rxd_i(uart_rxd_i),
      .txd_o(uart_txd_o)
  );

  //-----------------------------------------------------------------
  // Output FIFO
  //-----------------------------------------------------------------
  wire uart_tx_pop_w = ~uart_wr_busy_w;

  dbg_bridge_fifo #(
      .WIDTH (8),
      .DEPTH (1024),
      .ADDR_W(10)
  ) u_fifo_tx (
      .clk_i(clk_i),
      .rst_i(rst_i),

      // In
      .push_i(tx_valid_w),
      .data_in_i(tx_data_w),
      .accept_o(tx_accept_w),

      // Out
      .pop_i(uart_tx_pop_w),
      .data_out_o(uart_wr_data_w),
      .valid_o(uart_wr_w)
  );


  // dbg_bridge Inputs
  reg         mem_awready_i = 1;
  reg         mem_wready_i = 1;
  reg         mem_bvalid_i = 1;
  reg  [ 1:0] mem_bresp_i = 0;
  reg  [ 3:0] mem_bid_i = 0;
  reg         mem_arready_i = 1;
  reg         mem_rvalid_i = 1;
  reg  [31:0] mem_rdata_i = 0;
  reg  [ 1:0] mem_rresp_i = 0;
  reg  [ 3:0] mem_rid_i = 0;
  reg         mem_rlast_i = 0;
  reg  [31:0] gpio_inputs_i = 0;

  // dbg_bridge Outputs
  wire        mem_awvalid_o;
  wire [31:0] mem_awaddr_o;
  wire [ 3:0] mem_awid_o;
  wire [ 7:0] mem_awlen_o;
  wire [ 1:0] mem_awburst_o;
  wire        mem_wvalid_o;
  wire [31:0] mem_wdata_o;
  wire [ 3:0] mem_wstrb_o;
  wire        mem_wlast_o;
  wire        mem_bready_o;
  wire        mem_arvalid_o;
  wire [31:0] mem_araddr_o;
  wire [ 3:0] mem_arid_o;
  wire [ 7:0] mem_arlen_o;
  wire [ 1:0] mem_arburst_o;
  wire        mem_rready_o;
  wire [31:0] gpio_outputs_o;

  dbg_bridge #(
      .CLK_FREQ    (CLK_FREQ),
      .UART_SPEED  (UART_SPEED),
      .AXI_ID      (AXI_ID),
      .GPIO_ADDRESS(GPIO_ADDRESS),
      .STS_ADDRESS (STS_ADDRESS)
  ) u_dbg_bridge (
      .clk_i        (clk_i),
      .rst_i        (rst_i),
      .uart_rxd_i   (uart_txd_o),
      .mem_awready_i(mem_awready_i),
      .mem_wready_i (mem_wready_i),
      .mem_bvalid_i (mem_bvalid_i),
      .mem_bresp_i  (mem_bresp_i[1:0]),
      .mem_bid_i    (mem_bid_i[3:0]),
      .mem_arready_i(mem_arready_i),
      .mem_rvalid_i (mem_rvalid_i),
      .mem_rdata_i  (mem_rdata_i[31:0]),
      .mem_rresp_i  (mem_rresp_i[1:0]),
      .mem_rid_i    (mem_rid_i[3:0]),
      .mem_rlast_i  (mem_rlast_i),
      .gpio_inputs_i(gpio_inputs_i[31:0]),

      .uart_txd_o    (),
      .mem_awvalid_o (mem_awvalid_o),
      .mem_awaddr_o  (mem_awaddr_o[31:0]),
      .mem_awid_o    (mem_awid_o[3:0]),
      .mem_awlen_o   (mem_awlen_o[7:0]),
      .mem_awburst_o (mem_awburst_o[1:0]),
      .mem_wvalid_o  (mem_wvalid_o),
      .mem_wdata_o   (mem_wdata_o[31:0]),
      .mem_wstrb_o   (mem_wstrb_o[3:0]),
      .mem_wlast_o   (mem_wlast_o),
      .mem_bready_o  (mem_bready_o),
      .mem_arvalid_o (mem_arvalid_o),
      .mem_araddr_o  (mem_araddr_o[31:0]),
      .mem_arid_o    (mem_arid_o[3:0]),
      .mem_arlen_o   (mem_arlen_o[7:0]),
      .mem_arburst_o (mem_arburst_o[1:0]),
      .mem_rready_o  (mem_rready_o),
      .gpio_outputs_o(gpio_outputs_o[31:0])
  );
endmodule
