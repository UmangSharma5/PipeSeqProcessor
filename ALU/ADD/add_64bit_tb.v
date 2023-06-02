//Test Bench
// `include "add_1bit.v"  ****************Before running just uncomment this******************
// `include "add_64bit.v" ****************Before running just uncomment this******************  


module add_64bit_tb;

reg signed [63:0]a;
reg signed [63:0]b;

wire signed [63:0]sum;
wire overflow;

add_64bit DUT(.sum(sum), .overflow(overflow), .a(a) , .b(b));

initial begin
    $dumpfile("add_64bit.vcd");
    $dumpvars(0,add_64bit_tb);
    a = 64'b0;
    b = 64'b0;
end
initial begin
    $monitor("a=%d,b=%d, sum = %d, overflow = %b  \n",a,b,sum,overflow);
    #10
    a=64'b111111111111111111111111111111111111111111111111111111111111111;//Remember that input 
    b=64'b10;
    #10
    a=64'b1;
    b=64'b10;
    #10
    a=64'b11;
    b=64'b100;

    //Here i have added few test cases(some edge case), to check other cases please change the a and b value
end



endmodule


