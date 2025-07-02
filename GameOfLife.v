module GameOfLife #(
	parameter M = 64, N = 64
) 
(
	input clk_i, 
	input reset_n_i,
	// row-major flattened grid of N rows by M columns
	output reg [N*M-1:0] state
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
					if ((dx != 0) || (dy != 0)) begin // ignore (dx, dy) = (0, 0)

						// Method 1: wrap around borders
						// nx = (x + dx + M) % M;
						// ny = (y + dy + N) % N;
						// count = count + (state[ny*M + nx] ? 32'd1 : 32'd0);   // widen the 1-bit state[...] to a 32-bit integer

						// Method 2: no border wrapping
						nx = x + dx;
						ny = y + dy;
						if (nx >= 0 && nx < M && ny >= 0 && ny < N) begin
							count = count + (state[ny*M + nx] ? 32'd1 : 32'd0);
						end

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

	  	// choose an origin so the pattern sits somewhere in the middle
	  	localparam integer r0 = N/2 - 1;  
	  	localparam integer c0 = M/2 - 1;
		// hard-code initial state
		// R-pentomino shape
  		state <= {(M*N){1'b0}} |
	    (1 << ((r0 + 0)*M + (c0 + 1))) |
	    (1 << ((r0 + 0)*M + (c0 + 2))) |
	    (1 << ((r0 + 1)*M + (c0 + 0))) |
	    (1 << ((r0 + 1)*M + (c0 + 1))) |
	    (1 << ((r0 + 2)*M + (c0 + 1)));
	end else begin
		// update state
		state <= next_state;
	end
end

endmodule

