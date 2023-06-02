module fetch (clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,instr,PC);

input clk; //This is the input clock
input [63:0] PC; //This is the program counter where 63rd bit is MSB
input [0:79] instr; //This is the current instruction (10bytes)
output reg [3:0] icode,ifun; // 4bit each (instruction)
// icode-> Instruction Code   ifun->Instruction Function 
output reg [3:0] rA,rB;// 4 bit each (Register/Memory address)
output reg [63:0] valC; // 8 byte constant (immediate)
output reg [63:0] valP;// New(incremented) PC
output reg memory_error=0, instr_valid=1;

// memory_error -> To check if PC value is correct address or not
//instr_valid  -> To check if our instruction is between 0 to 11 

always @(*)
begin

    if(PC>255) // 255 is just a random number for memory instruction
    begin
        memory_error=1;
    end

    icode=instr[0:3];
    ifun=instr[4:7];

    //We can use the case implementation or if-else
    //In case the default : can set instr_valid to 0

    case(icode)

    4'b0000: //halt
    begin
        valP=PC+1;
    end

    4'b0001: //nop
    begin 
        valP=PC+1;
    end

    4'b0010: //cmovq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
    end

    4'b0011: //irmovq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valC=instr[16:79];
        valP=PC+10;
    end

    4'b0100: //rmmovq
    begin
        rA=instr[8:11]; 
        rB=instr[12:15];
        valC=instr[16:79];
        valP=PC+10;
    end

    4'b0101: //mrmovq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valC=instr[16:79];
        valP=PC+10;
    end

    4'b0110: //Opq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
    end

    4'b0111: //jxx
    begin
        valC=instr[8:71];
        valP=PC+9;
    end

    4'b1000: //call
    begin
        valC=instr[8:71];
        valP=PC+9;
    end

    4'b1001: //ret
    begin
        valP=PC+1;
    end

    4'hA: //pushq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
    end

    4'hB: //popq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
    end

    default:
        instr_valid=1'b0;

    endcase
end



endmodule