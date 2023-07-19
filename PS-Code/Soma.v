// soma module in physical neuron

module soma (	clk, rst, kill,
				vrest, vth, vlk, r_time, a_delay, 
				weight,
			 	in_spike, 
				suspend,
				out_spike);
  
// Neuron Inputs Declaration
input wire weight, clk, in_spike;

// Neuron parameter data to be Initialized
input wire [7:0] vrest;
input wire [7:0] vth;
input wire [7:0] vlk;
input wire [7:0] r_time;
input wire [7:0] a_delay;
//Neuron Outputs Declaration

wire w_suspend;
output suspend;
output out_spike;

// Spike Time
reg[7:0] _spike;
reg[7:0] _spike2Accumulate;

  
// Neuron Constants
reg[7:0] _vrest;
reg[7:0] _vth;
reg[7:0] _r_time;
reg[7:0] _a_delay;
reg[7:0] _vlk;
reg[] _V_potential;


reg _is_REF;

// FSM STATE PARAM
reg[1:0] state_reg, next_state_reg;

parameter DEACTIVE = 2'b00;
parameter ACTIVE = 2'b01;
parameter REFRATORY = 2'b10;

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
				if (!_is_REF) begin
					next_state_reg <= ACTIVE;
				end
				else begin
					next_state_reg <= next_state_reg;
				end
		endcase
	end
end



// Neuron Dynamics
always @(posedge clk or negedge rst) begin 
	if (!rst) begin
		_vrest <= vrest;
		_vth <= vth;
		_r_time <= r_time;
		_a_delay <= a_delay;
		_vlk <= vlk;
	end

	if (state_reg == ACTIVE) begin
		_V_potential = _V_potential + weight - _vlk; // TODO: (LIF equation)  //TODO: int() wrap!

		if (_V_potential >= _vth) begin //fire out_spike
			_V_potential = _vrest;
			_spike = in_spike + _a_delay;
			_is_REF = 1'b0;
			
		end

		if (_V_potential < _vrest) begin //return to V_rest
			~~~; //TODO:
		end

	end
    
	else if (state_reg == REFRATORY) begin
		_spike2Accumulate = _spike2Accumulate + in_spike;	//TODO: int() wrap!
		if (_spike2Accumulate > _r_time) begin
			_is_REF = 1'b0;
			w_suspend <= 1'b1;		//TODO: grammar check needed
		end

		_is_REF <= 1'b0;
	begin

	end
end
assign suspend = w_suspend;
assign output_spike = _spike;

endmodule