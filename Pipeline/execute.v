`include "../ALU/ALU/ALU.v"
`include "../ALU/ADD/add_64bit.v"
`include "../ALU/ADD/add_1bit.v"
`include "../ALU/AND/and_64bit.v"
`include "../ALU/AND/and_1bit.v"
`include "../ALU/SUB/sub_64bit.v"
`include "../ALU/XOR/xor_1bit.v"
`include "../ALU/XOR/xor_64bit.v"

module execute(clk,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,E_stat,W_stat,m_stat,M_stat,set_cc,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,e_dstE,e_valE,e_cnd);   

input clk;
input [3:0] E_icode,E_ifun;
input [63:0] E_valA,E_valB,E_valC;
input [3:0] E_dstE,E_dstM;
input [3:0] E_srcA,E_srcB;
input [0:3] E_stat;  // Status coming from execute pipeline register

input set_cc;
input [0:3] W_stat; // this is an input taken from above stages to determine whether or not to update the conditions codes
input [0:3] m_stat; // similarly this is also an input taken from above stages to determine whether or not to update the condition codes


output reg [0:3] M_stat;
output reg [3:0] M_icode;
output reg M_cnd;
output reg [63:0] M_valE,M_valA;
output reg [3:0] M_dstE,M_dstM;


output reg [3:0] e_dstE; // This is directed to decode stage (used in forwarding)
output reg [63:0] e_valE; // similarly used in forwarding 
output reg e_cnd;

reg [2:0] CC =3'b000;

reg ZF,SF,OF;
// assign ZF=CC[0];
// assign SF=CC[1];
// assign OF=CC[2];

// My 5 input parameters for ALU

reg [1:0] control; // this acts as 2 bit binary number so that we can choose an operation from (0 t0 3)
reg signed [63:0] a;
reg signed [63:0] b;
wire signed [63:0] out;
wire overflow;


always @(*)
begin
    if(E_icode==2 |E_icode ==7)
    begin
    case (E_ifun)
        4'h0: e_cnd = 1;              // unconditional
        4'h1: e_cnd = (OF^SF)|ZF;     // le
        4'h2: e_cnd = OF^SF;           // l
        4'h3: e_cnd = ZF;             // e
        4'h4: e_cnd = ~ZF;            // ne
        4'h5: e_cnd = ~(SF^OF);        // ge
        4'h6: e_cnd = ~(SF^OF)&~ZF;   // g
        default:
            e_cnd=0;
    endcase
    // $display("e_cnd=%d,zf=%d",e_cnd, ZF);
    e_dstE = e_cnd ? E_dstE : 4'hF;
    end
    else
    begin
        e_dstE=E_dstE;
    end
end

ALU alu(out,overflow,b,a,control);

initial begin
    e_cnd=0;
    ZF=CC[0];
    SF=CC[1];
    OF=CC[2];
end

always @(*)
begin
      
      if(E_icode == 4'b0011) //irmovq
      begin
           a=1'b0;
           b=E_valC;
           control=2'b00;
      end
      else if(E_icode==4'b0100) //rmmovq
      begin
            a=E_valC;
            b=E_valB;
            control=2'b00;
      end
      else if(E_icode == 4'b0101) //mrmovq
      begin
           a=E_valC;
           b=E_valB;
           control=2'b00; 

      end
    
    else if(E_icode == 4'b0110) //opq
    begin
        a=E_valA;
        b=E_valB;
        case(E_ifun)
            2'b00:
            begin
                control=2'b00;
            end
            2'b01:
            begin
                control=2'b01;
            end
            2'b10:
            begin
                control=2'b10;
            end
            2'b11:
            begin
                control=2'b11;
            end
        endcase
    end
    else if(E_icode==4'b1000) //call
    begin
        b=E_valB;
        a=64'd8;
        control=2'b01;
        // $display("b=%d\n",b);
    end
    else if(E_icode==4'b1001)//ret
    begin
        a=64'd8;
        b=E_valB;
        control=2'b00;
    end
    else if(E_icode==4'hA)//pushq
    begin
        b=E_valB;
        a=64'd8;
        control=2'b01;
    end
    else if(E_icode==4'hB)//popq
    begin
        a=64'd8;
        b=E_valB;
        control=2'b00;
    end
    else if(E_icode == 4'b0010) // cmovxx
    begin
        a=E_valA;
        b=64'd0;
        control=2'b00;
    end
    else
    begin
        a=64'd0;
        b=64'd0;
        control=2'b00;
    end 
    // $display("out=%d\n",out);
    e_valE=out;

        CC[0] = e_valE ? 0:1; // Check value of valE
        CC[1] = e_valE[63]; // The MSB bit
        CC[2]= overflow; // This comes from the output of ALU


end

always @(posedge clk)
begin
    begin
        M_stat <= E_stat;
        M_icode <= E_icode;
        M_cnd <= e_cnd;
        M_valE <= e_valE;
        M_valA <= E_valA;
        M_dstE <= e_dstE;
        M_dstM <= E_dstM;
    end
end




endmodule
