`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "write_back.v"

module execute_test ;
    reg clk;
    reg [63:0] PC;
    reg [0:79] instr;
    reg [7:0] instr_mem[0:255]; // to store each byte of my instruction
    reg [2:0] CC_in;

    wire [3:0] icode,ifun,rA,rB;
    wire [63:0]valA,valB;
    wire [63:0]valC,valP,valM;
    wire signed [63:0]valE;
    wire memory_error;
    wire instr_valid;
    wire [2:0] CC_out;  

    wire [63:0] reg_file0,reg_file1,reg_file2,reg_file3,reg_file4,reg_file5,reg_file6,reg_file7,reg_file8,reg_file9,reg_file10,reg_file11,reg_file12,reg_file13,reg_file14; 

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

    write_back write_back (clk, icode, rA, rB, valE, valM, reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7, reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14);



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
        if(icode== 0 && ifun==0)
        begin  $finish; end
    end

    always @(*) begin
        CC_in = CC_out;
    end 


    initial begin
        clk=1;
        PC=64'd32;
        instr_mem[32]=8'b01100001; //6 1
        instr_mem[33]=8'b00010011; // 1 3


        #10


        clk=~clk;
        PC=64'd34;
        instr_mem[34]=8'b01100000;
        instr_mem[35]=8'b00100011;

    end



    initial
                 $monitor(" r0=%d\n r1=%d\n r2=%d\n r3=%d\n r4=%d\n r5=%d\n r6=%d\n r7=%d\n r8=%d\n r9=%d\n r10=%d\n r11=%d\n r12=%d\n r13=%d\n r14=%d\n valE=%d\n",reg_file0,reg_file1,reg_file2,reg_file3,reg_file4,reg_file5,reg_file6,reg_file7,reg_file8,reg_file9,reg_file10,reg_file11,reg_file12,reg_file13,reg_file14,valE);


endmodule