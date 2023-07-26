module ADDR_decoder(clk, rst,
                    iADDR, W_DATA,
                    W_EN2Synapse, W_EN2SOMA, W_EN2STDP,
                    R_EN2Synapse, R_EN2SOMA, R_EN2STDP,
                    to_Synapse_Addr, to_STDP_Addr,
                    to_Synapse_DATA, to_SOMA_DATA, to_STDP_DATA


);


input clk, rst;
input [15:0] iADDR;
input [31:0] W_DATA;

output W_EN2SOMA, W_EN2Synapse, W_EN2STDP;
output R_EN2Synapse, R_EN2SOMA, R_EN2STDP;

output wire [6:0] to_Synapse_Addr;
//output reg [15:0] to_SOMA_Addr;
output wire [6:0] to_STDP_Addr;

output wire [31:0] to_Synapse_DATA;
output wire [31:0] to_SOMA_DATA;
output wire [31:0] to_STDP_DATA;

reg syn_switch = 0;

//fired #N -> Synapse module의 memory 주소 형태로 변경
reg [6:0] _iADDR; //7bit 가능?
reg [7:0] encoded_syn_Addr; 

Syn_Addr_encoder SAE(
    .Addr(_iADDR),
    .outAddr(encoded_syn_Addr)
);


//ADDR decoding (latch 합성 피하기 위해서 주소와 데이터 구문을 분리?)
always @(posedge clk or negedge rst) begin
    if (iADDR[15] == 1) begin   // Param Initializing
        case (iADDR[14:13])
            2'b01:  // to Synapse 
            begin
                W_EN2Synapse <= 1'b1;
                W_EN2SOMA <= 1'b0;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b0;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= encoded_syn_Addr;
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= W_DATA;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;

            end
            
            2'b10:  // to SOMA
            begin
                to_SOMA_DATA <= W_DATA;

                W_EN2Synapse <= 1'b0;
                W_EN2SOMA <= 1'b1;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b0;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= encoded_syn_Addr;
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= W_DATA;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;
            end
            
            2'b11:  // to STDP
            begin
                
            end

            default:    //TODO: role of default?
            begin
                W_EN2Synapse <= 1'b0;
                W_EN2SOMA <= 1'b0;
                W_EN2STDP <= 1'b0;
                R_EN2Synapse <= 1'b0;
                R_EN2SOMA <= 1'b0;
                R_EN2STDP <= 1'b0;

                to_Synapse_Addr <= 7'b0;
                to_STDP_Addr <= 7'b0;

                to_Synapse_DATA <= 7'b0;
                to_SOMA_DATA <= 7'b0;
                to_STDP_DATA <= 7'b0;
            end
        endcase
        end 
    else begin  //Spike Initializing
        
    end

    //init
    if (!rst && iADDR[15] == 1) begin //condition?
        
        if ( iADDR[14:13] == 2'b00 ) begin
        end

        //synapse
        else if ( iADDR[14:13] == 2'b01 ) begin
            to_Synapse_Addr <= encoded_syn_Addr;
            to_Synapse_DATA <= W_DATA; //W_DATA : weight 32'b
        end

        //SOMA
        else if ( iADDR[14:13] == 2'b10 ) begin
            to_SOMA_DATA <= W_DATA;


        end

        //STDP
        else if ( iADDR[14:13] == 2'b11 ) begin
            to_STDP_Addr <=; //TODO:
            to_STDP_DATA <= W_DATA;
        end


    end

    //When PN is active
    else begin

        //spike
        if (iADDR[15] = 0) begin
            
            //not rich club -> can get two address 
            //TODO: iADDR rich club 판단을 iADDR[14]로 했으면 좋겠음 & syn,soma,STDP 주소는 iADDR[13:12]로 변경
            if (iADDR[12] == 0) begin

                if (syn_switch == 0) begin
                    _iADDR <= iADDR[14:13] + iADDR[11:7] //concat?
                    syn_switch <= 1;
                end

                else () begin
                    _iADDR <= iADDR[6:0];
                    syn_switch <= 0; 
                end

            end


            //rich club
            else begin
            end


        end


        //param
        else begin
        
        
        
        end




    end
        
end


endmodule



module Syn_Addr_encoder(
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