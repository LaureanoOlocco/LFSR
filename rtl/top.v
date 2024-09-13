module top (
    input  wire       clk         ,
    input  wire       i_valid     ,
    input  wire       i_rst       ,
    input  wire       i_btn       ,
    input  wire [3:0] i_sw        ,
    input  wire       i_corrupt   ,
    output wire       o_led       
);
    wire [7:0] seed                ;
    wire [7:0] LFSR_connect_checker;
    wire [7:0] corrupt_LFSR        ;


    assign seed = {{4{1'b0}},i_sw} ;
    
    // Instancia del módulo LFSR_generator
    LFSR_generator uut_generator
    (
        .clk         (clk                 ),
        .i_valid     (i_valid             ),
        .i_rst       (i_rst               ),
        .i_soft_reset(i_btn               ),
        .i_seed      (seed                ),
        .o_LFSR      (LFSR_connect_checker)
    );

    // Instancia del módulo LFSR_Checker
    LFSR_Checker uut_checker
    (
        .clk         (clk                 ),
        .i_valid     (i_valid             ),
        .i_LFSR      (corrupt_LFSR        ),
        .i_rst       (i_rst               ),
        .o_lock      (o_led               )
    );

    // Si corrupt está en 1, corrompo la secuencia y falla el checker
    assign corrupt_LFSR = i_corrupt ? {LFSR_connect_checker [7:1], ~LFSR_connect_checker[0]} : LFSR_connect_checker;
    
endmodule