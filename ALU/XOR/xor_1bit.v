// brute force implementation of xor

module xor_1bit(out,a,b);

input a ,b ;
output reg out;

always @(a or b ) 
begin
	
    out=1'b0;
	
	if (a == 1'b1) 
	begin
		if(b == 1'b0)
			out = 1'b1;

		else
			out = 1'b0;
	end
	if (b == 1'b1) 
	begin
		if(a == 1'b0)
			out = 1'b1;

		else
			out = 1'b0;
	end

end

endmodule