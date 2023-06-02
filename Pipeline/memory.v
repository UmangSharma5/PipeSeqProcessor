module memory (clk,M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_valM,m_stat,M_valP);

input clk;
input [0:3] M_stat;
input [3:0] M_icode;
input M_cnd;
input [63:0] M_valE,M_valA;
input [3:0] M_dstE,M_dstM;
input [63:0] M_valP;

output reg [0:3] W_stat;
output reg [3:0] W_icode;
output reg [63:0] W_valE,W_valM;
output reg [3:0] W_dstE,W_dstM;
output reg [63:0] m_valM;
output reg [0:3] m_stat;

reg [63:0] memory [0:255];
reg memory_error = 0; //This is just a flag to ensure that we are accessing the correct memory 
reg check_valE,check_valA;

initial begin
    memory[4]=1;
end

always @*
begin
    if(memory_error)
        m_stat = 4'b0010;
    else
        m_stat = M_stat;
end

always @(*)
begin
    // $display("memory=%d",memory[4]);
    if(M_icode==4'b0100 | M_icode==4'b0101 | M_icode== 4'b1000 | M_icode==4'hB) // These are the values of icode where value of valE determines the location in memory
        begin check_valE=1; end
    else
        begin check_valE=0; end

    if(M_icode == 4'b1001 | M_icode == 4'hA)
        begin check_valA=1; end
    else
        begin check_valA=0; end
end


always @(*)
begin

    if((M_valE>255 & check_valE)| (M_valA > 255 & check_valA))
        begin memory_error=1 ;end
    if(M_icode == 4'b0101) //mrmovq
    begin
        m_valM=memory[M_valE];
    end
    if(M_icode == 4'b1001) //ret
    begin
        m_valM=memory[M_valA];
    end
    if( M_icode== 4'hB) //popq
    begin
        m_valM=memory[M_valA];
    end

end


always @(posedge clk)
begin
    // we are checking only valE because we are accessing memory with the value of valE in the following cases->
    if(M_valE>255 & check_valE) 
        memory_error=1;
    if(M_icode == 4'b0100) //rmmovq
    begin
        memory[M_valE] <= M_valA;
    end
    if(M_icode == 4'b1000) //call
    begin
        memory[M_valE] <= M_valA;
        m_valM=M_valP;
    end
    if(M_icode == 4'hA) // pushq
    begin
        memory[M_valE] <= M_valA;
    end
end

// updating the writeback pipeline register
always @(posedge clk)
begin
    W_stat <= m_stat;
    W_icode <= M_icode;
    W_valE <= M_valE;
    W_valM <= m_valM;
    W_dstE <= M_dstE;
    W_dstM <= M_dstM;
end


endmodule