`include "fetch.v"

module fetch_tb;

    reg clk;
    reg [3:0] M_icode,W_icode;
    reg [63:0] M_valA, W_valM;
    reg [63:0] F_predPC;

    wire [3:0] D_icode;
    wire [3:0] D_ifun;
    wire [3:0] D_rA;
    wire [3:0] D_rB; 
    wire [63:0] D_valC;
    wire [63:0] D_valP;
    wire [3:0] D_stat;
    wire [63:0] f_predPC;

    fetch fetch(
    .D_stat(D_stat),
    .D_icode(D_icode),
    .D_ifun(D_ifun),
    .D_rA(D_rA),
    .D_rB(D_rB),
    .D_valC(D_valC),
    .D_valP(D_valP),
    .f_predPC(f_predPC),
    .M_icode(M_icode),
    .M_cnd(M_cnd),
    .M_valA(M_valA),
    .W_icode(W_icode),
    .W_valM(W_valM),
    .F_predPC(F_predPC),
    .clk(clk)
  );


  always @(D_icode) begin
    if(D_icode==0) 
      $finish;
  end

  always @(posedge clk)
  begin
    $display("clk=%d F_predPC=%d F_predPC_in=%d icode=%b ifun=%b rA=%b rB=%b,valC=%d,valP=%d\n",clk,f_predPC,F_predPC, D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP);

    F_predPC <= f_predPC;
  end

  always #10 clk = ~clk;

    // always @(*)begin
    //     if(D_stat==4'b0001) begin
    //         $display("halting");
    //     end
    // end

  initial begin 
    F_predPC=64'd13;
    clk=1;
end 
  
//   initial 
		// $monitor("clk=%d F_predPC=%d F_predPC_in=%d icode=%b ifun=%b rA=%b rB=%b,valC=%d,valP=%d\n",clk,f_predPC,F_predPC, D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP);
endmodule
