module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
)(
    input wire clk,
    input wire resetn,
    input wire rd,
    input wire wr,
    input wire [DATA_WIDTH-1:0] w_data,

    output wire empty,
    output wire full,
    output wire [DATA_WIDTH-1:0] r_data
);
    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];
    reg [ADDR_WIDTH-1:0] w_reg , w_next , w_succ;
    reg [ADDR_WIDTH-1:0] r_reg , r_next , r_succ;

    reg full_reg , empty_reg , full_next , empty_next;
    wire w_en = wr & ~full_reg;

    always@(posedge clk) begin
        if(w_en)
            mem[w_reg] <= w_data;
    end
    assign r_data = mem[r_reg];

    always@(posedge clk or negedge resetn) begin
        if(~resetn) begin
            w_reg <= 0;
            r_reg <= 0;
            full_reg <= 0;
            empty_reg <= 0;
        end else begin
            w_reg <= w_next;
            r_reg <= r_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end

    always@(*) begin
        w_succ = w_reg + 1;
        r_succ = r_reg + 1;
        
        case({w_en,rd})
        2'b10 : begin
            if(~full_reg) begin
                w_next = w_succ;
                r_next = r_reg;
                empty_next = 1'b0;
                if(w_succ == r_reg)
                    full_next = 1'b1;
                else
                    full_next = full_reg;
            end
            end
        2'b01 : begin
            if(~empty_reg) begin
               w_next = w_reg;
               r_next = r_succ;
               full_next = 1'b0;
               if(r_succ == w_reg)
                    empty_next = 1'b1; 
                else
                    empty_next = empty_reg;
            end
        end
        2'b11 : begin
            w_next = w_succ;
            r_next = r_succ;
            full_next = full_reg;
            empty_next = empty_reg;
        end
        default : begin
            w_next = w_reg;
            r_next = r_reg;
            full_next = full_reg;
            empty_next = empty_reg;
        end
        endcase
    end

    assign full = full_reg;
    assign empty = empty_reg;

endmodule