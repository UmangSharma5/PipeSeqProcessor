module processor (clk,memory_error,instr_valid,halt,icode);

input clk;
input memory_error,instr_valid,halt;
input [3:0]icode;

always @(*)
begin
    if(memory_error==1)
    begin
        $display("Memory Error\n");
        $finish();
    end
    if(instr_valid==0)
    begin
        $display("Invalid Instruction\n");
        $finish();
    end
end

always @(icode)
begin
    if(icode==0)
    begin
        $display("halting\n");
        $finish();
    end
end


endmodule