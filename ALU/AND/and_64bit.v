`timescale  1ns/1ps

module and_64bit(
	output signed [63:0] out, 
	input signed [63:0]a,
	input signed [63:0]b
	
);

genvar count;

generate for(count = 0; count<64;count=count+1)
begin
	and_1bit w1(out[count],a[count],b[count]);
end
	
endgenerate

endmodule