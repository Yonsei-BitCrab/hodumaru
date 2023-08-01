module Divider  (   clk, ctl, o_toggle,
                    Data_In,
                    Data_Out_1, Data_Out_2
);

input clk;
input [1:0] ctl;
input [31:0] Data_In;
output reg [15:0] Data_Out_1, Data_Out_2;

output o_toggle;

reg toggle = 0;
reg EN_toggle;

always @(posedge clk) begin
    if (EN_toggle) begin
        toggle = ~toggle;
    end
	 else begin
			toggle = toggle;
	 end
end

always @(posedge clk) begin
    case (ctl)
        2'b00: 
        begin
            Data_Out_1 <= 0;
            Data_Out_2 <= 0;
            EN_toggle <= 0;
        end

        2'b01:
        begin
            Data_Out_1 = toggle ? Data_In[15:0] : 0;
            Data_Out_2 = toggle ? 0 : Data_In[15:0];
            EN_toggle <= 1;
        end

        2'b10:
        begin
            Data_Out_1 = toggle ? Data_In[15:0] : 0;
            Data_Out_2 = toggle ? 0 : Data_In[15:0];
            EN_toggle <= 1;
        end

        2'b11:
        begin
            Data_Out_1 = toggle ? Data_In[15:0] : Data_In[31:16];
            Data_Out_2 = toggle ? Data_In[31:16] : Data_In[15:0];
            EN_toggle <= 1;
        end
        default: 
		  begin
            Data_Out_1 <= 0;
            Data_Out_2 <= 0;
            EN_toggle <= 0;
			end
    endcase
end

assign o_toggle = toggle;

endmodule
