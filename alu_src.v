module alu_source(immediate,branch,PC_Current,S1,S2,offset,alu_src1,alu_src2);
	input immediate,branch;
    input [7:0]S2,S1,offset;
    input [7:0] PC_Current;
  	output [7:0]alu_src1,alu_src2;
  	assign alu_src1 = (branch === 1'b1) ? PC_Current : S1;
  	assign alu_src2 = (immediate === 1'b1) ? offset : S2;
endmodule
