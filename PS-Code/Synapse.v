// TODO: timing analysis whether input should be sliced in decoder or in the synapse module!
// TODO: register 유지에 대한 고민..!
module synapse( clk, rst, kill,
                iADDR, W_DATA,
                W_EN, R_EN,
                _weight_out
                        );


 // synapse Inputs Declaration 

input clk, rst, kill;
input [15:0] iADDR; //줄일 수도 있음
input [31:0] W_DATA; 
input W_EN, R_EN;

output reg [7:0] _weight_out;

reg [15:0] _iADDR;
//reg [31:0] _W_DATA;
reg [6:0] _iAddr;
reg [31:0] _Weight_table [0:31]; //memory
reg _count = 0;
//reg [7:0] __weight_out;
reg [4:0] _base; //TODO: int wrap;
reg [1:0]_remains;


always @(posedge clk or negedge rst) begin 

	if (!rst) begin // init : #table 저장
        if (W_EN == 1'b1) begin
        _Weight_table[_count] <= W_DATA;
        _count <= _count + 1;
        end

        else begin
            _count <= 0;
        end
	end

    // else if (kill == 1'b1) begin //table data 뺴라
    //     _count <= 0;
    // end


    //synapse on
    else begin
        //Address decoding
        _base <= _iAddr / 4;
        _remains <= _iAddr % 4;

        if(R_EN == 1'b1 && W_EN ==1'b0 ) begin
            //_Weight_table <= _Weight_table;
            //Read
            if (_remains ==2'b00)begin
            _weight_out <= _Weight_table[_base][7:0]; //TODO: 접근방법
            end

            else if(_remains ==2'b01)begin
            _weight_out <= _Weight_table[_base][15:8]; //TODO: 접근방법
            end

            else if(_remains ==2'b10)begin
            _weight_out <= _Weight_table[_base][23:16]; //TODO: 접근방법
            end
            
            else begin
            _weight_out <= _Weight_table[_base][31:24]; //TODO: 접근방법
            end
        end


        //STDP writing
        else if(R_EN == 1'b0 && W_EN ==1'b1 ) begin
            
            // _W_DATA slicing needed into 1B like below...
            if (_remains ==2'b00)begin
            _Weight_table[_base][7:0] <= W_DATA[7:0]; //TODO: 접근방법
            end

            else if(_remains ==2'b01)begin
            _Weight_table[_base][15:8] <= W_DATA[7:0]; //TODO: 접근방법
            end

            else if(_remains ==2'b10)begin
           _Weight_table[_base][23:16] <= W_DATA[7:0]; //TODO: 접근방법
            end
            
            else begin
            _Weight_table[_base][31:24] <= W_DATA[7:0]; //TODO: 접근방법
            end
            
        end

        else begin
            _weight_out <= _weight_out; // or _weight_out <= 0;
        end


    end


// assign _weight_out = __weight_out;

end

endmodule
