	// soma module in physical neuron

	module soma (
		input clk,
		input rst,
		input kill,
		input en,
		input [31:0] W_DATA, //from PN controller
		input [15:0] weight, //from synapse
		output o_wait,
		output reg [15:0] spike_out

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
	reg[15:0] _V_potential;
	reg[15:0] _dummy;			//TODO: change w/ fixed point library
	wire _is_REF; //TODO:
	integer tau = 10;


	// FSM STATE PARAM
	reg[1:0] state_reg;

	parameter DEACTIVE = 2'b00;
	parameter ACTIVE = 2'b01;
	parameter REFRATORY = 2'b11;
	parameter _E = 2;


	check_isREF CIR (
		._V_potential(_V_potential),
		._spike_interval(_spike_interval),
		._axon_delay(_axon_delay),
		._V_th(_V_th),
		.spike_out(spike_out),
		._is_REF(_is_REF)
	);

	confirm_isREF COIR (
		._spikeDelaySum_int(_spikeDelaySum[15:8]),
		._refr_time(_refr_time),
		._is_REF(_is_REF)		
	);
	
	// Neural Type Initializing using FSM
	always @(posedge clk or negedge rst) begin
		
		if (!rst) begin
			state_reg <= DEACTIVE;
		end

		else if(kill == 1'b1) begin
			state_reg <= DEACTIVE;
		end

		else begin
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
			if(!_is_REF) begin
				_V_potential <= _V_potential * (1-_E**(_spike_interval/tau)) + weight; //TODO: LIF, e quatization sub
				_dummy <= 0;
			end

			else begin
				_V_potential <= 0;
				_dummy <= weight;
				_dummy <= _spike_interval;
			end
		end
		
		else if (state_reg == REFRATORY) begin
			if (!_is_REF) begin
				_spikeDelaySum <= 0;
			end

			else begin
				_spikeDelaySum <= _spikeDelaySum + _spike_interval;
			end

		end

		else begin
			_V_th <= _V_th;
			_V_leak <= _V_leak;
			_refr_time <= _refr_time;
			_axon_delay <= _axon_delay;
			_V_potential <= _V_potential;
			_spikeDelaySum <= _spikeDelaySum;
		end
	end
	end

	assign o_wait = _wait;

	endmodule





///////////////////////////////
///////////////////////////////

	module check_isREF (
		input [15:0] _V_potential,
		input [15:0] _spike_interval,
		input [15:0] _axon_delay,
		input [7:0] _V_th,
		output reg [15:0] spike_out,
		output reg _is_REF
	);


	always @(_V_potential) begin
		if (_V_potential >= _V_th) begin
			_is_REF <= 1'b1;
			spike_out <= _spike_interval + _axon_delay; //fire spike
			_spikeDelaySum <= 0;
			end
		else begin
			_is_REF <= 1'b0;
			spike_out <= 0;
		end
	end
	
	endmodule


	module confirm_isREF (
		input [7:0] _spikeDelaySum_int;
		input [7:0] _refr_time;
		output reg _is_REF
	);
		always @(_spikeDelaySum_int) begin
			if (_spikeDelaySum_int >= _refr_time) begin
				_is_REF <= 1'b0;
			end
			else begin
				_is_REF <= 1'b1;
			end
				//_wait <= 1'b1;		//TODO: grammar check needed
		end
	endmodule