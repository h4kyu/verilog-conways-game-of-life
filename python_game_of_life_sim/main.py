# VCD parser to display Conway's Game of Life verilog sim

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.animation import PillowWriter


def parse_vcd(filename):
    """
    Parses a VCD file and returns:
      - timescale (string)
      - var_defs: dict mapping id -> (name, width)
      - changes: dict mapping time -> dict of id -> value (bitstring or '0'/'1')
    """
    var_defs = {}
    changes = {}

    with open(filename, 'r') as f:
        scope_stack = []

        for line in f:
            line = line.strip()
            if not line:
                continue

            # definitions
            if line.startswith("$scope"):
                scope = line.split()[2]
                scope_stack.append(scope)
                continue
            if line.startswith("$upscope"):
                scope_stack.pop()
                continue

            # get var IDs
            if scope_stack and scope_stack[-1] == "GameOfLife" and line.startswith("$var"):
                # $var wire <width> <id> <name> [ranges] $end
                parts = line.split()
                width = int(parts[2])
                vid = parts[3]
                name = parts[4]
                var_defs[vid] = (name, width)
                continue

            # read and store bit info
            if line.startswith("#"):  # timestamp
                current_time = int(line[1:])
                changes.setdefault(current_time, {})

            elif line.startswith("b"):  # binary string, vector change  b<bits> <id>
                bits, vid = line[1:].split()
                changes[current_time][vid] = bits

            elif line[0] in ("0", "1"):  # binary digit, single bit change <bit><id>
                bit = line[0]
                vid = line[1:]
                changes[current_time][vid] = bit

    return var_defs, changes


def display_latest_frame(vcd_file, grid_name="state", M=16, N=16):
    # Parse the VCD file
    var_defs, changes = parse_vcd(vcd_file)

    # Find the var ID for grid
    state_id = None
    for vid, (name, width) in var_defs.items():
        if name == grid_name and width == M*N:
            state_id = vid
            break
    if state_id is None:
        raise ValueError(f"Grid signal '{grid_name}' not found in VCD.")

    # find latest timestamp with new state value
    latest_time = max(t for t, vals in changes.items() if state_id in vals)
    bits = changes[latest_time][state_id]

    # reverse bit order from MSB
    bits_rev = bits[::-1]

    print(f"\nGame of Life @ t = {latest_time} ps\n")
    for y in range(N):
        row = ''.join('O' if bits_rev[y*M + x] == '1' else '.' for x in range(M))
        print(row)


def display_animation(vcd_file, grid_name="state", M=16, N=16, interval=200):
    # Parse the VCD file
    var_defs, changes = parse_vcd(vcd_file)

    # Find the var ID for grid
    state_id = None
    for vid, (name, width) in var_defs.items():
        if name == grid_name and width == M*N:
            state_id = vid
            break
    if state_id is None:
        raise ValueError(f"Grid signal '{grid_name}' not found in VCD.")

    # get frames
    times = sorted(
        [time for time in changes if state_id in changes[time]]
    )
    frames = []
    for time in times:
        bits = changes[time][state_id]
        # reverse bit order from MSB
        bits_rev = bits[::-1]
        # print(f"\nGame of Life @ t = {time} ps\n")
        # for y in range(N):
        #     row = ''.join('O' if bits_rev[y * M + x] == '1' else '.' for x in range(M))
        #     print(row)
        grid = np.array([1 if b=='1' else 0 for b in bits_rev]).reshape((N, M))
        frames.append(grid)

    # set up plot
    fig, ax = plt.subplots()
    im = ax.imshow(frames[0])  # draw initial frame
    ax.set_title(f'time = {times[0]}')

    def update(i):
        im.set_array(frames[i])
        ax.set_title(f'time = {times[i]}')
        return [im]

    ani = FuncAnimation(fig, update, frames=len(frames), interval=100, blit=False)
    gif_writer = PillowWriter(fps=5)
    ani.save("game_of_life.gif", writer=gif_writer)
    # plt.show()

    return


vcd_path = "/Users/nahshonweissberg/repos/verilog-conways-game-of-life/build/GameOfLife.vcd"

# display_latest_frame(vcd_path)
display_animation(vcd_path, "state", 64, 64)

