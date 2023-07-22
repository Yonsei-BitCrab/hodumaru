module synapse(clk, rst, kill,
               weight,
               Neuron_number,


                        );


 // synapse Inputs Declaration

input wire [7:0] weight; //TODO:
input clk, rst, kill;
input [6:0] Neuron_number;
input [15:0][127:0] hash_table_input;

reg _weight_number;
reg [16:0] _hash_table;


always @(AXI_weight) begin
    
end


always @(posedge clk or negedge rst) begin 
	if (!rst) begin // init : #table 저장
		_weight# <= 

        
	end


    else if(axi) begin //#참고 -> Neuron 보내기

    //if input_Neuron_Number && Hash_table[15:9];
    _out_weight <= Hast_table[8:0];
    end

    

    else if(STDP) begin
    //input_Neuron_Number == Hash_table[15:9];
    Hast_table[8:0] <= weight;    

    end

assign out_weight = _out_weight;

end


endmodule





