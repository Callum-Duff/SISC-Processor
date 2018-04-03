// ECE:3350 SISC processor project
// 32-bit mux

`timescale 1ns/100ps

module mux32 (in_a, in_b, in_c, in_d, sel, out);

  /*
   *  32-BIT MULTIPLEXER - mux32.v
   *
   *  Inputs:
   *   - in_a = output alu_result from alu (32 bits): First input to multiplexer. Selected when sel = 00.
   *   - in_b = output from dm (32 bits): Second input. Selected when sel = 01.
   *   - in_c = register A (Rs) (32 bits): Second input. Selected when sel = 10.
   *   - in_d = register B (Rd) (32 bits): Second input. Selected when sel = 11.
   *   - sel = output wb_sel (2 bits) from ctrl: Selects which input propagates to output.
   *
   *  Outputs:
   *   - out = input write_data of rf (32 bits): Multiplexer output.
   *
   */

  input  [31:0] in_a;
  input  [31:0] in_b;
  input  [31:0] in_c;
  input  [31:0] in_d;
  input  [1:0]  sel;
  output [31:0] out;

  reg   [31:0] outreg;
   
  always @ (in_a, in_b, in_c, in_d, sel)
  begin
    if (sel == 2'b00)
    begin
      outreg = in_a;
    end
    else if (sel == 2'b01)
    begin
      outreg = in_b;
    end
    else if (sel == 2'b10)
    begin
      outreg = in_c;
    end
    else if (sel == 2'b11)
    begin
      outreg = in_d;
    end
  end

  assign out = outreg;

endmodule
