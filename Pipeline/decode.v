module decode (clk,D_icode,D_ifun,D_rA,D_rB,D_stat,D_valC,D_valP,E_bubble,W_icode,e_dstE,M_dstE,M_dstM,W_dstE,W_dstM,e_valE,M_valE,m_valM,W_valE,W_valM,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7, reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14,d_srcA,d_srcB);

// These are the values stored in the Decode pipeline register (D_ ...)
input clk;
input [3:0] D_icode,D_ifun,D_rA,D_rB;
input [63:0] D_valC,D_valP; 
input E_bubble;
input [3:0] D_stat; // status coming from the decode pipeline register 

input [3:0] W_icode;
input [3:0] e_dstE,M_dstE,M_dstM,W_dstE,W_dstM;
input [63:0] e_valE,M_valE,m_valM,W_valE,W_valM;


// These are values which should be stored in Execute pipeline register  
output reg [0:3] E_stat; 
output reg [3:0] E_icode,E_ifun;
output reg [63:0] E_valC,E_valA,E_valB;
output reg [3:0] E_dstE,E_dstM,E_srcA,E_srcB;

output reg [63:0] reg_file0;
output reg [63:0] reg_file1;
output reg [63:0] reg_file2;
output reg [63:0] reg_file3;
output reg [63:0] reg_file4;
output reg [63:0] reg_file5;
output reg [63:0] reg_file6;
output reg [63:0] reg_file7;
output reg [63:0] reg_file8;
output reg [63:0] reg_file9;
output reg [63:0] reg_file10;
output reg [63:0] reg_file11;
output reg [63:0] reg_file12;
output reg [63:0] reg_file13;
output reg [63:0] reg_file14;

reg [63:0] register_memory[0:14];
output reg [3:0] d_srcA,d_srcB;
reg [3:0] d_dstE,d_dstM;
reg [63:0] d_valA,d_valB;


// Initialized my register file to random values
initial begin
    register_memory[0]=0;
    register_memory[1]=1;
    register_memory[2]=2;
    register_memory[3]=3;
    register_memory[4]=14;
    register_memory[5]=0;
    register_memory[6]=0;
    register_memory[7]=18;
    register_memory[8]=30;  
    register_memory[9]=20;
    register_memory[10]=22;
    register_memory[11]=0;
    register_memory[12]=0;
    register_memory[13]=1;
    register_memory[14]=10;
end

