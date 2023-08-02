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
	reg[7:0] tau;
	reg[15:0] _next_spike_reg;
	reg[15:0] _spike_interval;

	wire skip_REF;
	wire is_REF;
	wire after_REF;
	wire [15:0] V_potential;
	wire [15:0] cal_spike;
	wire [15:0] depolarized_V_poten;

	parameter _E = 2;

	V_potential_reg VPreg (
		.clk(clk),
		.rst(rst),
		.en(en),
		.depolarized_V_poten(depolarized_V_poten),
		._V_potential(V_potential)
	);

	REF_control_unit RCU (
		.clk(clk),
		.depolarized_V_poten(depolarized_V_poten),
		._spike_interval(_spike_interval),
		._W_DATA(W_DATA[31:16]),
		.spike_out(spike_out),
		._is_REF(is_REF);
		.after_REF(after_REF);
	);

	spikeDelay_unit SDU (
		.clk(clk),
		._is_REF(is_REF),
		._W_DATA(W_DATA[15:8]),
		.skip_REF(skip_REF),
		._is_REF(is_REF),
		.after_REF(after_REF)
	);

	//spike_reg
	always @(posedge clk) begin
		if(rst) begin
			tau <= W_DATA[7:0];
			_next_spike_reg <= 0;
			_spike_interval <= 0;
		end

		else begin
			_next_spike_reg <= W_DATA[15:0]
			_spike_interval <= _next_spike_reg;
			tau <= tau;
		end
	end

	//combinatioal logic
	assign cal_spike = after_REF ? 0 : (1-_E**(_spike_interval/tau)); //after any one of three signals changes, this statement works
	assign depolarized_V_poten = V_potential * cal_spike + weight;

endmodule

////////////////////////////////////////////////////////////////////////////////

module V_potential_reg (
	input clk,
	input rst,
	input en,
	input [15:0] depolarized_V_poten,
	output reg [15:0] _V_potential
);

	always @(posedge clk) begin 
		if (rst) begin
			_V_potential <= 0;
		end

		else begin
			if (en) begin
				_V_potential <= depolarized_V_poten;
			end
			
			else begin
				_V_potential <= _V_potential;
			end
		end
	end

endmodule

/////////////////////////////////////////////////////////////////////////////////

module REF_control_unit (
	input clk,
	input [15:0] _depolarized_V_poten,
	input [15:0] _spike_interval,
	input [15:0] _W_DATA, //W_DATA[31:16]
	output reg [15:0] _spike_out,
	output reg _is_REF;
	output reg _after_REF;
);

	reg [7:0] _V_th;
	reg [7:0] _axon_delay;

	always @(posedge clk) begin
		if (rst) begin
			_V_th <= _W_DATA[15:8]; //W_DATA[31:24]
			_axon_delay <= _W_DATA[7:0]; //W_DATA[23:16]
		end

		else begin
			if (_depolarized_V_poten >= _V_th) begin
				_spike_out <= _spike_interval + _axon_delay;
				if(skip_REF) begin
					_is_REF <= 1'b0;
					_after_REF <= 1'b1;
				end
				else begin
					_is_REF <= 1'b1;
					_after_REF <= 1'b0;
				end
			end

			else begin
				_spike_out <= 0;
				_is_REF <= 1'b0;
				_after_REF <= 1'b0;
			end
		end
	end

endmodule

///////////////////////////////////////////////////////////////////////////////////

module spikeDelay_unit (
	input clk,
	input is_REF,
	input [15:8] _W_DATA,
	output reg _skip_REF,
	output reg _is_REF,
	output reg _after_REF
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
			if (!is_REF) begin
				if (_W_DATA >= _refr_time) begin
					_skip_REF <= 1'b1;
					_spikeDelaySum <= 0;
				end
				else begin
					_skip_REF <= 1'b0;
					_spikeDelaySum <= _W_DATA;
				end
			end
			else begin
				_spikeDelaySum <= _spikeDelaySum + _W_DATA;
				_skip_REF <= _skip_REF;
			end
		end
	end



	always @(_spikeDelaySum) begin
		if(is_REF) begin
			if(_spikeDelaySum >= ref_time) begin
				_is_REF <= 1'b0;
				_after_REF <= 1'b1;
			end
			else begin
				_is_REF <= 1'b1;
				_after_REF <= 1'b0;
			end
		end

		else begin
		_is_REF <= _is_REF;
		_after_REF <= _after_REF;
		end
	end


endmodule