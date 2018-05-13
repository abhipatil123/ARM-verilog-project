module dataout_src(alu_out,mem_out,mem_to_reg,data_to_reg);
  input [7:0]alu_out;
  input [7:0]mem_out;
  input mem_to_reg;
  output [7:0]data_to_reg;
  assign data_to_reg = mem_to_reg ? mem_out : alu_out; 
endmodule

  
  
  