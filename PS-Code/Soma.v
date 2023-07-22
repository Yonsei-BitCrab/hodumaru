// soma module in physical neuron

module soma (	clk, rst, kill,
				V_rest, V_th, V_leak, refr_time, axon_delay, 
				weight,
			 	in_spike, 
				o_wait,
				out_spike);
  
// Neuron Inputs Declaration
input wire clk;
input wire [7:0] in_spike; //in
input wire [7:0] weight; //TODO:
input rst, kill;

// Neuron parameter data to be Initialized
input wire [7:0] V_rest;
input wire [7:0] V_th;
input wire [7:0] V_leak;
input wire [7:0] refr_time;
input wire [7:0] axon_delay;

//Neuron Outputs Declaration

reg _wait;
output o_wait;
output out_spike;

// Spike Time
integer _spike;
integer _spikeDelaySum;

  
// Neuron Constants
reg[7:0] _V_rest;
reg[7:0] _V_th;
reg[7:0] _refr_time;
reg[7:0] _axon_delay;
reg[7:0] _V_leak;
integer _V_potential;			//TODO: change w/ fixed point library
integer tau;


reg _is_REF;

// FSM STATE PARAM
reg[1:0] state_reg, next_state_reg;

parameter DEACTIVE = 2'b00;
parameter ACTIVE = 2'b01;
parameter REFRATORY = 2'b11;

// Neural Type Initializing using FSM
always @(posedge clk or negedge rst) begin
    
	if (!rst) begin   			// initialize
		next_state_reg <= ACTIVE;
	end

	else begin   			// FSM
		state_reg <= next_state_reg;
		case (state_reg)
			DEACTIVE:
				next_state_reg <= next_state_reg;
			
			ACTIVE:
				if (kill == 1'b1) begin
					next_state_reg <= DEACTIVE; 
				end
				else if (_is_REF == 1'b1) begin
					next_state_reg <= REFRATORY;
				end
				else begin
					next_state_reg <= next_state_reg;
				end    
			
			REFRATORY:
				if (kill == 1'b1) begin
					next_state_reg <= DEACTIVE;
				end
				else if (_is_REF == 1'b0) begin
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



// Neuron Dynamics
always @(posedge clk or negedge rst) begin 
	if (!rst) begin
		//_V_rest <= V_rest;
		_V_potential <= V_rest;
		_V_th <= V_th;
		_refr_time <= refr_time;
		_axon_delay <= axon_delay;
		_V_leak <= V_leak;
	end

	else if (state_reg == ACTIVE) begin
		//_V_potential <= _V_potential + weight - in_spike *_V_leak; // TODO: (LLIF equation)

		//_V_potential <= _V_potential + del_t / time_constant ( _V_rest - _V_potential + weight )
		_V_potential <= _V_potential * (1-e**(in_spike/tau)) + weight; //TODO: LIF, e quatization sub


		if (_V_potential >= _V_th) begin //fire out_spike
			_V_potential <= _V_rest;
			_spike <= in_spike + _axon_delay;
			_is_REF <= 1'b1;
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
		end

	end

	else begin
		_wait <= 1'b0;
		_is_REF <= 1'b0;
		_spikeDelaySum <= 0;
	end
end

assign o_wait = _wait;
assign output_spike = _spike;

endmodule