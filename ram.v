module ram(address,data_in,rd_en,wr_en,data_out);
  input [7:0]address;
  input [7:0]data_in;
  input rd_en;
  input wr_en;
  output reg [7:0]data_out;
  reg [7:0]ram[127:0];
  
  integer i;
  initial begin
    for(i=0;i<=127;i=i+1) 
      ram[i]=i;
  end
  
  always @(*) begin
    if (wr_en) begin
      ram[address] <= data_in;
      data_out <= 8'b0;
    end
    else if (rd_en)
      data_out <= ram[address];
    else
      data_out <= 8'b0;
  end
endmodule
    
      