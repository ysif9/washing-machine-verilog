module Controller(
    input clock,
    input reset,
    input sig_door_closed,
    input sig_start_button,
    input sig_cancel_button,
    input sig_Motor_Failure,
    input sig_Low_Water_Pressure,
    input sig_Sensor_Malfunction,
    output [8:0] state,
    output complete,
    output water_filling,
    output door_locked
    );

    wire sig_Full;
    wire sig_Wash_Completed;
    wire sig_Rinse_Completed;
    wire sig_Spin_Completed;
    wire sig_Drain_Completed;
    wire sig_Delay;

    parameter IDLE       = 9'b000000001; // Initial state
    parameter READY      = 9'b000000010; // Waiting to start
    parameter FILL       = 9'b000000100; // Filling water
    parameter WASH       = 9'b000001000; // Washing
    parameter RINSE      = 9'b000010000; // Rinsing
    parameter SPIN       = 9'b000100000; // Spinning
    parameter DRAIN      = 9'b001000000; // Draining water
    parameter COMPLETE   = 9'b010000000; // Cycle complete
    parameter ERROR      = 9'b100000000; // Error state


timer u_timer (
    .clk(clock),
    .state(state),
    .sig_Full(sig_Full),
    .sig_Wash_Completed(sig_Wash_Completed),
    .sig_Rinse_Completed(sig_Rinse_Completed),
    .sig_Spin_Completed(sig_Spin_Completed),
    .sig_Drain_Completed(sig_Drain_Completed),
    .sig_Delay(sig_Delay)
    );


washing_machine u_washing_machine (
    .clk(clock),
    .start_button(sig_start_button),
    .cancel_button(sig_cancel_button),
    .delay_done(sig_Delay),
    .door_closed(sig_door_closed),
    .draincomplete(sig_Drain_Completed),
    .reset(reset),
    .rinsecomplete(sig_Rinse_Completed),
    .Low_Water_Pressure(sig_Low_Water_Pressure),
    .Motor_Failure(sig_Motor_Failure),
    .Sensor_Malfunction(sig_Sensor_Malfunction),
    .spincomplete(sig_Spin_Completed),
    .washcomplete(sig_Wash_Completed),
    .waterlevelreached(sig_Full),
    .state(state),
    .complete(complete),
    .door_locked(door_locked),
    .water_filling(water_filling)
    );



        //Assertion 1: door is always locked while washing
            // psl default clock = rose(clock);
            //psl property DOOR_LOCKED = always ((state != IDLE && state != ERROR && state != COMPLETE) -> {door_locked == 1});
            // psl assert DOOR_LOCKED;

       //Assertion 2: reset should transition to IDLE state
            //psl property RESET_TRANSITION = always (reset -> state == IDLE);
            // psl assert RESET_TRANSITION;

        // Assertion 3: Error will always be detected
            //psl property ERROR_DETECTION = always ((sig_Low_Water_Pressure == 1 || sig_Motor_Failure == 1  || sig_Sensor_Malfunction == 1) -> next(state == ERROR));
            // psl assert ERROR_DETECTION;


          // Assertion 4: Cancel Button will override all states
            //psl property CANCEL_BUTTON = always ((sig_cancel_button) -> next(state == IDLE));
            // psl assert CANCEL_BUTTON;


endmodule