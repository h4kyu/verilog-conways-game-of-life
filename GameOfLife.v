module GameOfLife #(
	parameter M = 16, N = 16
) 
(
	input clk_i, 
	input reset_n_i,
	// row-major flattened grid of N rows by M columns
	output reg [N*M - 1 : 0] state
);

// next_state
reg [M*N - 1 : 0] next_state;
integer x, y, dx, dy, nx, ny; // to hold (x,y) cell, x and y offset, and neighboring cells (nx, ny) respectively
integer count; // # of live neighbouring cells

always @* begin
	next_state = {M*N{1'b0}};

	for (y = 0; y < N; y = y + 1) begin
		for (x = 0; x < M; x = x + 1) begin
			count = 0;

			for (dy = -1; dy <= 1; dy = dy + 1) begin
				for (dx = -1; dx <= 1; dx = dx + 1) begin
					if (dx || dy) begin // ignore (dx, dy) = (0, 0)
						nx = (x + dx + M) % M; // ensure to skip over 
					end
				end
			end
		end
	end
end

end module

