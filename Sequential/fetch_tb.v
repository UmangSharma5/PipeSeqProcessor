`include "fetch.v"

module fetch_tb;
reg clk;
reg [63:0] PC;
reg [0:79] instr; // 10 byte instruction

wire [3:0] icode;
wire [3:0] ifun;
wire [3:0] rA;
wire [3:0] rB; 
wire [63:0] valC;
wire [63:0] valP;
wire memory_error;
wire instr_valid;
reg [7:0] instr_mem[0:255]; // to store each byte of my instruction

    fetch fetch(
    .icode(icode),
    .ifun(ifun),
    .rA(rA),
    .rB(rB),
    .valC(valC),
    .valP(valP),
    .clk(clk),
    .PC(PC),
    .memory_error(memory_error),
    .instr_valid(instr_valid),
    .instr(instr)
  );
initial 
begin
  // for (integer i=0; i<=255 ; i+=1 ) begin
  //   instr_mem[i]=8'b0;
  // end
end
always@(PC)
begin
  // as instr is 10 bytes instr_mem[] represents each byte
  instr={
    instr_mem[PC],
    instr_mem[PC+1],
    instr_mem[PC+2],
    instr_mem[PC+3],
    instr_mem[PC+4],
    instr_mem[PC+5],
    instr_mem[PC+6],
    instr_mem[PC+7],
    instr_mem[PC+8],
    instr_mem[PC+9]
  };
end
    
always @(icode) 
begin
    if(icode==0 && ifun==0) // halt
      $finish;
end


initial begin
  clk=1;
  PC=64'd34;

  // instr_mem[32]=8'b01100001; //6 fn
  // instr_mem[33]=8'b00100011; //rA rB
  instr_mem[34]=8'b01010000; // 4 0 rmmovq
  instr_mem[35]=8'b00100001; //2 1
  instr_mem[36]=8'b00000000;
  instr_mem[37]=8'b00000000;
  instr_mem[38]=8'b00000001;
  instr_mem[39]=8'b00000010;  
  instr_mem[40]=8'b00000011;
  instr_mem[41]=8'b00000100;
  instr_mem[42]=8'b00000101;
  instr_mem[43]=8'b00000110;
  instr_mem[44]=8'b00000111;
  instr_mem[45]=8'b00001000;
  instr_mem[46]=8'b00001001;
  instr_mem[47]=8'b00001011;
  $monitor("clk=%d PC=%d icode=%b ifun=%b rA=%b rB=%b,valC=%d,valP=%d\n",clk,PC,icode,ifun,rA,rB,valC,valP);

end

endmodule