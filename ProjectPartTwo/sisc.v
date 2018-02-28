// ECE:3350 SISC processor project
// main SISC module, part 1

`timescale 1ns/100ps  

module sisc (clk, rst_f);

  input clk, rst_f;
  

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

  //---------------Part 2 internal wires-----------------------------------------
  //Instruction register wires
  wire [31:0] instr;
  wire ir_load;
  wire [31:0] read_data;
  
  //Instruction memory wires
  wire [15:0] read_addr;
  
  //Branch register wires
  wire [15:0] pc;
  wire br_sel;
  wire [15:0] br_addr;
  
  //PC wires
  wire pc_sel;
  wire pc_write;
  wire pc_rst;
  
  //mux4 new wire
  wire rb_sel;
  
  //-----------------------------------------------------------------------------
  
  //---------------Part 2 component instantiation goes here----------------------
  ir instructionRegister(clk, ir_load, read_data, instr);
  im instructionMemory(pc, read_data);
  br branchRegister(pc, instr[15:0], br_sel, br_addr);
  pc programCounter(clk, br_addr, pc_sel, pc_write, pc_rst, pc);
  //-----------------------------------------------------------------------------
  
  ////---------------Part 1 component instantiation goes here--------------------
  mux4 muxIR( instr[15:12], instr[23:20], rb_sel, mux4ToRF);
  rf register(clk, instr[19:16], mux4ToRF, instr[23:20], mux32ToRF, ctrlToRFrf_we, rfToALUrsa, rfToALUrsb);
  alu logicUnit(clk, rfToALUrsa, rfToALUrsb, instr[15:0], ctrlToALUalu_op, aluToMUX32, aluToSTATstat, aluToSTATenable);
  mux32 muxALU(aluToMUX32, 32'h00000000, ctrlToMUX32sel, mux32ToRF);   
  statreg status(clk, aluToSTATstat, aluToSTATenable, statToCTRLstat);
  ctrl control(clk, rst_f, instr[31:28], instr[27:24], statToCTRLstat, ctrlToRFrf_we, ctrlToALUalu_op, ctrlToMUX32sel, br_sel, rb_sel, ir_load, pc_sel, pc_write, pc_rst);
  //-----------------------------------------------------------------------------


  initial
    begin
      //monitor IR, R1-R6,RD_SEL,ALU_OP,WB_SEL,RF_WE, rf write_data, pc, pc_write, pc_sel, br_sel
      $monitor("Time=%h, IR=%h,R1=%h, R2=%h, R3=%h, R4=%h, R5=%h, R6=%h, RD_SEL=%h, ALU_OP=%h, WB_SEL=%h, RF_WE=%h, WRITE_DATA=%h, PC=%h, PC_WRITE=%h, PC_SEL=%h, BR_SEL=%h"
      ,$time,instr,register.ram_array[1],register.ram_array[2],register.ram_array[3],register.ram_array[4],register.ram_array[5],
      register.ram_array[6], 32'h00000000, ctrlToALUalu_op, ctrlToMUX32sel, ctrlToRFrf_we, mux32ToRF, pc, pc_write, pc_sel, br_sel);
    end
  
// put a $monitor statement here.  



endmodule


