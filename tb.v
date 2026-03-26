`timescale 1ns/1ps

module top_module_tb;

    // Inputs
    reg clk;
    reg in;
    reg reset;

    // Outputs
    wire [7:0] out_byte;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    top_module uut (
        .clk(clk),
        .in(in),
        .reset(reset),
        .out_byte(out_byte),
        .done(done)
    );

    // Clock generation: 100MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // GTKWave Setup
    initial begin
        $dumpfile("uart_datapath.vcd");
        $dumpvars(0, top_module_tb);
    end

    // Task to send a serial byte: Start bit (0), 8 Data bits (LSB first), Stop bit (1)
    task send_byte(input [7:0] data, input valid_stop);
        integer i;
        begin
            $display("Sending byte: 8'h%h (binary: %b)", data, data);
            
            // Start Bit
            in = 0;
            @(posedge clk);
            
            // 8 Data Bits
            for (i = 0; i < 8; i = i + 1) begin
                in = data[i];
                @(posedge clk);
            end
            
            // Stop Bit
            in = valid_stop ? 1 : 0;
            @(posedge clk);
            
            // Return to IDLE
            in = 1;
            @(posedge clk);
        end
    endtask

    initial begin
        // Initialize
        in = 1;
        reset = 0;

        // Reset Pulse
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // --- Case 1: Send 0x4B (0100 1011) ---
        // Expected out_byte: 0x4B when done=1
        send_byte(8'h4B, 1);
        if (done && out_byte == 8'h4B) 
            $display("SUCCESS: Received 0x4B correctly.");
        else 
            $display("ERROR: Expected 0x4B, Got 8'h%h (done=%b)", out_byte, done);

        repeat(2) @(posedge clk);

        // --- Case 2: Send 0x62 (0110 0010) ---
        send_byte(8'h62, 1);
        if (done && out_byte == 8'h62) 
            $display("SUCCESS: Received 0x62 correctly.");
        else 
            $display("ERROR: Expected 0x62, Got 8'h%h (done=%b)", out_byte, done);

        repeat(2) @(posedge clk);

        // --- Case 3: Framing Error (Stop bit = 0) ---
        // out_byte should be ignored because done should not pulse
        send_byte(8'hFF, 0);
        if (done) 
            $display("ERROR: 'done' pulsed despite framing error.");
        else 
            $display("SUCCESS: Framing error correctly ignored.");

        // Recovery from WAIT state
        in = 1;
        repeat(5) @(posedge clk);

        $display("Simulation complete.");
        $finish;
    end

endmodule