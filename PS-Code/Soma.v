	// soma module in physical neuron

	module soma (
		input clk,
		input rst,
		input kill,
		input en,
		input [31:0] W_DATA, //from PN controller
		input [15:0] weight, //from synapse
		output o_wait,
		output out_spike,

	);
	
	// Neuron Inputs Declaration

	reg _wait;
	
	// Spike Time
	integer _spike;
	integer _spikeDelaySum;

	
	// Neuron Constants
	reg[7:0] _V_th;
	reg[7:0] _refr_time;
	reg[7:0] _axon_delay;
	reg[7:0] _V_leak;
	
	reg[15:0] _spike_interval;

	integer _V_potential;			//TODO: change w/ fixed point library
	integer tau = 10;


	reg _is_REF;

	// FSM STATE PARAM
	reg[1:0] state_reg, next_state_reg;

	parameter DEACTIVE = 2'b00;
	parameter ACTIVE = 2'b01;
	parameter REFRATORY = 2'b11;

	parameter _E = 2;


	// Neural Type Initializing using FSM
	always @(posedge clk or negedge rst) begin
		
		if (!rst) begin
			next_state_reg <= DEACTIVE;
		end

		else if(kill == 1'b1) begin
			next_state_reg <= DEACTIVE;
		end

		else begin
			state_reg <= next_state_reg;
			case (state_reg)
				DEACTIVE:
					if(!en) begin
						next_state_reg <= ACTIVE;
					end

					else begin
						next_state_reg <= next_state_reg;
					end
				// 여기까지..
				ACTIVE:
					if(!en) begin
						next_state_reg <= DEACTIVE;
					end

					else begin
						if (_is_REF == 1'b1) begin
							next_state_reg <= REFRATORY;
						end
						else begin
							next_state_reg <= next_state_reg;
						end    
					end

				
				REFRATORY:
					if (_is_REF == 1'b0) begin
						next_state_reg <= ACTIVE;
					end
					else begin
						next_state_reg <= next_state_reg;
					end
					
				default:
					next_state_reg <= next_state_reg; 
			endcase
		end
	end

	always @(posedge clk) begin
		_spike_interval <= W_DATA[15:0];
	end


	// Neuron Dynamics
	always @(posedge clk or negedge rst) begin 
		if (!rst) begin
			_V_th <= W_DATA[:];
			_refr_time <= W_DATA[:];
			_axon_delay <= W_DATA[:];
			_V_leak <= W_DATA[:];
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
				_spike <= in_spike + _axon_delay;
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
			_spikeDelaySum <= _spikeDelaySum + in_spike;
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
	assign output_spike = _spike;

	endmodule