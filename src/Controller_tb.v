`timescale 1ns / 1ps

module Controller_tb;

    // Inputs
    reg clk_tb;
    reg reset;
    reg sig_door_closed;
    reg sig_start_button;
    reg sig_cancel_button;
    reg sig_Motor_Failure;
    reg sig_Low_Water_Pressure;
    reg sig_Sensor_Malfunction;

    // Outputs
    wire [8:0] state;
    wire complete;
    wire water_filling;
    wire door_locked;

    parameter IDLE       = 9'b000000001; // Initial state
    parameter READY      = 9'b000000010; // Waiting to start
    parameter FILL       = 9'b000000100; // Filling water
    parameter WASH       = 9'b000001000; // Washing
    parameter RINSE      = 9'b000010000; // Rinsing
    parameter SPIN       = 9'b000100000; // Spinning
    parameter DRAIN      = 9'b001000000; // Draining water
    parameter COMPLETE   = 9'b010000000; // Cycle complete
    parameter ERROR      = 9'b100000000; // Error state

    Controller uut (
        .clock(clk_tb),
        .reset(reset),
        .sig_door_closed(sig_door_closed),
        .sig_start_button(sig_start_button),
        .sig_cancel_button(sig_cancel_button),
        .sig_Motor_Failure(sig_Motor_Failure),
        .sig_Low_Water_Pressure(sig_Low_Water_Pressure),
        .sig_Sensor_Malfunction(sig_Sensor_Malfunction),
        .state(state),
        .complete(complete),
        .water_filling(water_filling),
        .door_locked(door_locked)
    );

    always #5 clk_tb = ~clk_tb; // Clock period = 10ns

    initial
    begin
    $monitor("Time: %0t | State: %b | Door Locked: %b | Water Filling: %b | Complete: %b | Start: %b | Cancel: %b | Motor Failure: %b | Low Pressure: %b | Sensor Malfunction: %b",
                      $time, state, door_locked, water_filling, complete, sig_start_button, sig_cancel_button, sig_Motor_Failure, sig_Low_Water_Pressure, sig_Sensor_Malfunction);
        $dumpfile("Controller.vcd");
        $dumpvars;
        clk_tb = 0;
        reset = 0;
        sig_door_closed = 0;
        sig_start_button = 0;
        sig_cancel_button = 0;
        sig_Motor_Failure = 0;
        sig_Low_Water_Pressure = 0;
        sig_Sensor_Malfunction = 0;



        $display("\n--- Test 1: System starts in IDLE state after reset ---");
        #10 reset = 1;
        #10 reset = 0;


        $display("\n--- Test 2: Full washing cycle ---");
        sig_door_closed = 1;
        sig_start_button = 1;
        wait(complete == 1);
        $display("time up");



       $display("\n--- Test 3: Reset during washing cycle ---");
        reset = 1;
        reset = 0;
        sig_start_button = 1;
        sig_door_closed = 1;
        #50 reset = 1;
        #10 reset = 0;

        $display("\n--- Test 4: random constrained failures ---");
        repeat(100) begin
            sig_Motor_Failure = {$urandom} % 2;
            sig_Low_Water_Pressure = {$urandom} % 2;
            sig_Sensor_Malfunction = {$urandom} % 2;
            @(posedge clk_tb);
        end
        sig_Motor_Failure = 0;
        sig_Sensor_Malfunction = 0;
        sig_Low_Water_Pressure = 0;


        $display("\n--- Test 5: cancel button with all states   ---");
            #50 reset = 1;
            #50 reset = 0;
            while (state != READY) begin
                #2;
            end
            wait(state == READY)
             sig_cancel_button = 1;
            #50 sig_cancel_button = 0;


            while (state != FILL) begin
                #10;
            end
            wait(state == FILL)

             sig_cancel_button = 1;
            #50 sig_cancel_button = 0;


            while (state != WASH) begin
                #10;
            end
                    wait(state == WASH)

             sig_cancel_button = 1;
            #50 sig_cancel_button = 0;


            while (state != RINSE) begin
                #10;
            end
                    wait(state == RINSE)

             sig_cancel_button = 1;
            #50 sig_cancel_button = 0;

            while (state != SPIN) begin
                #10;
            end
                    wait(state == SPIN)

             sig_cancel_button = 1;
            #50 sig_cancel_button = 0;


            while (state != DRAIN) begin
                #5;
            end
                wait(state == DRAIN)

            sig_cancel_button = 1;
            #50 sig_cancel_button = 0;

        $display("\n--- Test 6: start with door open ---");
            sig_door_closed = 0;
            #50 reset = 1;
            #50 reset = 0;
            #60
            sig_door_closed = 1;

        $display("\n--- Test 7: start with error ---");
            sig_Motor_Failure = 1;
            sig_Low_Water_Pressure = 1;
            reset = 1;
            reset = 0;
            #200
            sig_Motor_Failure = 0;
            sig_Low_Water_Pressure = 0;

        $display("\n--- Test 8: start and cancel ---");
            sig_cancel_button = 1;
            sig_start_button = 1;
            reset = 1;
            reset = 0;
            #200;
            sig_cancel_button = 0;


        $display("\n--- Test 9: All errors on all states ---");
            sig_Sensor_Malfunction = 0;
             sig_Low_Water_Pressure = 0;
             sig_Motor_Failure = 0;
            #50 reset = 1;
            #50 reset = 0;
            while (state != READY) begin
                #2;
            end
            wait(state == READY)
//            sig_Sensor_Malfunction = 1;
//             sig_Low_Water_Pressure = 1;
             sig_Motor_Failure = 1;
            #50 sig_Sensor_Malfunction = 0;
             sig_Low_Water_Pressure = 0;
             sig_Motor_Failure = 0;


            while (state != FILL) begin
                #10;
            end
            wait(state == FILL)

             sig_Sensor_Malfunction = 1;
             sig_Low_Water_Pressure = 1;
             sig_Motor_Failure = 1;
            #50 sig_Sensor_Malfunction = 0;
             sig_Low_Water_Pressure = 0;
             sig_Motor_Failure = 0;

            while (state != FILL) begin
                #10;
            end
            wait(state == FILL)

             sig_Sensor_Malfunction = 1;

            #50 sig_Sensor_Malfunction = 0;

            while (state != FILL) begin
                #10;
            end
            wait(state == FILL)


             sig_Low_Water_Pressure = 1;
            #50
             sig_Low_Water_Pressure = 0;

            while (state != WASH) begin
                #10;
            end
                    wait(state == WASH)

             sig_Motor_Failure = 1;
            #50 sig_Motor_Failure = 0;


            while (state != RINSE) begin
                #10;
            end
                    wait(state == RINSE)

             sig_Motor_Failure = 1;
            #50 sig_Motor_Failure = 0;

            while (state != SPIN) begin
                #10;
            end
                    wait(state == SPIN)

             sig_Motor_Failure = 1;
            #50 sig_Motor_Failure = 0;


            while (state != DRAIN) begin
                #5;
            end
                wait(state == DRAIN)
         sig_Motor_Failure = 1;
        #50 sig_Motor_Failure = 0;
        wait(sig_Motor_Failure == 0);
        #10;

        $display("\n--- Test 10: removing start signal while washing ---");
            sig_start_button = 1;
            reset = 1;
            #50 reset = 0;
            #400
            sig_start_button = 0;
            wait(complete)

    $finish;
 end
endmodule
