module write_back (clk, icode, rA, rB, valE, valM, reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7, reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14);

input clk;
input [3:0] icode ,rA,rB;
input [63:0] valE,valM;

output reg [63:0] reg_file0;
output reg [63:0] reg_file1;
output reg [63:0] reg_file2;
output reg [63:0] reg_file3;
output reg [63:0] reg_file4;
output reg [63:0] reg_file5;
output reg [63:0] reg_file6;
output reg [63:0] reg_file7;
output reg [63:0] reg_file8;
output reg [63:0] reg_file9;
output reg [63:0] reg_file10;
output reg [63:0] reg_file11;
output reg [63:0] reg_file12;
output reg [63:0] reg_file13;
output reg [63:0] reg_file14;

reg [63:0] memory [0:14];

initial
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
end
always @(*)
begin
    if(icode == 4'b0010) //cmovXX
    begin memory[rB] = valE; end
    if(icode == 4'b0011) //irmovq
    begin memory[rB]=valE; end
    if(icode==4'b0101) // mrrmovq D(rB),rA
    begin memory[rA]=valE; end
    if(icode == 4'b0110) //opq
    begin memory[rB] = valE; end
    if(icode == 4'b1000) //Dest
    begin memory[4'b0100]= valE; end // updating %rsp
    if(icode == 4'b1000) //ret
    begin memory[4'b0100]= valE; end // updating %rsp
    if(icode== 4'hA) //push
    begin memory[4'b0100]=valE; end
    if(icode==4'b1011)
    begin
        memory[4'b0100] =valE;
        memory[rA]=valM;
    end

end


always @(*) begin
    reg_file0 = memory[0];
    reg_file1 = memory[1];
    reg_file2 = memory[2];
    reg_file3 = memory[3];
    reg_file4 = memory[4];
    reg_file5 = memory[5];
    reg_file6 = memory[6];
    reg_file7 = memory[7];
    reg_file8 = memory[8];
    reg_file9 = memory[9];
    reg_file10 =memory[10];
    reg_file11 =memory[11];
    reg_file12 =memory[12];
    reg_file13 =memory[13];
    reg_file14 =memory[14];
end


endmodule
