module PNC_STMC_Control_Unit (
    clk, rst,
    iAddr,
    ctrl
);

input clk, rst;
input [15:0] iAddr;
output [1:0] ctrl;

reg [1:0] o_ctrl;

always @(posedge clk) begin
    if (rst == 1) begin
        o_ctrl <= 2'b10;
    end
    else begin
        if (iAddr[15] == 1) begin   // param => only 1
            o_ctrl <= 2'b01;
        end
        else begin      // spike
            if (iAddr[14] == 1) begin   // Spike from RichClub => only 1
                o_ctrl <= 2'b10;
            end
            else begin
                if (iAddr[13:7] == 7'b0) begin  // 2nd Addr is null
                    if (iAddr[6:0] == 7'b0) begin   // 2nd & 1st Addr is null
                        o_ctrl <= 2'b00;    //DEBUG
                    end
                    else begin                      // 2nd->null, 1st->valid
                        o_ctrl <= 2'b01;
                    end
                end
                else begin                      // 2nd Addr is valid
                    o_ctrl <= 2'b11;
                end
            end
        end
    end
end

assign ctrl = o_ctrl;
//assign ctrl = 2'b10; //debug

endmodule