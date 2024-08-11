module encoder_8_to_3 (
    input [7:0] in,
    output reg [2:0] encoded_out,
    output reg valid
);
    always @(*) begin
        valid = 1'b0;
        case (in)
            8'b00000001: begin encoded_out = 3'b000; valid = 1'b1; end
            8'b00000010: begin encoded_out = 3'b001; valid = 1'b1; end
            8'b00000100: begin encoded_out = 3'b010; valid = 1'b1; end
            8'b00001000: begin encoded_out = 3'b011; valid = 1'b1; end
            8'b00010000: begin encoded_out = 3'b100; valid = 1'b1; end
            8'b00100000: begin encoded_out = 3'b101; valid = 1'b1; end
            8'b01000000: begin encoded_out = 3'b110; valid = 1'b1; end
            8'b10000000: begin encoded_out = 3'b111; valid = 1'b1; end
            default: begin encoded_out = 3'b000; valid = 1'b0; end
        endcase
    end
endmodule

module shift_register (
    input clk,
    input reset,
    input [2:0] data_in,
    output reg [7:0] shift_out
);
    reg [7:0] shift_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            shift_reg <= 8'b0;
        else
            shift_reg <= {shift_reg[6:0], data_in[0]};
    end
    
    always @(*) begin
        shift_out = shift_reg;
    end
endmodule

module decoder_3_to_8 (
    input [2:0] encoded_in,
    input valid,
    output reg [7:0] decoded_out
);
    always @(*) begin
        decoded_out = 8'b00000000;
        if (valid) begin
            case (encoded_in)
                3'b000: decoded_out = 8'b00000001;
                3'b001: decoded_out = 8'b00000010;
                3'b010: decoded_out = 8'b00000100;
                3'b011: decoded_out = 8'b00001000;
                3'b100: decoded_out = 8'b00010000;
                3'b101: decoded_out = 8'b00100000;
                3'b110: decoded_out = 8'b01000000;
                3'b111: decoded_out = 8'b10000000;
                default: decoded_out = 8'b00000000;
            endcase
        end
    end
endmodule

module top_module (
    input clk,
    input reset,
    input [7:0] data_in,
    output [7:0] data_out,
    output valid
);
    wire [2:0] encoded_data;
    wire valid_encoded;
    wire [7:0] shifted_data;

    encoder_8_to_3 encoder (
        .in(data_in),
        .encoded_out(encoded_data),
        .valid(valid_encoded)
    );

    shift_register shift_reg (
        .clk(clk),
        .reset(reset),
        .data_in(encoded_data),
        .shift_out(shifted_data)
    );

    decoder_3_to_8 decoder (
        .encoded_in(encoded_data),
        .valid(valid_encoded),
        .decoded_out(data_out)
    );

    assign valid = valid_encoded;

endmodule

module tb_top_module;
    reg clk;
    reg reset;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire valid;

    top_module uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .valid(valid)
    );

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        data_in = 8'b00000001;
        #50 data_in = 8'b00000010;
        #50 data_in = 8'b00000100;
        #50 data_in = 8'b00001000;
        #50 data_in = 8'b00010000;
        #50 data_in = 8'b00100000;
        #50 data_in = 8'b01000000;
        #50 data_in = 8'b10000000;
        #50 $finish;
    end

    always #5 clk = ~clk;

    initial begin
        $monitor("Time: %0t, Input Data: %b, Output Data: %b, Valid: %b", $time, data_in, data_out, valid);
    end
endmodule

