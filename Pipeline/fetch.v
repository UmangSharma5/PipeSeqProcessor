// the difference with pipeline registers is that the data would be stored in a pipeline register instead of being immediately passed to the next stage of the pipeline.

// When an instruction is fetched in the fetch stage, it is passed to the pipeline register that connects the fetch stage to the decode stage. The pipeline register acts as a temporary storage location for the instruction data while the decode stage is performing its tasks. Once the decode stage is ready for the instruction data, it will retrieve it from the pipeline register.

// With pipeline registers, the fetch stage can continue to fetch instructions from memory and store them in the instruction register while the decode stage is processing the previous instruction. This allows for overlap of the fetch and decode stages, which can improve performance by reducing the amount of time the processor spends waiting for instructions to be fetched.


module fetch(D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,f_predPC,M_icode,M_cnd,M_valA,W_icode,W_valM,F_predPC,clk,F_stall,D_stall,D_bubble,M_valP);

input clk;
input M_cnd;
input [3:0] M_icode,W_icode;
input [63:0] M_valA,W_valM;
input [63:0] F_predPC; // This is the predicted value of PC coming from previous instruction
input F_stall;  // in stall case we keep our PC value fixed
input D_stall; // Conditions for load/use hazard
input D_bubble; // Conditions for Mispredicted branch

// D pipeline register
output reg [3:0] D_icode,D_ifun;
output reg [3:0] D_rA,D_rB;
output reg [63:0] D_valC,D_valP;
output reg [0:3] D_stat =4'b1000; // AOK,HLT,ADR,INS
output reg [63:0] M_valP;
// 1st bit(MSB) -> All ok (AOK) , 2nd bit->halt , 3rd bit->memory error 4th bit(LSB)-> instruction invalid
output reg [63:0] f_predPC;  // we predict next PC

reg [3:0] icode,ifun;
reg [3:0] rA,rB;
reg [63:0] valC,valP;
reg memory_error=0, instr_valid=1; 
// memory_error -> To check if PC value is correct address or not
//instr_valid  -> To check if our instruction is between 0 to 11 
reg [0:3] stat;
reg [0:79] instr;
reg [7:0] instr_mem[0:255];
reg [63:0] PC;
// initial 
//     PC = F_predPC;


