library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CONTROL is
port (Instr : in std_logic_vector (31 downto 0);
		Reset: in std_logic;
	Zero : in std_logic;
	Clk : in std_logic;
	RF_WriteData_sel : out std_logic;
	MemWE : out std_logic;
	ALU_Bin_sel : out std_logic;
	PC_sel : out std_logic;
	PC_LdEn : out std_logic;
	RF_WrEn : out std_logic;
	isWord :out std_logic;
	RF_B_sel: out std_logic;
	ALU_func : out std_logic_vector (3 downto 0);
	reg_en : out std_logic_vector(5 downto 0)
	);
end CONTROL;

architecture Behavioral of CONTROL is

signal OpCode : std_logic_vector(5 downto 0); 
type state is (nop, choose_state, ALU_state,ALU_state_stage1, ALU_state_stage2, LoadImm_state, LoadImm_state_stage2, LoadImm_state_stage3, LogImm_state, LogImm_state_stage2, LogImm_state_stage3, b1, b1_2, b2, b2_2, l1, l1_stage2, l1_stage3, l2, l2_stage2, l2_stage3, s1, s1_stage2, s2, s2_stage2);
signal current_state, next_state: state;

begin
process(Instr, current_state, OpCode)
begin

case current_state is
	when choose_state =>
		OpCode <= Instr(31 downto 26);
		MemWE<='0';
		RF_WrEn<='0';
		isWord<='0';
		PC_Sel <='0';
		reg_en<="000001";
		
		If OpCode = "111000" or OpCode ="111001"  then
		   RF_B_sel <='1';
			next_state <= LoadImm_state;
		elsif OpCode = "111011" or Opcode = "110000" or Opcode = "110010" then
			RF_B_sel <='1';
			next_state <=LogImm_state;
		elsif OpCode = "111111" then
			RF_B_sel <='1';
			next_state <=b1;
		elsif OpCode = "010000" or Opcode = "010001"then
			RF_B_sel <='1';
			next_state<=b2;
		elsif OpCode = "000011" then
			RF_B_sel <='1';
			next_state <=l1;
		elsif OpCode = "000111" then
			RF_B_sel <='1';
			next_state<=s1;
		elsif OpCode = "001111" then
			RF_B_sel <='1';
			next_state<=l2;
		elsif OpCode = "011111" then
			RF_B_sel <='1';
			next_state<=s2;
		elsif Opcode = "100000" then
		   RF_B_sel <='0';
			next_state<=ALU_state;
		elsif Instr = "00000000000000000000000000000000" then
			next_state<=nop;
		else
			next_state<=choose_state;
			
			end if;	
		
	when ALU_state =>
		reg_en(0)<='0';
		reg_en(3 downto 1) <= "111";
		ALU_Bin_sel<='0';
		next_state <= ALU_state_stage1;
	
	when ALU_state_stage1 =>
		reg_en(3 downto 1) <="000";
		ALU_func <= Instr(3 downto 0);
		reg_en(4)<='1';
		PC_LdEN<='1';
		next_state<=ALU_state_stage2;
		
	when ALU_state_stage2 =>
		reg_en(4)<='0';
		RF_WrEn<='1';
		RF_WriteData_sel<='0';
		PC_LdEN<='0';
		next_state <= choose_state;
		

	when LoadImm_state =>
		ALU_func <= "0000";
		reg_en(0) <= '0';
		reg_en(3 downto 1) <= "111";
		RF_B_sel <= '1';
		ALU_Bin_sel <= '1';
		next_state <= LoadImm_state_stage2;
		
	when LoadImm_state_stage2 =>
		reg_en(3 downto 1) <= "000";
		reg_en(4)<='1';
		PC_LdEN<='1';
		next_state <= LoadImm_state_stage3;
	when LoadImm_state_stage3 =>
		reg_en(4)<='0';
		RF_WrEn <= '1';
		RF_WriteData_sel <= '0';
		PC_LdEN<='0';
		next_state <= choose_state;

		
	when LogImm_state =>
		ALU_func <= Instr(29 downto 26);
		reg_en<= "000001";
		reg_en(3 downto 1) <="111";
		RF_B_sel <= '1';
		ALU_Bin_sel <= '1';
		next_state <= LogImm_state_stage2;
		
	when LogImm_state_stage2 =>
		reg_en(3 downto 1) <= "000";
		reg_en(4)<='1';
		PC_LdEN<='1';
		next_state<=LogImm_state_stage3;
		
	when LogImm_state_stage3 =>
		reg_en(4)<='0';
		RF_WrEn<='1';
		RF_WriteData_sel<='0';
		PC_LdEN<='0';
		next_state<=choose_state;
		
	when b1 =>
		PC_sel<='1';
		PC_LdEN<='1';
		next_state<=b1_2;
		
	when b1_2=>
		PC_LdEN<='0';
		next_state<=choose_state;
		
		
	when b2 =>
		reg_en(0)<='0';
		reg_en(3 downto 1) <="111";
		ALU_func <= "0001";
		ALU_Bin_sel <='0';
		PC_LdEN<='1';

		next_state<=b2_2;
	
	when  b2_2 =>
		if OpCode = "010000" then --beq
			if Zero = '1' then
			PC_sel <='1';
			else
			PC_sel<='0';
			end if;
			
		elsif OpCode ="010001" then --bne
			if Zero = '1' then
			PC_sel <='0';
			else
			PC_sel<='1';
			end if;			
		end if;
		PC_LdEN<='0';
		next_state <= choose_state;
	

		
	when l1 =>
		reg_en(0)<='0';
		reg_en(3 downto 1) <="111";
		RF_B_sel<='1';
		ALU_Bin_sel<='1';
		next_state<= l1_stage2;
		
	when l1_stage2 =>
		reg_en(3 downto 1) <="000";
		reg_en(4)<='1';
		ALU_func<="0000";
		PC_LdEN<='1';
		next_state<=l1_stage3;
		
	when l1_stage3 =>
		reg_en(4)<='0';
		reg_en(5)<='1';
		RF_WrEn<='1';
		RF_WriteData_sel<='1';
		PC_LdEN<='0';
		next_state <=choose_state;
		
	when l2 =>
		reg_en(0)<='0';
		reg_en(3 downto 1) <="111";
		RF_B_sel<='1';
		ALU_Bin_sel<='1';
		isWord<='1';
		next_state<= l2_stage2;
		
	when l2_stage2 =>
		reg_en(3 downto 1) <= "000";
		reg_en(4) <='1';
		ALU_func<="0000";
		PC_LdEN<='1';
		next_state<=l2_stage3;
	
	when l2_stage3 =>
		reg_en(4) <='0';
		RF_WrEn<='1';
		RF_WriteData_sel<='1';
		MemWE <='0';
		PC_LdEN <='0';
		next_state<=choose_state;
		
	when s1 =>
		reg_en(0)<='0';
		reg_en(3 downto 1) <="111";
		RF_B_sel<='1';
		ALU_Bin_sel<='1';
		PC_LdEN<='1';
		next_state<= s1_stage2;
		
	when s1_stage2 =>
		reg_en(3 downto 1) <="000";
		reg_en(4)<='1';
		ALU_func <="0000";
		MemWE <='1';
		PC_LdEN <='0';
		next_state<=choose_state;
		
	when s2 =>
		reg_en(0)<='0';
		reg_en(3 downto 1) <="111";
		RF_B_sel<='1';
		ALU_Bin_sel<='1';
		PC_LdEN <= '1';
		isWord<='1';
		next_state<= s2_stage2;
		
	when s2_stage2 =>
		reg_en(3 downto 1) <="000";
		reg_en(4)<='1';
		ALU_func <="0000";
		MemWE <='1';
		PC_LdEn<='0';
		next_state<=choose_state;
		

	when nop =>
		RF_WrEn	<='0';
		MemWE <= '0';
		PC_Sel	<= '0';
		next_state	<= choose_state;
		
	end case;
end process;
process(Clk)
begin
if Clk='1' and Reset ='0' then
  current_state<=next_state;
elsif Clk = '0' and Reset ='0' then
  current_state <=current_state;
 else
	current_state<=choose_state;
end if;
end process;

end Behavioral;