// Implementation of NOT for 1bit using (brute force)

module not_1bit(NOT,a);

input a;
output NOT;


always @(a) begin

    if(a==1'b0)
        begin
            assign NOT=1'b1;
        end
    else
    begin
        assign NOT=1'b0;
    end
end

endmodule
