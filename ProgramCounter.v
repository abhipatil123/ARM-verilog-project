`timescale 1ns / 1ps

module ProgramCounterReg(clk,rst,PC_Next,PC_Current);
  input clk,rst;
  input [7:0] PC_Next;
  output reg [7:0] PC_Current;
  //reg [7:0]PCC;
  
  always @ (posedge clk or posedge rst)
  begin
    if (rst)
        PC_Current <= 8'b11111111;
    else
      PC_Current <= PC_Next;
  end
endmodule

module PCIncrement(PC_Current,in,branch,cond_satisfy,Branch_Target,PC_Next);
  input [7:0] PC_Current;
  input [7:0] Branch_Target;
  input [1:0]in;
  input branch;  // branch = 1 if branch instruction, fetch next instruction from branch target if in ==3 & branch ==1
  input cond_satisfy;
  output [7:0] PC_Next; // if branch instruction then next PC == PC+1+branch target
  assign PC_Next = ((branch === 1'b1) && (in===2'b11) && (cond_satisfy===1'b1)) ? Branch_Target : PC_Current + 1 ; //Branch Target offset should be less than 127 (becuase of 128b Instruction memory)
endmodule
