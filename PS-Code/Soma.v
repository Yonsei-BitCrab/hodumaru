// soma module in physical neuron

module soma (
	input clk,
	input rst,
	input kill,
	input en,
	input [31:0] W_DATA, //from PN controller
	input [15:0] weight, //from synapse
	output reg [15:0] spike_out
);
	
	// Neuron Constants
	reg[7:0] _V_th;
	reg[7:0] tau;
	reg[7:0] _refr_time;
	reg[7:0] _axon_delay;
	reg[15:0] _spike_interval;
	reg[15:0] _V_potential;
	reg[15:0] _next_spike_reg;
	//reg[7:0] _spikeDelaySum;

	wire _is_REF;


	// FSM STATE PARAM
	// reg[1:0] state_reg;

	// parameter DEACTIVE = 2'b00;
	// parameter ACTIVE = 2'b01;
	// parameter REFRATORY = 2'b11;
	parameter _E = 2;

	// // Neural Type Initializing using FSM
	// always @(posedge clk) begin
		
	// 	if (rst) begin
	// 		state_reg <= DEACTIVE;
	// 	end

	// 	else if(kill == 1'b1) begin
	// 		state_reg <= DEACTIVE;
	// 	end

	// 	else begin
	// 		case (state_reg)
	// 			DEACTIVE:
	// 				if(en) begin
	// 					state_reg <= ACTIVE;
	// 				end

	// 				else begin
	// 					state_reg <= state_reg;
	// 				end
				
	// 			ACTIVE:
	// 				if(!en) begin
	// 					state_reg <= DEACTIVE;
	// 				end

	// 				else begin
	// 					if (_is_REF == 1'b1) begin
	// 						state_reg <= REFRATORY;
	// 					end
	// 					else begin
	// 						state_reg <= state_reg;
	// 					end    
	// 				end
				
	// 			REFRATORY:
	// 				if (_is_REF == 1'b0) begin
	// 					state_reg <= ACTIVE;
	// 				end
	// 				else begin
	// 					state_reg <= state_reg;
	// 				end
					
	// 			default:
	// 				state_reg <= state_reg; 
	// 		endcase
	// 	end
	// end

	//spike_reg
	always @(posedge clk) begin
		_next_spike_reg <= W_DATA[15:0]
		_spike_interval <= _next_spike_reg;
	end

	//combinatioal logic
	assign cal_spike = after_REF ? 0 : (1-_E**(_spike_interval/tau)); //after any one of three signals changes, this statement works
	assign attenuated_V_poten = _V_potential * cal_spike;
	assign depolarized_V_poten = attenuated_V_poten + weight;

	// Neuron reg dynamics
	always @(posedge clk) begin 
		if (rst) begin
			_V_th <= W_DATA[31:24];
			tau <= W_DATA[23:16];
			_refr_time <= W_DATA[15:8];
			_axon_delay <= W_DATA[7:0];
			
			_V_potential <= 0;
			_spikeDelaySum <= 0;
		end

		else begin

			if (state_reg == ACTIVE) begin
				_V_potential <= depolarized_V_poten;
			end
			
			else begin
				_V_th <= _V_th;
				tau <= tau;
				_refr_time <= _refr_time;
				_axon_delay <= _axon_delay;
				_V_potential <= _V_potential;
				_spikeDelaySum <= _spikeDelaySum;
			end
		end
	end

endmodule


/////////////////////////////////////////////////////////////////////////////////

module isREF_controller (
	input clk,
	input [15:0] depolarized_V_poten,
	input [15:0] _spike_interval,
	input [31:16] _W_DATA,
	output reg [15:0] spike_out,
	output reg _is_REF;
	output reg after_REF;
);

	reg [7:0] _V_th;
	reg [7:0] _axon_delay;

	always @(posedge clk) begin
		if (rst) begin
			_V_th <= _W_DATA[31:24];
			_axon_delay <= _W_DATA[23:16];
			_
		end

		else begin
			if (depolarized_V_poten >= _V_th) begin
				spike_out <= _spike_interval + _axon_delay;
				if(skip_REF) begin
					_is_REF <= 1'b0;
					after_REF <= 1'b1;
				end
				else begin
					_is_REF <= 1'b1;
					after_REF <= 1'b0;
				end
			end

			else begin
				spike_out <= 0;
				_is_REF <= 1'b0;
				after_REF <= 1'b0;
			end
		end
	end

endmodule


module spikeDelayUnit (
	input clk,
	input _is_REF,
	input [15:8] _W_DATA,
	output reg skip_REF,
	output reg _is_REF,
	output reg after_REF
);

	reg [7:0] _spikeDelaySum;
	reg [7:0] _refr_time

	//check next spike interval is larger than ref_time, if then pass REF. otherwise, set REF state.
	always @(posedge clk) begin
		if(rst) begin
			_refr_time <= _W_DATA;
			_spikeDelaySum <= 0;
		end

		else begin
			if (!_is_REF) begin
				if (_W_DATA >= _refr_time) begin
					skip_REF <= 1'b1;
					_spikeDelaySum <= 0;
				end
				else begin
					skip_REF <= 1'b0;
					_spikeDelaySum <= _W_DATA;
				end
			end
			else begin
				_spikeDelaySum <= _spikeDelaySum + _W_DATA;
				skip_REF <= skip_REF;
			end
		end
	end



	always @(_spikeDelaySum) begin
		if(_is_REF) begin
			if(_spikeDelaySum >= ref_time) begin
				_is_REF <= 1'b0;
				after_REF <= 1'b1;
			end
			else begin
				_is_REF <= 1'b1;
				after_REF <= 1'b0;
			end
		end

		else begin
		_is_REF <= _is_REF;
		after_REF <= after_REF;
		end
	end


endmodule