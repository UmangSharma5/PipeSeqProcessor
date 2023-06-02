`include "../ALU/ALU/ALU.v"
`include "../ALU/ADD/add_64bit.v"
`include "../ALU/ADD/add_1bit.v"
`include "../ALU/AND/and_64bit.v"
`include "../ALU/AND/and_1bit.v"
`include "../ALU/SUB/sub_64bit.v"
`include "../ALU/XOR/xor_1bit.v"
`include "../ALU/XOR/xor_64bit.v"
module execute(clk,icode,ifun,valC,valA,valB,CC_in,CC_out,cnd,valE);

input clk;
input [3:0] icode,ifun;
input [63:0] valC,valA,valB;
input [2:0] CC_in; // 3 conditional code
output reg cnd;
output reg signed [63:0] valE;
output reg [2:0] CC_out; // Changed values of CC

wire ZF,SF,OF;
assign ZF=CC_in[0];
assign SF=CC_in[1];
assign OF=CC_in[2];

// My 5 input parameters for ALU

reg [1:0] control; // this acts as 2 bit binary number so that we can choose an operation from (0 t0 3)
reg signed [63:0] a;
reg signed [63:0] b;
wire signed [63:0] out;
wire overflow;


always @(*)
begin
    if(icode==2 |icode ==7)
    begin
    case (ifun)
        4'h0: cnd = 1;              // unconditional
        4'h1: cnd = (OF^SF)|ZF;     // le
        4'h2: cnd = OF^SF;           // l
        4'h3: cnd = ZF;             // e
        4'h4: cnd = ~ZF;            // ne
        4'h5: cnd = ~(SF^OF);        // ge
        4'h6: cnd = ~(SF^OF)&~ZF;   // g
    endcase
    end
end

ALU alu(out,overflow,b,a,control);

always @(*)
begin
      
      if(icode == 4'b0011) //irmovq
      begin
           a=1'b0;
           b=valC;
           control=2'b00;
      end
      if(icode==4'b0100) //rmmovq
      begin
            a=valC;
            b=valB;
            control=2'b00;
      end
      if(icode == 4'b0101) //mrmovq
      begin
           a=valC;
           b=valB;
           control=2'b00; 

      end
    
    if(icode == 4'b0110) //opq
    begin
        a=valA;
        b=valB;
        case(ifun)
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
    if(icode==4'b1000) //call
    begin
        a=valB;
        b=64'd8;
        control=2'b01;
    end
    if(icode==4'b1001)//ret
    begin
        a=64'd8;
        b=valB;
        control=2'b00;
    end
    if(icode==4'hA)//pushq
    begin
        a=valB;
        b=64'd8;
        control=2'b01;
    end
    if(icode==4'hB)//popq
    begin
        a=64'd8;
        b=valB;
        control=2'b00;
    end
    if(icode == 4'b0010) // cmovxx
    begin
        a=valA;
        b=64'd0;
        control=2'b00;
    end

    // ALU alu(out,overflow,a,b,control);
    valE=out;
    CC_out[0] = valE ? 0:1; // Check value of valE
    CC_out[1] = valE[63]; // The MSB bit
    CC_out[2]= overflow; // This comes from the output of ALU

end


endmodule
