	// soma module in physical neuron

	module soma (
		input clk,
		input rst,
		input kill,
		input en,
		input [31:0] W_DATA, //from PN controller
		input [15:0] weight, //from synapse
		output o_wait,
		output reg [15:0] spike_out,

	);
	
	// Neuron Inputs Declaration

	reg _wait;
	
	// Spike Time

	integer _spikeDelaySum;

	
	// Neuron Constants
	reg[7:0] _V_th;
	reg[7:0] _V_leak;
	reg[7:0] _refr_time;
	reg[15:0] _axon_delay = 0;
	reg[15:0] _spike_interval;
	reg[15:0] _V_potential;			//TODO: change w/ fixed point library
	reg _is_REF;
	integer tau = 10;


	// FSM STATE PARAM
	reg[1:0] state_reg;

	parameter DEACTIVE = 2'b00;
	parameter ACTIVE = 2'b01;
	parameter REFRATORY = 2'b11;
	parameter _E = 2;


	// Neural Type Initializing using FSM
	always @(posedge clk or negedge rst) begin
		
		if (!rst) begin
			state_reg <= DEACTIVE;
		end

		else if(kill == 1'b1) begin
			state_reg <= DEACTIVE;
		end

		else begin
//			state_reg <= state_reg;
			case (state_reg)
				DEACTIVE:
					if(en) begin
						state_reg <= ACTIVE;
					end

					else begin
						state_reg <= state_reg;
					end
				
				ACTIVE:
					if(!en) begin
						state_reg <= DEACTIVE;
					end

					else begin
						if (_is_REF == 1'b1) begin
							state_reg <= REFRATORY;
						end
						else begin
							state_reg <= state_reg;
						end    
					end
				
				REFRATORY:
					if (_is_REF == 1'b0) begin
						state_reg <= ACTIVE;
					end
					else begin
						state_reg <= state_reg;
					end
					
				default:
					state_reg <= state_reg; 
			endcase
		end
	end

	always @(posedge clk) begin
		_spike_interval <= W_DATA[15:0];
	end


	// Neuron Dynamics
	always @(posedge clk or negedge rst) begin 
		if (!rst) begin
			_V_th <= W_DATA[31:24];
			_V_leak <= W_DATA[23:16];
			_refr_time <= W_DATA[15:8];
			_axon_delay[15:8] <= W_DATA[7:0];
			
			_V_potential <= 0;
			_spikeDelaySum <= 0;
		end

		else begin

		if (state_reg == ACTIVE) begin
			//_V_potential <= _V_potential + weight - in_spike *_V_leak; // TODO: (LLIF equation)

			//_V_potential <= _V_potential + del_t / time_constant ( _V_rest - _V_potential + weight )
			// _V_potential <= _V_potential * (1-e**(_spike_interval/tau)) + weight; //TODO: LIF, e quatization sub
			_V_potential <= _V_potential * (1-_E**(_spike_interval/tau)) + weight; //TODO: LIF, e quatization sub

			if (_V_potential >= _V_th) begin //fire out_spike
				_V_potential <= 0;
				spike_out <= _spike_interval + _axon_delay; //fire spike
				_is_REF <= 1'b1;
			end

			else begin
			_V_potential <= _V_potential;
			_V_th <= _V_th;
			_refr_time <= _refr_time;
			_axon_delay <= _axon_delay;
			_V_leak <= _V_leak;
			end
			

		end
		
		else if (state_reg == REFRATORY) begin
			_spikeDelaySum <= _spikeDelaySum + _spike_interval;
			if (_spikeDelaySum >= _refr_time) begin
				_spikeDelaySum <= 0;
				_is_REF <= 1'b0;
				_wait <= 1'b1;		//TODO: grammar check needed
			end
			
			else begin
				_is_REF <= 1'b1;
				_wait <= 1'b0;
				_V_potential <= _V_potential;
				_V_th <= _V_th;
				_refr_time <= _refr_time;
				_axon_delay <= _axon_delay;
				_V_leak <= _V_leak;
			end

		end

		else begin
			_wait <= 1'b0;
			_is_REF <= 1'b0;
			_spikeDelaySum <= 0;

			_V_potential <= _V_potential;
			_V_th <= _V_th;
			_refr_time <= _refr_time;
			_axon_delay <= _axon_delay;
			_V_leak <= _V_leak;
		end
	end
	end
	
	assign o_wait = _wait;

	endmodule