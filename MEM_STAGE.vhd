library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.arr_pkg.all;

entity MEM_STAGE is
    Port ( clk : in  STD_LOGIC;
			  isWord : in std_logic;
           Mem_WrEN : in  STD_LOGIC;
           ALU_MEM_Addr : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataIn : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataOut : out  STD_LOGIC_VECTOR (31 downto 0));
end MEM_STAGE;

architecture Behavioral of MEM_STAGE is

signal mux1in : datain_t;
signal mux1out: std_logic_vector(31 downto 0);
signal mux2in: datain_t;
signal mux2out : std_logic_vector(31 downto 0);

component MEM is
port(clk:in std_logic;
     we: in std_logic;
      a:in std_logic_vector(11 downto 2);
      d: in std_logic_vector(31 downto 0);
      spo: out std_logic_vector(31 downto 0));
      
end component;

component mux_2to1 is
port (     datain: in datain_t;
            sel: in std_logic;
            dataout: out std_logic_vector(31 downto 0));
end component;

begin
mux1in(0)(31 downto 8) <= "000000000000000000000000";
mux1in(0)(7 downto 0) <= MEM_DataIn(7 downto 0);
mux1in(1)<=MEM_DataIn;

mux1 :mux_2to1 port map( datain=>mux1in, sel=>isWord, dataout=>mux1out);
ram: MEM port map(clk=>clk,we=>MEM_WrEN,a=>ALU_MEM_Addr(9 downto 0),d=>mux1out,spo=>mux2in(1));

mux2in(0)(31 downto 8) <= "000000000000000000000000";
mux2in(0)(7 downto 0) <= mux2in(1)(7 downto 0);

mux2: mux_2to1 port map(datain => mux2in, sel => isWord, dataout=>MEM_DataOut);

end Behavioral;