module PipelineReg_IDEX(nclk,rst,control,S1,S2,reg_dest,reg_write,rd_en,wr_en,mem_to_reg,data_to_mem,cond_is_zero,
                    cond_is_negative,cond_is_overflow,cond_is_always,cond_update,conditions_flags,branch,riscv_branch_offset,riscv_branch,PC_current,data_out);
  input [3:0]control;
  input [7:0] S1,S2,data_to_mem,PC_current,riscv_branch_offset;
  input [3:0] reg_dest;
  input rd_en,wr_en,mem_to_reg,reg_write,rst,riscv_branch;
  input cond_is_zero,cond_is_negative,cond_is_overflow,cond_is_always,cond_update;
  input [3:0]conditions_flags;
  input branch;
  input nclk;
  output reg [68:0] data_out;
  
  always @(posedge nclk or posedge rst) begin
    if (rst)
      data_out <= 0;
    else begin
      data_out[3:0] <= control;
      data_out[11:4] <= S1;
      data_out[19:12] <= S2;
      data_out[27:20] <= data_to_mem;
      data_out[31:28] <= reg_dest;
      data_out[35:32] <= {reg_write,rd_en,wr_en,mem_to_reg};
      data_out[40:36] <= {cond_is_zero,cond_is_negative,cond_is_overflow,cond_is_always,cond_update};
      data_out[48:41] <= {conditions_flags,4'b0000};
      data_out[49] <= (riscv_branch === 1'b1) ? 1 : branch;
      data_out[57:50] <= riscv_branch_offset;
      data_out[58] <= riscv_branch;
      data_out[66:59] <= PC_current;
    end
  end
  
endmodule
  