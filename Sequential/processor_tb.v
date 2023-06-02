`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "write_back.v"
`include "pc_update.v"
`include "processor.v"

module pro_test ;
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
    wire [63:0] valM;
    wire [63:0]PC_next; //updated value of PC

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

    memory_seq memory_seq(clk, icode, valA, valB, valP, valE, valM);

    write_back write_back (clk, icode, rA, rB, valE, valM, reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7, reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14);

    pc_update pc_update(.PC(PC_next),
                    .cnd(cnd),
                    .clk(clk),
                    .icode(icode),
                    .valM(valM),
                    .valC(valC),
                    .valP(valP));

    processor processor (clk,memory_error,instr_valid,halt,icode);

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

    always @(*) begin  // So here we are carry forwarding our values
        CC_in = CC_out;
    end 

    always @(clk)
    begin
        PC=PC_next;
    end

    initial begin
        $dumpfile("pro_test.vcd");
        $dumpvars(0,pro_test);
        // PC=64'd1;
        // clk=~clk;
        // instr_mem[1]=8'b01100000; // 6 0 addq
        // instr_mem[2]=8'b00010011; //1 3
        // #10 clk=1;
        // instr_mem[3]=8'b01100001; // 6 1 subq
        // instr_mem[4]=8'b00010011; //1 3
        // #10 clk=~clk;
        // instr_mem[5]=8'b10000000; //8 0 call
        // instr_mem[6]=8'b00000000;
        // instr_mem[7]=8'd0;
        // instr_mem[8]=8'd0;
        // instr_mem[9]=8'd0;
        // instr_mem[10]=8'd0;
        // instr_mem[11]=8'd0;
        // instr_mem[12]=8'd0;
        // instr_mem[13]=8'd18;
        // #10 clk=~clk;
        // instr_mem[14]=8'b01100000;
        // // // #10 clk=~clk;
        // instr_mem[15]=8'b01100011;
        // instr_mem[16]=8'b00010010;
        // instr_mem[17]=8'b01100011;
        // instr_mem[18]=8'b00010010;

        // instr_mem[15]=8'd0;
        // instr_mem[16]=8'd0;
        // instr_mem[17]=;
        // instr_mem[18]=;
        // instr_mem[19]=;
        // instr_mem[20]=;
    

        // instr_mem[32]=8'b01110000; //6 fn
        // // instr_mem[33]=8'b00000000; //rA rB
        // instr_mem[33]=8'd0;
        // instr_mem[34]=8'd0;
        // instr_mem[35]=8'd0;
        // instr_mem[36]=8'd0;
        // instr_mem[37]=8'd0;
        // instr_mem[38]=8'd0;
        // instr_mem[39]=8'd0;
        // instr_mem[40]=8'd46;

        // #10 clk=1;
        // instr_mem[41]=8'b00000000;
        // instr_mem[35]=8'b00111111;
        // #10 clk=~clk;
        // instr_mem[36]=8'b00010000; // 1 0 
        // #10 clk=~clk;
        // instr_mem[37]=8'b00010000;  // 1 0
        // #10 clk=~clk;
        // instr_mem[38]=8'b00000001;  //9  1
        // #10 clk=~clk;
        // instr_mem[39]=8'b01000000; // 4 0  
        // instr_mem[40]=8'b00000001; // 0 1
        // instr_mem[41]=8'b00000100;
        // instr_mem[42]=8'b00000101;
        // instr_mem[43]=8'b00000110;
        // instr_mem[44]=8'b00000111;
        // instr_mem[45]=8'b00001000;
        // instr_mem[46]=8'b00001001;
        // instr_mem[47]=8'b00001011;
        // instr_mem[48]=8'b00011001;
        // instr_mem[49]=8'b00001000;
        // instr_mem[50]=8'b00000011;


        //irmovq $10,%rdx
        instr_mem[128]=8'b00110000; //3 0
        instr_mem[129]=8'b11110010; //F rB=2
        instr_mem[130]=8'b00000000;           
        instr_mem[131]=8'b00000000;           
        instr_mem[132]=8'b00000000;           
        instr_mem[133]=8'b00000000;          
        instr_mem[134]=8'b00000000;          
        instr_mem[135]=8'b00000000;          
        instr_mem[136]=8'b00000000;
        instr_mem[137]=8'b00001010; //V=10

        // irmovq  $3,%rax
        instr_mem[138]=8'b00110000; //3 0
        instr_mem[139]=8'b11110000; //F rB=0
        instr_mem[140]=8'b00000000;           
        instr_mem[141]=8'b00000000;           
        instr_mem[142]=8'b00000000;           
        instr_mem[143]=8'b00000000;          
        instr_mem[144]=8'b00000000;          
        instr_mem[145]=8'b00000000;          
        instr_mem[146]=8'b00000000;
        instr_mem[147]=8'b00000011; //V=3

        // addq %rdx,%rax
        instr_mem[148]=8'b01100000; //6 0```
        instr_mem[149]=8'b00100000; //rA=2 rB=0


    end

    initial 
           $monitor("clk=%d PC=%d icode=%b ifun=%b cnd=%d CC_in=%b CC_out=%b rA=%b rB=%b,valA=%d,valB=%d,valP=%d,valE=%d,PC_next=%d\n",clk,PC,icode,ifun,cnd,CC_in,CC_out,rA,rB,valA,valB,valP,valE,PC_next);  





endmodule



