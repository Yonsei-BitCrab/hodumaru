module syn_int_Addis_RCCODER (
    input clk,
    input rst,
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
    if (rst) begin
        we = 4'b1111;
    end

    else begin
        case(remainder)
            2'b00:
                we <= 4'b0001;
                
            2'b01:
                we <= 4'b0010;
                
            2'b10:
                we <= 4'b0100;
                
            2'b11:
                we <= 4'b1000;
                
            default:
                we <= we;
        endcase
    end
end

endmodule


module RichClub_switch (
    input clk,
    input rst,
    input is_RC,
    output reg Int_EN,
    output reg Deci_EN  
);

//memory access switching unit
always @(posedge clk) begin 

    if (rst) begin
        if (is_RC) begin
            Int_EN <= 0;
            Deci_EN <= 1;
        end

        else begin
            Int_EN <= 1;
            Deci_EN <= 0; 
        end
    end
    
    else begin
        if (is_RC) begin
            Int_EN <= 1;
            Deci_EN <= 1;
            
        end

        else begin
            Int_EN <= 1;
            Deci_EN <= 0;
        end
    end
end

endmodule



// Block RAM with Resettable Data Output
// File: rams_sp_rf_rst.v
module syn_int_BRAM (clk, kill, en, W_EN, we, addr, addr_col, RAM_in, RAM_out);
parameter NUM_COL = 4;
parameter COL_WIDTH = 8;
parameter ADDR_WIDTH = 5;
parameter DATA_WIDTH = NUM_COL*COL_WIDTH; // Data Width in bits (4*8=32)

input clk, kill, en, W_EN;
input [NUM_COL-1:0] we; //4bit
input [ADDR_WIDTH-1:0] addr;
input [1:0] addr_col;
input [DATA_WIDTH-1:0] RAM_in;

output reg [7:0] RAM_out;

(* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram_block [(2**ADDR_WIDTH)-1:0];

integer i;
//memory
always @(posedge clk) begin
   if (kill) begin
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



module syn_Deci_MEM (clk, kill, en, W_EN, rst, iAddr, di, dout);
input clk;
input kill;
input en;
input W_EN;
input rst;
input [6:0] iAddr;
input [7:0] di;
output reg [7:0] dout;

reg [15:0] ram [3:0];
reg  count = 0;
    
integer i;

wire [15:0] metadata;

assign metadata[14:8] = iAddr;
assign metadata[7:0] = di;

always @(posedge clk) begin
    if (rst) begin
        ram[count] <= metadata;
        count <= count + 1;
    end
end

    else if (kill) begin
        count <= 0;
        for (i=0; i<4; i=i+1) begin
            ram[i] <= 0;
        end
    end
     
    else begin
        if (en)
        begin
            if (W_EN) begin
               for (i=0; i<4; i=i+1) begin
                    if (ram[i][14:8] == iAddr) begin
                        ram[i][7:0] <= metadata;
                    end
                end 
            end
        
            else begin
                for (i=0; i<4; i=i+1) begin
                    if (ram[i][14:8] == iAddr) begin
                        dout <= ram[i][7:0];
                    end
                end 
            end
        end
    end
    
endmodule



//TODO:
module RandomGenerator (
    input clk,
    output reg [7:0] randomValue
);

endmodule



module weight_out_controller (
    input clk, rst, W_EN,
    input [6:0]iAddr,
    output reg weight_ctrl = 0
);

parameter set = 1;
parameter reset = 0;

always @(posedge clk) begin
    if (rst || W_EN) begin
        weight_ctrl <= reset;
    end
    
    else begin
        if (iAddr !== 0) begin   
            weight_ctrl <= set; 
        end   
        else begin
            weight_ctrl <= reset;
        end
    end
end

endmodule




`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 00:22:11
// Design Name: 
// Module Name: synapse
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module synapse( 
    input clk, 
    input rst, 
    input kill,
    input [6:0] iAddr, 
    input [31:0] W_DATA,
    input W_EN, 
    input R_EN,
    //output [15:0] weight_out
    output reg [15:0] weight_out
);

reg [31:0] _W_DATA;

wire [3:0] we;
wire [4:0] addr;
wire [1:0] addr_col;
wire [7:0] weight_int;
wire [7:0] randomValue;
wire Int_EN;
wire Deci_EN;
wire [7:0] weight_deci;
wire [7:0] RC_Deci;
wire [15:0] weight_set;
wire weight_ctrl;

//instantiation of submodule
syn_int_Addr_ENCODER SIAE (
    .clk(clk),
    .rst(rst),
    .iAddr(iAddr),
    .we(we),
    .addr(addr),
    .addr_col(addr_col)
);

syn_int_BRAM SIB (
    .clk(clk),
    .rst(rst),
    .kill(kill),
    .en(Int_EN),
    .W_EN(W_EN), 
    .we(we),  
    .addr(addr), 
    .addr_col(addr_col),
    .RAM_in(_W_DATA), 
    .RAM_out(weight_int)
);

syn_Deci_MEM SDM (
    .clk(clk),
    .rst(rst),
    .kill(kill),
    .en(Deci_EN),
    .W_EN(W_EN),
    .iAddr(iAddr),
    .di(_W_DATA[7:0]),
    .dout(RC_Deci)
);

RandomGenerator RG (
    .clk(clk),
    .rst(rst),
    .randomValue(randomValue)
)
;

RichClub_switch RCSW (
    .clk(clk),
    .rst(rst),
    .R_EN(R_EN),
    .Int_EN(Int_EN),
    .Deci_EN(Deci_EN)
);

weight_out_controller WOC(
    .clk(clk),
    .W_EN(W_EN),
    .rst(rst),
    .iAddr(iAddr),
    .weight_ctrl(weight_ctrl)
);

always @(posedge clk) begin
    _W_DATA <= W_DATA;
end

assign weight_deci = Deci_EN ? RC_Deci : randomValue;
assign weight_set[15:8] = weight_int;
assign weight_set[7:0] = weight_deci;

always @(posedge clk) begin
    if (weight_ctrl) begin
        weight_out = weight_set;
        end
    else begin
        weight_out = 16'b0000_0000_0000_0000;
    end
    //weight_out = weight_ctrl ? weight_set : 
    end

endmodule