// Finding dstW,dstM,srcA,srcB follow the chart of different operations
always @(*)begin
    case(D_icode)
        4'h2: begin //cmovxx
          d_srcA = D_rA;
          d_dstE = D_rB;
        end
        4'h3: begin
        	d_dstE = D_rB;
        end
        4'h4: begin
          d_srcA = D_rA;
          d_srcB = D_rB;
        end
        4'h5: begin
          d_srcB = D_rB;
          d_dstM = D_rA;
        end
        4'h6: begin
          d_srcA = D_rA;
          d_srcB = D_rB;
          d_dstE = D_rB;
        end
        4'h8:begin
          d_srcB = 4;
          d_dstE = 4;
        end
        4'h9:begin
          d_srcA = 4;
          d_srcB = 4;
          d_dstE = 4;
        end
        4'hA: begin
          d_srcA = D_rA;
          d_srcB = 4;
          d_dstE = 4;
        end
        4'hB: begin
          d_srcA = 4;
          d_srcB = 4;
          d_dstE = 4;
          d_dstM = D_rA;
        end
        default: begin
          d_srcA = 4'hF;
          d_srcB = 4'hF;
          d_dstE = 4'hF;
          d_dstM = 4'hF;
        end
    endcase

    if(D_icode==4'b0010) //cmovxx
    begin
        d_valA=register_memory[D_rA];
    end
    if(D_icode==4'b0100) //rmmovq
    begin
        d_valA=register_memory[D_rA];
        d_valB=register_memory[D_rB];
    end
    if(D_icode==4'b0101) //mrmovq
    begin
        d_valB=register_memory[D_rB];
    end
    if(D_icode==4'b0110)  //opq
    begin
        d_valA=register_memory[D_rA];
        d_valB=register_memory[D_rB];
    end
    if(D_icode==4'b1000) //call
    begin
        // As we have to push address o fnext instruction onto stack
        d_valB=register_memory[4];
    end
    if(D_icode==4'b1001) //ret
    begin
        d_valA=register_memory[4];
        d_valB=register_memory[4];
    end
    if(D_icode==4'b1010) //pushq
    begin
        d_valA = register_memory[D_rA];
        d_valB = register_memory[4];
    end
    if(D_icode==4'b1011) //popq
    begin
        d_valA=register_memory[4];
        d_valB=register_memory[4];
    end


     // Forwarding A
    if(D_icode==4'h7 | D_icode == 4'h8) //jxx or call
      d_valA = D_valP;
    else if(d_srcA==e_dstE & e_dstE!=4'hF)
      d_valA = e_valE;
    else if(d_srcA==M_dstM & M_dstM!=4'hF)
      d_valA = m_valM;
    else if(d_srcA==W_dstM & W_dstM!=4'hF)
      d_valA = W_valM;
    else if(d_srcA==M_dstE & M_dstE!=4'hF)
      d_valA = M_valE;
    else if(d_srcA==W_dstE & W_dstE!=4'hF)
      d_valA = W_valE;

       // Forwarding B
    if(d_srcB==e_dstE & e_dstE!=4'hF)      
      d_valB = e_valE;
    else if(d_srcB==M_dstM & M_dstM!=4'hF)
      d_valB = m_valM;
    else if(d_srcB==W_dstM & W_dstM!=4'hF) 
      d_valB = W_valM;
    else if(d_srcB==M_dstE & M_dstE!=4'hF) 
      d_valB = M_valE;
    else if(d_srcB==W_dstE & W_dstE!=4'hF) 
      d_valB = W_valE;

end

// updating the values in Execute pipeline register
always @(posedge clk)
begin
	 if(E_bubble)
    begin
      // $display("E-bubble=%d\n",E_bubble);
      E_stat <= 4'b1000;
      E_icode <= 4'b0001;
      E_ifun <= 4'b0000;
      E_valC <= 4'b0000;
      E_valA <= 4'b0000;
      E_valB <= 4'b0000;
      E_dstE <= 4'hF;
      E_dstM <= 4'hF;
      E_srcA <= 4'hF;
      E_srcB <= 4'hF;
    end
    else
    begin
      E_stat <= D_stat;
      E_icode <= D_icode;
      E_ifun <= D_ifun;
      E_valC <= D_valC;
      E_valA <= d_valA;
      E_valB <= d_valB;
      E_srcA <= d_srcA;
      E_srcB <= d_srcB;
      E_dstE <= d_dstE;
      E_dstM <= d_dstM;
    end
end

// Write back

always @(posedge clk)
begin
	if(W_icode == 4'b0010) //cmovXX
    begin register_memory[W_dstE] = W_valE; end
    if(W_icode == 4'b0011) //irmovq
    begin register_memory[W_dstE]=W_valE; end
    if(W_icode==4'b0101) // mrrmovq D(rB),rA
    begin register_memory[W_dstM]=W_valE; end
    if(W_icode == 4'b0110) //opq
    begin register_memory[W_dstE] = W_valE; end
    if(W_icode == 4'b1000) //Dest
    begin register_memory[W_dstE]= W_valE; end // updating %rsp
    if(W_icode == 4'b1000) //ret
    begin register_memory[W_dstE]= W_valE; end // updating %rsp
    if(W_icode== 4'hA) //push
    begin register_memory[W_dstE]=W_valE; end
    if(W_icode==4'b1011) // pop
    begin
        register_memory[W_dstE] =W_valE;
        register_memory[W_dstM]=W_valM;
    end

		reg_file0 <= register_memory[0];
    reg_file1 <= register_memory[1];
    reg_file2 <= register_memory[2];
    reg_file3 <= register_memory[3];
    reg_file4 <= register_memory[4];
    reg_file5 <= register_memory[5];
    reg_file6 <= register_memory[6];
    reg_file7 <= register_memory[7];
    reg_file8 <= register_memory[8];
    reg_file9 <= register_memory[9];
    reg_file10 <=register_memory[10];
    reg_file11 <=register_memory[11];
    reg_file12 <=register_memory[12];
    reg_file13 <=register_memory[13];
    reg_file14 <=register_memory[14];


end




endmodule