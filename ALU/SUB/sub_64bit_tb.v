//Test Bench
// `include "sub_64bit.v" ****************Before running just uncomment this******************

module sub_64bit_tb;

reg signed [63:0]a;
reg signed [63:0]b;

wire signed [63:0]out;
wire overflow;

sub_64bit DUT(.out(out),.overflow(overflow), .a(a) , .b(b));

initial begin
    $dumpfile("sub_64bit.vcd");
    $dumpvars(0,sub_64bit_tb);
    a = 64'b0;
    b = 64'b0;
end
initial begin
    $monitor("a=%d,b=%d, out = %d, overflow = %b  \n",a,b,out,overflow);
    #10
    a=64'b111111111111111111111111111111111111111111111111111111111111111;//Remember that input is signed
    b=64'b1111111111111111111111111111111111111111111111111111111111111101;//Rember that input is signed
    #10
    a=64'b1;
    b=64'b10;
    #10
    a=64'b111;
    b=64'b100;
end



endmodule


