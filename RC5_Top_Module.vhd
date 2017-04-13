----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:37:43 12/10/2016 
-- Design Name: 
-- Module Name:    RC5_Top_Module - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RC5_Top_Module is
    Port ( sw : in  STD_LOGIC_VECTOR (15 downto 0);
			  led: out STD_LOGIC_VECTOR (3 downto 0);
				btn : in STD_LOGIC_VECTOR (3 DOWNTO 0);
				clk : in  STD_LOGIC;
				clr : in  STD_LOGIC;
				--key_vld: in  STD_LOGIC;
				data_vld: in  STD_LOGIC;
				led17_b, led17_r, led16_r, led16_b: out STD_LOGIC;
			  --enc: in  STD_LOGIC;
			  SSEG_CA: out STD_LOGIC_VECTOR(6 DOWNTO 0);
			  SSEG_AN: out STD_LOGIC_VECTOR(7 DOWNTO 0)
			  );
end RC5_Top_Module;
architecture Behavioral of RC5_Top_Module is
component RC5_Modules is
    Port ( clk : in  STD_LOGIC;
           clr : in  STD_LOGIC;
			  enc : in  STD_LOGIC; --
			  key : in  STD_LOGIC_VECTOR (127 downto 0); --
			  key_vld: in STD_LOGIC; --
			  din: in STD_LOGIC_VECTOR (63 DOWNTO 0); -- 
			  data_vld: in STD_LOGIC; --
			  exp_key_rdy: out STD_LOGIC; -- light
			  dout: out STD_LOGIC_VECTOR(63 DOWNTO 0);
			  data_rdy: out STD_LOGIC
			  );
end component;
component rc5_segmentdriver is
	Port (clk:in std_logic;
			  displayA,displayB,displayC,displayD,displayE,displayF,displayG,displayH : in std_logic_vector(3 downto 0);
			  segA,segB,segC,segD,segE,segF,segG:out std_logic;
			  selectA,selectB,selectC,selectD,selectE,selectF,selectG,selectH:out std_logic);
end component;
signal key_input: STD_LOGIC_VECTOR (127 DOWNTO 0);
signal din: STD_LOGIC_VECTOR (63 DOWNTO 0);
signal dout: STD_LOGIC_VECTOR (31 DOWNTO 0);
--signal data_rdy: STD_LOGIC;
signal key_vld: STD_LOGIC;
signal input: STD_LOGIC_VECTOR(63 DOWNTO 0);
--Type inputstate is (zero, one, two, three, four, five, six, seven);
--signal nextstate : inputstate;
Type inputstate is (idle, preround, round, ready);
signal inputstatus : inputstate;
signal counter: STD_LOGIC_VECTOR(3 DOWNTO 0);
signal output: STD_LOGIC_VECTOR(63 DOWNTO 0);
begin

process (clk, clr, sw, btn(2))
	begin
	if (clr = '1') then inputstatus <= idle;
	elsif(clk'event and clk='1') then
		case inputstatus is
			when idle =>
				input<=x"0000000000000000";
				counter<=x"8";						
				key_vld<='0';
				led17_r<='0';
				if (btn(2)='1') then 
					inputstatus<=preround; 
				end if;
			when preround =>
				if (btn(2) = '1' and counter>"0001") then
						input<=input(55 downto 0)&x"00";
						input(7 downto 0) <= sw(7 downto 0);
						counter<=counter-'1';
						inputstatus <= round;
				elsif (btn(2)='1' and counter="0001") then
						input<=input(55 downto 0)&x"00";
						input(7 downto 0) <= sw(7 downto 0);
						inputstatus <= ready;
				end if;
			when round =>
				if (btn(2)='0') then
					inputstatus<=preround;					
				end if;
			when ready =>
				if (btn(2)='0') then
					led17_r<='1';
					key_vld<='1';
				end if;
		end case;
	end if;
end process;
key_input<=x"0000000000000000"&input;
din<=input;
led17_b<='0';
led16_r<='0';
led16_b<='0';
led(0)<=key_vld;
led(3)<=sw(15);
rc5: RC5_Modules port map
			(clk => clk,
           clr => clr,
			  enc => sw(15), --d
			  key => key_input,
			  key_vld => sw(14),--c
			  din => din,
			  data_vld => sw(13), --R
			  exp_key_rdy => led(1),
			  dout => output,
			  data_rdy => led(2));
WITH sw(12) SELECT
dout<= output(63 DOWNTO 32) WHEN '1',
		 output(31 DOWNTO 0) WHEN '0';

Show: rc5_segmentdriver port map
			(clk => clk,
			  displayA=>dout(31 DOWNTO 28),
			  displayB=>dout(27 DOWNTO 24),
			  displayC=>dout(23 DOWNTO 20),
			  displayD=>dout(19 DOWNTO 16),
			  displayE=>dout(15 DOWNTO 12),
			  displayF=>dout(11 DOWNTO 8),
			  displayG=>dout(7 DOWNTO 4),
			  displayH=>dout(3 DOWNTO 0),
			  segA=>SSEG_CA(0),segB=>SSEG_CA(1),segC=>SSEG_CA(2),segD=>SSEG_CA(3),segE=>SSEG_CA(4),segF=>SSEG_CA(5),segG=>SSEG_CA(6),
			  selectA=>SSEG_AN(7),selectB=>SSEG_AN(6),selectC=>SSEG_AN(5),selectD=>SSEG_AN(4),selectE=>SSEG_AN(3),selectF=>SSEG_AN(2),selectG=>SSEG_AN(1),selectH=>SSEG_AN(0)
			  );

end Behavioral;

