// STDP module in physical neuron

module STDP (	clk, rst, kill,
			 	pre_spike, post_spike, weight, neuron_number,
				STDP_interval,
                o_wait,
                updated_weight
				);
  
// STDP Inputs Declaration
input wire clk, rst, kill;
input wire [7:0] pre_spike;
input wire [7:0] post_spike; 
input wire [7:0] weight;
input wire [6:0] neuron_number;



// STDP param data to be Initialized
input wire STDP_interval;



//STDP Outputs Declaration

output o_wait;
output updated_weight;


// reg
reg [8:0] _pre_spike [0:2];
reg [8:0] _post_spike [0:2];
reg _weight;
reg _wait;
// reg [15:0] _tagged_spike;

reg _STDP_interval = STDP_interval;
reg _delta;                 //time difference
reg _delta_weight;          //weight difference
//reg pre_count = 0;
//reg post_count = 0;



//tagging
// assign _tagged_spike [15:8] = neruon_number 
// assign _tagged_spike [7:0] = pre_spike


// STDP
always @(posedge clk or negedge rst) begin 
	if (!rst) begin
		
	end


    if (kill == 1'b0) begin
        _STDP_interval <= 0;
        //if STDP graph adaption -> pull out data function 
    end


	else begin
        if (W_EN == 1'b1 && R_EN == 1'b0 ) begin  //write
            _post_spike[] <= post_spike;
            //pre, post reg에 맞게 3개씩 저장, 3개 이후에는 pop out되도록

        end

        else if(W_EN == 1'b0 && R_EN == 1'b1) begin //read
            //difference 계산하고 LUT로 보냄
            post_readout <= _post_spike[];
            pre_readout <= _re_spike[];

            _delta <= post_readout - pre_readout;

            //LUT 보내기?
            _delta_weight <= STDP_LUT[_delta];
            _updated_weight <= _delta_weight + weight;
        end


	end
end

assign o_wait = _wait;
assign updated_weight = _updated_weight;



endmodule






//LUT

module STDP_LUT (
    delta,
    delta_weight
);

input wire delta;

output delta_weight;

if ( <= delta_weight && delta_weight <=) begin
    delta_weight <= ~~              //quantization
end
else if ( <= delta_weight && delta_weight <=) begin
    delta_weight <= ~~
end

else if ( <= delta_weight && delta_weight <=) begin
    delta_weight <= ~~
end

else if ( <= delta_weight && delta_weight <=) begin
    delta_weight <= ~~
end

else if ( <= delta_weight && delta_weight <=) begin
    delta_weight <= ~~
end

else if ( <= delta_weight && delta_weight <= ) begin
    delta_weight <= ~~
end

else begin
    delta_weight <= ~~
end



endmodule