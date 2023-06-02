// `include "../ADD/add_64bit.v" ****************Before running just uncomment this******************   
// `include "../ADD/add_1bit.v" ****************Before running just uncomment this******************


module sub_64bit(out,overflow,a,b);

input signed [63:0]a;
input signed [63:0]b;
output signed [63:0]out;
output overflow;

//Finding the 1's complement of b
wire [63:0] NOT;
genvar i;
generate
    for(i=0;i<64;i=i+1)begin
        not(NOT[i],b[i]);
    end
endgenerate

//Adding 1 to the 1's complement of b
wire [63:0]one =64'b1;
wire [63:0]addone;
wire temp;
add_64bit w2(addone,temp,one,NOT);

//Finally adding a to 2's complement of b
add_64bit w3(out,overflow,a,addone);

endmodule