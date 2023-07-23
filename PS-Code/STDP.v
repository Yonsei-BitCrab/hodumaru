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
input wire [7:0] neuron_number;



// STDP param data to be Initialized
input wire STDP_interval;



//STDP Outputs Declaration

output o_wait;
output updated_weight;


// reg
reg _pre_spike;
reg post_spike;
reg weight;
reg _wait;

reg _STDP_interval = STDP_interval;



// STDP
always @(posedge clk or negedge rst) begin 
	if (!rst) begin
		
	end

    if (kill == 1'b0) begin
        _STDP_interval <= 0;
        //if STDP graph adaption -> pull out data function 
    end

	else begin
        if (spike == pre) begin
            _pre_spike <= spike

        end

        else begin



        end


	end
end

assign o_wait = _wait;
assign output_spike = _spike;

endmodule