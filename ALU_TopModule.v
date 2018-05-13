module ALU_TopModule(A,B,control,inst_conds,cond_is_zero,cond_is_negative,cond_is_overflow,cond_is_always,cond_update,branch,riscv_branch_offset,PC,cond_satisfy,out,conditions_flags,cpsr_write);
  input [7:0] A,B;	/* declaration of the inputs outputs and required intermediate register*/
  input [3:0] control;
  input cond_is_zero,cond_is_negative,cond_is_overflow,cond_is_always,cond_update;
  input [3:0] inst_conds; //conditions under which instructions has to be executed ( inst_conds = {N Z C V})
  input branch;
  input [7:0] PC,riscv_branch_offset;;
  output [7:0]out;
  output [3:0]conditions_flags;
  output cpsr_write;
  reg [7:0]a,b;
  reg [7:0]Out;
  reg oN;
  reg oZ;
  reg oC;
  reg oV;
  output reg cond_satisfy;
  assign out = Out;
  
  assign conditions_flags = cond_update ? {oN,oZ,oC,oV}: inst_conds;
  assign cpsr_write = cond_update ? 1 :0;
  //Whether to execute instructions or not (according to condition fields of instruction(31:28))
  //for example BZ #6 if Z is zero then take branch
  
  always @(*) begin
    if (cond_is_zero)
      cond_satisfy = inst_conds[2];
    else if (cond_is_negative)
      cond_satisfy = inst_conds[3];
    else if (cond_is_overflow)
      cond_satisfy = inst_conds[0];
    else
      cond_satisfy = cond_is_always;
  end
        
  always @(*)	// making the  whole process respond to the any signal
    begin
      if(cond_satisfy) begin
        case(control)	//The operation done by the ALU is controlled by the control signal.
          4'b0011:begin
            CLA2(A,B,1'b0,Out,oN,oZ,oC,oV);	//performs addition for this opcode
          end
          4'b0010:CLA2(A,~B,1'b1,Out,oN,oZ,oC,oV); //performs subtraction using one's compliment addition for this opcode
          4'b0000: begin
            Out = A & B;	//performs logical AND for this opcode
            oN = 0;
            oZ = (Out == 8'b0);
            oC =0;
            oV =0;
          end
          4'b0001: begin
            Out = A^B; //performs logical XOR of this opcode 
            oN = 0;
            oZ = (Out == 8'b0);
            oC =0;
            oV =0;
          end
          4'b0100: begin
            CLA2(A,~B,1'b1,Out,oN,oZ,oC,oV); //CMP instruction
          end
          4'b0101: begin
            CLA2(A,B,1'b0,Out,oN,oZ,oC,oV); //CMN instruction
          end
          4'b0110: Out = B; //MOV Instruction  Bypass ALU 
          4'b1000: CLA2(A,B,1'b0,Out,oN,oZ,oC,oV); //Load  
          4'b1001: CLA2(A,B,1'b0,Out,oN,oZ,oC,oV); // Store
          4'b0111: begin
            barrel_shifter(B,3'b010,1,0,b);
            CLA2(A,b,1'b0,Out,oN,oZ,oC,oV);  //branch B ARM 
          end
          4'b1010: begin
            barrel_shifter(riscv_branch_offset,3'b010,1,0,b);
            CLA2(A,B,1'b1,Out,oN,oZ,oC,oV);  //branch BEQ RISC V
            Out = (Out == 8'b0) ? PC + b : PC+4;
            //cond_satisfy = (Out == 8'b0) ? 1:0;
          end
          4'b1011: begin
            barrel_shifter(riscv_branch_offset,3'b010,1,0,b);
            CLA2(A,B,1'b1,Out,oN,oZ,oC,oV);  //branch BNEQ RISV V
            Out = (Out != 8'b0) ? PC + b : PC+4;
            //cond_satisfy = (Out == 8'b0) ? 0:1;
          end
          
        endcase
      end
  end
  
  task CLA2;
    // Carry look ahead adder 
    input [7:0] a; //8 bits Input 1 
    input [7:0] b; //8 bits Input 2 
    input cin;  //Input Carry
    output [7:0] out;  // 8 bits output 
    output oN;
    output oZ;
    output oC;
    output oV;
    // Internal wires g, p, G, P, c, C 
    reg[7:0]g;
    reg [7:0]p;
    reg G0,G1;
    reg P0,P1;
    reg Neg;
    reg [7:0]c;
    reg C1,C2;
    begin
      c[0] = cin;

      /* c[i+1] = a[i] * b[i] + c[i] * (a[i] + b[i]) c[i+1] = g[i] + c[i] * p[i] */

      g = a & b; 
      p = a | b;

      /* C[i] = G[i] + P[i] * C[i]
      Splitting 7 bits adder into two 4 bits adder C[1] is carry out from first block */
      // Precomputing P, G and C to save some cycles 

      P0 = p[0] & p[1] & p[2] & p[3];
      P1 = p[4] & p[5] & p[6] & p[7];
      G0 = g[3] | g[2] & p[3] | g[1] & p[3] & p[2] | g[0] & p[3] & p[2] & p[1];
      G1 = g[7] | g[6] & p[7] | g[5] & p[7] & p[6] | g[4] & p[7] & p[6] & p[5];
      C1 = G0 | P0 & c[0];
      C2 = G1 | G0 & P1 | P1 & P0 & c[0];

      c[1] = g[0] | p[0] & c[0];
      c[2] = g[1] | g[0] & p[1] | p[1] & p[0] & c[0];
      c[3] = g[2] | g[1] & p[2] | g[0] & p[2] & p[1] | p[2] & p[1] & p[1] & c[0]; 
      c[4] = C1;
      c[5] = g[4] | p[4] & C1;
      c[6] = g[5] | g[4] & p[5] | p[5] & p[4] & C1;
      c[7] = g[6] | g[5] & p[6] | g[4] & p[6] & p[5] | p[6] & p[5] & p[4] & C1; 

      out[0] = a[0] ^ b[0] ^ c[0];	// final operations 
      out[1] = a[1] ^ b[1] ^ c[1];
      out[2] = a[2] ^ b[2] ^ c[2];
      out[3] = a[3] ^ b[3] ^ c[3];
      out[4] = a[4] ^ b[4] ^ c[4];
      out[5] = a[5] ^ b[5] ^ c[5];
      out[6] = a[6] ^ b[6] ^ c[6];
      out[7] = a[7] ^ b[7] ^ c[7];
      oC = C2;	//assiging the C/V if carry/overflow occurs 
      oZ = (out == 8'b0);
      Neg = 0;
      if (cin) begin
        if (out[7] & ~C2) begin
          Neg = out[7];
          out = ~out + 1;
          oV = 1;
        end
        else begin
          oC = 0;
          oV = 0;
        end
      end
      else
        oV = C2;
      
      oN = Neg;
    end
  endtask

task barrel_shifter;
  input [7:0] a;
  input [2:0] shift_by;
  input lsh;
  input rsh;
  output [7:0] b;
  reg [7:0] b;
  begin
  //lsh true left shift by (shift_by)
  //rsh true right shift by (shift_by)
    if (lsh) begin
    case (shift_by)
      3'b000: b = a;
      3'b001: b = a << 1;
      3'b010: b = a << 2;
      3'b011: b = a << 3;
      3'b100: b = a << 4;
      3'b101: b = a << 5;
      3'b110: b = a << 6;
      3'b111: b = a << 7;
    endcase
    end
    else if (rsh) begin
      case(shift_by)
      3'b000: b = a;
      3'b001: b = a>>1;
      3'b010: b = a>>2;
      3'b011: b = a>>3;
      3'b100: b = a>>4;
      3'b101: b = a>>5;
      3'b110: b = a>>6;
      3'b111: b = a>>7;
      endcase
    end
  end
endtask

endmodule
