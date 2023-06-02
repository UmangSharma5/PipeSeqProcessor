// `include "../ADD/add_64bit.v"
// `include "../ADD/add_1bit.v"
// `include "../AND/and_64bit.v"
// `include "../AND/and_1bit.v"
// `include "../SUB/sub_64bit.v"
// `include "../XOR/xor_1bit.v"
// `include "../XOR/xor_64bit.v"

module ALU(out,overflow,a,b,control);
input signed [63:0]a;
input signed [63:0]b;
input [1:0] control; // this acts as 2 bit binary number so that we can choose an operation from (0 t0 3)
output reg signed [63:0]out;
output reg overflow;

wire signed [63:0] out1;
wire overflow1;
wire signed [63:0] out2;
wire overflow2;
wire signed [63:0] out3;
wire signed [63:0] out4;


add_64bit w1(out1,overflow1,a,b);
sub_64bit w2(out2,overflow2,a,b);
and_64bit w3(out3,a,b);
xor_64bit w4(out4,a,b);

always@(*)
	begin
		case(control)
			2'b00:begin //ADD
				out = out1;
				overflow = overflow1;
			end
			2'b01:begin //SUB
			out = out2;
			overflow = overflow2;
			end
			2'b10:begin //AND
			out = out3;
            overflow=0;
			end
			2'b11:begin //XOR	
			out = out4;
            overflow=0;
				
			end
		endcase
	end

   
endmodule


