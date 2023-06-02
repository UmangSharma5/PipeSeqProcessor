`timescale  1ns/1ps
`include "ALU.v"

module alu_tb;

	reg signed [63:0]a;
	reg signed [63:0]b;
	wire signed [63:0]out;
	wire  overflow;
	reg [1:0] control;

	// ALU DUT(.out(out), .overflow(overflow),.a(a), .b(b), .control(control));
    ALU temp(out,overflow,a,b,control);

	
	initial begin
		$dumpfile("alu.vcd");
		$dumpvars(0,alu_tb);

		a=64'b0;
		b=64'b0;
		control = 2'b00;
	end
initial
    begin
        
        $monitor("control = %d a=%d b=%d  out=%d  overflow=%b\n",control,a,b,out,overflow);
        #20 control=2'b00;a=64'b1011;b=64'b0100;
        #20 control=2'b01;a=64'b111111111111111111111111111111111111111111111111111111111111111;//Remember that input is signed
    b=64'b1111111111111111111111111111111111111111111111111111111111111101;
        #20 control=2'b01;a=64'b1011;b=64'b0100;
        #20 control=2'b10;a=64'b1011;b=64'b0100;
        #20 control=2'b11;a=64'b1011;b=64'b0100;
    end
endmodule
