// TODO: timing analysis whether input should be sliced in decoder or in the synapse module!
module synapse( clk, rst, kill,
                iADDR, W_DATA,
                W_EN, R_EN,
                weight_out
                        );


 // synapse Inputs Declaration 

input clk, rst, kill;
input [15:0] iADDR;
input [31:0] W_DATA; 
input W_EN, R_EN;

output reg [7:0] weight_out;

reg [15:0] _iADDR;
reg [31:0] _W_DATA;
reg [7:0] _iAddr;
reg [31:0] _Weight_table [0:31] ; //memory
reg _count = 0;
//reg [7:0] _weight_out;
reg [4:0] _base; //TODO: int wrap;
reg [1:0]_remains;



always @(posedge clk or negedge rst) begin 
	if (!rst) begin // init : #table 저장
        if (W_EN == 1'b1) begin
		_count <= _count + 1;
        _Weight_table[_count] <= _W_DATA;
        end

        else begin
            _count <= 0;
        end
	end

    // else if (kill == 1'b1) begin //table data 뺴라
    //     _count <= 0;
    // end


    else begin

        if(R_EN == 1'b1 && W_EN ==1'b0 ) begin //#참고 -> Neuron 보내기
            //Address decoding
            _base <= _iAddr / 4;
            _remains <= _iAddr % 4;

            //Read
            if (_remains ==2'b00)begin
            weight_out <= _Weight_table[_base][7:0]; //TODO: 접근방법
            end

            else if(_remains ==2'b01)begin
            weight_out <= _Weight_table[_base][15:8]; //TODO: 접근방법
            end

            else if(_remains ==2'b10)begin
            weight_out <= _Weight_table[_base][23:16]; //TODO: 접근방법
            end
            
            else begin
            weight_out <= _Weight_table[_base][31:24]; //TODO: 접근방법
            end
        end


        
        // else if(R_EN == 1'b0 && W_EN ==1'b1 ) begin //STDP writing
        //     //input_Neuron_Number == Hash_table[15:9];
        //     Weight_table[8:0] <= weight;    
        // end

        else begin
        end


    end

// assign weight_out = _weight_out;

end

endmodule
