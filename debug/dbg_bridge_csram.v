module dbg_bridge_csram
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter CLK_FREQ     = 14745600,
    parameter UART_SPEED   = 115200,
    parameter STS_ADDRESS  = 32'hf0000004
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
    input wire        clk_i,
    input wire        rst_i,
    input wire        uart_rxd_i,
    input wire        dbg_hready,
    input wire [31:0] dbg_hrdata,

    // Outputs
    output reg         dbg_hsel,
    output wire        uart_txd_o,
    output reg         dbg_hwrite,
    output reg  [31:0] dbg_haddr,
    output reg  [ 2:0] dbg_hsize,
    output wire [ 2:0] dbg_hburst,
    output wire [ 1:0] dbg_htrans,
    output wire [31:0] dbg_hwdata,
    output wire [ 3:0] dbg_hwuser,
    output wire        dbg_hresp
);

  //-----------------------------------------------------------------
  // Defines
  //-----------------------------------------------------------------
  localparam REQ_WRITE = 8'h10;
  localparam REQ_READ = 8'h11;

  `define STATE_W 4
  `define STATE_R 3:0
  localparam STATE_IDLE = 4'd0;
  localparam STATE_LEN = 4'd2;
  localparam STATE_ADDR0 = 4'd3;
  localparam STATE_ADDR1 = 4'd4;
  localparam STATE_ADDR2 = 4'd5;
  localparam STATE_ADDR3 = 4'd6;
  localparam STATE_WRITE = 4'd7;
  localparam STATE_READ = 4'd8;
  localparam STATE_DATA0 = 4'd9;
  localparam STATE_DATA1 = 4'd10;
  localparam STATE_DATA2 = 4'd11;
  localparam STATE_DATA3 = 4'd12;

  //-----------------------------------------------------------------
  // Wires / Regs
  //-----------------------------------------------------------------
  wire        uart_wr_w;
  wire [ 7:0] uart_wr_data_w;
  wire        uart_wr_busy_w;

  wire        uart_rd_w;
  wire [ 7:0] uart_rd_data_w;
  wire        uart_rd_valid_w;

  wire        uart_rx_error_w;

  wire        tx_valid_w;
  wire [ 7:0] tx_data_w;
  wire        tx_accept_w;
  wire        read_skip_w;

  wire        rx_valid_w;
  wire [ 7:0] rx_data_w;
  wire        rx_accept_w;

  reg  [31:0] mem_addr_q;
  reg         mem_busy_q;
  reg         mem_wr_q;

  reg  [ 7:0] len_q;

  // Byte Index
  reg  [ 1:0] data_idx_q;

  // Word storage
  reg  [31:0] data_q;

  wire        magic_addr_w = (mem_addr_q == STS_ADDRESS);

  //-----------------------------------------------------------------
  // UART core
  //-----------------------------------------------------------------
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
      .DEPTH (8),
      .ADDR_W(3)
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

  //-----------------------------------------------------------------
  // Input FIFO
  //-----------------------------------------------------------------
  dbg_bridge_fifo #(
      .WIDTH (8),
      .DEPTH (8),
      .ADDR_W(3)
  ) u_fifo_rx (
      .clk_i(clk_i),
      .rst_i(rst_i),

      // In
      .push_i(uart_rd_valid_w),
      .data_in_i(uart_rd_data_w),
      .accept_o(uart_rd_w),

      // Out
      .pop_i(rx_accept_w),
      .data_out_o(rx_data_w),
      .valid_o(rx_valid_w)  //当收到data时，=1
  );


  //wait read , ahb read data needs 3clock
  reg [1:0] read_bits;
  always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) read_bits <= 2'b00;
    else begin
      if (state_q == STATE_ADDR3) read_bits <= 2'b00;
      else if(state_q == STATE_READ) read_bits <= read_bits + 1;
      else read_bits <= 2'b00;
    end
  end

  //-----------------------------------------------------------------
  // States
  //-----------------------------------------------------------------
  reg [`STATE_R] state_q;
  reg [`STATE_R] next_state_r;

  always @* begin
    next_state_r = state_q;

    case (next_state_r)
      //-------------------------------------------------------------
      // IDLE:
      //-------------------------------------------------------------
      STATE_IDLE: begin
        if (rx_valid_w) begin
          case (rx_data_w)
            REQ_WRITE, REQ_READ: next_state_r = STATE_LEN;
            default: ;
          endcase
        end
      end
      //-----------------------------------------
      // STATE_LEN
      //-----------------------------------------
      STATE_LEN: begin
        if (rx_valid_w) next_state_r = STATE_ADDR0;
      end
      //-----------------------------------------
      // STATE_ADDR
      //-----------------------------------------
      STATE_ADDR0: if (rx_valid_w) next_state_r = STATE_ADDR1;
      STATE_ADDR1: if (rx_valid_w) next_state_r = STATE_ADDR2;
      STATE_ADDR2: if (rx_valid_w) next_state_r = STATE_ADDR3;
      STATE_ADDR3: begin
        if (rx_valid_w && mem_wr_q) next_state_r = STATE_WRITE;
        else if (rx_valid_w) begin
          next_state_r = STATE_READ;
        end
      end
      //-----------------------------------------
      // STATE_WRITE
      //-----------------------------------------
      STATE_WRITE: begin
        if (len_q == 8'b0 && (dbg_hready || magic_addr_w)) next_state_r = STATE_IDLE;
        else next_state_r = STATE_WRITE;
      end
      //-----------------------------------------
      // STATE_READ
      //-----------------------------------------
      STATE_READ: begin
        // Data ready
        if ((dbg_hready || magic_addr_w) && read_bits == 2'b11) next_state_r = STATE_DATA0;
      end
      //-----------------------------------------
      // STATE_DATA
      //-----------------------------------------
      STATE_DATA0: begin
        if (read_skip_w) next_state_r = STATE_DATA1;
        else if (tx_accept_w && (len_q == 8'b0)) next_state_r = STATE_IDLE;
        else if (tx_accept_w) next_state_r = STATE_DATA1;
      end
      STATE_DATA1: begin
        if (read_skip_w) next_state_r = STATE_DATA2;
        else if (tx_accept_w && (len_q == 8'b0)) next_state_r = STATE_IDLE;
        else if (tx_accept_w) next_state_r = STATE_DATA2;
      end
      STATE_DATA2: begin
        if (read_skip_w) next_state_r = STATE_DATA3;
        else if (tx_accept_w && (len_q == 8'b0)) next_state_r = STATE_IDLE;
        else if (tx_accept_w) next_state_r = STATE_DATA3;
      end
      STATE_DATA3: begin
        if (tx_accept_w && (len_q != 8'b0)) next_state_r = STATE_READ;
        else if (tx_accept_w) next_state_r = STATE_IDLE;
      end
      default: ;
    endcase
  end

  // State storage
  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) state_q <= STATE_IDLE;
    else state_q <= next_state_r;

  //-----------------------------------------------------------------
  // RD/WR to and from UART
  //-----------------------------------------------------------------

  // Write to UART Tx buffer in the following states
  assign tx_valid_w = ((state_q == STATE_DATA0) |
                    (state_q == STATE_DATA1) |
                    (state_q == STATE_DATA2) |
                    (state_q == STATE_DATA3)) && !read_skip_w;

  // Accept data in the following states
  assign rx_accept_w = (state_q == STATE_IDLE) |
                     (state_q == STATE_LEN) |
                     (state_q == STATE_ADDR0) |
                     (state_q == STATE_ADDR1) |
                     (state_q == STATE_ADDR2) |
                     (state_q == STATE_ADDR3) |
                     (state_q == STATE_WRITE);

  //-----------------------------------------------------------------
  // Capture length
  //-----------------------------------------------------------------
  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) len_q <= 8'd0;
    else if (state_q == STATE_LEN && rx_valid_w) len_q[7:0] <= rx_data_w;
    else if (state_q == STATE_WRITE && rx_valid_w) len_q <= len_q - 8'd1;
    else if ((state_q == STATE_READ && read_bits == 2'b11) && (dbg_hready || magic_addr_w)) len_q <= len_q - 8'd1;
    else if (((state_q == STATE_DATA0) || (state_q == STATE_DATA1) || (state_q == STATE_DATA2)) && (tx_accept_w && !read_skip_w))
      len_q <= len_q - 8'd1;

  //-----------------------------------------------------------------
  // Capture addr
  //-----------------------------------------------------------------
  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) mem_addr_q <= 'd0;
    else if (state_q == STATE_ADDR0 && rx_valid_w) mem_addr_q[31:24] <= rx_data_w;
    else if (state_q == STATE_ADDR1 && rx_valid_w) mem_addr_q[23:16] <= rx_data_w;
    else if (state_q == STATE_ADDR2 && rx_valid_w) mem_addr_q[15:8] <= rx_data_w;
    else if (state_q == STATE_ADDR3 && rx_valid_w) mem_addr_q[7:0] <= rx_data_w;
    // Address increment on every access issued
    else if (state_q == STATE_WRITE && dbg_hready && rx_valid_w)
      mem_addr_q <= {mem_addr_q[31:0]} + 'd1;
    else if ((state_q == STATE_READ && dbg_hready ) && read_bits == 2'b00) mem_addr_q <= {mem_addr_q[31:0]} + 'd4;

  //-----------------------------------------------------------------
  // Data Index 只有write时有效
  //-----------------------------------------------------------------
  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) data_idx_q <= 2'b0;
    else if (state_q == STATE_ADDR3) data_idx_q <= rx_data_w[1:0];
    else if (state_q == STATE_WRITE && rx_valid_w) data_idx_q <= data_idx_q + 2'd1;
    else if (((state_q == STATE_DATA0) || (state_q == STATE_DATA1) || (state_q == STATE_DATA2)) && tx_accept_w && (data_idx_q != 2'b0))
      data_idx_q <= data_idx_q - 2'd1;

  assign read_skip_w = (data_idx_q != 2'b0);

  //-----------------------------------------------------------------
  // Data Sample
  //-----------------------------------------------------------------
  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) data_q <= 32'b0;
    // Write to memory
    else if (state_q == STATE_WRITE && rx_valid_w) begin
      case (data_idx_q)
        2'd0: data_q[7:0] <= rx_data_w;
        2'd1: data_q[15:8] <= rx_data_w;
        2'd2: data_q[23:16] <= rx_data_w;
        2'd3: data_q[31:24] <= rx_data_w;
      endcase
    end  // Read from status register?
    else if (state_q == STATE_READ && mem_addr_q == STS_ADDRESS)
      data_q <= {16'hcafe, 15'd0, 1'b0};
    // Read from memory
    else if ((state_q == STATE_READ && read_bits == 2'b11) && dbg_hready) data_q <= dbg_hrdata;
    // Shift data out (read response -> UART)
    else if (((state_q == STATE_DATA0) || (state_q == STATE_DATA1) || (state_q == STATE_DATA2)) && (tx_accept_w || read_skip_w))
      data_q <= {8'b0, data_q[31:8]};

  assign tx_data_w = data_q[7:0];


  //AHB signals
  always @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      dbg_hwrite <= 'd0;
      dbg_hsel   <= 1'b0;
      dbg_haddr  <= {32{1'b0}};
      dbg_hsize  <= 3'b000;
    end  // Address increment on every access issued
    else if (state_q == STATE_WRITE && dbg_hready && rx_valid_w) begin
      dbg_hwrite <= 1'b1;
      dbg_hsize  <= 3'b000;
      dbg_hsel   <= 1'b1;
      dbg_haddr  <= mem_addr_q;
    end else if ((state_q == STATE_READ && dbg_hready) && read_bits == 2'b00) begin
      dbg_hwrite <= 1'b0;
      dbg_hsize  <= 3'b010;
      dbg_hsel   <= 1'b1;
      dbg_haddr  <= mem_addr_q;
    end else begin
      dbg_hwrite <= 1'b0;
      dbg_hsel   <= 1'b0;
      dbg_haddr  <= dbg_haddr;
    end
  end

  assign dbg_hwdata = data_q;
  assign dbg_hburst = 3'b001;
  assign dbg_htrans = 2'b10;


  //-----------------------------------------------------------------
  // Write mask
  //-----------------------------------------------------------------
  reg [3:0] mem_sel_q;
  reg [3:0] mem_sel_r;

  always @* begin
    mem_sel_r = 4'b1111;

    case (data_idx_q)
      2'd0: mem_sel_r = 4'b0001;
      2'd1: mem_sel_r = 4'b0011;
      2'd2: mem_sel_r = 4'b0111;
      2'd3: mem_sel_r = 4'b1111;
    endcase

    case (mem_addr_q[1:0])
      2'd0: mem_sel_r = mem_sel_r & 4'b1111;
      2'd1: mem_sel_r = mem_sel_r & 4'b1110;
      2'd2: mem_sel_r = mem_sel_r & 4'b1100;
      2'd3: mem_sel_r = mem_sel_r & 4'b1000;
    endcase
  end

  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) mem_sel_q <= 4'b0;
    // Idle - reset for read requests
    else if (state_q == STATE_IDLE) mem_sel_q <= 4'b1111;
    // Every 4th byte, issue bus access
    else if (state_q == STATE_WRITE && rx_valid_w && (data_idx_q == 2'd3 || len_q == 8'd1))
      mem_sel_q <= mem_sel_r;

  assign dbg_hwuser = mem_sel_q;

  //-----------------------------------------------------------------
  // Write enable
  //-----------------------------------------------------------------
  always @(posedge clk_i or negedge rst_i)
    if (!rst_i) mem_wr_q <= 1'b0;
    else if (state_q == STATE_IDLE && rx_valid_w) mem_wr_q <= (rx_data_w == REQ_WRITE);


endmodule
