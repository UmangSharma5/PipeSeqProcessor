// This is an Implementation of Full Adder
//Here we are using the implementation where 2 XOR , 2 AND and 1 OR gate is required to build Full Adder


module add_1bit(sum,carry_out,a,b,carry_in);

output sum,carry_out;
input a,b,carry_in;
wire x,y,z;
xor(sum,a,b,carry_in);
xor(x,a,b);
and(y,a,b);
and(z,x,carry_in);
or(carry_out,y,z);

endmodule