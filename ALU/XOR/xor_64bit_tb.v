//Test Bench
//`include "xor_1bit.v"  ****************Before running just uncomment this******************
//`include "xor_64bit.v" ****************Before running just uncomment this******************
module xor_64bit_tb;

reg signed [63:0]a;
reg signed [63:0]b;

wire signed [63:0]out;

xor_64bit DUT(.out(out), .a(a) , .b(b));

initial begin
    $dumpfile("xor_64bit.vcd");
    $dumpvars(0,xor_64bit_tb);
    a = 64'b0;
    b = 64'b0;
end
initial begin
    $monitor("a=%d,b=%d, out = %d \n",a,b,out);
    #10
    a=64'b111111111111111111111111111111111111111111111111111111111111111;//Remember that input 
    b=64'b10;
    #10
    a=64'b1;
    b=64'b10;
    #10
    a=64'b11;
    b=64'b111;
end



endmodule


