
module LFSR_Checker (
    input  wire clk                                         , // Señal de reloj
    input  wire i_valid                                     , // Señal de validación del generador LFSR
    input  wire [7:0] i_LFSR                                , // Valor del LFSR del generador
    input  wire i_rst                                       , // Reset asincrónico
    output wire o_lock                                        // Señal de salida para indicar si el checker está bloqueado  
        
);

    // Declaración de registros para los contadores

    // Inicialización de los registros
    reg [2:0] valid_counter                                         ;  // Contador para valores válidos (hasta 5)
    reg [2:0] invalid_counter                                       ;  // Contador para valores inválidos (hasta 3)
    reg [7:0] LFSR                                                  ;
    wire feedback = LFSR[7] ^ (LFSR[6:0]==7'b0000000)               ; //i_LFSR[7]
    //wire feedback = LFSR[7] ^ i_LFSR[7]                             ;
    reg aux_lock                                                    ;
    reg [7:0] bufferLFSR                                            ;
    

    // Lógica secuencial para los contadores y el estado de bloqueo
    always @(posedge clk or posedge i_rst) begin

        if (i_rst) begin
            // Reset asincrónico: Reinicia todos los contadores y desbloquea
            valid_counter   <= 3'b000           ;
            invalid_counter <= 3'b000           ;  
            aux_lock        <= 1'b0             ; // empieza como unlock
            LFSR            <= 8'b00000001      ;
            bufferLFSR      <= 8'd0             ;
        end 
        
        else  begin
            
            if (i_valid) begin

               bufferLFSR <= i_LFSR;

                if ((aux_lock == 1'd0) && (bufferLFSR != LFSR) ) begin

                    LFSR <= i_LFSR                  ;
                    
                end

                else begin
                    

                    LFSR[0] <= feedback             ;
                    LFSR[1] <= LFSR[0] ^ feedback   ;
                    LFSR[2] <= LFSR[1]              ;
                    LFSR[3] <= LFSR[2]              ;
                    LFSR[4] <= LFSR[3]              ;
                    LFSR[5] <= LFSR[4] ^ feedback   ;
                    LFSR[6] <= LFSR[5] ^ feedback   ;
                    LFSR[7] <= LFSR[6]              ;
                    
                end

                if(bufferLFSR == LFSR) begin //valid

                    valid_counter <= valid_counter + 1              ;
                    invalid_counter <= 0                            ;
                    if(valid_counter>= 5) begin
                        aux_lock <= 1'd1                            ;
                        valid_counter <= 3'd0                       ;
                    end
                end
                // cuando estoy en unlock y genera un dato invalido genero un nuevo dato con el i_LFSR
                else if (bufferLFSR != LFSR) begin //invalid

                        invalid_counter <= invalid_counter + 1'd1       ;
                        valid_counter <= 3'd0                           ;
                        if(invalid_counter>=3'd3) begin
                            aux_lock<= 1'd0                             ;
                            invalid_counter <= 3'd0                     ;

                        end
                end
            end
        end
    end    

assign o_lock = aux_lock                                                ;
  
endmodule
