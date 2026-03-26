UART Receiver with Datapath (LSB-First)
This project implements a hardware-level UART receiver FSM in Verilog. It successfully extracts 8-bit data from a serial stream, handles framing errors, and outputs the result in parallel.

📁 Files in this Project
top_module.v: The Verilog implementation of the FSM and 8-bit shift register.

tb.v: The testbench that simulates serial input and verifies the output byte.

sim.out: The compiled simulation executable.

uart_datapath.vcd: The waveform file generated for GTKWave analysis.

🚀 Execution Flow
1. Compilation
Use Icarus Verilog to compile the source and testbench files:

PowerShell
iverilog -o sim.out top_module.v tb.v
2. Simulation
Run the compiled simulation using vvp. This will execute the test cases defined in the testbench:

PowerShell
vvp sim.out
3. Debugging with GTKWave
If the simulation reports a mismatch (e.g., Expected 0x4B, Got 8'hE1), open the VCD file to inspect the timing of the bit_cnt and data_reg signals:

PowerShell
gtkwave uart_datapath.vcd

🛠️ Technical Logic
LSB-First: Data is shifted right (data_reg <= {in, data_reg[7:1]}) so the first bit received ends up at out_byte[0].

Framing Error: If the stop bit is sampled as 0, the done signal remains low, and the FSM enters a WAIT state to resynchronize with the idle line.

Shift Sync: The bit_cnt tracks exactly 8 data pulses before transitioning to the STOP check state.
