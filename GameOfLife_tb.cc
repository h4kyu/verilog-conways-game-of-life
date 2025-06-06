#include <systemc.h>
#include <verilated.h>
#include <verilated_vcd_sc.h>

// #include "VBuffer.h"
#include "VGameOfLife.h"

#include <iostream>

int sc_main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // get vcd file path from command line arguments
    std::string vcd_file = (argc == 2 ? argv[1] : "GameOfLife.vcd");
    // std::string vcd_file_path;

    // if(argc == 2) {
    //     vcd_file_path = std::string(argv[1]);
    // }

    // signals
    sc_clock clk_i{"clk", 10, SC_NS, 0.5, 0, SC_NS, true};
    sc_signal<bool> reset_n_i;

    // flattened 16×16 grid
    sc_signal< sc_bv<256> > state;

    // const std::unique_ptr<VBuffer> buffer{new VBuffer{"buffer"}};

    // instantiate DUT
    VGameOfLife* dut = new VGameOfLife{"dut"};

    // hook up ports
    dut->clk_i     (clk_i);
    dut->reset_n_i (reset_n_i);
    dut->state     (state);

    // start simulation and trace
    std::cout << "start!" << std::endl;

    sc_start(0, SC_NS);

    VerilatedVcdSc* tfp = new VerilatedVcdSc();
    dut->trace(tfp, 99);

    tfp->open(vcd_file.c_str());

    // apply an asynchronous reset pulse
    reset_n_i.write(false);
    sc_start(1, SC_NS);        // at t=1 ns, DUT sees reset_n_i=0
    reset_n_i.write(true);
    sc_start(1, SC_NS);        // at t=2 ns, DUT comes out of reset

    // assert(data_o.read() == 0);

    // run for 200 generations
    const int NUM_GENS = 200;
    for (int gen = 0; gen < NUM_GENS; gen++) {
        sc_start(10, SC_NS);    // advance one clock period (10 ns)
    }

    dut->final();
    tfp->flush();
    tfp->close();
    delete tfp;
    delete dut;

    std::cout << "simulation complete, wrote to " << vcd_file << std::endl;
    return 0;
}
