`include "fetch.v"
`include "decode.v"
`include "execute.v"

module execute_test ;
    reg clk;
    reg [63:0] PC;
    reg [0:79] instr;
    reg [7:0] instr_mem[0:255]; // to store each byte of my instruction
    reg [2:0] CC_in;

    wire [3:0] icode,ifun,rA,rB;
    wire [63:0]valA,valB;
    wire [63:0]valC,valP;
    wire signed [63:0]valE;
    wire memory_error;
    wire instr_valid;
    wire [2:0] CC_out;  

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

    decode decode(.clk(clk),.icode(icode),.rA(rA),.rB(rB),.valA(valA),.valB(valB));

    execute execute(.valE(valE),
                  .cnd(cnd),
                  .CC_out(CC_out),
                  .icode(icode),
                  .ifun(ifun),
                  .valA(valA),
                  .valB(valB),
                  .valC(valC),
                  .CC_in(CC_in),
                  .clk(clk)
                  );

    always @(PC) begin
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

    always @(icode) begin
        if(icode== 0)
        begin  $finish; end
    end

    always @(*) begin
        CC_in = CC_out;
    end 


    initial begin
        clk=1;
        PC=64'd32;
        instr_mem[32]=8'b01100000; // 6 0
        instr_mem[33]=8'b00000011; // 0 3


        #10
        clk=~clk;
        PC=64'd34; // here we are only testing execute hence there is no pc update we have done manually to check test cases
        instr_mem[34]=8'b01000000; // 4 0 rmmovq
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
    end

     initial 
            $monitor("clk=%d PC=%d icode=%b ifun=%b cnd=%d CC_in=%b CC_out=%b rA=%b rB=%b,valA=%d,valB=%d,valE=%d\n",clk,PC,icode,ifun,cnd,CC_in,CC_out,rA,rB,valA,valB,valE);


endmodule