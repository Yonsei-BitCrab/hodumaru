module FIFOQueue(
    input clk,
    input rst,
    input enq,
    input deq,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
);

parameter DEPTH = 8; // The depth of the FIFO queue
parameter DATA_WIDTH = 32; // Width of data in bits

reg [DATA_WIDTH-1:0] queue[0:DEPTH-1];
reg [2:0] head = 0;
reg [2:0] tail = 0;
reg _full, _empty;
//output [DATA_WIDTH-1:0] data_out;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset the queue
        head <= 0;
        tail <= 0;
        _full <= 0;
        _empty <= 1;
    end else begin
        // Update full and empty flags
        _full <= (head == tail) && enq;
        _empty <= (head == tail) && !enq;

        // Perform enqueue operation
        if (enq && !full) begin
            queue[tail] <= data_in;
            tail <= (tail == DEPTH-1) ? 0 : tail + 1;
        end

        // Perform dequeue operation
        if (deq && !empty) begin
            data_out <= queue[head];
            head <= (head == DEPTH-1) ? 0 : head + 1;
        end
    end
end

assign full = _full;
assign empty = _empty;
endmodule