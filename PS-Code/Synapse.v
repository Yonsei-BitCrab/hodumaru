
module synapse( clk, rst, kill,
                weight,
                neuron_number,
                W_EN, R_EN,
                out_weight
                        );


 // synapse Inputs Declaration 

input [7:0] weight; //TODO:
input clk, rst, kill;
input [7:0] neuron_number;
input W_EN, R_EN;

output out_weight;

reg _neuron_number;
reg _weight;
reg _out_weight;
reg [16:0] _hash_table;



always @(posedge clk or negedge rst) begin 
	if (!rst) begin // init : #table 저장
		
	end

    else if (kill == 1'b1) begin //table data 뺴라
    
    end


    else begin

        if(R_EN == 1'b1 && W_EN ==1'b0 ) begin //#참고 -> Neuron 보내기

            //if input_Neuron_Number && Hash_table[15:9];
            _out_weight <= hast_table(_neuron_number); //TODO:
        end

        else if(R_EN == 1'b0 && W_EN ==1'b1 ) begin //STDP writing
            //input_Neuron_Number == Hash_table[15:9];
            Hast_table[8:0] <= weight;    
        end

    end

assign out_weight = _out_weight;

end

endmodule


// Table Module for Neuron Number

// module NeuronNumberTable();

// input [7:0] Neuron_number;
// output [] weight;

// always @(Neuron_number) begin
//     case(Neuron_number)
//         7'b0000000: 0;
//         7'b0000001: 0

//         ...
//         7'b1111111: 0;


// end