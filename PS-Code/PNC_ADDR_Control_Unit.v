module PNC_ADDR_Control_Unit(clk,
                        iADDR_ctl,
                        EN_SYNAPSE, EN_SOMA, EN_STDP,
                        RC_SYNAPSE, RC_SOMA, RC_STDP,
                        W_EN2Synapse, W_EN2SOMA, W_EN2STDP
);


input clk;
input [3:0] iADDR_ctl;

output reg EN_SYNAPSE, EN_SOMA, EN_STDP;
output reg RC_SYNAPSE, RC_SOMA, RC_STDP;
output reg W_EN2SOMA, W_EN2Synapse, W_EN2STDP;



always @(posedge clk) begin
    if (iADDR_ctl[3] == 1) begin   // PARAM in
        case (iADDR_ctl[1:0])
            2'b00:          // to SYNAPSE(RichClub)
            begin
                EN_SYNAPSE <= 1'b1;
                RC_SYNAPSE <= 1'b1;
                W_EN2Synapse <= 1'b1;
                EN_SOMA <= 1'b0;
                RC_SOMA <= 1'b0;
                W_EN2SOMA <= 1'b0;
                EN_STDP <= 1'b0;
                RC_STDP <= 1'b0;
                W_EN2STDP <= 1'b0;
            end

            2'b01:          // to SYNAPSE
            begin
                EN_SYNAPSE <= 1'b1;
                RC_SYNAPSE <= 1'b0;
                W_EN2Synapse <= 1'b1;
                EN_SOMA <= 1'b0;
                RC_SOMA <= 1'b0;
                W_EN2SOMA <= 1'b0;
                EN_STDP <= 1'b0;
                RC_STDP <= 1'b0;
                W_EN2STDP <= 1'b0;
            end

            2'b10:          // to SOMA
            begin
                EN_SYNAPSE <= 1'b0;
                RC_SYNAPSE <= 1'b0;
                W_EN2Synapse <= 1'b0;
                EN_SOMA <= 1'b1;
                RC_SOMA <= 1'b0;
                W_EN2SOMA <= 1'b1;
                EN_STDP <= 1'b0;
                RC_STDP <= 1'b0;
                W_EN2STDP <= 1'b0;
            end

            2'b11:          // to STDP
            begin
                EN_SYNAPSE <= 1'b0;
                RC_SYNAPSE <= 1'b0;
                W_EN2Synapse <= 1'b0;
                EN_SOMA <= 1'b0;	
                RC_SOMA <= 1'b0;
                W_EN2SOMA <= 1'b0;
                EN_STDP <= 1'b1;
                RC_STDP <= 1'b0;
                W_EN2STDP <= 1'b1;
            end

            default:
            begin
                EN_SYNAPSE <= 1'b0;
                RC_SYNAPSE <= 1'b0;
                W_EN2Synapse <= 1'b0;
                EN_SOMA <= 1'b0;
                RC_SOMA <= 1'b0;
                W_EN2SOMA <= 1'b0;
                EN_STDP <= 1'b1;
                RC_STDP <= 1'b0;
                W_EN2STDP <= 1'b1;
            end
        endcase
    end
    else begin                  // SPIKE in
        if (iADDR_ctl[2] == 1) begin   //  RichClub
            EN_SYNAPSE <= 1'b1;
            RC_SYNAPSE <= 1'b1;
            W_EN2Synapse <= 1'b0;
            EN_SOMA <= 1'b0;
            RC_SOMA <= 1'b0;
            W_EN2SOMA <= 1'b0;
            EN_STDP <= 1'b0;
            RC_STDP <= 1'b0;
            W_EN2STDP <= 1'b0;            
        end
        else begin
            EN_SYNAPSE <= 1'b1;
            RC_SYNAPSE <= 1'b0;
            W_EN2Synapse <= 1'b0;
            EN_SOMA <= 1'b0;
            RC_SOMA <= 1'b0;
            W_EN2SOMA <= 1'b0;
            EN_STDP <= 1'b0;
            RC_STDP <= 1'b0;
            W_EN2STDP <= 1'b0;       
        end
    end
end


endmodule
