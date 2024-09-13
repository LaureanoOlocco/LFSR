/* 

Un LFSR de n bits puede generar una secuencia de 2^(n-1) estados antes de repetirse

Combinaciones para Galois: 2-3/4/5/6/7

Combinaciones para Fibonacci: 1-6-7, 1-5-6


*/
module LFSR_generator 
(
    input  wire clk                      ,
    input  wire i_valid                  ,
    input  wire i_rst                    ,           // Reset asincrónico para fijar el valor de seed
    input  wire i_soft_reset             ,           // Reset sincrónico para registrar el valor de i_seed
    input  wire [7:0] i_seed             ,           // Seed inicial
    output wire [7:0] o_LFSR                        // Salida del LFSR
    //output wire o_valid
);


reg [7:0] LFSR                                     ;
wire feedback = LFSR[7] ^ (LFSR[6:0]==7'b0000000)  ;
always @(posedge clk or posedge i_rst) 
begin
    if (i_rst)  begin
        // Reset asincrónico: Fijar el valor de seed
        LFSR <= 8'b11111111                        ;
    end 
    
    else if (i_soft_reset) begin
        // Reset sincrónico: Registrar el valor de i_seed
        LFSR <= i_seed                             ;
    end 

    else if (i_valid) begin
        
        // Generar nueva secuencia solo si i_valid está activo
        LFSR[0] <= feedback             ;
        LFSR[1] <= LFSR[0] ^ feedback   ;
        LFSR[2] <= LFSR[1]              ;
        LFSR[3] <= LFSR[2]              ;
        LFSR[4] <= LFSR[3]              ;
        LFSR[5] <= LFSR[4] ^ feedback   ;
        LFSR[6] <= LFSR[5] ^ feedback   ;
        LFSR[7] <= LFSR[6]              ;
        
    end
end
assign o_LFSR = LFSR                    ;

endmodule
