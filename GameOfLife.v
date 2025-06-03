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
						nx = (x + dx + M) % M; // wrap around borders
						ny = (y + dy + N) % N;
						count = count + state[ny*M + nx];
					end
				end
			end

			// apply game of life rules
			if (state[y*M + x]) begin
				// live cell with 2 or 3 neighbors lives on
				next_state[y*M + x] = (count == 2 || count == 3);
			end else begin
				// a dead cell with 3 neighbors revives
				next_state[y*M + x] = (count == 3);
			end
		end
	end
end

// clocked update and reset
always @(posedge clk_i or negedge reset_n_i) begin
	if (!reset_n_i) begin
		// hard-code initial state
		state <= {(M*N){1'b0}} |
		(1 << (1*M + 2)) |
		(1 << (2*M + 3)) |
		(1 << (3*M + 1)) |
		(1 << (3*M + 2)) |
		(1 << (3*M + 3));
	end else begin
		// update state
		state <= next_state;
	end
end

end module

