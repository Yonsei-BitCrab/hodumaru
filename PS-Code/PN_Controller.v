module PN_Controller(clk, rst,
                    iADDR, W_DATA,
                    W_EN2Synapse, W_EN2SOMA, W_EN2STDP,
                    R_EN2Synapse, R_EN2SOMA, R_EN2STDP,
                    to_Synapse_Addr, to_STDP_Addr,
                    to_Synapse_DATA, to_SOMA_DATA, to_STDP_DATA,
                    SWU_EN, SWU_Addr, SWU_DATA      // Synaptic Weight Update

);


input clk, rst;
input [15:0] iADDR;
input [31:0] W_DATA;

output W_EN2SOMA, W_EN2Synapse, W_EN2STDP;
output R_EN2Synapse, R_EN2SOMA, R_EN2STDP;

output wire [6:0] to_Synapse_Addr;
//output wire[13:0] to_Synapse_Addr;
//output reg [15:0] to_SOMA_Addr;
output wire [6:0] to_STDP_Addr;

output wire [31:0] to_Synapse_DATA;
output wire [31:0] to_SOMA_DATA;
output wire [31:0] to_STDP_DATA;

input SWU_EN;
input wire [6:0] SWU_Addr;
input wire [7:0] SWU_DATA;

reg syn_switch = 0;

//fired #N -> Synapse module의 memory 주소 형태로 변경
reg [6:0] _iADDR; //7bit 가능?
reg [7:0] decoded_Addr; 

wire rdy;
wire CD_inData, CD_outData;

Addr_Decoder SAE(
    .Addr(_iADDR),
    .outAddr(decoded_Addr)
);

Clk_Delayer CD(
    .clk(clk),
    .ready(rdy),
    .indata(CD_inData),
    .outdata(CD_outData)
)


//ADDR decoding (latch 합성 피하기 위해서 주소와 데이터 구문을 분리?)
always @(posedge clk or negedge rst) begin
    if (iADDR[15] == 1) begin   // Param Initializing
        case (iADDR[13:12])
            2'b01:  // to Synapse 
            begin
                if (SWU_EN == 1'b0) begin   //from AXI
                    W_EN2Synapse <= 1'b1;
                    W_EN2SOMA <= 1'b0;
                    W_EN2STDP <= 1'b0;
                    R_EN2Synapse <= 1'b0;
                    R_EN2SOMA <= 1'b0;
                    R_EN2STDP <= 1'b0;

                    to_Synapse_Addr <= iADDR[6:0];
                    to_STDP_Addr <= 7'b0;

                    to_Synapse_DATA <= W_DATA;
                    to_SOMA_DATA <= 7'b0;
                    to_STDP_DATA <= 7'b0;
                end
                else begin  // from STDP Update
                    W_EN2Synapse <= 1'b1;
                    W_EN2SOMA <= 1'b0;
                    W_EN2STDP <= 1'b0;
                    R_EN2Synapse <= 1'b0;
                    R_EN2SOMA <= 1'b0;
                    R_EN2STDP <= 1'b0;

                    to_Synapse_Addr <= SWU_Addr;
                    to_STDP_Addr <= 7'b0;

                    to_Synapse_DATA <= {24'b0, SWU_DATA[7:0]};
                    to_SOMA_DATA <= 7'b0;
                    to_STDP_DATA <= 7'b0;
                end

            end
            
            2'b10:  // to SOMA
            begin
                W_EN2Synapse <= 1'b0;
                W_EN2SOMA <= 1'b1;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b0;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= 7'b0;
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= 7'b0;
                to_SOMA_DATA <= W_DATA;
                to_STDP_DATA <= 7'b0;
            end
            
            2'b11:  // to STDP
            begin
                W_EN2Synapse <= 1'b0;
                W_EN2SOMA <= 1'b0;
                W_EN2STDP <= 1'b1;
                R_EN2Synapse <= 1'b0;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= 7'b0;
                to_STDP_Addr <= iADDR[6:0];

                to_Synapse_DATA <= 7'b0;
                to_SOMA_DATA <= W_DATA;
                to_STDP_DATA <= 7'b0;
            end

            default:    //TODO: role of default? => rich Club
            begin
                W_EN2Synapse <= 1'b1;
                W_EN2SOMA <= 1'b0;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b1;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= iADDR[6:0];
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= W_DATA;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;
            end
        endcase
        end 
    else begin  //Spike Initializing
        if (iADDR[14] == 1) begin   // Rich Club => must 1 addr
            W_EN2Synapse <= 1'b0;
            W_EN2SOMA <= 1'b0;
            W_EN2STDP <= 1'b0;
            R_EN2Synapse <= 1'b1;
            R_EN2SOMA <= 1'b0;
            R_EN2STDP <= 1'b0;

            to_Synapse_Addr <= iADDR[6:0];
            to_STDP_Addr <= 7'b0;

            to_Synapse_DATA <= W_DATA;
            to_SOMA_DATA <= 7'b0;
            to_STDP_DATA <= 7'b0;
        end
        else begin                  // not Rich Club => must two addr, if #Neuron is 0, not valid addr
            if (iADDR[13:7] == 7'b0) begin      // only one neuron
                W_EN2Synapse <= 1'b0;
                W_EN2SOMA <= 1'b0;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b1;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= iADDR[6:0];
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= W_DATA;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;
            end
            else begin                      // two neurons
                W_EN2Synapse <= 1'b0;
                W_EN2SOMA <= 1'b0;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b1;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= iADDR[6:0];
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= W_DATA;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;
            end
        end
    end

    
        
end


endmodule
module Clk_Delayer(
    .clk,
    .ready,
    .indata,
    .outdata
);

input clk;
input ready;

input [13:0] indata;
input [6:0] outdata;

reg[13:0] q;

always @(posedge clk) begin
    q <= indata;
    q[13:7] <= q[6:0];
    
end

assign outdata = q[6:0];

endmodule


module Addr_Decoder(
    Addr,
    outAddr
);

input [6:0] Addr;
output [6:0] outAddr;

reg base;
reg remains;

assign base = Addr / 4; //TODO: int wrap? or bit cal.?
assign remains = Addr % 4;

assign outAddr = base + remains; //concat?


endmodule