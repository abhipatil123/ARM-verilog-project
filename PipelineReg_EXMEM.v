module PipelineReg_EXMEM(nclk,rst,alu_result,data_to_mem,reg_dest,reg_write,rd_en,wr_en,mem_to_reg,branch,data_out);
  input [7:0] alu_result;
  input [7:0] data_to_mem;
  input [3:0] reg_dest;
  input rd_en,wr_en,mem_to_reg,reg_write,rst,branch;
  input nclk;
  output reg[23:0] data_out;
  
  always @(posedge nclk or posedge rst) begin
    if (rst)
      data_out <= 0;
    else begin
      if (branch !== 1'b1) 
      	data_out[7:0] <= alu_result;
      data_out[15:8] <= data_to_mem;
      data_out[19:16] <= reg_dest;
      data_out[23:20] <= {reg_write,rd_en,wr_en,mem_to_reg};
    end
  end
endmodule
