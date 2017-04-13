----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:40:22 12/10/2016 
-- Design Name: 
-- Module Name:    RC5_Modules - Behavioral 
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

entity RC5_Modules is
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
end RC5_Modules;

architecture Behavioral of RC5_Modules is
component RC5_Exp is
    Port ( clk : in  STD_LOGIC;
           clr : in  STD_LOGIC;
           key_in : in  STD_LOGIC;
           ukey : in  STD_LOGIC_VECTOR(127 Downto 0);
           skey : out  ROM;
           key_rdy : out  STD_LOGIC);
end component;
component RC5_Enc is
    Port ( clr : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  skey: ROM;
           din : in  STD_LOGIC_VECTOR(63 downto 0);
			  di_vld	: IN	STD_LOGIC;  
           dout : out  STD_LOGIC_VECTOR(63 downto 0);
			  do_rdy	: OUT	STD_LOGIC   
			  );
end component;
component RC5_Dec is
	port(clk: in std_logic;
		clr: in std_logic;
		di_vld: in std_logic;
		do_rdy: out std_logic;
		skey: in ROM;
		din: in std_logic_vector(63 downto 0);
		dout: out std_logic_vector(63 downto 0)
	);
end component;
signal skey: ROM;
type statetype is (idle, pre_round, round, ready);
signal state : statetype;
signal dec_dout: STD_LOGIC_VECTOR (63 DOWNTO 0);
signal enc_dout: STD_LOGIC_VECTOR (63 DOWNTO 0);
signal enc_rdy: STD_LOGIC;
signal dec_rdy: STD_LOGIC;
begin
Key_Exp: RC5_Exp port map 
	(
		clk => clk,
		clr => clr,
		key_in => key_vld,
		ukey => key,
		skey => skey,
		key_rdy=> exp_key_rdy
	);
Encoder: RC5_Enc port map
	(
			  clr => clr,
           clk => clk,
			  skey => skey,
           din => din,
			  di_vld	=> data_vld,  
           dout => enc_dout,
			  do_rdy	=> enc_rdy
	);
Decoder: RC5_Dec port map
	(
		clk => clk,
		clr => clr,
		skey => skey,
		di_vld => data_vld, 
		do_rdy => dec_rdy,
		din => din,
		dout => dec_dout
	);
	
WITH enc SELECT
   dout <=	enc_dout WHEN '1',
				dec_dout WHEN OTHERS;
WITH enc SELECT
	data_rdy <= enc_rdy WHEN '1',
					dec_rdy WHEN OTHERS;

end Behavioral;

