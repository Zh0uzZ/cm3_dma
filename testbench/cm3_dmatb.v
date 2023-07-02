`timescale 1ns/1ns
module cm3_dmatb;

  reg fclk , fpga_reset_n;

  fpga_top u_m3(
    .fpga_clk(fclk),
    .fpga_reset_n(~fpga_reset_n)
  );

  initial begin
    fpga_reset_n = 1'b0;
    #20 fpga_reset_n = 1'b1;
    #20 fpga_reset_n = 1'b0;
  end

  initial begin
    fclk = 1'b0; 
    forever begin
        #5 fclk = ~fclk;
    end
    
  end

endmodule