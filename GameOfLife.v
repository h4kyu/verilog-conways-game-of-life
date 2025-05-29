module GameOfLife #(
	parameter M = 16, N = 16
) 
(
	input clk_i, 
	input reset_n_i,
	// row-major flattened grid of N rows by M columns
	output reg [N*M - 1 : 0] state
);

