`timescale 1ns / 1ns
module Instruction_Mem(PC,IC,in);
  input [7:0]PC;
  output[7:0] IC;
  output [1:0]in;
  reg [7:0]my_IMreg;
  
  always @(*) begin
    case(PC) 
      8'b00000000: my_IMreg <= 8'b00000000; 
      8'b00000001: my_IMreg <= 8'b00000000; 
      8'b00000010: my_IMreg <= 8'b00000000; 
      8'b00000011: my_IMreg <= 8'b00000000; //ISA Idnetifier instruction 
      8'b00000100: my_IMreg <= 8'b00000101; 
      8'b00000101: my_IMreg <= 8'b01000000; 
      8'b00000110: my_IMreg <= 8'b10100000; 
      8'b00000111: my_IMreg <= 8'b11100011; //MOV R4 #3
      8'b00001000: my_IMreg <= 8'b00000000; 
      8'b00001001: my_IMreg <= 8'b00010000; 
      8'b00001010: my_IMreg <= 8'b10100000; 
      8'b00001011: my_IMreg <= 8'b11100011; //MOV R1 #0
      8'b00001100: my_IMreg <= 8'b00000001;
      8'b00001101: my_IMreg <= 8'b00100000; 
      8'b00001110: my_IMreg <= 8'b10100000;
      8'b00001111: my_IMreg <= 8'b11100011; //MOV R2 #1
      8'b00010000: my_IMreg <= 8'b00000110; 
      8'b00010001: my_IMreg <= 8'b00000000; 
      8'b00010010: my_IMreg <= 8'b00000000; 
      8'b00010011: my_IMreg <= 8'b00001010; //BZ #6
      8'b00010100: my_IMreg <= 8'b00000001; 
      8'b00010101: my_IMreg <= 8'b01000000; 
      8'b00010110: my_IMreg <= 8'b01000100; 
      8'b00010111: my_IMreg <= 8'b11100010; // SUB R4 R4 #1
      8'b00011000: my_IMreg <= 8'b00000001; 
      8'b00011001: my_IMreg <= 8'b00110000; 
      8'b00011010: my_IMreg <= 8'b10000010; 
      8'b00011011: my_IMreg <= 8'b11100000; //ADD R3 R2 R1 
      8'b00011100: my_IMreg <= 8'b00000010; 
      8'b00011101: my_IMreg <= 8'b00010000; 
      8'b00011110: my_IMreg <= 8'b10100000; 
      8'b00011111: my_IMreg <= 8'b11100001; //MOV R1 R2
      8'b00100000: my_IMreg <= 8'b00000011; 
      8'b00100001: my_IMreg <= 8'b00100000; 
      8'b00100010: my_IMreg <= 8'b10100000; 
      8'b00100011: my_IMreg <= 8'b11100001; //MOV R2 R3
      8'b00100100: my_IMreg <= 8'b11111010; 
      8'b00100101: my_IMreg <= 8'b00000000; 
      8'b00100110: my_IMreg <= 8'b00000000; 
      8'b00100111: my_IMreg <= 8'b11101010;  //B #-6
      8'b00101000: my_IMreg <= 8'b00000010; 
      8'b00101001: my_IMreg <= 8'b00000000; 
      8'b00101010: my_IMreg <= 8'b01010100; 
      8'b00101011: my_IMreg <= 8'b11100011; //CMP R4 #2
      8'b00101100: my_IMreg <= 8'b11111111; 
      8'b00101101: my_IMreg <= 8'b00000000; 
      8'b00101110: my_IMreg <= 8'b00000000; 
      8'b00101111: my_IMreg <= 8'b11101010; //B #-1
      8'b00110000: my_IMreg <= 8'b00000011; 
      8'b00110001: my_IMreg <= 8'b00100000;
      8'b00110010: my_IMreg <= 8'b10100000; 
      8'b00110011: my_IMreg <= 8'b11100001;  //MOV R2 R3 
     /*
      8'b00000000: my_IMreg <= 8'b00000001; 
      8'b00000001: my_IMreg <= 8'b00000000; 
      8'b00000010: my_IMreg <= 8'b00000000; 
      8'b00000011: my_IMreg <= 8'b00000000; //ISA Idnetifier instruction 
      8'b00000100: my_IMreg <= 8'b00010011; 
      8'b00000101: my_IMreg <= 8'b00000010; 
      8'b00000110: my_IMreg <= 8'b00110000; 
      8'b00000111: my_IMreg <= 8'b00000000; //MOV R4 #7--ADDI R4, R0, #7
      8'b00001000: my_IMreg <= 8'b10010011; 
      8'b00001001: my_IMreg <= 8'b00000000; 
      8'b00001010: my_IMreg <= 8'b00010000; 
      8'b00001011: my_IMreg <= 8'b00000000; //MOV R1 #0 --ADDI R1, R0, #1
      8'b00001100: my_IMreg <= 8'b10010011;
      8'b00001101: my_IMreg <= 8'b00000010; 
      8'b00001110: my_IMreg <= 8'b00100000;
      8'b00001111: my_IMreg <= 8'b00000000; //ADDI R5, R0, #2
      8'b00010000: my_IMreg <= 8'b00010011;
      8'b00010001: my_IMreg <= 8'b00000001; 
      8'b00010010: my_IMreg <= 8'b00010000;
      8'b00010011: my_IMreg <= 8'b00000000; //MOV R2 #1 --ADDI R2, R0, #1
	  8'b00010100: my_IMreg <= 8'b01100011;  
      8'b00010101: my_IMreg <= 8'b00010101; 
      8'b00010110: my_IMreg <= 8'b01010010; 
      8'b00010111: my_IMreg <= 8'b00000000; //BZ #6 -- BEQ R4,R5,#5
      8'b00011000: my_IMreg <= 8'b00010011; 
      8'b00011001: my_IMreg <= 8'b00000010; 
      8'b00011010: my_IMreg <= 8'b11110010; 
      8'b00011011: my_IMreg <= 8'b00001111; // SUB R4 R4 #1 -- ADDI R4, R4 ,#-1
      8'b00011100: my_IMreg <= 8'b10110011; 
      8'b00011101: my_IMreg <= 8'b10000001; 
      8'b00011110: my_IMreg <= 8'b00100000; 
      8'b00011111: my_IMreg <= 8'b00000000; //ADD R3 R2 R1 -- ADD R3, R2, R1
      8'b00100000: my_IMreg <= 8'b10010011; 
      8'b00100001: my_IMreg <= 8'b00000000; 
      8'b00100010: my_IMreg <= 8'b00000001; 
      8'b00100011: my_IMreg <= 8'b00000000; //MOV R1 R2 -- ADDI R1, R2, #0
      
      8'b00100100: my_IMreg <= 8'b11100011; 
      8'b00100101: my_IMreg <= 8'b00011010; 
      8'b00100110: my_IMreg <= 8'b00000010; 
      8'b00100111: my_IMreg <= 8'b00011110;  //B #-6 -- JAL #-6   BNEQ R4,R0, # -6
      8'b00101000: my_IMreg <= 8'b00010011; 
      8'b00101001: my_IMreg <= 8'b10000001; 
      8'b00101010: my_IMreg <= 8'b00000001; 
      8'b00101011: my_IMreg <= 8'b00000000; //MOV R2 R3 -- ADDI R2, R3, #0
      8'b00101100: my_IMreg <= 8'b11100011; 
      8'b00101101: my_IMreg <= 8'b00011111; 
      8'b00101110: my_IMreg <= 8'b00000010; 
      8'b00101111: my_IMreg <= 8'b00011110; //B #-1  BNEQ R4,RO ,#-1
	  8'b00110000: my_IMreg <= 8'b00010011; 
	  8'b00110001: my_IMreg <= 8'b10000001;
	  8'b00110010: my_IMreg <= 8'b00000001; 
	  8'b00110011: my_IMreg <= 8'b00000000;  //MOV R2 R3  -- ADDI R2, R3, #0 	*/	
      default:my_IMreg <=8'b0;
    endcase
  end
assign IC = my_IMreg;
assign in = PC % 8'b00000100;

endmodule

