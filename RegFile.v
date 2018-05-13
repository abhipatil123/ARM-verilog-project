`timescale 1ns / 1ps

module RegFile(clk,rn,rm,str_src_reg,rd,WD,reg_write,conditions_flags,cpsr_write,S1,S2,data_to_mem,cpsr);
  input [3:0]rn;
  input [3:0]rm;
  input [3:0]rd,str_src_reg;
  input [7:0]WD;
  input clk,reg_write;
  input [3:0] conditions_flags;
  input cpsr_write;
  output reg [7:0]S1;
  output reg [7:0]S2;
  output reg [7:0]data_to_mem;
  output reg [7:0] cpsr;
  reg [7:0] R[15:0];
  integer i;
  initial begin
    for(i=0;i<=15;i=i+1)
      R[i]=i;
  end
  
  always @(*) begin
    if (((rn !== rd) && ( rm !== rd)) | ((rd === 1'bx) | (rd === 1'b0)))begin
      case(rn)
    4'b0000: S1= R[0];
    4'b0001: S1= R[1];
    4'b0010: S1= R[2];
    4'b0011: S1= R[3];
    4'b0100: S1= R[4];
    4'b0101: S1= R[5];
    4'b0110: S1= R[6];
    4'b0111: S1= R[7];
    4'b1000: S1= R[8]; 
    4'b1001: S1= R[9];
    4'b1010: S1= R[10];
    4'b1011: S1= R[11];
    4'b1100: S1= R[12];
    4'b1101: S1= R[13];
    4'b1110: S1= R[14];
    4'b1111: S1= R[15];
  endcase

      case(rm)
    4'b0000: S2= R[0];
    4'b0001: S2= R[1];
    4'b0010: S2= R[2];
    4'b0011: S2= R[3];
    4'b0100: S2= R[4];
    4'b0110: S2= R[6];
    4'b0111: S2= R[7];
    4'b1000: S2= R[8];
    4'b1001: S2= R[9];
    4'b1010: S2= R[10];
    4'b1011: S2= R[11];
    4'b1100: S2= R[12];
    4'b1101: S2= R[13];
    4'b1110: S2= R[14];
    4'b1111: S2= R[15];
  endcase
    end
  case(str_src_reg)
    4'b0000: data_to_mem= R[0];
    4'b0001: data_to_mem= R[1];
    4'b0010: data_to_mem= R[2];
    4'b0011: data_to_mem= R[3];
    4'b0100: data_to_mem= R[4];
    4'b0110: data_to_mem= R[6];
    4'b0111: data_to_mem= R[7];
    4'b1000: data_to_mem= R[8];
    4'b1001: data_to_mem= R[9];
    4'b1010: data_to_mem= R[10];
    4'b1011: data_to_mem= R[11];
    4'b1100: data_to_mem= R[12];
    4'b1101: data_to_mem= R[13];
    4'b1110: data_to_mem= R[14];
    4'b1111: data_to_mem= R[15];
  endcase
 end
  
  always@(*) begin
    if (cpsr_write)
      cpsr[3:0] = 8'b0; 
      cpsr[7:4] = conditions_flags;
  end
  
  always @(*) begin
  if (reg_write) begin
    case(rd)
      4'b0000: R[0]=WD;
      4'b0001: R[1]=WD;
      4'b0010: R[2]=WD;
      4'b0011: R[3]=WD;
      4'b0100: R[4]=WD;
      4'b0101: R[5]=WD;
      4'b0110: R[6]=WD;
      4'b0111: R[7]=WD;
      4'b1000: R[8]=WD;
      4'b1001: R[9]=WD;
      4'b1010: R[10]=WD;
      4'b1011: R[11]=WD;
      4'b1100: R[12]=WD;
      4'b1101: R[13]=WD;
      4'b1110: R[14]=WD;
      4'b1111: R[15]=WD;
    endcase
  end
  end
  
endmodule
