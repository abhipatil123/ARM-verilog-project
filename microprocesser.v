module Processor_TopModule(clk,rst,Out,conditions_flags,seg_out,disp1,disp2,disp3,disp4);
  //input Rst; 
  input clk;
  input rst;
 
  output [7:0]Out;
  output [3:0] conditions_flags; //NZCV
  output reg [7:0] seg_out;
  output  reg disp1;
  output  reg disp2;
  output  disp3;
  output  disp4;
  wire [7:0] PC_Next;
  wire [7:0] PC_Current;
  wire [31:0] IC;
  wire [39:0] PdataIfId;
  wire [49:0] PdataIdEx;
  wire [12:0] PdataMemWb;
  wire [23:0] PdataExMem;
  wire [3:0]control;
  wire [7:0] S1,S2,alu_src1,alu_src2,data_to_reg,data_to_mem;
  wire [3:0] reg_dest;
  wire rd_en,wr_en,mem_to_reg,reg_write,branch;
  wire [7:0]ic;
  wire [1:0]in;
  wire [7:0]offset;
  wire [3:0]rn,rm,str_src_reg;
  wire [7:0]alu_out,mem_out;
  wire [3:0] condtions_flags;
  wire cond_is_zero,cond_is_negative,cond_is_overflow,cond_is_always,cond_update;
  wire cpsr_write;
  wire [7:0] cpsr;
  reg [15:0] nclk;
  reg [3:0] sclk;
  reg [3:0] temp1;
  reg [3:0] temp2;
  reg [7:0] seg_led_1;
  reg [7:0] seg_led_2;
  reg [7:0] cur_state;
  reg [7:0] next_state;
  
  ProgramCounterReg pc(nclk[15],rst,PC_Next,PC_Current);
  PCIncrement pcInc(PC_Current,in,cond_satisfy,branch,alu_out,PC_Next);
  
  Instruction_Mem im(PC_Current,ic,in);
  instruction_reg ireg(ic,in,IC);
  PipelineReg_IFID PRegIfId(sclk[3],rst,IC,PC_Current,PdataIfId);
  ControlUnit cU(PdataIfId[31:0],control,rn,rm,reg_dest,str_src_reg,rd_en,wr_en,mem_to_reg,branch,reg_write,immediate,offset,cond_is_zero,
                    cond_is_negative,cond_is_overflow,cond_is_always,cond_update);
  RegFile rF(nclk,rn,rm,str_src_reg,PdataMemWb[11:8],PdataMemWb[7:0],PdataMemWb[12],conditions_flags,cpsr_write,S1,S2,data_to_mem,cpsr);
  alu_source mux1(immediate,branch,PdataIfId[39:32],S1,S2,offset,alu_src1,alu_src2);
  PipelineReg_IDEX PRegIdEx(nclk[15],rst,control,alu_src1,alu_src2,reg_dest,reg_write,rd_en,wr_en,mem_to_reg,data_to_mem,cond_is_zero,
                    cond_is_negative,cond_is_overflow,cond_is_always,cond_update,conditions_flags,cpsr,branch,PdataIdEx);
  
  ALU_TopModule aluTop(PdataIdEx[11:4],PdataIdEx[19:12],PdataIdEx[3:0],PdataIdEx[48:45],PdataIdEx[40],PdataIdEx[39],PdataIdEx[38],PdataIdEx[37],
                          PdataIdEx[36],PdataIdEx[49],cond_satisfy,alu_out,conditions_flags,cpsr_write);
  PipelineReg_EXMEM PregExMem(nclk[15],rst,alu_out,PdataIdEx[27:20],PdataIdEx[31:28],PdataIdEx[35],PdataIdEx[34],PdataIdEx[33],PdataIdEx[32],PdataExMem);
  ram dataMem(.address(PdataExMem[7:0]),.data_in(PdataExMem[15:8]),.rd_en(PdataExMem[22]),.wr_en(PdataExMem[21]),.data_out(mem_out));
  dataout_src mux2(.alu_out(PdataExMem[7:0]),.mem_out(mem_out),.mem_to_reg(PdataExMem[20]),.data_to_reg(data_to_reg));
  PipelineReg_MEMWB PRegMemWb(nclk[15],rst,data_to_reg,PdataExMem[19:16],PdataExMem[23],PdataMemWb);
  
  assign Out = PdataMemWb[7:0];
  
  always @(posedge clk)
		begin
			nclk <= nclk+1;
		end
		
	always @(posedge nclk[15])
		begin
			sclk <= sclk+1;
		end
	always @(*)
		begin
			temp1 = Out % 10;
			temp2 = Out / 10;
		end
always @(*)
		begin
			case(temp1)
				1:seg_led_1 = 8'b11001111;
				2:seg_led_1 = 8'b10010010;
				3:seg_led_1 = 8'b10000110;
				4:seg_led_1 = 8'b11001100;
				5:seg_led_1 = 8'b10100100;
				6:seg_led_1 = 8'b10100000;
				7:seg_led_1 = 8'b10001111;
				8:seg_led_1 = 8'b10000000;
				9:seg_led_1 = 8'b10001100;
				0:seg_led_1 = 8'b10000001;
				default:seg_led_1 = 8'b11111111;
			endcase
		end	
always @(*)
		begin
			case(temp2)
				1:seg_led_2 = 8'b11001111;
				2:seg_led_2 = 8'b10010010;
				3:seg_led_2 = 8'b10000110;
				4:seg_led_2 = 8'b11001100;
				5:seg_led_2 = 8'b10100100;
				6:seg_led_2 = 8'b10100000;
				7:seg_led_2 = 8'b10001111;
				8:seg_led_2 = 8'b10000000;
				9:seg_led_2 = 8'b10001100;
				0:seg_led_2 = 8'b10000001;
				default:seg_led_2 = 8'b11111111;
			endcase
		end
always @(*)
		begin
			case(cur_state)
				0:	begin
						disp1 <= 1'b0;
						disp2 <= 1'b1;
						seg_out <= seg_led_1;
						next_state <= 1;
					end
				1:	begin
						disp1 <= 1'b1;
						disp2 <= 1'b0;
						seg_out <= seg_led_2;
						next_state <= 0;
					end
				default:	begin
						disp1 <= 1'b0;
						disp2 <= 1'b1;
						seg_out <= seg_led_1;
						next_state <= 0;
					end		
					
			endcase
		end
	always @(posedge sclk[3])
		begin
				cur_state <= next_state;
	end
assign 	disp3 = 1'b1;
assign 	disp4 = 1'b1;
	
endmodule