`./python_game_of_life_sim/main.py` parses `GameOfLife.vcd`:

```
...
 $scope module dut $end
  $scope module GameOfLife $end
   ...
   $var wire 256 # state [255:0] $end
   ...
  $upscope $end
 $upscope $end
$enddefinitions $end


#0                    - 🕛 timestamp = 0 ps
b000...000 #          - 💡 state row-major grid, state_id = #
b000...000 +
...
1:                    - ⏲️ clock in signal
0;                    - 🔄 reset in signal
b000...000 <
#1000                 - 🕐 timestamp = 1000 ps
1;
#2000                 - 🕑 timestamp = 2000 ps
#5000                 - 🕔 timestamp = 5000 ps
0:
#10000                - 🕙 timestamp = 10000 ps
b000...000 #
b000...000 +
1:
#12000                - 🕛 timestamp = 12000 ps
#15000                - 🕒 timestamp = 15000 ps
0:
#20000                - 🕗 timestamp = 20000 ps
...
```

Initial state as classic glider, 16x16 grid, border wrapping:

```
		state <= {(M*N){1'b0}} |
		(1 << (1*M + 2)) |
		(1 << (2*M + 3)) |
		(1 << (3*M + 1)) |
		(1 << (3*M + 2)) |
		(1 << (3*M + 3));
```
![game_of_life](https://github.com/user-attachments/assets/1e086559-1244-4be7-adf2-7f79bc932f5c)

Initial state as R-pentomino, 64x64 grid, no border wrapping:

```
  		state <= {(M*N){1'b0}} |
	    	(1 << ((r0 + 0)*M + (c0 + 1))) |
	    	(1 << ((r0 + 0)*M + (c0 + 2))) |
	    	(1 << ((r0 + 1)*M + (c0 + 0))) |
	    	(1 << ((r0 + 1)*M + (c0 + 1))) |
	    	(1 << ((r0 + 2)*M + (c0 + 1)));
```
![game_of_life](https://github.com/user-attachments/assets/08b9dc3a-b335-4a97-bba8-d1ef55cfeed1)
