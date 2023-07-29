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

// TODO: tomorrow 16bit change with random generator
output reg [15:0] _weight_out;

reg [15:0] _iADDR;
//reg [31:0] _W_DATA;
reg [6:0] _iAddr;
reg [31:0] _Weight_table [0:31]; //memory
reg [7:0] _RC_table [];

reg _count = 0;
//reg [7:0] __weight_out;
reg [4:0] _base; //TODO: int wrap;
reg [1:0]_remains;


always @(posedge clk or negedge rst) begin 

	if (!rst) begin // init : #table 저장
        if (W_EN == 1'b1 && R_EN == 1'b0 ) begin
            _Weight_table[_count] <= W_DATA;
            _count <= _count + 1;
        end

        else if (W_EN == 1'b1 && R_EN == 1'b1 ) begin
            _RC_table[] <= W_DATA;
        end

        else begin
            _count <= _count; // or <= 0?
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

        end


        //STDP writing
        else if(R_EN == 1'b0 && W_EN ==1'b1 ) begin


        //Rich Club    
        else if (R_EN == 1'b1 && W_EN == 1'b1) begin
            
        end

        end

        else begin
            _weight_out <= _weight_out; // or _weight_out <= 0;
        end


    end


// assign _weight_out = __weight_out;

end

endmodule









////////////////////////////////////////////////////////////////////////////////////////////////////////

// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v

module simple_dual_one_clock (clk,ena,enb,wea,addra,addrb,dia,dob);

input clk,ena,enb,wea;
input [9:0] addra,addrb;
input [15:0] dia;
output [15:0] dob;
reg [15:0] ram [1023:0];
reg [15:0] doa,dob;

always @(posedge clk) begin
if (ena) begin
if (wea)
ram[addra] <= dia;
end
end

always @(posedge clk) begin
if (enb)
dob <= ram[addrb];
end

endmodule




// Block RAM with Resettable Data Output
// File: rams_sp_rf_rst.v
module rams_sp_rf_rst (clk, en, we, rst, addr, di, dout);
input clk;
input en;
input we;
input rst;
input [9:0] addr;
input [15:0] di;
output [15:0] dout;

reg [15:0] ram [1023:0];
reg [15:0] dout;

always @(RN, EN)
begin
if (en) //optional enable
begin
    if (we) //write enable
        ram[addr] <= di;
    if (rst) //optional reset
        dout <= 0;
else
dout <= ram[addr];
end
end

endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////

module syn_int_WE_ENCODER (
    input rst,
    input [1:0] remain,
    output reg [3:0] we = 4'b0000;
);

always @(remain) begin
    if (!rst) begin
        we = 4'b1111;
    end

    else begin
        case(remain)
            2'b00:
                we = 4'b0001;
                
            2'b01:
                we = 4'b0010;
                
            2'b10:
                we = 4'b0100;
                
            2'b11:
                we = 4'b1000;
                
            default:
                we = we;
        endcase
    end
end

endmodule




// Block RAM with Resettable Data Output
// File: rams_sp_rf_rst.v
module syn_int_BRAM (clk, re, we, rst, addr, RAM_in, RAM_out);
parameter NUM_COL = 4,
parameter COL_WIDTH = 8,
parameter ADDR_WIDTH = 5,
parameter DATA_WIDTH = NUM_COL*COL_WIDTH // Data Width in bits (4*8=32)

input re, clk;
input [NUM_COL-1:0] we; //4bit
input rst;
input [ADDR_WIDTH-1:0] addr; //5bit
input [DATA_WIDTH-1:0] RAM_in;
output reg [DATA_WIDTH-1:0] RAM_out;

(* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram_block [(2**ADDR_WIDTH)-1:0];

always @(toggle)
begin
    if(!re) begin
    for(i=0; i<4; i=i+1) begin
        if(we[i]) begin
            ram_block[addr][i*COL_WIDTH +: COL_WIDTH] <= RAM_in[i*COL_WIDTH +: COL_WIDTH]; //i*COL_WIDTH + -> i*COL_WIDTH를 시작으로, COL_WIDTH까지 선택
        end
        end
    end
    
    else begin
        RAM_out <= ram_block[addr];
    end
end

endmodule   



module syn_int_READSLICE(
    input rst,
    input [1:0] remain,
    input [31:0] RAM_out,
    output reg [7:0] dout
);

//slicing during reading
always @(RAM_out) begin
    if(rst)
        if (remain == 2'b00) begin
            dout <= RAM_out[7:0];
        end

        else if(remain == 2'b01) begin
            dout <= RAM_out[15:8];
        end

        else if(remain == 2'b10) begin
            dout <= RAM_out[23:16];
        end

        else if(remain == 2'b11) begin
            dout <= RAM_out[31:24];
        end

    else begin
        dout <= 0;
    end

end
endmodule





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

// TODO: tomorrow 16bit change with random generator
output reg [15:0] _weight_out;

reg [15:0] _iADDR;
//reg [31:0] _W_DATA;
reg [6:0] _iAddr;
reg [7:0] _RC_table [];
reg _count = 0;
//reg [7:0] __weight_out;
wire [4:0] _base; //TODO: int wrap;
wire [1:0] _remain;
reg [3:0] _we;
reg Rdi;
reg [31:0] _RAM_out;
reg [7:0] _weight_int;


//instantiation of submodule
syn_int_WE_ENCODER SIWE (
    .rst(rst),
    .remain(_remain),
    .we(_we)
);

syn_int_BRAM SIB (
    .re(R_EN), 
    .we(_we), 
    .rst(rst), 
    .addr(_base), 
    .RAM_in(W_DATA), 
    .RAM_out(_RAM_out)
);

syn_int_READSLICE SIRS(
    .rst(rst),
    .remain(_remain),
    .RAM_out(_RAM_out),
    .dout(_weight_int)
);



//
always @(posedge clk or negedge rst) begin 

	if (!rst) begin // init : #table 저장
        if (W_EN == 1'b1 && R_EN == 1'b0 ) begin
            _Weight_table[_count] <= W_DATA;
            _count <= _count + 1;
        end

        else if (W_EN == 1'b1 && R_EN == 1'b1 ) begin
            _RC_table[] <= W_DATA;
        end

        else begin
            _count <= _count; // or <= 0?
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
            RM <= R_EN;
            _weight_out <= dout;
            
        end


        //STDP writing
        else if(R_EN == 1'b0 && W_EN ==1'b1 ) begin
            
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
            
        //Rich Club    
        else if (R_EN == 1'b1 && W_EN == 1'b1) begin
            
        end

        end

        else begin
            _weight_out <= _weight_out; // or _weight_out <= 0;
        end


    end



// assign _weight_out = __weight_out;

end

endmodule












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

// TODO: tomorrow 16bit change with random generator
output reg [15:0] _weight_out;

reg [15:0] _iADDR;
//reg [31:0] _W_DATA;
reg [6:0] _iAddr;
reg [31:0] _Weight_table [0:31]; //memory
reg [7:0] _RC_table [];

reg _count = 0;
//reg [7:0] __weight_out;
reg [4:0] _base; //TODO: int wrap;
reg [1:0]_remains;


always @(posedge clk or negedge rst) begin 

	if (!rst) begin // init : #table 저장
        if (W_EN == 1'b1 && R_EN == 1'b0 ) begin
            _Weight_table[_count] <= W_DATA;
            _count <= _count + 1;
        end

        else if (W_EN == 1'b1 && R_EN == 1'b1 ) begin
            _RC_table[] <= W_DATA;
        end

        else begin
            _count <= _count; // or <= 0?
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

        end


        //STDP writing
        else if(R_EN == 1'b0 && W_EN ==1'b1 ) begin


        //Rich Club    
        else if (R_EN == 1'b1 && W_EN == 1'b1) begin
            
        end

        end

        else begin
            _weight_out <= _weight_out; // or _weight_out <= 0;
        end


    end


// assign _weight_out = __weight_out;

end

endmodule









////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


//evaluation complete.
module syn_int_Addr_ENCODER (
    input rst,
    input clk,
    input [6:0] iAddr,
    output reg [3:0] we = 4'b0000,
    output reg [4:0] addr,
    output reg [1:0] addr_col
);

// iAddr encoding
wire [4:0] quotient;
wire [1:0] remainder;

assign quotient = iAddr / 4;
assign remainder = iAddr % 4;

always @(posedge clk) begin
    addr <= quotient;
    addr_col <= remainder;

end


//we encoding
always @(posedge clk) begin
    if (!rst) begin
        we = 4'b1111;
    end

    else begin
        case(remainder)
            2'b00:
                we = 4'b0001;
                
            2'b01:
                we = 4'b0010;
                
            2'b10:
                we = 4'b0100;
                
            2'b11:
                we = 4'b1000;
                
            default:
                we = we;
        endcase
    end
end

endmodule




// Block RAM with Resettable Data Output
// File: rams_sp_rf_rst.v
module syn_int_BRAM (clk, en, W_EN, we, addr, addr_col, rst, RAM_in, RAM_out);
parameter NUM_COL = 4;
parameter COL_WIDTH = 8;
parameter ADDR_WIDTH = 5;
parameter DATA_WIDTH = NUM_COL*COL_WIDTH; // Data Width in bits (4*8=32)

input clk, en, W_EN;
input [NUM_COL-1:0] we; //4bit
input [ADDR_WIDTH-1:0] addr;
input [1:0] addr_col;
input rst;
input [DATA_WIDTH-1:0] RAM_in;

output reg [7:0] RAM_out;

(* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram_block [(2**ADDR_WIDTH)-1:0];

integer i;
//memory
always @(posedge clk or negedge rst) begin
   if (!rst) begin
      // Reset RAM_out to 0 on reset
      RAM_out <= 0;
    end 
    
    else begin
        if(en) begin
            if(W_EN) begin
                for (i=0; i<4; i=i+1) begin
                    if(we[i]) begin
                        ram_block[addr][i*COL_WIDTH +: COL_WIDTH] <= RAM_in[i*COL_WIDTH +: COL_WIDTH]; //i*COL_WIDTH + -> i*COL_WIDTH를 시작으로, COL_WIDTH까지 선택
                        end
                    end
                end
            
            else begin
                RAM_out <= ram_block[addr][addr_col*COL_WIDTH +: COL_WIDTH];    
            end
        end
    end
end
endmodule



module syn_Deci_BRAM (clk, en, W_EN, rst, addr, di, dout);
    input clk;
    input en;
    input W_EN;
    input rst;
    input [9:0] addr;
    input [15:0] di;
    output [15:0] dout;

    reg [7:0] ram [1023:0];
    reg [15:0] dout;

    always @(RN, EN) begin
        if (en) //optional enable
        begin
            if (we) //write enable
                ram[addr] <= di;
            if (rst) //optional reset
                dout <= 0;
        end

        else
        dout <= ram[addr];
    end
    
endmodule


module RandomGenerator (
    input clk,
    output reg randomValue
);

always @(posedge clk) begin
    randomValue <= $urandom; 
end
endmodule


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

// TODO: tomorrow 16bit change with random generator
output reg [15:0] _weight_out;

reg [31:0] _W_DATA;
reg [6:0] _iAddr;
reg [7:0] _RC_table [7:0];
wire [3:0] we;
wire [4:0] addr;
wire [1:0] addr_col;

reg [7:0] _weight_int;

reg Int_EN;
reg Deci_EN;

//instantiation of submodule
syn_int_Addr_ENCODER SIAE (
    .rst(rst),
    .clk(clk),
    .iAddr(iADDR[6:0]),
    .we(we)
    .addr(addr),
    .addr_col(addr_col)
);

syn_int_BRAM SIB (
    .clk(clk),
    .en(Int_EN),
    .W_EN(W_EN), 
    .we(we),  
    .addr(addr), 
    .addr_col(addr_col),
    .rst(rst),
    .RAM_in(_W_DATA), 
    .RAM_out(_weight_int)
);

syn_Deci_BRAM SDB (
    .clk(clk),
    .en(Deci_EN),
    .W_EN(W_EN),
    .iAddr(iAddr),
    .rst(rst),
    .RAM_in(_W_DATA),
    .RAM_out(_weight_deci)
);





//memory access switching unit
always @(posedge clk or negedge rst) begin 

    if (!rst) begin
        if (R_EN) begin
            Int_EN <= 0;
            Deci_EN <= 1;
        end

        else begin
            Int_EN <= 1;
            Deci_EN <= 0; 
        end
    end

end


// assign _weight_out = _weight_out;


endmodule