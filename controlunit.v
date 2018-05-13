module ControlUnit (cmd,ALUC,rn,rm,reg_dest,str_src_reg,rd_en,wr_en,mem_to_reg,branch,reg_write,immediate,offset,cond_is_zero,
                    cond_is_negative,cond_is_overflow,cond_is_always,cond_update,riscv_branch_offset,riscv_branch);
  input [31:0] cmd;
  output reg rd_en,wr_en,mem_to_reg,reg_write;
  output [3:0]rn,rm,reg_dest;
  output reg [3:0]ALUC;
  output immediate,branch;
  output reg [7:0]offset;
  output [3:0] str_src_reg;
  output reg cond_is_zero;
  output reg cond_is_negative;
  output reg cond_is_overflow;
  output reg cond_is_always;
  output reg cond_update;
  output reg [7:0]riscv_branch_offset;
  output riscv_branch;
  wire cmd_is_dp;
  wire cmd_is_swi;
  wire cmd_is_b;
  wire cmd_is_ld_str;
  wire [3:0]cmd_conditions_bits;
  wire arm_str_reg;
  wire immediate_risc;
  
  reg arm_isa;
  reg riscv_isa;
  //RISC-V
  wire             cmd_risc_is_dp;
  wire             cmd_risc_is_swi;
  wire             cmd_risc_is_b;
  wire             cmd_risc_is_ld_str;
  wire riscv_str_reg;
  
  assign cmd_is_dp =  ( cmd[27:26]==2'b0 ) & (cmd != 32'b0);
  assign cmd_is_swi =  ( cmd[27:24]==4'b1111 );
  assign cmd_is_b =  ( cmd[27:25]==3'b101 );
  assign cmd_is_ld_str =  ( cmd[27:26]==2'b01 );
  assign rn = arm_isa ? cmd[19:16]: cmd[18:15];
  assign reg_dest = arm_isa ? cmd[15:12]:cmd[10:7]; 
  assign rm = arm_isa ? cmd[3:0]:cmd[23:20];
    
  assign immediate = arm_isa ? cmd[25]: immediate_risc;
  assign immediate_risc = cmd_risc_is_dp ? ~ cmd[5] : cmd_risc_is_ld_str;
  assign cond_update = arm_isa ? (cmd_is_dp ? cmd[20] : 0) :0;
  assign arm_str_reg = (cmd_is_ld_str & (cmd[20] == 1'b0)) ? reg_dest :4'b0;
  assign risc_str_reg = (cmd_risc_is_ld_str & cmd[5] == 1'b1) ? rm : 4'b0;
  assign str_src_reg = arm_isa ? arm_str_reg :risc_str_reg;
  assign cmd_conditions_bits = cmd[31:28];
  assign riscv_branch_offset = riscv_isa ? {cmd[28:25],cmd[11:8]}:8'b0; 
  //RISC-v
  assign cmd_risc_is_dp =  ( cmd[4]==1'b1 );
  assign cmd_risc_is_b =  ( cmd[6:0]==7'b1100011 );
  assign cmd_risc_is_ld_str =  ( cmd[14:12]==3'b010 );
  
  assign branch = arm_isa ? cmd_is_b : 0;
  assign riscv_branch = riscv_isa ? cmd_risc_is_b : 0;
  
  always @(*) begin
    case(cmd)
      32'h00000000 : begin
        arm_isa <= 1;
        riscv_isa <= 0;
      end
      32'h00000001: begin
        arm_isa <= 0;
        riscv_isa <= 1;
      end
    endcase
     end
  //data - processing
  always @(*) begin
    if (arm_isa) begin
      //default 
      cond_is_zero = 0;
      cond_is_negative = 0;
      cond_is_overflow = 0;
      cond_is_always = 0;

      case(cmd_conditions_bits)
        4'b0000: cond_is_zero = 1;
        4'b0100: cond_is_negative = 1;
        4'b0010: cond_is_overflow = 1;
        4'b1110: cond_is_always = 1;
        default: cond_is_always = 1;
      endcase

      if ( cmd_is_dp ) begin
        offset = immediate ? cmd[7:0] : 8'b0; //immediate
        reg_write = 1;
        rd_en = 0;
        wr_en = 0;
        mem_to_reg = 0;
        case (cmd[24:21])
          4'b0000: ALUC = 4'b0000; //and
          4'b0001: ALUC = 4'b0001; //eor
          4'b0010: ALUC = 4'b0010; //sub
          4'b0100: ALUC = 4'b0011; //add
          4'b1010: begin
            ALUC = 4'b0100; //cmp
            reg_write = 0;
          end
          4'b1011: begin
            ALUC = 4'b0101; //cmn
            reg_write = 0;
          end
          4'b1101: ALUC = 4'b0110; //mov
        endcase
      end

    //branch
      if ( cmd_is_b ) begin
        if ( cmd[24] == 1'b0 ) begin
          //branch without link
          offset = cmd[7:0];  //taking only first 8 bits of 24 bits offset
          ALUC = 4'b0111;
          reg_write = 0;
          rd_en = 0;
          wr_en = 0;
          mem_to_reg = 0;
        end
      end
    //software interrupt
      if ( cmd_is_swi ) begin
        ALUC = 4'b1010;
        reg_write = 1;
        rd_en = 0;
        wr_en = 0;
        mem_to_reg = 0;
      end
      //Load-Store 	
      if ( cmd_is_ld_str ) begin
        if ( immediate ) begin
          offset = cmd[7:0];    //taking only first 8 bits of 12 bits offset
          rd_en = 0;
          wr_en = 0;
          mem_to_reg = 0;
        end
        if ( cmd[20] == 1'b1 ) begin
          ALUC = 4'b1000;  //load
          rd_en = 1;
          wr_en = 0;
          mem_to_reg = 1;
          reg_write = 1;
        end
        else begin
          ALUC = 4'b1001;  //store
          rd_en = 0;
          wr_en = 1;
          mem_to_reg = 0;
          reg_write = 0;
        end
      end
     end
    else if (riscv_isa) begin
      
      cond_is_zero = 0;
      cond_is_negative = 0;
      cond_is_overflow = 0;
      cond_is_always = 1;
      
      if ( cmd_risc_is_dp ) begin
        offset = immediate_risc ? cmd[27:20] :8'b0; //immediate
        reg_write = 1;
        rd_en = 0;
        wr_en = 0;
        mem_to_reg = 0;
        case (cmd[14:12])
          3'b111: ALUC = 4'b0000; //and
          3'b100: ALUC = 4'b0001; //eor
          3'b000: ALUC = 4'b0011; //add
        endcase
        if (cmd[30]==1) begin
          ALUC = 4'b0010; //sub
        end
      end
      if ( cmd_risc_is_b ) begin
        if ( cmd[14:12] == 3'b000 ) begin
          //BEQ
          //offset = cmd[7:0];
          ALUC = 4'b1010;
          reg_write = 0;
          rd_en = 0;
          wr_en = 0;
          mem_to_reg = 0;
        end
        else begin
          //BNEQ
          //offset = cmd[7:0]; 
          ALUC = 4'b1011;
          reg_write = 0;
          rd_en = 0;
          wr_en = 0;
          mem_to_reg = 0;
        end
   	 end
     
     if ( cmd_risc_is_ld_str ) begin
        rd_en = 0;
        wr_en = 0;
        mem_to_reg = 0;
        if ( cmd[5] == 1'b0 ) begin
          ALUC = 4'b1000;  //load
          offset = cmd[27:20];   
          rd_en = 1;
          wr_en = 0;
          mem_to_reg = 1;
          reg_write = 1;
        end
        else begin
          ALUC = 4'b1001;  //store
          offset = {cmd[27:25],cmd[11:7]}; 
          rd_en = 0;
          wr_en = 1;
          mem_to_reg = 0;
          reg_write = 0;
        end
    end 
    end  
      
   end
endmodule
