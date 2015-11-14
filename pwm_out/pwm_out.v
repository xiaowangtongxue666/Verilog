module pwm_out(
	input	      clk,
	input	      nRst,
   input       pwm_clk, // Clock running at best resolution (out = pwm_clk/256)   
   input [7:0] duty,    // Duty 0..255
   input       update,  // Output a new duty
   output      out
);

   reg   [7:0] flip;
   reg   [7:0] count; 
   reg         pwm_clk_last; 
   reg         out_reg;

   wire        pwm_clk_rise;

   assign pwm_clk_rise  = pwm_clk & ~pwm_clk_last;

   assign hit_top       =  (count == 8'hFF)   ?  1'b1 : 1'b0;

   assign hit_flip      =  (count == flip)    ?  1'b1 : 1'b0; 

   assign out           =  (flip == 8'h00)    ?  1'b0 :
                           (flip == 8'hFF)    ?  1'b1 :
                                             out_reg;

   always @(posedge clk or negedge nRst) begin
      pwm_clk_last <= pwm_clk;
      casex({nRst,update,pwm_clk_rise,hit_top,hit_flip}) 
         5'b0xxxx:  begin
                        out_reg  <= 1'b1;
                        flip     <= 8'h00;
                        count    <= 8'h00; 
                     end
         5'b1001x:  begin
                        count    <= 8'h00;
                        out_reg  <= 1'b1;
                     end
         5'b1010x:  begin
                        count    <= count + 1'b1;
                     end
         5'b101x1:  begin
                        out_reg  <= 1'b0;
                     end
         5'b11xxx:  begin
                        flip     <= duty;
                     end
      endcase
   end
endmodule
