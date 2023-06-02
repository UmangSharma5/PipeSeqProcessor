module decode (clk, icode, rA, rB, valA, valB);

input clk;
input [3:0] icode;
input [3:0] rA;
input [3:0] rB;

output reg [63:0] valA;
output reg [63:0] valB;

reg [63:0]memory [0:14];

always @(*)
begin
    memory[0] = 64'd0;
    memory[1] = 64'd1;
    memory[2] = 64'd2;
    memory[3] = 64'd3;
    memory[4] = 64'd4;
    memory[5] = 64'd5;
    memory[6] = 64'd6;
    memory[7] = 64'd7;
    memory[8] = 64'd8;
    memory[9] = 64'd9;
    memory[10] =64'd10;
    memory[11] =64'd11;
    memory[12] =64'd12;
    memory[13] =64'd13;
    memory[14] =64'd14;   

    // For nop and halt conditions there are no registers involved

    if(icode==4'b0010) //cmovxx
    begin
        valA=memory[rA];
    end
    if(icode==4'b0100) //rmmovq
    begin
        valA=memory[rA];
        valB=memory[rB];
    end
    if(icode==4'b0101) //mrmovq
    begin
        valB=memory[rB];
    end
    if(icode==4'b0110)  //opq
    begin
        valA=memory[rA];
        valB=memory[rB];
    end
    if(icode==4'b1000) //call
    begin
        // As we have to push address o fnext instruction onto stack
        valB=memory[4];
    end
    if(icode==4'b1001) //ret
    begin
        valA=memory[4];
        valB=memory[4];
    end
    if(icode==4'b1010) //pushq
    begin
        valA = memory[rA];
        valB = memory[4];
    end
    if(icode==4'b1011) //popq
    begin
        valA=memory[4];
        valB=memory[4];
    end


end


endmodule
