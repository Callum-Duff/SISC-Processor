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
  wire [1:0] ctrlToMUX32sel; //changed
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
  
  //mux16 new wires
  wire [1:0] mm_sel; //changed for part 4
  wire [15:0] mux16out;
  
  //DM new wires
  wire [31:0] dm_out;
  wire dm_we; //connects to control unit

  //mux4 for rd/rs
  wire [3:0] write_reg; //write register rs or rd
  wire wr_sel; //select for rd or rs 

  //----------------------------------------------------------------------------
  //---------------Part 3 swap component instantiation goes here----------------
  mux4 writeSel(instr[23:20], instr[19:16], wr_sel, write_reg);
  
  //-----------------------------------------------------------------------------
  //---------------Part 3 component instantiation goes here----------------------
  mux16 dm_mux16(aluToMUX32[15:0], instr[15:0], rfToALUrsa[15:0], mm_sel, mux16out); //changed for Part 4
  dm data_module(mux16out, mux16out, rfToALUrsb, dm_we, dm_out);
  
  //---------------Part 2 component instantiation goes here----------------------
  ir instructionRegister(clk, ir_load, read_data, instr);
  im instructionMemory(pc, read_data);
  br branchRegister(pc, instr[15:0], br_sel, br_addr);
  pc programCounter(clk, br_addr, pc_sel, pc_write, pc_rst, pc);
  //-----------------------------------------------------------------------------
  
  ////---------------Part 1 component instantiation goes here--------------------
  mux4 muxIR( instr[15:12], instr[23:20], rb_sel, mux4ToRF);
  rf register(clk, instr[19:16], mux4ToRF, /*instr[23:20]*/ write_reg, mux32ToRF, ctrlToRFrf_we, rfToALUrsa, rfToALUrsb); //changed
  alu logicUnit(clk, rfToALUrsa, rfToALUrsb, instr[15:0], ctrlToALUalu_op, aluToMUX32, aluToSTATstat, aluToSTATenable);
  mux32 muxALU(aluToMUX32, dm_out, rfToALUrsa, rfToALUrsb,  ctrlToMUX32sel, mux32ToRF);  //changed for SWP
  statreg status(clk, aluToSTATstat, aluToSTATenable, statToCTRLstat);
  ctrl control(clk, rst_f, instr[31:28], instr[27:24], statToCTRLstat, ctrlToRFrf_we, ctrlToALUalu_op, ctrlToMUX32sel, br_sel, rb_sel, ir_load, pc_sel, pc_write, pc_rst, mm_sel, dm_we, wr_sel);
  //-----------------------------------------------------------------------------


  initial
    begin
      //monitor IR, R1-R6,RB_SEL,ALU_OP,WB_SEL,RF_WE, rf write_data, pc, pc_write, pc_sel, br_sel
      /*$monitor("IR=%h,R0=%h,R1=%h, R2=%h, R3=%h, R4=%h, R5=%h, RB_SEL=%h, ALU_OP=%h, WB_SEL=%h, RF_WE=%h, WRITE_DATA=%h, write_addr=%h, PC=%h, PC_WRITE=%h, PC_SEL=%h, BR_SEL=%h, MM_SEL=%h, DM_WE=%h, m[8]=%h, m[9]=%h, wr_sel=%h ",
	  instr,register.ram_array[0],register.ram_array[1],register.ram_array[2],register.ram_array[3],register.ram_array[4],register.ram_array[5],
       rb_sel, ctrlToALUalu_op, ctrlToMUX32sel, ctrlToRFrf_we, mux32ToRF, mux16out, pc, pc_write, pc_sel, br_sel, mm_sel, dm_we, data_module.ram_array[8],data_module.ram_array[9], wr_sel);*/
	$monitor("IR=%h, R1=%h, R2=%h, R3=%h, R4=%h, R5=%h, R6=%h, m[0]=%h, m[1]=%h, m[2]=%h, m[3]=%h, m[4]=%h, m[5]=%h, m[6]=%h, m[7]=%h, m[8]=%h, m[9]=%h" , 
	instr,register.ram_array[1],register.ram_array[2],register.ram_array[3],register.ram_array[4],register.ram_array[5],register.ram_array[6],data_module.ram_array[0], data_module.ram_array[1], data_module.ram_array[2],
 data_module.ram_array[3],data_module.ram_array[4],data_module.ram_array[5],data_module.ram_array[6],data_module.ram_array[7],data_module.ram_array[8],data_module.ram_array[9]);
    end
  
// put a $monitor statement here.  



endmodule


