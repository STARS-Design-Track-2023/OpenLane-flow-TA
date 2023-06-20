// File name:   sample_rate_clkdiv.sv
// Author:      Vishnu Lagudu
// Description: Tells the Wave-Shaper when to sample

module sample_rate_clkdiv 
(
    input  wire clk,
    input  wire n_rst,
    output wire  divide_now
);

reg [7:0] counter; 

always @ (posedge clk, negedge n_rst) begin
    if (~n_rst) begin
        counter <= 8'b0;
    end else begin
        counter <= counter + 1;
    end
end

assign divide_now = (counter == 8'd255) ? 1'b1 : 1'b0; 

endmodule