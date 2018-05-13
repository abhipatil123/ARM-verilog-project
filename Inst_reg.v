module instruction_reg(ic,in,IC);
  input [7:0]ic;
  input [1:0]in;
  output reg [31:0]IC;
 
  always @(*) begin
  case(in) 
    2'b00:IC[7:0] = ic;
    2'b01:IC[15:8] = ic;
    2'b10:IC[23:16] = ic;
    2'b11:IC[31:24] = ic;
  endcase
  end
endmodule

  