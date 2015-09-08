module robo (
    clk,
    led0, led1, led2, led3, led4, led5, led6, led7,
    servo0, servo1, servo2, servo3
);

input clk /* synthesis chip_pin = "R8" */;
output reg led0 /* synthesis chip_pin = "A15" */;
output reg led1 /* synthesis chip_pin = "A13" */;
output reg led2 /* synthesis chip_pin = "B13" */;
output reg led3 /* synthesis chip_pin = "A11" */;
output reg led4 /* synthesis chip_pin = "D1" */;
output reg led5 /* synthesis chip_pin = "F3" */;
output reg led6 /* synthesis chip_pin = "B1" */;
output reg led7 /* synthesis chip_pin = "L3" */;

output reg servo0 /* synthesis chip_pin = "B5" */; // JP1.10 GPIO_07
output reg servo1 /* synthesis chip_pin = "B4" */; // JP1.08 GPIO_05
output reg servo2 /* synthesis chip_pin = "A3" */; // JP1.06 GPIO_03
output reg servo3 /* synthesis chip_pin = "C3" */; // JP1.04 GPIO_01
/*

0.6..2.4 ms. = -90..+90 deg.   20ms -- repeat


1 ms / 40 ns = 25000 / 1024 = 24.4 [run[10]]

*/

/*
0  -- 25 MHz  40 ns
1  -- 12.5
2  -- 6.25
3  -- 3.125
4  -- 1.5
5  -- 781 KHz
6  -- 391
7  -- 195
8  -- 98khz
9  -- 49khz
10 -- 24khz
11
12
13
14
15
16
17

*/

// prescaller

reg [31:0] run;

always @(posedge clk)
    run <= run + 32'b1;


// memory
reg [63:0] mem [0:255];
reg [63:0] data;
reg [7:0] ptr;

initial begin
    $readmemh("ram.txt", mem);
end

always @*
    data = mem[ptr];


// memory fetch timer
reg [31:0] tf;
reg tf_reset;
reg tf_en;

always @*
    tf_reset = (tf === 32'd600);

always @*
    tf_en = &run[10:0]; // T = 40.96 us

always @(posedge clk)
    if (tf_en) begin
        if (tf_reset) begin
            tf <= 32'b0;
        end else begin
            tf <= tf + 32'b1;
        end
    end


always @(posedge clk)
    if (tf_en & tf_reset)
        ptr <= ptr + 1;

// pulse timer 0
reg [15:0] t0;
reg t0_valid;

always @*
    t0_valid = |t0;

always @(posedge clk)
    if (tf_en) begin
        if (tf_reset) begin
            t0 <= data[15:0];
        end else begin
            if (t0_valid) begin
                t0 <= t0 - 16'b1;
            end
        end
    end

// pulse timer 0
reg [15:0] t1;
reg t1_valid;

always @*
    t1_valid = |t1;

always @(posedge clk)
    if (tf_en) begin
        if (tf_reset) begin
            t1 <= data[31:16];
        end else begin
            if (t1_valid) begin
                t1 <= t1 - 16'b1;
            end
        end
    end

// pulse timer 0
reg [15:0] t2;
reg t2_valid;

always @*
    t2_valid = |t2;

always @(posedge clk)
    if (tf_en) begin
        if (tf_reset) begin
            t2 <= data[47:32];
        end else begin
            if (t2_valid) begin
                t2 <= t2 - 16'b1;
            end
        end
    end

// pulse timer 0
reg [15:0] t3;
reg t3_valid;

always @*
    t3_valid = |t3;

always @(posedge clk)
    if (tf_en) begin
        if (tf_reset) begin
            t3 <= data[63:48];
        end else begin
            if (t3_valid) begin
                t3 <= t3 - 16'b1;
            end
        end
    end

always @* begin
    servo0 = t0_valid;
    servo1 = t1_valid;
    servo2 = t2_valid;
    servo3 = t3_valid;
    led0 = run[24];
    led1 = run[25];
    led2 = run[26];
    led3 = run[27];
    led4 = run[28];
    led5 = run[29];
    led6 = run[30];
    led7 = run[31];
end

endmodule
