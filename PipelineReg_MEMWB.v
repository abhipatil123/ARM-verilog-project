module PipelineReg_MEMWB(nclk,rst,data_to_reg,reg_dest,reg_write,data_out);
  input [7:0] data_to_reg;
  input [3:0] reg_dest;
  input reg_write,rst;
  input nclk;
  output reg[12:0] data_out;
  
  always @(posedge nclk or posedge rst) begin
    if (rst)
      data_out <= 0;
    else begin
      data_out[7:0] <= data_to_reg;
      data_out[11:8] <= reg_dest;
      data_out[12] <= reg_write;
    end
  end
endmodule