always @(*) begin
    if(W_icode==4'h9) // ret 
        PC = W_valM;
    else if(M_icode==4'h7) // jxx
    begin
        if(!M_cnd) // jump not taken
            // $display("hello\n");
            PC= M_valA; // M_valA not always store R[rA] it stores valP for 
            // f_predPC=PC;
            //not jump,call  (Select A hardware)
    end
    else // default
        PC = F_predPC;
end

always @(*)
begin

    instr_valid=1;
    if(PC>256)
    begin
        memory_error=1;
    end
    instr={
      instr_mem[PC],
      instr_mem[PC+1],
      instr_mem[PC+2],
      instr_mem[PC+3],
      instr_mem[PC+4],
      instr_mem[PC+5],
      instr_mem[PC+6],
      instr_mem[PC+7],
      instr_mem[PC+8],
      instr_mem[PC+9]
    };
    // $display("")
    // if(PC==8'd212) 
    // begin $display("PC IS 212\n");
    // end
    icode=instr[0:3];
    ifun=instr[4:7];

    case(icode)

    4'b0000: //halt
    begin
        valP=PC;
        f_predPC=valP;
    end

    4'b0001: //nop
    begin 
        valP=PC+1;
        f_predPC=valP;
        // $display("f_pred=%d \n",f_predPC);
    end

    4'b0010: //cmovq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
        f_predPC=valP;
    end

    4'b0011: //irmovq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valC=instr[16:79];
        valP=PC+10;
        f_predPC=valP;
    end

    4'b0100: //rmmovq
    begin
        rA=instr[8:11]; 
        rB=instr[12:15];
        valC=instr[16:79];
        valP=PC+10;
        f_predPC=valP;
    end

    4'b0101: //mrmovq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valC=instr[16:79];
        valP=PC+10;
        f_predPC=valP;
    end

    4'b0110: //Opq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
        f_predPC=valP;
    end

    4'b0111: //jxx
    begin
        valC=instr[8:71];
        valP=PC+9;
        f_predPC=valC; // In pipeline we assume initailly jump is taken
    end

    4'b1000: //call
    begin
        valC=instr[8:71];
        valP=PC+9;
        f_predPC=valC;
        M_valP=valP;
    end

    4'b1001: //ret
    begin
        valP=PC+1;
        f_predPC=valP;
        // In case of ret we cannot predict we have to wait for memory stage
    end

    4'hA: //pushq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
        f_predPC=valP;
    end

    4'hB: //popq
    begin
        rA=instr[8:11];
        rB=instr[12:15];
        valP=PC+2;
        f_predPC=valP;
    end

    default:
        instr_valid=1'b0;
    endcase

    if(instr_valid==1'b0) // If the instruction is invalid
        stat = 4'b0001;
    else if(memory_error==1) // for memory address
    begin
        stat = 4'b0010;
    end
    else if(icode==4'b0000) // for halting
        stat = 4'b0100;
    else            // ALL OK (MSB is 1 and rest are 0)
        stat = 4'b1000; 

end


// Now we store this information in the decode pipeline register 

always @(posedge clk)
begin
    if(F_stall)
    begin
        PC = F_predPC; // we keep our PC value same as previous
    end
    else if(D_bubble) // In this case we just execute of nop 
    begin
        // $display("In D_bubble\n");
        D_icode <= 4'b0001;
        D_ifun <= 4'b0000;
        D_rA <= 4'b0000;
        D_rB <= 4'b0000;
        D_valC <= 64'b0;
        D_valP <= 64'b0;
        D_stat <= 4'b1000; // ALL OK status
    end
    else
    begin
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA;
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_stat <= stat;
    end
end

initial begin

    instr_mem[0]=8'h80; // 8 0 call 
    instr_mem[1]=8'h0; 
    instr_mem[2]=8'h0;
    instr_mem[3]=8'h0;
    instr_mem[4]=8'h0;
    instr_mem[5]=8'h0;
    instr_mem[6]=8'h0;
    instr_mem[7]=8'h0;
    instr_mem[8]=8'h09;
    instr_mem[9]=8'h10;
    instr_mem[10]=8'h00;
    instr_mem[11]=8'h10;
    instr_mem[12]=8'h00;

    // instr_mem[13]=8'h30; // 3 0 irmovq    
    // instr_mem[14]=8'hF2; // F rB=2
    // instr_mem[15]=8'h0;
    // instr_mem[16]=8'h0;
    // instr_mem[17]=8'h0;
    // instr_mem[18]=8'h0;
    // instr_mem[19]=8'h0;
    // instr_mem[20]=8'h0;
    // instr_mem[21]=8'h0;
    // instr_mem[22]=8'h25;
    // instr_mem[23]=8'h00;
    // instr_mem[24]=8'h10;


    // call ret example
    // instr_mem[60] = 8'h80; //call
    // {instr_mem[61],instr_mem[62],instr_mem[63],instr_mem[64],instr_mem[65],instr_mem[66],instr_mem[67],instr_mem[68]} = 64'd70;

    // instr_mem[69] = 8'h00;

    // instr_mem[70] = 8'h10;
    // instr_mem[71] = 8'h10;


    // instr_mem[72] = 8'h90;

    //opq
    // instr_mem[25]=8'h60;
    // instr_mem[26]=8'h23;
    // instr_mem[27]=8'h00;

    // push pop
    instr_mem[28]=8'hA0;
    instr_mem[29]=8'h2F;
    instr_mem[30]=8'hB0;
    instr_mem[31]=8'h2F;
    instr_mem[32]=8'h10;
    instr_mem[33]=8'h10;

    // text book example
    // instr_mem[32]=8'h30;    
    // instr_mem[33]=8'hF3;
    // instr_mem[34]=8'h0;
    // instr_mem[35]=8'h0;
    // instr_mem[36]=8'h0;
    // instr_mem[37]=8'h0;
    // instr_mem[38]=8'h0;
    // instr_mem[39]=8'h0;
    // instr_mem[40]=8'h0;
    // instr_mem[41]=8'h0A;
    // instr_mem[42]=8'h30;
    // instr_mem[43]=8'hF2;
    // instr_mem[44]=8'h0;
    // instr_mem[45]=8'h0;
    // instr_mem[46]=8'h0;
    // instr_mem[47]=8'h0;
    // instr_mem[48]=8'h0;
    // instr_mem[49]=8'h0;
    // instr_mem[50]=8'h0;
    // instr_mem[51]=8'hB;
    // instr_mem[52]=8'h10;
    // instr_mem[53]=8'h10;
    // instr_mem[54]=8'h10;
    // instr_mem[55]=8'h60;
    // instr_mem[56]=8'h23;
    // instr_mem[57]=8'h00;
    // instr_mem

    //..............DATA forwarding ............................
    // irmovq $10,%rdx
    instr_mem[128]=8'b00110000; //3 0
    instr_mem[129]=8'b11110010; //F rB=2
    instr_mem[130]=8'b00000000;           
    instr_mem[131]=8'b00000000;           
    instr_mem[132]=8'b00000000;           
    instr_mem[133]=8'b00000000;          
    instr_mem[134]=8'b00000000;          
    instr_mem[135]=8'b00000000;          
    instr_mem[136]=8'b00000000;
    instr_mem[137]=8'b00001010; //V=10

    // irmovq  $3,%rax
    instr_mem[138]=8'b00110000; //3 0
    instr_mem[139]=8'b11110000; //F rB=0
    instr_mem[140]=8'b00000000;           
    instr_mem[141]=8'b00000000;           
    instr_mem[142]=8'b00000000;           
    instr_mem[143]=8'b00000000;          
    instr_mem[144]=8'b00000000;          
    instr_mem[145]=8'b00000000;          
    instr_mem[146]=8'b00000000;
    instr_mem[147]=8'b00000011; //V=3

    // addq %rdx,%rax
    instr_mem[148]=8'b01100000; //6 0```
    instr_mem[149]=8'b00100000; //rA=2 rB=0
    instr_mem[150]=8'h10;
    instr_mem[151]=8'h10;
    instr_mem[152]=8'h10;
    instr_mem[153]=8'h10;
    

    //

    // instr_mem[150]=8'b00110000; 
    // instr_mem[151]=8'b11110010; 
    // instr_mem[152]=8'b00000000;           
    // instr_mem[153]=8'b00000000;           
    // instr_mem[154]=8'b00000000;           
    // instr_mem[155]=8'b00000000;          
    // instr_mem[156]=8'b00000000;          
    // instr_mem[157]=8'b00000000;          
    // instr_mem[158]=8'b00000000;
    // instr_mem[159]=8'b10000000; 

    // instr_mem[160]=8'b00110000; 
    // instr_mem[161]=8'b11110001; 
    // instr_mem[162]=8'b00000000;           
    // instr_mem[163]=8'b00000000;           
    // instr_mem[164]=8'b00000000;           
    // instr_mem[165]=8'b00000000;          
    // instr_mem[166]=8'b00000000;          
    // instr_mem[167]=8'b00000000;          
    // instr_mem[168]=8'b00000000;
    // instr_mem[169]=8'b00000011; 

    // instr_mem[170]=8'b01000000; 
    // instr_mem[171]=8'b00010010; 
    // instr_mem[172]=8'b00000000; 
    // instr_mem[173]=8'b00000000; 
    // instr_mem[174]=8'b00000000; 
    // instr_mem[175]=8'b00000000; 
    // instr_mem[176]=8'b00000000; 
    // instr_mem[177]=8'b00000000; 
    // instr_mem[178]=8'b00000000; 
    // instr_mem[179]=8'b00000000; 

    // instr_mem[180]=8'b00110000; 
    // instr_mem[181]=8'b11110011; 
    // instr_mem[182]=8'b00000000;           
    // instr_mem[183]=8'b00000000;           
    // instr_mem[184]=8'b00000000;           
    // instr_mem[185]=8'b00000000;          
    // instr_mem[186]=8'b00000000;          
    // instr_mem[187]=8'b00000000;          
    // instr_mem[188]=8'b00000000;
    // instr_mem[189]=8'b00001010; 

    // instr_mem[190]=8'b01010000; 
    // instr_mem[191]=8'b00100000; 
    // instr_mem[192]=8'b00000000; 
    // instr_mem[193]=8'b00000000;
    // instr_mem[194]=8'b00000000; 
    // instr_mem[195]=8'b00000000; 
    // instr_mem[196]=8'b00000000; 
    // instr_mem[197]=8'b00000000; 
    // instr_mem[198]=8'b00000000; 
    // instr_mem[199]=8'b00000000; 

    // instr_mem[200]=8'b01100000; 
    // instr_mem[201]=8'b00110000;
    
    // .................... load use hazard ....................
    instr_mem[190]=8'h50; 
    instr_mem[191]=8'h23; 
    instr_mem[192]=8'b00000000; 
    instr_mem[193]=8'b00000000;
    instr_mem[194]=8'b00000000; 
    instr_mem[195]=8'b00000000; 
    instr_mem[196]=8'b00000000; 
    instr_mem[197]=8'b00000000; 
    instr_mem[198]=8'b00000000; 
    instr_mem[199]=8'b00000001; 

    instr_mem[200]=8'h60; 
    instr_mem[201]=8'h42;
    instr_mem[202]=8'h00; 

    // ............. jump (misprediction) ..................
    instr_mem[203]=8'h73; 
    instr_mem[204]=8'h00; 
    instr_mem[205]=8'b00000000; 
    instr_mem[206]=8'b00000000;
    instr_mem[207]=8'b00000000; 
    instr_mem[208]=8'b00000000; 
    instr_mem[209]=8'b00000000; 
    instr_mem[210]=8'b00000000; 
    instr_mem[211]=8'd213; 
    instr_mem[212]=8'h00; 
    instr_mem[213]=8'h10;

    //...........return ..........
    instr_mem[213]=8'h80; 
    instr_mem[214]=8'h00; 
    instr_mem[215]=8'b00000000; 
    instr_mem[216]=8'b00000000;
    instr_mem[217]=8'b00000000; 
    instr_mem[218]=8'b00000000; 
    instr_mem[219]=8'b00000000; 
    instr_mem[220]=8'b00000000; 
    instr_mem[221]=8'd224; 
    instr_mem[222]=8'h60;

    instr_mem[223]=8'h23; 
    instr_mem[224]=8'h90; 



    // instr_mem[225]=8'b00010000; 
    // instr_mem[226]=8'b00000000;
    // instr_mem[227]=8'b00000000; 
    // instr_mem[228]=8'b00000000; 
    // instr_mem[229]=8'b00000000; 
    // instr_mem[230]=8'b00000000; 
    // instr_mem[231]=8'd202; 
    // instr_mem[232]=8'h00;

    // instr_mem[233]=8'h61;
    // instr_mem[234]=8'h32;











end


endmodule