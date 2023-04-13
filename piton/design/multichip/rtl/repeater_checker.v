module repeater_checker (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input val1, 
	input [63:0] dat1, 
	input rdy1, 

	input val2, 
	input rdy2, 
	input [63:0] dat2

);

localparam BUFSIZE=64;
localparam PTR_WIDTH=6;

reg [63:0] buffer [BUFSIZE];
reg [PTR_WIDTH-1:0] in;
reg [PTR_WIDTH-1:0] out;
reg overflow;
reg extradata;
reg error;


wire go1 = rdy1 & val1;
wire go2 = rdy2 & val2;

reg [`NOC_DATA_WIDTH-1:0] dat2_except_mshr;
reg [`NOC_DATA_WIDTH-1:0] buffer_except_mshr;

always @(*) begin
	dat2_except_mshr = dat2;
	dat2_except_mshr[`MSG_MSHRID] = `MSG_MSHRID_WIDTH'b0;
	buffer_except_mshr = buffer[out];
	buffer_except_mshr[`MSG_MSHRID] = `MSG_MSHRID_WIDTH'b0;
end

always @(posedge clk) begin
	if(~rst_n) begin
		in <= {PTR_WIDTH{1'b0}};
		out <= {PTR_WIDTH{1'b0}};
		overflow <= 1'b0;
		extradata <= 1'b0;
		error <= 1'b0;
	end 
	else begin
		if (go1) begin
			in <= in + 6'd1;
			if (in + 6'd1 == out) begin
				overflow <= 1'b1;
			end
			buffer[in] <= dat1; 
		end
		if (go2) begin
			out <= out + 6'd1;
			if (out == in) begin
				extradata <= 1'b1;
			end
			if (dat2_except_mshr != buffer_except_mshr) begin
				error <= 1'b1;
			end
		end
	end
end


endmodule 