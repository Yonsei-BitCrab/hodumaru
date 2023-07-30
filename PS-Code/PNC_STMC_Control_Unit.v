module PNC_STMC_Control_Unit (
    clk,
    iAddr,
    ctrl
);

input clk;
input [15:0] iAddr;
output [1:0] ctrl;

always @(posedge clk) begin
    if (iAddr[15] == 1) begin   // param => only 1
        ctrl = 2'b01;
    end
    else begin      // spike
        if (iAddr[14] == 1) begin   // Spike from RichClub => only 1
            ctrl = 2'b01;
        end
        else begin
            
        end
    end
end

endmodule