module DHT11_reader (
    input wire clk,
    inout wire data,
    output reg [7:0] temp,
    output reg [7:0] humidity,
    output reg [7:0] temp_fraction,
    output reg [7:0] humidity_fraction
);
    reg [39:0] data_buffer;
    reg [5:0] bit_index = 0;
    reg [19:0] counter = 0;
    reg [25:0] counter_new_temp = 0;
    reg previous_data;
    reg [2:0] state = 0;
    reg data_direction = 0;
	 reg data_reg;

    always @(posedge clk) begin
	 
		//Watchdog (if no correct read after 1s, reset)
		if (counter_new_temp > 50000000) begin
			state <= 0;
			bit_index <= 0;
			counter <= 0;
			counter_new_temp <= 0;
		end
		
		else begin
			counter_new_temp <= counter_new_temp +1;
		end
		
		//copy data to registry
		data_reg <= data;
		
		//temperature sensor handling
		case(state)
			//sending start signal
			0: begin
				 data_direction <= 0;
				 if (counter > 901000) begin // a little over 18ms start
					  counter <= 0;
					  data_direction <= 1;
					  state <= 1;
				 end else begin
					  counter <= counter + 1;
				 end
			end
			//wait for signal from sensor
			1: begin
				 if (~data_reg) state <= 2;
			end

			2: begin
				 if (data_reg) state <= 3;
			end

			3: begin
				 if (~data_reg) state <= 4;
			end
			
			4: begin
				 if (data_reg) state <= 5;
			end

			5: begin
				 if (~data_reg) state <= 6;
			end
			//receive data bits
			6: begin
				 if (bit_index < 40) begin
				 
						//save received bit
					  if (~data_reg && previous_data) begin
							// ~70us bit "1" (cheking if > 50us)
							if (counter > 2500) begin 
								 data_buffer[39-bit_index] <= 1;
							//26-28us bit "0"
							end else begin
								 data_buffer[39-bit_index] <= 0;
							end
							//preparing to receive next bit
							counter <= 0;
							bit_index <= bit_index + 1;
					  end
					  //data line high
					  if (data_reg) begin
							counter <= counter + 1;
					  end
				 end else begin
					 
					  humidity <= data_buffer[39:32];
					  humidity_fraction <= data_buffer[31:24];
					  temp <= data_buffer[23:16];
					  temp_fraction <= data_buffer[15:8];
					 
					  state <= 0;
					  bit_index <= 0;
					  counter <= 0;
					  counter_new_temp <= 0;
				 end
				 //saving previous state of data line to detect end of data bit
				 previous_data <= data_reg;
			end
	  endcase
    end
	
	//data line, high impadance or pull-down
    assign data = (data_direction) ? 1'bz : 0;
endmodule