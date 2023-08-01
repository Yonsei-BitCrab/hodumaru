module STACK_MACHINE_DATA  ( clk, rst,
								ctl, o_wait,
								DATA_in, DATA_out,
                            o_STACK_REG0, o_STACK_REG1, o_STACK_REG2,  //DBG
                            o_state, o_state_next
);

parameter DATA_WIDTH = 32;
parameter STACK_SIZE = 3;       // IF Size increases, You have to add codes(refer to STATE REG)

input clk, rst;
input [1:0] ctl;
input [DATA_WIDTH-1:0] DATA_in;
output reg o_wait;
output [DATA_WIDTH-1:0] DATA_out;
output [15:0]  o_STACK_REG0, o_STACK_REG1, o_STACK_REG2;  //DBG
output [1:0] o_state, o_state_next;

reg [1:0] next_state_reg, state_reg;
reg[DATA_WIDTH-1:0] _STACK_REG[STACK_SIZE-1:0];
reg[DATA_WIDTH-1:0] _next_STACK_REG[STACK_SIZE-1:0];
//reg[15:0] _o_STACK_REG0, _o_STACK_REG1, _o_STACK_REG2;		//DBG
reg [DATA_WIDTH-1:0] buf_DATA_out;

always @(posedge clk) begin
	state_reg <= next_state_reg;
end

always @(posedge clk) begin
    if (rst)  begin
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


always @(posedge clk) begin
	if (rst) begin
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

always @(posedge clk) begin
	if (rst) begin
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
assign o_STACK_REG0 = _STACK_REG[0];
assign o_STACK_REG1 = _STACK_REG[1];
assign o_STACK_REG2 = _STACK_REG[2];
assign o_state_next = next_state_reg;
assign o_state = state_reg;
//DEBUG

assign DATA_out = buf_DATA_out;

endmodule
