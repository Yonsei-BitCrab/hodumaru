module STACK_MACHINE  ( clk, rst,
						ctl, o_wait,
						DATA_in, DATA_out
                        // o_STACK_REG0, o_STACK_REG[1], o_STACK_REG[2]
);

parameter DATA_WIDTH = 32;
parameter STACK_SIZE = 3;       // IF Size increases, You have to add codes(refer to STATE REG)

input clk, rst;
input [1:0] ctl;
input [DATA_WIDTH-1:0] DATA_in;
output reg o_wait;
output [DATA_WIDTH-1:0] DATA_out;
// output [15:0]  o_STACK_REG0, o_STACK_REG[1], o_STACK_REG[2];

reg [1:0] next_state_reg, state_reg;
reg[DATA_WIDTH-1:0] _STACK_REG[STACK_SIZE-1:0];
reg[DATA_WIDTH-1:0] _next_STACK_REG[STACK_SIZE-1:0];
// reg[15:0] o_STACK_REG0, o_STACK_REG[1], o_STACK_REG[2];
reg [DATA_WIDTH-1:0] buf_DATA_out;

always @(posedge clk) begin
	if (rst == 1'b1) begin
		state_reg <= 0;
	end
	else begin
		state_reg <= next_state_reg;
	end
end

always @(posedge clk) begin
    if (rst == 1'b1)  begin
        _STACK_REG[0] <= 0;
        _STACK_REG[1] <= 0;
        _STACK_REG[2] <= 0;
    end
    else begin
        _STACK_REG[0] <= _next_STACK_REG[0];
        _STACK_REG[1] <= _next_STACK_REG[1];
        _STACK_REG[2] <= _next_STACK_REG[2];
    end
end


always @(posedge clk, posedge rst, posedge ctl) begin
	if (rst == 1'b1) begin
		next_state_reg <= 0;
	end
	else begin
		case(state_reg)
			2'b00:
				case (ctl)
				2'b00:
					next_state_reg <= 2'b00;
				2'b01:
					next_state_reg <= 2'b00;
				2'b10:
					next_state_reg <= 2'b00;
				2'b11:
					next_state_reg <= 2'b01;
				default:
					next_state_reg <= 2'b00;
				endcase
				
			2'b01:
				case (ctl)
				2'b00:
					next_state_reg <= 2'b00;
				2'b01:
					next_state_reg <= 2'b01;
				2'b10:
					next_state_reg <= 2'b01;
				2'b11:
					next_state_reg <= 2'b10;
				default:
					next_state_reg <= 2'b00;
				endcase

			2'b10:
				case (ctl)
				2'b00:
					next_state_reg <= 2'b01;
				2'b01:
					next_state_reg <= 2'b10;
				2'b10:
					next_state_reg <= 2'b10;
				2'b11:
					next_state_reg <= 2'b11;
				default:
					next_state_reg <= 2'b00;
				endcase
				
			2'b11:
				case (ctl)
				2'b00:
					next_state_reg <= 2'b10;
				2'b01:
					next_state_reg <= 2'b11;
				2'b10:
					next_state_reg <= 2'b11;
				2'b11:
					next_state_reg <= 2'b10;
				default:
					next_state_reg <= 2'b00;
				endcase
				
			default:
				next_state_reg <= next_state_reg;
		endcase
	end
end

always @(posedge clk, posedge rst) begin
	if (rst == 1'b1) begin
        buf_DATA_out <= 0;
		o_wait <= 1'b0;
        _next_STACK_REG[0] <= 0;
        _next_STACK_REG[1] <= 0;
        _next_STACK_REG[2] <= 0;
	end
	else begin
		case (state_reg)
		2'b00:
			case (ctl)
			2'b00:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= 0;
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
				
			2'b01:
            begin
                buf_DATA_out <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[DATA_WIDTH/2-1:0]};
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= 0;
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
				
			2'b10:
            begin
                buf_DATA_out <= DATA_in;
				//buf_DATA_out <= 1;
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= 0;
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
				
			2'b11:
            begin
                buf_DATA_out <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[(DATA_WIDTH/2)-1:0]};
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[DATA_WIDTH-1:(DATA_WIDTH/2)]};
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
				
				
			endcase
		2'b01:
			case (ctl)
			2'b00:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= 0;
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
                
			2'b01:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[(DATA_WIDTH/2)-1:0]};
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
                
			2'b10:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= DATA_in;
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
                
			2'b11:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[(DATA_WIDTH/2)-1:0]};
                _next_STACK_REG[1] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[DATA_WIDTH-1:(DATA_WIDTH/2)]};
                _next_STACK_REG[2] <= 0;
            end
                
			endcase
		2'b10:
			case (ctl)
			2'b00:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= 0;
                _next_STACK_REG[2] <= 0;
            end
                
			2'b01:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[(DATA_WIDTH/2)-1:0]};
                _next_STACK_REG[2] <= 0;
            end
                
			2'b10:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= DATA_in;
                _next_STACK_REG[2] <= 0;
            end
                
			2'b11:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[(DATA_WIDTH/2)-1:0]};
                _next_STACK_REG[2] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[DATA_WIDTH-1:(DATA_WIDTH/2)]};
            end
                
			endcase
		2'b11:
			case (ctl)
			2'b00:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= _STACK_REG[2];
                _next_STACK_REG[2] <= 0;
            end
                
			2'b01:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= _STACK_REG[2];
                _next_STACK_REG[2] <= {{(DATA_WIDTH/2){1'b0}}, DATA_in[(DATA_WIDTH/2)-1:0]}; 
            end
                
			2'b10:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b0;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= _STACK_REG[2];
                _next_STACK_REG[2] <= DATA_in;
            end
                
			2'b11:
            begin
                buf_DATA_out <= _STACK_REG[0];
				o_wait <= 1'b1;
                _next_STACK_REG[0] <= _STACK_REG[1];
                _next_STACK_REG[1] <= _STACK_REG[2];
                _next_STACK_REG[2] <= 0;
            end
                
			endcase
		// default:
        // begin
        //     buf_DATA_out <= buf_DATA_out;
		// 	o_wait <= 1'b0;
        //     _next_STACK_REG[0] <= _next_STACK_REG[1];
        //     _next_STACK_REG[1] <= _next_STACK_REG[2];
        //     _next_STACK_REG[2] <= _next_STACK_REG[2];
        // end
			
		endcase
	end
end

// DEBUG
// assign o_STACK_REG[0] = _STACK_REG[0];
// assign o_STACK_REG[1] = _STACK_REG[1];
// assign o_STACK_REG[2] = _STACK_REG[2];
assign DATA_out = buf_DATA_out;

endmodule
