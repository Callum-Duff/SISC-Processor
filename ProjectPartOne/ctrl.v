// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel);

 

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
  //inputs
  input clk;
  input rst_f;
  input [3:0] opcode;
  input [3:0] mm;
  input [3:0] stat;
 
  //outputs
  output reg rf_we;
  output reg [1:0] alu_op;
  output reg wb_sel;
  
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
  always @ (posedge clk or negedge rst_f)
  begin
	if (rst_f==0) //reset is low
	begin
	  present_state <= start1; //does in sync with clock
	end
	else
	begin
          present_state <= next_state;
	end  
  end 


  
  /* TODO: Write a combination procedure that determines the next state of the fsm. */
  always @(present_state) // when present_state is changed need to update next_state
    begin
  	if (present_state == start0)
	begin
		next_state <= start1;
	end
	else if (present_state == start1)
	begin
		next_state <= fetch;
	end
	else if (present_state == fetch)
	begin
		next_state <= decode;
	end
	else if (present_state == decode)
	begin
		next_state <= execute;
	end
	else if (present_state == execute)
	begin
		next_state <= mem;
	end
	else if (present_state == mem)
	begin
		next_state <= writeback;
	end
    end


  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2, 3 and 4 you will
       add the new control signals here. */
  //Part 1: NOP, ADD, ADI, ADD IMM, SUB, NOT, OR, AND, XOR, ROTR, ROTL, SHFR, SHFL, HLT
  always @ (posedge clk)
    begin
  	if (opcode == NOOP) //NOP
	begin
	  rf_we <= 1'b0; //don't write
	  alu_op <= 2'b10; //bit 1 set to 1 so stat reg not changed
          wb_sel <= 1'b1; //load 0
	  
	end

	else if (opcode == LOD) //LDX, LDA, LDP, LDR
	begin
	
	end

	else if (opcode == STR) //
	begin
	
	end

	else if (opcode == SWP)
	begin
	
	end

	else if (opcode == BRA)
	begin
	
	end

	else if (opcode == BRR)
	begin
	
	end

	else if (opcode == BNE)
	begin
	
	end

	else if (opcode == ALU_OP)
	begin
	  if (mm == 4'b1000) //ADI
	  begin
	    
	  end

	  else if (mm == 4'b0000 && stat == 4'b0001) //ADD
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b0010) //SUB
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b0100) //NOT
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b0101) //OR
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b0110) //AND
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b0111) //XOR
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b1000) //RTR
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b1001) //RTL
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b1010) //SHR
	  begin

	  end

	  else if (mm == 4'b0000 && stat == 4'b1011) //SHL
	  begin

	  end
	
	end

	else if (opcode == HLT)
	begin
	
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
