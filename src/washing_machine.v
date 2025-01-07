module washing_machine (
    input wire clk,
    input wire reset,
    input wire start_button,
    input wire door_closed,
    input wire delay_done,
    input wire waterlevelreached,
    input wire washcomplete,
    input wire rinsecomplete,
    input wire spincomplete,
    input wire draincomplete,
    input wire cancel_button,
    input wire Motor_Failure,
    input wire Low_Water_Pressure,
    input wire Sensor_Malfunction,
    output reg [8:0] state,
    output reg complete,
    output reg door_locked,
    output reg water_filling
);

    // One-Hot Encoding
    parameter IDLE       = 9'b000000001; // Initial state
    parameter READY      = 9'b000000010; // Waiting to start
    parameter FILL       = 9'b000000100; // Filling water
    parameter WASH       = 9'b000001000; // Washing
    parameter RINSE      = 9'b000010000; // Rinsing
    parameter SPIN       = 9'b000100000; // Spinning
    parameter DRAIN      = 9'b001000000; // Draining water
    parameter COMPLETE   = 9'b010000000; // Cycle complete
    parameter ERROR      = 9'b100000000; // Error state

    reg [8:0] cs, ns;

    always @(posedge clk or posedge reset) begin
        if (reset)
            cs <= IDLE;
        else
            cs <= ns;
    end

    always @(*) begin
        door_locked = 0;
        water_filling = 0;
        complete = 0;
        case (cs)
            IDLE: begin
                if (Sensor_Malfunction == 1 || Low_Water_Pressure == 1 || Motor_Failure == 1)
                    ns = ERROR;
                else if (start_button == 1 && door_closed == 1 && cancel_button == 0)
                    ns = READY;
                else
                    ns = IDLE;
            end

            READY: begin
            // add pause state ??
                door_locked = 1;
                if (Sensor_Malfunction == 1 || Low_Water_Pressure == 1 || Motor_Failure == 1)
                    ns = ERROR;
                else if (cancel_button)
                    ns = IDLE;
                else if (delay_done)
                    ns = FILL;
                else
                    ns = READY;
            end

            FILL: begin
                door_locked = 1;
                water_filling = 1;
                if (Sensor_Malfunction == 1 || Low_Water_Pressure == 1)
                    ns = ERROR;
                else if (cancel_button)
                    ns = IDLE;
                else if (waterlevelreached)
                    ns = WASH;
                else
                    ns = FILL;
            end

            WASH: begin
                door_locked = 1;
                if (Motor_Failure == 1)
                    ns = ERROR;
                else if (cancel_button)
                    ns = IDLE;
                else if (washcomplete)
                    ns = RINSE;
                else
                    ns = WASH;
            end

            RINSE: begin
                door_locked = 1;
                if (Motor_Failure == 1)
                    ns = ERROR;
                else if (cancel_button)
                    ns = IDLE;
                else if (rinsecomplete)
                    ns = SPIN;
                else
                    ns = RINSE;
            end

            SPIN: begin
                door_locked = 1;
                if (Motor_Failure == 1)
                    ns = ERROR;
                else if (cancel_button)
                    ns = IDLE;
                else if (spincomplete)
                    ns = DRAIN;
                else
                    ns = SPIN;
            end

            DRAIN: begin
                door_locked = 1;
                if (Motor_Failure == 1)
                    ns = ERROR;
                else if (cancel_button)
                    ns = IDLE;
                else if (draincomplete)
                    ns = COMPLETE;
                else
                    ns = DRAIN;
            end

            COMPLETE: begin //maybe remove
                door_locked = 0;
                complete = 1;
                ns = COMPLETE;
            end

            ERROR: begin
                door_locked = 0;
                water_filling = 0;
                if (Motor_Failure || Sensor_Malfunction || Low_Water_Pressure)
                    ns = ERROR;
                else
                    ns = IDLE;
            end

            default: begin
                ns = IDLE;
            end
        endcase
    end

    // Output signals
    always @(*) begin
        state = cs;
    end

endmodule
