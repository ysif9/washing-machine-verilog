module timer (
    input clk,
    input [8:0] state,
    output reg sig_Full,
    output reg sig_Wash_Completed,
    output reg sig_Rinse_Completed,
    output reg sig_Spin_Completed,
    output reg sig_Drain_Completed,
    output reg sig_Delay
);

    reg [2:0] fill_Water_Counter;
    reg [5:0] wash_Counter;
    reg [3:0] rinse_Counter;
    reg [2:0] spin_Counter;
    reg [1:0] drain_Counter;
    reg ready_Delay_Counter;


    parameter IDLE       = 9'b000000001; // Initial state
    parameter READY      = 9'b000000010; // Waiting to start
    parameter FILL       = 9'b000000100; // Filling water
    parameter WASH       = 9'b000001000; // Washing
    parameter RINSE      = 9'b000010000; // Rinsing
    parameter SPIN       = 9'b000100000; // Spinning
    parameter DRAIN      = 9'b001000000; // Draining water
    parameter COMPLETE   = 9'b010000000; // Cycle complete
    parameter ERROR      = 9'b100000000; // Error state


    parameter FULL_WATER_TIME = 3'd4;             // ~4 minutes for filling water
    parameter WASH_TIME = 5'd30;                 // ~30 minutes for the wash cycle
    parameter RINSE_TIME = 4'd10;               // ~10 minutes for rinsing
    parameter SPIN_TIME = 3'd5;                // ~5 minutes for spinning
    parameter DRAIN_TIME = 2'd2;              // ~2 minutes for draining water
    parameter DELAY_TIME = 1'd1;             // ~1 minute for cancel/add clothes

    always @ (posedge clk) begin
        if (state == IDLE) begin
                    fill_Water_Counter <= 0;
                    wash_Counter <= 0;
                    rinse_Counter <= 0;
                    spin_Counter <= 0;
                    drain_Counter <= 0;
                    ready_Delay_Counter <= 0;
                    sig_Full <= 0;
                    sig_Wash_Completed <= 0;
                    sig_Rinse_Completed <= 0;
                    sig_Spin_Completed <= 0;
                    sig_Drain_Completed <= 0;
                    sig_Delay <= 0;
        end

        if (state == READY) begin
                if (ready_Delay_Counter < DELAY_TIME)
                begin
                    ready_Delay_Counter <= ready_Delay_Counter + 1'd1;
                    sig_Delay <= 0;
                end
                else
                    sig_Delay <= 1;
        end

        case (state)
                    FILL:
                        fill_Water_Counter <= fill_Water_Counter + 1'd1;

                    WASH:
                        wash_Counter <= wash_Counter + 1'd1;

                    RINSE:
                        rinse_Counter <= rinse_Counter + 1'd1;

                    SPIN:
                        spin_Counter <= spin_Counter + 1'd1;

                    DRAIN:
                        drain_Counter <= drain_Counter + 1'd1;
        endcase


        if (fill_Water_Counter == FULL_WATER_TIME)
            sig_Full <= 1;
        if (wash_Counter == WASH_TIME)
            sig_Wash_Completed <= 1;
        if (rinse_Counter == RINSE_TIME)
            sig_Rinse_Completed <= 1;
        if (spin_Counter == SPIN_TIME)
            sig_Spin_Completed <= 1;
        if (drain_Counter == DRAIN_TIME)
            sig_Drain_Completed <= 1;
        if (ready_Delay_Counter == DELAY_TIME)
            sig_Delay <= 1;
    end
endmodule
