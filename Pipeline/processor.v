`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "pipe_control.v"

module processor;
    reg clk;
    reg [0:3] stat=4'b1000;
    reg [63:0] F_predPC;

    wire [63:0] f_predPC;
    wire [0:3] D_stat,E_stat,M_stat,W_stat,m_stat;
    wire [3:0] D_icode,E_icode,M_icode,W_icode;
    wire [3:0] D_ifun,E_ifun;
    wire [3:0] D_rA,D_rB;
    wire [63:0] D_valC,D_valP;
    wire [3:0] d_srcA,d_srcB;
    wire [63:0] E_valC,E_valA,E_valB,e_valE;
    wire [63:0] M_valE,M_valA,m_valM,M_valP;
    wire [63:0] W_valE,W_valM;
    wire [3:0] E_dstE,E_dstM,E_srcA,E_srcB,e_dstE;
    wire [3:0] M_dstE,M_dstM;
    wire [3:0] W_dstE,W_dstM;
    // wire [63:0] e_valE;

    wire M_cnd;
    wire e_cnd;
    
     wire [63:0] reg_file0,reg_file1,reg_file2,reg_file3,reg_file4,reg_file5,reg_file6,reg_file7,reg_file8,reg_file9,reg_file10,reg_file11,reg_file12,reg_file13,reg_file14; 
     wire F_stall,D_stall,D_bubble,E_bubble,set_cc;


    fetch fetch(D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,f_predPC,M_icode,M_cnd,M_valA,W_icode,W_valM,F_predPC,clk,F_stall,D_stall,D_bubble,M_valP);

    decode decode (clk,D_icode,D_ifun,D_rA,D_rB,D_stat,D_valC,D_valP,E_bubble,W_icode,e_dstE,M_dstE,M_dstM,W_dstE,W_dstM,e_valE,M_valE,m_valM,W_valE,W_valM,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7, reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14,d_srcA,d_srcB);

    execute execute(clk,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,E_stat,W_stat,m_stat,M_stat,set_cc,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,e_dstE,e_valE,e_cnd);

    memory memory (clk,M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_valM,m_stat,M_valP);

    pipe_control pipe_control (m_stat,W_stat,D_icode,E_icode,M_icode,d_srcA,d_srcB,E_dstM,e_cnd,F_stall,D_stall,D_bubble,E_bubble,set_cc);

    always@(W_stat)begin
        stat = W_stat;
    end  

    always@(stat) begin
        if(stat==4'b0001)
        begin
            $display("Instruction error");
            $finish;
        end
        else if (stat== 4'b0010)
        begin
            $display("Memory error");
            $finish;
        end
        else if(stat== 4'b0100)
        begin
            $display("halting");
            $finish;
        end
    end


    always #10 clk = ~clk;

    always @(posedge clk)
    begin
        F_predPC <= f_predPC;
    end

    initial begin 
        F_predPC=64'd213;
        clk=0;
        $monitor("f_predPC=%d F_predPC=%d D_icode=%d,E_icode=%d, M_icode=%d,W_icode=%d ,m_valM=%d, f_stall=%d, ifun=%d,valE=%d, valC=%d, register4=%d,reg2=%d,M_valA=%d,M_cnd=%d,e_cnd=%d,W_valM=%d \n",f_predPC,F_predPC, D_icode,E_icode,M_icode,W_icode,m_valM,F_stall,D_ifun,W_valE,E_valC,reg_file4,reg_file2,M_valA,M_cnd,e_cnd,W_valM);
    end 


endmodule