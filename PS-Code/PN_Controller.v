


module PN_Controller(clk, rst,
                    iADDR, W_DATA,
                    W_EN2Synapse, W_EN2SOMA, W_EN2STDP,
                    RC_EN2Synapse, R_EN2SOMA, R_EN2STDP,
                    to_Synapse_Addr, to_STDP_Addr,
                    to_Synapse_DATA, to_SOMA_DATA, to_STDP_DATA,
                    SWU_EN, SWU_Addr, SWU_DATA      // Synaptic Weight Update

);


input clk, rst;
input [15:0] iADDR;
input [31:0] W_DATA;

output reg W_EN2SOMA, W_EN2Synapse, W_EN2STDP;
output reg RC_EN2Synapse, R_EN2SOMA, R_EN2STDP;

wire _W_EN2SOMA, _W_EN2Synapse, _W_EN2STDP;
wire _RC_EN2Synapse, _R_EN2SOMA, _R_EN2STDP;

output reg [6:0] to_Synapse_Addr;
//output wire[13:0] to_Synapse_Addr;
//output reg [15:0] to_SOMA_Addr;
output reg [6:0] to_STDP_Addr;

output reg [31:0] to_Synapse_DATA;
output reg [31:0] to_SOMA_DATA;
output reg [31:0] to_STDP_DATA;

input SWU_EN;
input wire [6:0] SWU_Addr;
input wire [7:0] SWU_DATA;

//reg syn_switch = 0;

//fired #N -> Synapse module의 memory 주소 형태로 변경
reg [6:0] _iADDR; //7bit 가능?
reg [7:0] decoded_Addr; 

wire rdy;
wire CD_inData, CD_outData;
// module STACK_MACHINE( clk, rst,
// 								ctl, o_wait,
// 								DATA_in, DATA_out
//                                 // o_STACK_REG0, o_STACK_REG1, o_STACK_REG2
// );

wire stack_wait;
wire [1:0] STMC_ctl;
wire [15:0] STMC_DIN;
wire [15:0] STMC_DOUT;
STACK_MACHINE STMC (
    .clk(clk),
    .rst(rst),
    .ctl(STMC_ctl),
    .o_wait(stack_wait),
    .DATA_in(STMC_DIN),
    .DATA_out(STMC_DOUT)
);


//ADDR decoding (latch 합성 피하기 위해서 주소와 데이터 구문을 분리?)
always @(posedge clk) begin
    if (iADDR[14] == 1) begin   // Param Initializing
        case (iADDR[13:12])
            2'b01:  // to Synapse 
            begin
                if (SWU_EN == 1'b0) begin   //from AXI
                    W_EN2Synapse <= 1'b1;
                    W_EN2SOMA <= 1'b0;
                    W_EN2STDP <= 1'b0;
                    RC_EN2Synapse <= 1'b0;
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
                    RC_EN2Synapse <= 1'b0;
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
                RC_EN2Synapse <= 1'b0;
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
                RC_EN2Synapse <= 1'b0;
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
                RC_EN2Synapse <= 1'b1;
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
    else begin  //Spike 
        if (iADDR[14] == 1) begin   // Rich Club => must 1 addr
            W_EN2Synapse <= 1'b0;
            W_EN2SOMA <= 1'b0;
            W_EN2STDP <= 1'b0;
            RC_EN2Synapse <= 1'b1;
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
                RC_EN2Synapse <= 1'b0;
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
                RC_EN2Synapse <= 1'b0;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                //to_Synapse_Addr <= iADDR[6:0];
                // Using STACK MACHINE:         TODO: Optimize w/ STMC
                STMC_ctl <= 2'b11;
                STMC_DIN <= {{1'b0, iADDR[13:7]},{1'b0, iADDR[6:0]}};
                to_Synapse_Addr <= STMC_DOUT[6:0];

                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= W_DATA;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;
            end
        end
    end

    
        
end


//assign W_EN2SOMA = _W_EN2SOMA;
//assign W_EN2Synapse = _W_EN2Synapse;
//assign W_EN2STDP = _W_EN2STDP;
//assign RC_EN2Synapse = _RC_EN2Synapse;
//assign R_EN2SOMA = _R_EN2SOMA;
//assign R_EN2STDP = _R_EN2STDP;


endmodule
