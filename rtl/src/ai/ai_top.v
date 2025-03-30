module top_camera_integration (
    input wire clk,               // Pixel clock from the camera
    input wire reset_n,           // Reset signal, active low
    input wire in_vsync,          // Vertical sync signal from camera
    input wire in_hsync,          // Horizontal sync signal from camera
    input wire in_den,            // Data enable signal from camera
    input wire [23:0] cam_data,   // Camera input: 8-bit*3 channels (RGB)
    output wire out_vsync,        // Vertical sync signal for processed output
    output wire out_hsync,        // Horizontal sync signal for processed output
    output wire out_den,          // Data enable signal for processed output
    output wire [23:0] enhance_image // Enhanced output image: 8-bit*3 channels (RGB)
);

    // Internal wires
    wire [767:0] x_r;             // Intermediate result from FINN: 32-bit*24 channels
    wire valid_finn_out;          // Valid signal from FINN module
    wire valid_enhance_out;       // Valid signal for final output

    // Synchronize input signals
    reg in_vsync_sync, in_hsync_sync, in_den_sync;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            in_vsync_sync <= 0;
            in_hsync_sync <= 0;
            in_den_sync <= 0;
        end else begin
            in_vsync_sync <= in_vsync;
            in_hsync_sync <= in_hsync;
            in_den_sync <= in_den;
        end
    end

    // FINN design wrapper instantiation
    finn_design_wrapper finn_design_inst (
        .ap_clk(clk),
        .ap_rst_n(reset_n),
        .s_axis_0_tdata(cam_data),  // Camera data as input: 8-bit*3 channels
        .s_axis_0_tvalid(in_den_sync), // Data valid based on in_den
        .s_axis_0_tready(),        // Not used
        .m_axis_0_tdata(x_r),      // Output from FINN: 32-bit*24 channels
        .m_axis_0_tvalid(valid_finn_out),
        .m_axis_0_tready(1'b1)     // Always ready to accept FINN output
    );

    // Enhancement processing module instantiation
    enhance_image_processing enhance_proc_inst (
        .clk(clk),
        .rst_n(reset_n),
        .valid_in(valid_finn_out), // Trigger enhancement when FINN output is valid
        .x_in(cam_data),           // Original input: 8-bit*3 channels (RGB)
        .x_r(x_r),                 // FINN intermediate result: 32-bit*24
        .enhance_image(enhance_image), // Final enhanced image: 8-bit*3 channels (RGB)
        .valid_out(valid_enhance_out) // Enhanced data valid signal
    );

    // Output synchronization
    reg out_vsync_reg, out_hsync_reg, out_den_reg;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_vsync_reg <= 0;
            out_hsync_reg <= 0;
            out_den_reg <= 0;
        end else begin
            out_vsync_reg <= in_vsync_sync;
            out_hsync_reg <= in_hsync_sync;
            out_den_reg <= valid_enhance_out; // Output valid when enhancement is done
        end
    end

    // Assign synchronized signals to outputs
    assign out_vsync = out_vsync_reg;
    assign out_hsync = out_hsync_reg;
    assign out_den = out_den_reg;

endmodule
