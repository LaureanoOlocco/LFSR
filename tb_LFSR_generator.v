`timescale 1ns/1ps

// El testbench no tiene entradas ni salidas porque es un entorno de prueba que maneja internamente las señales.

module tb_LFSR_generator;

    // Señales del testbench
    reg     clk                                                                                 ;
    reg     i_valid                                                                             ;
    reg     i_rst                                                                               ;
    reg     i_soft_reset                                                                        ;
    reg     [7:0] i_seed                                                                        ;
    wire    [7:0] o_LFSR                                                                        ;   
    reg     [7:0] seed_reg                                                                      ;
    //! Instancia del módulo a testear
LFSR_generator uut 
(
    .clk(clk)                                                                                   ,
    .i_valid(i_valid)                                                                           ,
    .i_rst(i_rst)                                                                               ,
    .i_soft_reset(i_soft_reset)                                                                 ,
    .i_seed(i_seed)                                                                             ,
    .o_LFSR(o_LFSR)
);
// Clock de 10MHz
always #5 clk=~clk                                                                             ;

//! Task para cambiar el valor de i_seed
task change_seed(input [7:0] new_seed)                                                          ;
    begin
        i_seed = new_seed                                                                       ;
    end
endtask

// Task para setear el reset asincrónico (i_rst)
task async_reset                                                                                ;   
    reg [7:0] random_reset_async;                           
    begin
        random_reset_async = $urandom_range(1,2000);
        @(posedge clk) i_rst = 1                                                                ;
        # random_reset_async                                                                    ;           // delay aleatorio entre 1us y 250us
        @(posedge clk) i_rst = 0                                                                ;
    end
endtask

// Task para setear el reset sincrónico (i_soft_reset)
task sync_reset                                                                                 ;
    reg [7:0] random_reset; 
    begin
        random_reset = $urandom_range (1,2000);
        @(posedge clk) i_soft_reset = 1                                                         ;
        # random_reset                                                                          ; // delay aleatorio entre 1us y 250us
        @(posedge clk) i_soft_reset = 0                                                         ;
    end
endtask


task test_periodicity_init_value;
    integer cycle_count;
    reg [7:0] previous_value;
    
    
    begin
        // Inicializa el contador de ciclos
        cycle_count = 0                                                                                        ;
        i_valid     = 0                                                                                        ; 
        // previous_value = o_LFSR                                                                                ;
        @(posedge clk)                                                                                         ;
        previous_value = o_LFSR                                                                                ;
        // Ejecuta el test durante 256 ciclos
        repeat (256) 
        begin
            
            i_valid=1                               ;  //activo el valid ( para que se genere un nuevo valor del LFSR)
            @(posedge clk)                          ;
            cycle_count = cycle_count + 1           ;
            

            // Comprueba si el valor del LFSR se repite
            if (o_LFSR == previous_value) begin
                $display("Seed: %b.", i_seed)                                                                  ;
                $display("Periodicity test passed with initial value from o_LFSR after %d cycles", cycle_count);
                $display("Init_value: %b", previous_value)                                                     ;
                $display("current_value: %b", o_LFSR)                                                          ; 
            end
        end

        i_valid=0                                                                                              ;
        
        
    end
endtask



task test_periodicity_random_seeds;
    integer cycle_count;
    reg [7:0] previous_value;
    reg [7:0] random_seed;
    integer seed_counter;

    begin
        // Inicializa el contador de ciclos y el contador de semillas
        cycle_count  = 0;
        seed_counter = 0;

        // Ejecuta la prueba con varias semillas aleatorias
        repeat (10) begin // Cambiar 10 por el número de semillas que desees probar
            // Genera una semilla aleatoria
            random_seed = $urandom_range(1, 255)                                                               ; // Genera un valor aleatorio entre 1 y 255
            $display("Testing with random seed: %b", random_seed)                                              ;

            // Establece la semilla aleatoria en el LFSR
            change_seed(random_seed)                                                                           ;

            // Captura el valor inicial de la salida del LFSR
            @(posedge clk)                                                                                     ;
            previous_value = o_LFSR                                                                            ;

            // Inicializa el contador de ciclos
            cycle_count = 0                                                                                    ;

            // Ejecuta el test durante 256 ciclos para cada semilla
            repeat (256) begin
                i_valid=1                                                                                      ;
                @(posedge clk)                                                                                 ;
                cycle_count = cycle_count + 1                                                                  ;

                // Comprueba si el valor del LFSR se repite
                if (o_LFSR == previous_value) begin
                    $display("Periodicity found with random seed %b after %d cycles", random_seed, cycle_count);
                    // Salir del bucle si se encuentra periodicidad
                    
                end
            end

            // Reporta si no se encontró periodicidad para la semilla actual
            if (o_LFSR != previous_value) begin
                $display("No periodicity found with random seed %b within 256 cycles", random_seed);
            end

            // Incrementa el contador de semillas probadas
            seed_counter = seed_counter + 1                                                     ;
        end

        // Finaliza la prueba después de probar todas las semillas
        $display("Random seed periodicity test completed after testing %d seeds.", seed_counter);
        
    end
endtask


// Proceso principal de prueba
initial begin 
    // Inicialización de señales
    $display("Enters initial cycle")                                                            ;
    clk             = 0                                                                         ;
    i_valid         = 0                                                                         ;
    i_rst           = 0                                                                         ;  
    i_soft_reset    = 0                                                                         ;
    i_seed          = 8'b11111111                                                               ; // Valor inicial del seed
    
   

    // Realizar un reset asincrónico al inicio
    async_reset                                                                                 ;  
    //@(posedge clk) i_valid = 1                                                                      ;
    sync_reset    
                                                                                                ;
    // Generar valid aleatorio y realizar pruebas
    repeat(255) begin
        @(posedge clk)                                                                          ; //Se genere una señal de valid, en donde aleatoriamente suvalor cambie o no en cada ciclo de clock.
        i_valid = $random % 2                                                                   ; // Cambia aleatoriamente entre 0 y 1
        #100                                                                                    ;
        if (i_valid) begin
            seed_reg = o_LFSR                                                                   ; // Guarda el valor del LFSR
            change_seed(seed_reg)                                                               ; // Cambia el seed aleatoriamente
            sync_reset                                                                          ; // Realiza un reset sincrónico
        end
    end


    // Ejecuta las pruebas de periodicidad
    test_periodicity_init_value                                                                 ; // Prueba con una semilla fija específica
    test_periodicity_random_seeds                                                               ; // Llamada a la tarea para probar la periodicidad con semillas aleatorias
   
    
        

    // Finaliza la simulación
    $finish                                                                                     ;        
end


endmodule