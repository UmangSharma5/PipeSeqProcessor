
module not_64bit(out,a);

input signed [63:0]a;
output signed [63:0]out;

genvar count;

generate for(count = 0; count < 64; count = count + 1)
begin
    not_1bit w(out[i],a[i]);
end

endgenerate

endmodule