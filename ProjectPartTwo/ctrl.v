// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

//                                       BR      Mux4    IR             PC
//New output signals added in part 2: br_sel, rb_sel, ir_load, pc_sel, pc_write, pc_rst
module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel, br_sel, rb_sel, ir_load, pc_sel, pc_write, pc_rst);

 

 /*
   *  Control unit FILE - ctrl.v
   *
   *  Inputs:
   *   - clk : System clock, positive edge active
   *   - rst_f: Reset
   *   - opcode = instr [31:28] (4 bits): 
   *   - mm  = instr [27:24] (4 bits): 
   *   - stat = output out from statreg (4 bits): 
   *
   *  Outputs:
   *    
   *   - rf_we = input rf_we in rf : Write enable. When this is set to 1, the data on write_data
   *        is copied into register write_reg.
   *   - alu_op = input alu_op in alu (2 bits): This control line allows the control unit to override the
   *        usual function of the ALU to perform specific operations. When bit 1 is set
   *        to 1, the control unit is telling the ALU that the instruction being
   *        executed is not an arithmetic operation, and thus, the status code should
   *        not be saved to the status register. For loads and stores, though, the ALU
   *        may still be needed. When bit 0 is set to 1, the immediate value is used
   *        as the second operand to the adder, rather than RB.
   *    - wb_sel = input sel in mux32 : 0 selects alu_result, 1 selects 0
   *
   */
  
  /* TODO: Declare the ports listed above as inputs or outputs */
  //inputs part 1
  input clk;
  input rst_f;
  input [3:0] opcode;
  input [3:0] mm;
  input [3:0] stat;

  //outputs part 1
  output rf_we;
  output [1:0] alu_op;
  output wb_sel;
  
  reg rf_we;
  reg [1:0] alu_op;
  reg wb_sel;
  
  
  //outputs part 2
  output reg br_sel, rb_sel, ir_load, pc_sel, pc_write, pc_rst;
  
  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes
  parameter NOOP = 0, LOD = 1, STR = 2, SWP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7, ALU_OP = 8, HLT=15;
	
  // addressing modes
  parameter am_imm = 8;

  // state registers
  reg [2:0]  present_state, next_state;

  initial
    present_state = start0;

  /* TODO: Write a sequential procedure that progresses the fsm to the next state on the
       positive edge of the clock, OR resets the state to 'start1' on the negative edge
       of rst_f. Notice that the computer is reset when rst_f is low, not high. */
/* TODO: Write a combination procedure that determines the next state of the fsm. */
  always @ (posedge clk, negedge rst_f)
  begin
	if (rst_f==0) //reset is low
	begin
	  next_state<=start1;
	  pc_rst <= 1'b1;
	end
	else
        begin
          present_state <= next_state;
	end  
  end 

  always @ (present_state)
  begin
      if (present_state == start0)
	  begin
		next_state = start1;
	  end
	  else if (present_state == start1)
	  begin
		next_state = fetch;
	  end
	  else if (present_state == fetch)
	  begin
		next_state = decode;
	  end
	  else if (present_state == decode)
	  begin
		next_state = execute;
	  end
	  else if (present_state == execute)
	  begin
		next_state = mem;
	  end
	  else if (present_state == mem)
	  begin
		next_state = writeback;
	  end
	  else if (present_state == writeback)
	  begin
		next_state = fetch;
	  end
  end

  
  

  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2, 3 and 4 you will
       add the new control signals here. */
  //Part 1: NOP, ADD, ADI, ADD IMM, SUB, NOT, OR, AND, XOR, ROTR, ROTL, SHFR, SHFL, HLT
  //Part 2: BRA, BRR, BNE = branch of not equal, BNR
  always @ (present_state, opcode, mm)
    begin
	//default values part 1
	rf_we <= 1'b0;
	alu_op <= 2'b10;
	wb_sel <= 1'b0;
	
	//default values part 2
	pc_sel <= 1'b1; //By default save branch address , don't increment the pc
	pc_write <= 1'b0; //By default, don't save selected value/overrite saved value
	pc_rst <= 1'b0; //Don't reset the pc!!
	
	br_sel <= 1'b0; //by default, relative branch
	rb_sel <= 1'b0; //default select value for mux4 b/c 0 from part1
	ir_load <= 1'b0; //by default don't load the read_data into the instruction register
	
	
  	if (opcode == NOOP) //NOP
	begin
	  alu_op <= 2'b00;
          wb_sel <= 1'b1; //load 0
	end

	else if (present_state == fetch) //increment pc
	begin
	  pc_sel <= 1'b0; //inc pc: PC <- [PC] + 1
          ir_load <= 1'b1; //IR <- Memory data
	end

	else if (present_state == decode) 
	begin
	  if (opcode == BRR || opcode == BNR) 
          begin
            br_sel <= 1'b0; //relative branch
          end
	  else //if (opcode == BRA || opcode == BNE) or everything else
	  begin 
	    br_sel <= 1'b1; //absolut(e) (vodka) branch
	  end
	  
	end

	else if (present_state == execute)
	begin

	  if (opcode == BRA || opcode == BRR || opcode == BNE || opcode == BNR) //branches
          begin
	    if(mm == 4'b0000) // unconditional branch (fig 5.15)
	    begin
	      pc_sel <= 1'b1; //get branch address
            end
	    else if (mm == stat) //are equal
	      if(opcode == BNE) //BNE?
              begin
                pc_sel <= 1'b0; //don't branch
              end
              else if(opcode == BRA && opcode == BRR)
              begin
                pc_sel <= 1'b1; //branch
              end
            else //not equal
              if(opcode == BNE) //BRE?
              begin
                pc_sel <= 1'b1; // branch
              end
              else if(opcode == BRA && opcode == BRR)
              begin
                pc_sel <= 1'b0; //don't branch
              end
	  end 
	  
	  else if (opcode == ALU_OP && mm == 4'b1000) //ADI
	  begin
            alu_op <= 2'b01; //arithmetic, uses immediate
          end
          else //The rest of the arithmetic operations: ADD, ADD IMM, SUB, NOT, OR, AND, XOR, ROTR, ROTL, SHFR, SHFL
          begin
	    alu_op <= 2'b00; //arithmetic, does not use immediate
          end
	end

	else if (present_state == mem) //no memory access needed in this part
	begin
	  if (opcode == ALU_OP && mm == 4'b1000) //ADI
	  begin
              alu_op <= 2'b11; //save stat reg, uses immediate
          end
          else //The rest of the arithmetic operations: ADD, ADD IMM, SUB, NOT, OR, AND, XOR, ROTR, ROTL, SHFR, SHFL
          begin
	    alu_op <= 2'b10; //save stat reg, does not use immediate
          end
	end

	else if (present_state == writeback) // only write in writeback
	begin
          rf_we <= 1'b1; //write
          pc_write <= 1'b1; //save the value: Memory address <- [PC]
	end

    end



// Halt on HLT instruction
  
  always @ (opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 5 ns so $monitor will print the halt instruction
      $stop;
    end
  end
    
  
endmodule
