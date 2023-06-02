//brute force implementation of AND gate 

module and_1bit(out,a,b);

input a ,b ;
output reg out;

always @(a or b ) 
begin
	
	if (a == 1'b1) 
	begin
		if(b == 1'b1)
			out = 1'b1;

		else
			out = 1'b0;
	end
	else
		out = 1'b0;
end

endmodule