module PhysicalNeuronController_iLoop(
    clk, rst, kill,
    iADDR, W_DATA,
    SWU_EN, SWU_ADDR, SWU_DATA,

    Addr2SYNAPSE, Addr2SOMA, Addr2STDP,
    Data2SYNAPSE, Data2SOMA, Data2STDP,

    EN_SYNAPSE, EN_SOMA, EN_STDP,
    RC_SYNAPSE, RC_SOMA, RC_STDP,
    W_EN2Synapse, W_EN2SOMA, W_EN2STDP,
    o_ctrl, dbg_DATA1, dbg_DATA2
);

input clk, rst, kill;
input [15:0] iADDR;
input [31:0] W_DATA;

input SWU_EN;
input [15:0] SWU_ADDR;
input [7:0] SWU_DATA;

output [6:0] Addr2SYNAPSE, Addr2SOMA, Addr2STDP;
output [31:0] Data2SYNAPSE, Data2SOMA, Data2STDP;

output EN_SYNAPSE, EN_SOMA, EN_STDP;
output RC_SYNAPSE, RC_SOMA, RC_STDP;
output W_EN2Synapse, W_EN2SOMA, W_EN2STDP;

// DEBUG
output [1:0] o_ctrl;
output [31:0] dbg_DATA1, dbg_DATA2;

// Stack Machine
wire [15:0] STMC_gate_ADDR_Din;
wire [15:0] STMC_gate_ADDR_Dout;
//reg [1:0] STMC_gate_ADDR_ctl_in;
wire STMC_gate_ADDR_wait_out;

wire [31:0] STMC_gate_DATA_Din;
wire [31:0] STMC_gate_DATA_Dout;
//reg [1:0] STMC_gate_DATA_ctl_in;
wire STMC_gate_DATA_wait_out;


//DEBUG ///
// assign STMC_gate_ADDR_Din = SWU_EN ? SWU_ADDR : iADDR; //Origin Code
// assign STMC_gate_DATA_Din = SWU_EN ? {24'b0, SWU_DATA} : W_DATA;  // Origin Code
//always @(posedge clk) begin
assign STMC_gate_ADDR_Din = SWU_EN ? SWU_ADDR : iADDR; //Origin Code
assign STMC_gate_DATA_Din = SWU_EN ? {24'b0, SWU_DATA} : W_DATA;  // Origin Code
//end
//DEBUG ///


// TODO: Control line for STMC is needed
wire [1:0] ctl_line;
PNC_STMC_Control_Unit STMC_CU (
    .clk(clk),
	.rst(rst),
    .iAddr(STMC_gate_ADDR_Din),
    .ctrl(ctl_line)
);

//DEBUG
assign o_ctrl = ctl_line;
//assign STMC_gate_ADDR_ctl_in = ctl_line;
//assign STMC_gate_DATA_ctl_in = ctl_line;


STACK_MACHINE_ADDR STMC_gate_ADDR (
    .clk(clk),
    .rst(kill),
    //.ctl(STMC_gate_ADDR_ctl_in),
	 .ctl(ctl_line),
    .o_wait(STMC_gate_ADDR_wait_out),
    .DATA_in(STMC_gate_ADDR_Din),
    .DATA_out(STMC_gate_ADDR_Dout)
);

STACK_MACHINE_DATA STMC_gate_DATA  (
    .clk(clk),
    .rst(kill),
    //.ctl(STMC_gate_DATA_ctl_in),
	.ctl(ctl_line),
    .o_wait(STMC_gate_DATA_wait_out),
    .DATA_in(STMC_gate_DATA_Din),
    .DATA_out(STMC_gate_DATA_Dout)
);

// debUG
assign dbg_DATA1 = STMC_gate_DATA_Din;
assign dbg_DATA2 = STMC_gate_DATA_Dout;

// Control Unit
wire w_EN_SYNAPSE, w_EN_SOMA, w_EN_STDP;
wire w_RC_SYNAPSE, w_RC_SOMA, w_RC_STDP;
wire w_W_EN2Synapse, w_W_EN2SOMA, w_W_EN2STDP;

PNC_ADDR_Control_Unit PNC_ADDR_CU(
    .clk(clk),
    .iADDR_ctl(STMC_gate_ADDR_Dout[15:12]),
    .EN_SYNAPSE(w_EN_SYNAPSE), 
    .EN_SOMA(w_EN_SOMA), 
    .EN_STDP(w_EN_STDP),
    .RC_SYNAPSE(w_RC_SYNAPSE), 
    .RC_SOMA(w_RC_SOMA), 
    .RC_STDP(w_RC_STDP),
    .W_EN2Synapse(w_W_EN2Synapse), 
    .W_EN2SOMA(w_W_EN2SOMA), 
    .W_EN2STDP(w_W_EN2STDP)
);

// ADDR & DATA MUX
assign Addr2SYNAPSE = w_EN_SYNAPSE ? STMC_gate_ADDR_Dout : 0;
assign Addr2SOMA = w_EN_SOMA ? STMC_gate_ADDR_Dout : 0;
assign Addr2STDP = w_EN_STDP ? STMC_gate_ADDR_Dout : 0;
assign Data2SYNAPSE = w_EN_SYNAPSE ? STMC_gate_DATA_Dout : 0;
assign Data2SOMA = w_EN_SOMA ? STMC_gate_DATA_Dout : 0;
assign Data2STDP = w_EN_STDP ? STMC_gate_DATA_Dout : 0;

// Control lines
assign EN_SYNAPSE = w_EN_SYNAPSE;
assign EN_SOMA = w_EN_SOMA;
assign EN_STDP = w_EN_STDP;
assign RC_SYNAPSE = w_RC_SYNAPSE;
assign RC_SOMA = w_RC_SOMA;
assign RC_STDP = w_RC_STDP;
assign W_EN2Synapse = w_W_EN2Synapse;
assign W_EN2SOMA = w_W_EN2SOMA;
assign W_EN2STDP = w_W_EN2STDP;


endmodule
