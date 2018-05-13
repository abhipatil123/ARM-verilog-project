module PipelineReg_IFID(sclk,rst,IC,PC,conditions_flags,data_out);
  input sclk,rst;
  input [31:0]IC;
  input [7:0]PC;
  input [3:0] conditions_flags;
  
  output reg [43:0] data_out;
  
  always @(negedge sclk or posedge rst) begin
    if (rst)
      data_out <= 0;
    else
      data_out <= {conditions_flags,PC,IC};
  end
endmodule
  