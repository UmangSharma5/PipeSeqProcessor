module pc_update(cnd,clk,icode,PC,valM,valC,valP);

input clk;
input [63:0] valC,valM,valP;
input [3:0] icode;
input cnd;
output reg [63:0] PC;     

always@(*)
begin
case(icode)
4'b0111:     //jXX
begin
    if(cnd) // if the condition is true then the jump happens
        PC=valC;
    
    else
        PC=valP;
    
end

4'b1001:      //ret
begin
    PC=valM;
end

4'b1000:   //call
begin
    PC=valC;
end

default:
begin
    PC=valP;
end

endcase

end
endmodule