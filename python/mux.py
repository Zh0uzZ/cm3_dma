def generate_decoder_code():
    with open("decoder_7x128.v", "w") as f:
        f.write("module Decoder_7x128 (\n")
        f.write("  input wire [6:0] select,\n")
        f.write("  output wire [127:0] outputs\n")
        f.write(");\n")
        f.write("\n")
        f.write("  reg [127:0] data;\n")
        f.write("\n")
        f.write("  always @* begin\n")
        f.write("    case (select)\n")
        
        for i in range(128):
            f.write(f"      7'b{i:07b}: data = 128'h{2**i:032x};\n")
        
        f.write("      default: data = 128'h00000000000000000000000000000000;\n")
        f.write("    endcase\n")
        f.write("  end\n")
        f.write("\n")
        f.write("  assign outputs = data;\n")
        f.write("\n")
        f.write("endmodule\n")

generate_decoder_code()
