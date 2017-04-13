----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:33:55 10/08/2016 
-- Design Name: 
-- Module Name:    RC5_Dec
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
USE  WORK.RC5_PKG.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RC5_Dec is
	port(clk: in std_logic;
		clr: in std_logic;
		di_vld: in std_logic;
		do_rdy: out std_logic;
		skey: in ROM;
		din: in std_logic_vector(63 downto 0);
		dout: out std_logic_vector(63 downto 0)
	);
end RC5_Dec;

architecture Behavioral of RC5_Dec is
	type rom is array(0 to 25)of std_logic_vector(31 downto 0);
	signal a,b,a_reg, b_reg,ab_xor, ba_xor, a_rot, b_rot, a_pro, b_pro, a_pre, b_pre: std_logic_vector(31 downto 0);
	signal i_cnt: std_logic_vector(3 downto 0);
	
type statetype is (idle, pre_round,  round, ready);
signal state : statetype;
begin
-- register a
	process(clr, clk) begin
		if(clr = '1') then a_reg <= (others=>'0');
		elsif(clk'event and clk='1' ) then 
			if(state = pre_round) then a_reg <= a_pre;
			elsif(state = round) then
				if(i_cnt = "0001") then a_reg <= a_pro;
				else a_reg <= ab_xor; end if;
			end if;
		end if;
	end process;
-- register b	
	process(clr, clk) begin
		if(clr = '1') then b_reg <= (others=>'0');
		elsif(clk'event and clk='1' ) then 
			if(state = pre_round) then b_reg <= b_pre;
			elsif(state = round) then
				if(i_cnt = "0001") then b_reg <= b_pro;
				else b_reg <= ba_xor; end if;
			end if;
		end if;
	end process;
-- counter	
	process(clr, clk) begin
		IF(clr='1') THEN  i_cnt<="1100";   
		ELSIF (clk'EVENT AND clk='1') THEN
			IF (state = round) THEN 
			if(i_cnt = "0001") then i_cnt<="1100";
			ELSE i_cnt<=i_cnt-'1'; end if;
		END IF;
		END IF;
	END PROCESS;
	a_pre <= din(63 downto 32);
	b_pre <= din(31 downto 0);
-- B - S[2i+1]	
	b<= b_reg - skey(CONV_INTEGER(i_cnt&'1'));
-- (B - S[2i+1])>>> A
	with a_reg(4 downto 0) select
	b_rot <= b(0) & b(31 DOWNTO 1)  WHEN "00001",
	b(1 DOWNTO 0) & b(31 DOWNTO 2) WHEN "00010",
	b(2 DOWNTO 0) & b(31 DOWNTO 3) WHEN "00011",
	b(3 DOWNTO 0) & b(31 DOWNTO 4) WHEN "00100",
	b(4 DOWNTO 0) & b(31 DOWNTO 5) WHEN "00101",
	b(5 DOWNTO 0) & b(31 DOWNTO 6) WHEN "00110",
	b(6 DOWNTO 0) & b(31 DOWNTO 7) WHEN "00111",
	b(7 DOWNTO 0) & b(31 DOWNTO 8) WHEN "01000",
	b(8 DOWNTO 0) & b(31 DOWNTO 9) WHEN "01001",
	b(9 DOWNTO 0) & b(31 DOWNTO 10) WHEN "01010",
	b(10 DOWNTO 0) & b(31 DOWNTO 11) WHEN "01011",
	b(11 DOWNTO 0) & b(31 DOWNTO 12) WHEN "01100",
	b(12 DOWNTO 0) & b(31 DOWNTO 13) WHEN "01101",
	b(13 DOWNTO 0) & b(31 DOWNTO 14) WHEN "01110",
	b(14 DOWNTO 0) & b(31 DOWNTO 15) WHEN "01111",
	b(15 DOWNTO 0) & b(31 DOWNTO 16) WHEN "10000",
	b(16 DOWNTO 0) & b(31 DOWNTO 17) WHEN "10001",
	b(17 DOWNTO 0) & b(31 DOWNTO 18) WHEN "10010",
	b(18 DOWNTO 0) & b(31 DOWNTO 19) WHEN "10011",
	b(19 DOWNTO 0) & b(31 DOWNTO 20) WHEN "10100",
	b(20 DOWNTO 0) & b(31 DOWNTO 21) WHEN "10101",
	b(21 DOWNTO 0) & b(31 DOWNTO 22) WHEN "10110",
	b(22 DOWNTO 0) & b(31 DOWNTO 23) WHEN "10111",
	b(23 DOWNTO 0) & b(31 DOWNTO 24) WHEN "11000",
	b(24 DOWNTO 0) & b(31 DOWNTO 25) WHEN "11001",
	b(25 DOWNTO 0) & b(31 DOWNTO 26) WHEN "11010",
	b(26 DOWNTO 0) & b(31 DOWNTO 27) WHEN "11011",
	b(27 DOWNTO 0) & b(31 DOWNTO 28) WHEN "11100",
	b(28 DOWNTO 0) & b(31 DOWNTO 29) WHEN "11101",
	b(29 DOWNTO 0) & b(31 DOWNTO 30) WHEN "11110",
	b(30 DOWNTO 0) & b(31) WHEN "11111",
	b WHEN OTHERS;
-- ((B - S[2i+1])>>> A) xor A
	ba_xor<= b_rot xor a_reg;
-- B = B - S[1]	
	b_pro <= ba_xor - skey(1);	
-- A - S[2i]	
	a<=a_reg-skey(CONV_INTEGER(i_cnt&'0'));
-- (A - S[2i]) >>> B	
	with ba_xor(4 downto 0) select
	a_rot <=  a(0) & a(31 DOWNTO 1)  WHEN "00001",
	a(1 DOWNTO 0) & a(31 DOWNTO 2) WHEN "00010",
	a(2 DOWNTO 0) & a(31 DOWNTO 3) WHEN "00011",
	a(3 DOWNTO 0) & a(31 DOWNTO 4) WHEN "00100",
	a(4 DOWNTO 0) & a(31 DOWNTO 5) WHEN "00101",
	a(5 DOWNTO 0) & a(31 DOWNTO 6) WHEN "00110",
	a(6 DOWNTO 0) & a(31 DOWNTO 7) WHEN "00111",
	a(7 DOWNTO 0) & a(31 DOWNTO 8) WHEN "01000",
	a(8 DOWNTO 0) & a(31 DOWNTO 9) WHEN "01001",
	a(9 DOWNTO 0) & a(31 DOWNTO 10) WHEN "01010",
	a(10 DOWNTO 0) & a(31 DOWNTO 11) WHEN "01011",
	a(11 DOWNTO 0) & a(31 DOWNTO 12) WHEN "01100",
	a(12 DOWNTO 0) & a(31 DOWNTO 13) WHEN "01101",
	a(13 DOWNTO 0) & a(31 DOWNTO 14) WHEN "01110",
	a(14 DOWNTO 0) & a(31 DOWNTO 15) WHEN "01111",
	a(15 DOWNTO 0) & a(31 DOWNTO 16) WHEN "10000",
	a(16 DOWNTO 0) & a(31 DOWNTO 17) WHEN "10001",
	a(17 DOWNTO 0) & a(31 DOWNTO 18) WHEN "10010",
	a(18 DOWNTO 0) & a(31 DOWNTO 19) WHEN "10011",
	a(19 DOWNTO 0) & a(31 DOWNTO 20) WHEN "10100",
	a(20 DOWNTO 0) & a(31 DOWNTO 21) WHEN "10101",
	a(21 DOWNTO 0) & a(31 DOWNTO 22) WHEN "10110",
	a(22 DOWNTO 0) & a(31 DOWNTO 23) WHEN "10111",
	a(23 DOWNTO 0) & a(31 DOWNTO 24) WHEN "11000",
	a(24 DOWNTO 0) & a(31 DOWNTO 25) WHEN "11001",
	a(25 DOWNTO 0) & a(31 DOWNTO 26) WHEN "11010",
	a(26 DOWNTO 0) & a(31 DOWNTO 27) WHEN "11011",
	a(27 DOWNTO 0) & a(31 DOWNTO 28) WHEN "11100",
	a(28 DOWNTO 0) & a(31 DOWNTO 29) WHEN "11101",
	a(29 DOWNTO 0) & a(31 DOWNTO 30) WHEN "11110",
	a(30 DOWNTO 0) & a(31) WHEN "11111",
	a WHEN OTHERS;
-- ((A - S[2i]) >>> B) xor B
	ab_xor<= a_rot xor ba_xor;
-- A = A - S[0]
	a_pro <= ab_xor - skey(0);
	process(clr, clk)
	begin
		if(clr = '1') then
			state <= idle;
		elsif(clk'event and clk = '1') then
			case state is
				when idle => if(di_vld = '1') then state <= pre_round; end if;
				when pre_round => state <= round;
				when round=> if(i_cnt = "0001") then state <= ready; end if;
				when ready => state <= idle;
			end case;
		end if;
	end process;
	dout <= a_reg & b_reg;
	with state select
		do_rdy <= '1' when ready,
					 '0' when others;

end Behavioral;

