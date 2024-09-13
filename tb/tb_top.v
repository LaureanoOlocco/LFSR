`timescale 1ns/1ps

module tb_top;

    reg clk        ;
    reg i_valid    ;
    reg i_rst      ;
    reg i_btn      ;
    reg i_corrupt  ;
    reg [3:0] i_sw ;
    wire o_led     ;
    
    top uut
    (
        .clk         (clk         ),
        .i_valid     (i_valid     ),
        .i_rst       (i_rst       ),
        .i_btn       (i_btn       ),
        .i_corrupt   (i_corrupt   ),
        .i_sw        (i_sw        ),
        .o_led       (o_led       )
    );
    
    // Generación de clock a 100 MHz
    always #50 clk = ~clk; // 5 ns para 100 MHz             
    
    initial begin
        // Inicialización de señales
        clk           = 0    ;
        i_valid       = 0    ;
        i_btn         = 0    ;
        i_sw          = 4'd05;
        i_corrupt     = 0    ;
        i_rst         = 1    ;
        
        @(posedge clk)          ;
        i_rst   = 0             ;
        i_btn   = 1             ;


        // @(posedge clk)          ;
        // i_btn = 0               ;

        #2000

        repeat(26) begin
            i_valid = 1   ;
            @(posedge clk);
        end
        
        i_valid   = 0 ;
        i_corrupt = 1 ;
        repeat (6) begin
        i_valid = 1   ;
        @(posedge clk);
        end
        
        i_valid = 0;
        
        // finish 
        #200       ;
        $finish;
    end


   
endmodule