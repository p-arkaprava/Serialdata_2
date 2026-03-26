module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
); 

    parameter IDLE = 3'd0, READ = 3'd1, STOP = 3'd2, WAIT = 3'd3, DONE = 3'd4;
    reg [2:0] state, next_state;
    reg [3:0] bit_cnt;
    reg [7:0] data_reg; // Internal buffer to store bits as they arrive

    // State Register
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else       state <= next_state;
    end

    // Counter & Shift Register Logic
    always @(posedge clk) begin
        if (reset) begin
            bit_cnt <= 0;
            data_reg <= 0;
        end else if (state == READ) begin
            bit_cnt <= bit_cnt + 1;
            // Shift right: newest bit goes into MSB, others slide toward LSB
            data_reg <= {in, data_reg[7:1]}; 
        end else begin
            bit_cnt <= 0;
            // Keep data_reg value until the next READ cycle
        end
    end
    
    // Next State Logic
    always @(*) begin 
        case (state)
            IDLE: next_state = (in == 0) ? READ : IDLE;
            READ: next_state = (bit_cnt == 4'd7) ? STOP : READ;
            STOP: next_state = (in == 1) ? DONE : WAIT;
            DONE: next_state = (in == 0) ? READ : IDLE;
            WAIT: next_state = (in == 1) ? IDLE : WAIT;
            default: next_state = IDLE;
        endcase
    end
    
    // Assignments
    assign done = (state == DONE);
    // The problem says out_byte is don't-care when done is 0,
    // so we can just wire it directly to our shift register.
    assign out_byte = data_reg;

endmodule