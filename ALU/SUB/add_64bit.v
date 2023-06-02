//Implementation of ADD – 64 bits

module add_64bit(sum,overflow,a,b);

input signed [63:0]a;
input signed [63:0]b;
output signed [63:0]sum;
output overflow; //An overflow flag to check overflow condition

wire [64:0]carry;
assign carry[0]=1'b0; // 1'b0 –> single bit binary 0

genvar count;

generate for(count=0 ;count<64;count=count+1)
begin
    add_1bit w1(sum[count],carry[count+1],a[i],b[i],carry[i]);
end
endgenerate

xor w2(overflow,carry[64],carry[63]);

endmodule