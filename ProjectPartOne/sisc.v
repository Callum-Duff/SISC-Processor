// ECE:3350 SISC processor project
// main SISC module, part 1

`timescale 1ns/100ps  

module sisc (clk, rst_f, ir);

  input clk, rst_f;
  input [31:0] ir;

// declare all internal wires here
  wire [3:0] mux4ToRF;
  wire [31:0] mux32ToRF;
  wire ctrlToRFrf_we;
  wire [31:0] rfToALUrsa;
  wire [31:0] rfToALUrsb;
  wire [1:0] ctrlToALUalu_op;
  wire [31:0] aluToMUX32;
  wire [3:0] aluToSTATstat;
  wire aluToSTATenable;
  wire ctrlToMUX32sel;
  wire [3:0] statToCTRLstat;
  wire sel;


// component instantiation goes here
  mux4 muxIR( ir[15:12], ir[23:20], 1'b0, mux4ToRF);
  rf register(clk, ir[19:16], mux4ToRF, ir[23:20], mux32ToRF, ctrlToRFrf_we, rfToALUrsa, rfToALUrsb);
  alu logicUnit(clk, rfToALUrsa, rfToALUrsb, ir[15:0], ctrlToALUalu_op, aluToMUX32, aluToSTATstat, aluToSTATenable);
  mux32 muxALU(aluToMUX32, 32'h00000000, ctrlToMUX32sel, mux32ToRF);   
  statreg status(clk, aluToSTATstat, aluToSTATenable, statToCTRLstat);
  ctrl control(clk, rst_f, ir[31:28], ir[27:24], statToCTRLstat, ctrlToRFrf_we, ctrlToALUalu_op, ctrlToMUX32sel);



  initial
    begin
      //monitor IR, R1-R6,RD_SEL,ALU_OP,WB_SEL,RF_WE, rf write_data
      $monitor("Time=%h, IR=%h,R1=%h, R2=%h, R3=%h, R4=%h, R5=%h, R6=%h, RD_SEL=%h, ALU_OP=%h, WB_SEL=%h, RF_WE=%h, WRITE_DATA=%h"
      ,$time,ir,register.ram_array[1],register.ram_array[2],register.ram_array[3],register.ram_array[4],register.ram_array[5],
      register.ram_array[6], 32'h00000000, ctrlToALUalu_op, ctrlToMUX32sel, ctrlToRFrf_we, mux32ToRF);
    end
  
// put a $monitor statement here.  



endmodule


