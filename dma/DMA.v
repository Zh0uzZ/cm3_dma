module DMA (
    input  wire          PCLK,    
    input  wire          PRESETn, 
    input  wire          PSEL,    
    input  wire   [11:0] PADDR,   
    input  wire          PWRITE,  
    input  wire   [31:0] PWDATA,    
    output wire          PREADY,
    output wire   [31:0] PRDATA,  

    output reg           HSEL_R,
    output reg   [31:0]  HADDR_R,
    output reg   [2:0]   HBURST_R,
    output reg   [2:0]   HSIZE_R,
    output reg   [1:0]   HTRANS_R,
    input  wire  [31:0]  HRDATA_R,
    input  wire          HREADY_R,

    output reg           HSEL_W,
    output reg   [31:0]  HADDR_W,
    output reg   [2:0]   HBURST_W,
    output reg   [2:0]   HSIZE_W,
    output reg   [1:0]   HTRANS_W,
    output reg           HWRITE_W,
    output reg   [31:0]  HWDATA_W,
    input  wire          HREADY_W,

    output reg           DMA_INT
);


    //DMA reg
    reg [31:0] reg_rd_addr;
    reg [31:0] reg_wr_addr;
    reg [31:0] reg_length;
    reg [31:0] reg_step;
    reg [31:0] reg_ctrl;


    //DMA Control

    wire dma_start = reg_ctrl[0];
    wire [1:0] dma_size  = reg_ctrl[5:4];

    always @(posedge PCLK) begin
        if(PSEL & PWRITE & (PADDR == 12'h000))
            reg_rd_addr <= PWDATA;
        else
            reg_rd_addr <= reg_rd_addr;
    end

    always @(posedge PCLK) begin
        if(PSEL & PWRITE & (PADDR == 12'h004))
            reg_wr_addr <= PWDATA;
        else
            reg_wr_addr <= reg_wr_addr;
    end

    always @(posedge PCLK) begin
        if(PSEL & PWRITE & (PADDR == 12'h008))
            reg_length <= PWDATA;
        else
            reg_length <= reg_length;
    end

    always @(posedge PCLK) begin
        if(PSEL & PWRITE & (PADDR == 12'h00C))
            reg_step <= PWDATA;
        else
            reg_step <= reg_step;
    end

    always @(posedge PCLK) begin
        if(PSEL & PWRITE & (PADDR == 12'h010))
            reg_ctrl <= PWDATA;
        else
            reg_ctrl <= reg_ctrl_nxt;
    end

    // assign reg_ctrl_nxt = reg_ctrl & 32'hFFFF_FFFA;
    assign reg_ctrl_nxt = {reg_ctrl[31:3], DMA_INT, 1'b0, 1'b0};


// DMA DATA
reg [31:0] addr_rd_reg;

always @(posedge PCLK) begin
    addr_rd_reg <= HADDR_R;
end

reg [31:0] fifo_wr_data;
wire [31:0] fifo_rd_data;
always@(*) begin
    case(dma_size)
        2'b00 : begin
            case(addr_rd_reg[1:0])
                2'b00 : fifo_wr_data = {4{HRDATA_R[7:0]}};
                2'b01 : fifo_wr_data = {4{HRDATA_R[15:8]}};
                2'b10 : fifo_wr_data = {4{HRDATA_R[23:16]}};
                2'b11 : fifo_wr_data = {4{HRDATA_R[31:24]}};
            endcase
        end
        2'b01 : begin
            case(addr_rd_reg[1])
                1'b0 : fifo_wr_data = {2{HRDATA_R[15:0]}};
                1'b1 : fifo_wr_data = {2{HRDATA_R[31:16]}};
            endcase
        end
        default : begin
            fifo_wr_data = HRDATA_R;
        end
    endcase
end

//FIFO Control
wire fifo_empty , fifo_full;
reg fifo_rd , fifo_wr;
fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(2)
) dma_fifo(
    .clk(PCLK),
    .resetn(PRESETn),
    .rd(fifo_rd),
    .wr(fifo_wr),
    .w_data(fifo_wr_data),
    .empty(fifo_empty),
    .full(fifo_full),
    .r_data(fifo_rd_data)
);

//DMA READ
    reg [31:0] dma_count_rd; //read count number
    
    always@(posedge PCLK or negedge PRESETn) begin
        if(~PRESETn) begin
            dma_count_rd <= 32'b0;
            fifo_wr      <= 1'b0;
        end
        else begin
            if(dma_start) begin
                dma_count_rd <= reg_length;            
                fifo_wr      <= 1'b0;
            end
            else if(~HREADY_R | (dma_count_rd == 32'hffffffff)) begin
                dma_count_rd <= dma_count_rd;
                fifo_wr      <= 1'b0;
            end
            else begin
                dma_count_rd <= dma_count_rd - 1'b1;
                fifo_wr      <= 1'b1;
            end
        end
    end

    always@(posedge PCLK or negedge PRESETn) begin
        if(~PRESETn) begin
            HSEL_R   <= 1'b0;
            HADDR_R  <= 32'h0;
            HBURST_R <= 3'h0;
            HSIZE_R  <= 3'h0;
            HTRANS_R <= 2'h0;
        end
        else begin
            if(dma_start) begin
                HSEL_R   <= 1'b1;
                HADDR_R  <= reg_rd_addr;
                HBURST_R <= 3'h1;
                HSIZE_R  <= dma_size;
                HTRANS_R <= 2'h2;
            end
            else if(HREADY_R & dma_count_rd > 32'h0 & dma_count_rd != 32'hffffffff) begin
                HSEL_R   <= 1'b1;
                HADDR_R  <= HADDR_R + reg_step;
                HBURST_R <= 3'h1;
                HSIZE_R  <= HSIZE_R;
                HTRANS_R <= 2'h3;
            end
            else if(~HREADY_R) begin
                HSEL_R   <= 1'b1;
                HADDR_R  <= HADDR_R;
                HBURST_R <= HBURST_R;
                HSIZE_R  <= HSIZE_R ;
                HTRANS_R <= HTRANS_R;
            end
            else begin 
                HSEL_R   <= 1'b0;
                HADDR_R  <= 32'h0;
                HBURST_R <= 3'h0;
                HSIZE_R  <= 3'h0;
                HTRANS_R <= 2'h0;
            end
        end
    end


//DMA WRITE
    reg        dma_start_wr;
    reg [31:0] dma_count_wr;

    always @(posedge PCLK) begin
        dma_start_wr <= dma_start;
    end

    always@(posedge PCLK or negedge PRESETn) begin
        if(~PRESETn) begin
            dma_count_wr <= 32'hffffffff;
            fifo_rd      <= 1'b0;
            DMA_INT      <= 1'b0;
        end
        else begin
            if(dma_start_wr) begin
                dma_count_wr <= reg_length;            
                fifo_rd      <= 1'b0;
            end
            else if(dma_count_wr == 32'h00000000) begin
                dma_count_wr <= dma_count_wr - 1'b1;
                fifo_rd      <= 1'b1;
                DMA_INT      <= 1'b1;
            end
            else if(~HREADY_W | (dma_count_wr == 32'hffffffff)) begin
                dma_count_wr <= dma_count_wr;
                fifo_rd      <= 1'b0;
                DMA_INT      <= 1'b0;
            end
            else begin
                dma_count_wr <= dma_count_wr - 1'b1;
                fifo_rd      <= 1'b1;
                DMA_INT      <= 1'b0;
            end
        end
    end

    always@(posedge PCLK or negedge PRESETn) begin
        if(~PRESETn) begin
            HSEL_W   <= 1'b0;
            HWRITE_W <= 1'b0;
            // HWDATA_W <= 32'h0;
            HADDR_W  <= 32'h0;
            HBURST_W <= 3'h0;
            HSIZE_W  <= 3'h0;
            HTRANS_W <= 2'h0;
        end
        else begin
            if(dma_start_wr) begin
                HSEL_W   <= 1'b1;
                HWRITE_W <= 1'b1;
                HWDATA_W <= 32'h0;
                HADDR_W  <= reg_wr_addr;
                HBURST_W <= 3'h1;
                HSIZE_W  <= HSIZE_R;
                HTRANS_W <= 2'h2;
            end
            else if(HREADY_W & dma_count_wr >=32'h1 & dma_count_wr != 32'hffffffff) begin
                HSEL_W   <= 1'b1;
                HWRITE_W <= 1'b1;
                HWDATA_W <= fifo_wr_data;
                HADDR_W  <= HADDR_W + reg_step;
                HBURST_W <= 3'h1;
                HSIZE_W  <= HSIZE_R;
                HTRANS_W <= 2'h3;
            end
            else if(~HREADY_W) begin
                HSEL_W   <= 1'b1;
                HWRITE_W <= HWRITE_W;
                HWDATA_W <= HWDATA_W;
                HADDR_W  <= HADDR_W;
                HBURST_W <= HBURST_W;
                HSIZE_W  <= HSIZE_W ;
                HTRANS_W <= HTRANS_W;
            end
            else begin 
                HSEL_W   <= 1'b0;
                HWRITE_W <= 1'b0;
                HWDATA_W <= 32'h0;
                HADDR_W  <= 32'h0;
                HBURST_W <= 3'h0;
                HSIZE_W  <= 3'h0;
                HTRANS_W <= 2'h0;
            end
        end
    end

    // assign HWDATA_W = fifo_wr_data;
    assign PREADY   = 1'b1;
    assign HREADY   = 1'b1;
    assign PRDATA   = {32{1'b0}};
    
endmodule