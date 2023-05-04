module fifotb;
    reg clk,rst,rd,wr;
    reg [7:0] w_data;

    wire empty,full;
    wire [7:0] r_data;
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~ clk;
        end
    end

    initial begin
        rst = 1; #10 rst = 0; #10 rst = 1;
    end

    initial begin
        wr = 1;
        rd = 0;
        w_data = 8'hd;
    end

    fifo u_fifo(
        .clk(clk),
        .resetn(rst),
        .rd(rd),
        .wr(wr),
        .w_data(w_data),
        
        .empty(empty),
        .full(full),
        .r_data(r_data)
    );

endmodule