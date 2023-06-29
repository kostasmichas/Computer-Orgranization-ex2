library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DATAPATH is
	port(clk: in std_logic; 
	rst :in std_logic);
end DATAPATH;

architecture Behavioral of DATAPATH is

signal ALU_func :std_logic_vector (3 downto 0);

signal rf_w_s :std_logic;
signal pc_s :std_logic;
signal alu_b_s :std_logic;
signal mwe:std_logic;
signal isw :std_logic;
signal rf_w_e:std_logic;
signal pc_l_e:std_logic;
signal rf_b_s:std_logic;
signal zero: std_logic;

signal reg_1_in: std_logic_vector(31 downto 0);
signal reg_1_out:std_logic_vector(31 downto 0);
signal reg_2_in: std_logic_vector(31 downto 0);
signal reg_2_out:std_logic_vector(31 downto 0);
signal reg_3_in: std_logic_vector(31 downto 0);
signal reg_3_out:std_logic_vector(31 downto 0);
signal reg_4_in: std_logic_vector(31 downto 0);
signal reg_4_out:std_logic_vector(31 downto 0);
signal reg_5_in: std_logic_vector(31 downto 0);
signal reg_5_out:std_logic_vector(31 downto 0);
signal reg_6_in: std_logic_vector(31 downto 0);
signal reg_6_out:std_logic_vector(31 downto 0);

signal reg_en : std_logic_vector(5 downto 0);


component reg is
port (CLK : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           WE : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;


component CONTROL is
port(Instr : in std_logic_vector (31 downto 0);
	Reset : in std_logic;
	Clk : in std_logic;
	RF_WriteData_sel : out std_logic;
	MemWE : out std_logic;
	ALU_Bin_sel : out std_logic;
	PC_sel : out std_logic;
	PC_LdEn : out std_logic;
	RF_WrEn : out std_logic;
	isWord :out std_logic;
	RF_B_sel: out std_logic;
	ALU_func: out std_logic_vector (3 downto 0);
	Zero : in std_logic;
	reg_en : out std_logic_vector(5 downto 0)
	);
end component;

component IFSTAGE is
port(PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           PC_sel : in  STD_LOGIC;
           PC_LdEn : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Instr : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component DECSTAGE is
port(Instr : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrEn : in  STD_LOGIC;
           ALU_out : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_out : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrData_sel : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
			  Clk : in  STD_LOGIC;
			  Immed : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : out  STD_LOGIC_VECTOR (31 downto 0));
			  
end component;

component EXECSTAGE is
port(RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_Bin_sel : in  STD_LOGIC;
           ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
           ALU_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  Zero: out std_logic);

end component;

component MEM_STAGE is
port(clk : in  STD_LOGIC;
			  isWord : in std_logic;
           Mem_WrEN : in  STD_LOGIC;
           ALU_MEM_Addr : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataIn : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataOut : out  STD_LOGIC_VECTOR (31 downto 0));

end component;

begin
process(reg_1_in)
begin



end process;

reg_1: reg port map(CLK =>Clk,Data=>reg_1_in,WE=>reg_en(0),Dout=>reg_1_out);
reg_2: reg port map(CLK =>Clk,Data=>reg_2_in,WE=>reg_en(1),Dout=>reg_2_out);
reg_3: reg port map(CLK =>Clk,Data=>reg_3_in,WE=>reg_en(2),Dout=>reg_3_out);
reg_4: reg port map(CLK =>Clk,Data=>reg_4_in,WE=>reg_en(3),Dout=>reg_4_out);
reg_5: reg port map(CLK =>Clk,Data=>reg_5_in,WE=>reg_en(4),Dout=>reg_5_out);
reg_6 :reg port map(CLK =>Clk,Data=>reg_6_in,WE=>reg_en(5),Dout=>reg_6_out);

if_s :IFSTAGE port map(PC_Immed =>reg_4_in,PC_sel =>pc_s,PC_LdEn =>pc_l_e,Reset =>rst ,Clk=>Clk ,Instr =>reg_1_in);
dec_s :DECSTAGE port map(Instr=>reg_1_out,RF_WrEn=>rf_w_e,ALU_out=>reg_5_out,MEM_out =>reg_6_out,RF_WrData_sel=>rf_w_s,RF_B_sel =>rf_b_s,Clk =>clk ,Immed =>reg_4_in,RF_A =>reg_2_in ,RF_B =>reg_3_in);
exec_s: EXECSTAGE port map(RF_A=>reg_2_out,RF_B=>reg_3_out,Immed=>reg_4_out,ALU_Bin_sel=>alu_b_s,ALU_func=>ALU_func,ALU_out=>reg_5_in, Zero =>zero);
mem_s : MEM_STAGE port map(clk => clk,isWord=>isw,Mem_WrEn=>mwe,ALU_MEM_Addr =>reg_5_out,MEM_DataIn=>reg_3_out,MEM_DataOut=>reg_6_in);    
ctrl : CONTROL port map(Instr =>reg_1_in, Reset =>rst ,Clk=>clk,RF_WriteData_sel=>rf_w_s,MemWE =>mwe,ALU_Bin_sel=>alu_b_s,PC_sel=>pc_s,PC_LdEn=>pc_l_e ,RF_WrEn =>rf_w_e, isWord=> isw ,RF_B_sel=>rf_b_s,ALU_func=>ALU_func, Zero=>zero, reg_en => reg_en);
 
end Behavioral;