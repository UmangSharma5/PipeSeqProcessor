module memory_seq(clk, icode, valA, valB, valP, valE, valM);

input clk;
input wire [3:0] icode;
input wire [63:0] valA, valB, valP, valE;

output reg [63:0] valM;
reg [63:0] memory [0:255];
output reg memory_error = 0; //This is just a flag to ensure that we are accessing the correct memory 
reg check_valE,check_valA;


always @(*)
begin
    if(icode==4'b0100 | icode==4'b0101 | icode== 4'b1000 | icode==4'hB) // These are the values of icode where value of valE determines the location in memory
        begin check_valE=1; end
    else
        begin check_valE=0; end

    if(icode == 4'b1001 | icode == 4'hA)
        begin check_valA=1; end
    else
        begin check_valA=0; end
end


always @(*)
begin

    if((valE>255 & check_valE)| (valA > 255 & check_valA))
        begin memory_error=1 ;end
    if(icode == 4'b0101) //mrmovq
    begin
        valM=memory[valE];
    end
    if(icode == 4'b1001) //ret
    begin
        valM=memory[valA];
    end
    if( icode== 4'hB) //popq
    begin
        valM=memory[valA];
    end

end


always @(posedge clk)
begin
    // we are checking only valE because we are accessing memory with the value of valE in the following cases->
    if(valE>255 & check_valE) 
        memory_error=1;
    if(icode == 4'b0100) //rmmovq
    begin
        memory[valE] <= valA;
    end
    if(icode == 4'b1000) //call
    begin
        memory[valE] <= valP;
    end
    if(icode == 4'hA) // pushq
    begin
        memory[valE] <= valA;
    end
end


endmodule