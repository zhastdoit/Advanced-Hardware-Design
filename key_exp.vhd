----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:55:15 11/19/2016 
-- Design Name: 
-- Module Name:    key_exp - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE  WORK.RC5_PKG.ALL;  -- include the package to your design


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RC5_Exp is
    Port ( clk : in  STD_LOGIC;
           clr : in  STD_LOGIC;
           key_in : in  STD_LOGIC;
           ukey : in  STD_LOGIC_VECTOR(127 Downto 0);
           skey : out  ROM;
           key_rdy : out  STD_LOGIC
			  );
end RC5_Exp;

architecture Behavioral of RC5_Exp is
TYPE     StateType IS (ST_IDLE, ST_KEY_INIT, ST_KEY_EXP, ST_READY);
SIGNAL	state : StateType;

SIGNAL  a_reg	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  b_reg	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  a_tmp1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  a_tmp2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  ab_tmp	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  b_tmp1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  b_tmp2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  l_arr	: L_ARRAY;
SIGNAL  s_arr_tmp: ROM;
SIGNAL  s_pre	: STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL  i_cnt	: INTEGER RANGE 0 TO 25; 
SIGNAL  j_cnt	: INTEGER RANGE 0 TO 3;  
SIGNAL  k_cnt	: INTEGER RANGE 0 TO 77; 





begin

  -- it is not a data-dependent rotation!
  --A = S[i] = (S[i] + A + B) <<< 3;
  a_tmp1<=s_arr_tmp(conv_integer(i_cnt))+a_reg+b_reg; 
  -- <<<3
  a_tmp2<=a_tmp1(28 DOWNTO 0) & a_tmp1(31 DOWNTO 29); 

  -- this is a data-dependent rotation!
  --B = L[j] = (L[j] + A + B) <<< (A + B);
  ab_tmp<=a_tmp2+b_reg;
  b_tmp1<=l_arr(j_cnt)+ab_tmp;
   WITH ab_tmp (4 DOWNTO 0) SELECT
      b_tmp2<=	b_tmp1(30 DOWNTO 0) & b_tmp1(31) WHEN "00001",
   	b_tmp1(29 DOWNTO 0) & b_tmp1(31 DOWNTO 30) WHEN "00010",
   	b_tmp1(28 DOWNTO 0) & b_tmp1(31 DOWNTO 29) WHEN "00011",
   	b_tmp1(27 DOWNTO 0) & b_tmp1(31 DOWNTO 28) WHEN "00100",
   	b_tmp1(26 DOWNTO 0) & b_tmp1(31 DOWNTO 27) WHEN "00101",
   	b_tmp1(25 DOWNTO 0) & b_tmp1(31 DOWNTO 26) WHEN "00110",
   	b_tmp1(24 DOWNTO 0) & b_tmp1(31 DOWNTO 25) WHEN "00111",
   	b_tmp1(23 DOWNTO 0) & b_tmp1(31 DOWNTO 24) WHEN "01000",
   	b_tmp1(22 DOWNTO 0) & b_tmp1(31 DOWNTO 23) WHEN "01001",
   	b_tmp1(21 DOWNTO 0) & b_tmp1(31 DOWNTO 22) WHEN "01010",
   	b_tmp1(20 DOWNTO 0) & b_tmp1(31 DOWNTO 21) WHEN "01011",
   	b_tmp1(19 DOWNTO 0) & b_tmp1(31 DOWNTO 20) WHEN "01100",
   	b_tmp1(18 DOWNTO 0) & b_tmp1(31 DOWNTO 19) WHEN "01101",
   	b_tmp1(17 DOWNTO 0) & b_tmp1(31 DOWNTO 18) WHEN "01110",
   	b_tmp1(16 DOWNTO 0) & b_tmp1(31 DOWNTO 17) WHEN "01111",
   	b_tmp1(15 DOWNTO 0) & b_tmp1(31 DOWNTO 16) WHEN "10000",
      b_tmp1(14 DOWNTO 0) & b_tmp1(31 DOWNTO 15) WHEN "10001",
   	b_tmp1(13 DOWNTO 0) & b_tmp1(31 DOWNTO 14) WHEN "10010",
   	b_tmp1(12 DOWNTO 0) & b_tmp1(31 DOWNTO 13) WHEN "10011",
   	b_tmp1(11 DOWNTO 0) & b_tmp1(31 DOWNTO 12) WHEN "10100",
   	b_tmp1(10 DOWNTO 0) & b_tmp1(31 DOWNTO 11) WHEN "10101",
   	b_tmp1(9 DOWNTO 0) & b_tmp1(31 DOWNTO 10) WHEN "10110",
   	b_tmp1(8 DOWNTO 0) & b_tmp1(31 DOWNTO 9) WHEN "10111",
   	b_tmp1(7 DOWNTO 0) & b_tmp1(31 DOWNTO 8) WHEN "11000",
   	b_tmp1(6 DOWNTO 0) & b_tmp1(31 DOWNTO 7) WHEN "11001",
   	b_tmp1(5 DOWNTO 0) & b_tmp1(31 DOWNTO 6) WHEN "11010",
   	b_tmp1(4 DOWNTO 0) & b_tmp1(31 DOWNTO 5) WHEN "11011",
   	b_tmp1(3 DOWNTO 0) & b_tmp1(31 DOWNTO 4) WHEN "11100",
   	b_tmp1(2 DOWNTO 0) & b_tmp1(31 DOWNTO 3) WHEN "11101",
   	b_tmp1(1 DOWNTO 0) & b_tmp1(31 DOWNTO 2) WHEN "11110",
   	b_tmp1(0) & b_tmp1(31 DOWNTO 1) WHEN "11111",
   	b_tmp1 WHEN OTHERS;
		
  PROCESS(clr, clk)	
     BEGIN
       IF(clr='1') THEN
           state<=ST_IDLE;
       ELSIF(clk'EVENT AND clk='1') THEN
           CASE state IS
              WHEN ST_IDLE =>
                  IF(key_in='1') THEN  state<=ST_KEY_INIT;   END IF;
              WHEN ST_KEY_INIT=>
                  state<=ST_KEY_EXP;
              WHEN ST_KEY_EXP=>
                  IF(k_cnt=77) THEN   state<=ST_READY;  END IF;
				  when ST_READY=>
				      IF(key_in='0') THEN  state<=ST_IDLE;   END IF;
          END CASE;
        END IF;
  END PROCESS;
  
    -- A register
  PROCESS(clr, clk)  
	 BEGIN
        IF(clr='1') THEN
           a_reg<=(OTHERS=>'0');
        ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_KEY_EXP) THEN   a_reg<=a_tmp2;
           END IF;
        END IF;
    END PROCESS;
	 
    -- B register
  PROCESS(clr, clk)  
	 BEGIN
        IF(clr='1') THEN
           b_reg<=(OTHERS=>'0');
        ELSIF(clk'EVENT AND clk='1') THEN
           IF(state=ST_KEY_EXP) THEN   b_reg<=b_tmp2;
           END IF;
        END IF;
    END PROCESS;   
	 
--i = (i + 1) mod (t);
 PROCESS(clr, clk)
 BEGIN
    IF(clr='1') THEN  i_cnt<=0;
    ELSIF(clk'EVENT AND clk='1') THEN
	    IF(STATE = ST_IDLE) THEN i_cnt <= 0;END IF;
       IF(state=ST_KEY_EXP) THEN
         IF(i_cnt=25) THEN   i_cnt<=0;
         ELSE   i_cnt<=i_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
 
 PROCESS(clr, clk)
 BEGIN
    IF(clr='1') THEN  K_cnt<=0;
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=ST_KEY_EXP) THEN
         IF(k_cnt=77) THEN   k_cnt<=0;
         ELSE   k_cnt<=k_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
 
--j = (j + 1) mod (c);
 PROCESS(clr, clk)
 BEGIN
    IF(clr='1') THEN  j_cnt<=0;
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=ST_KEY_EXP) THEN
         IF(j_cnt=3) THEN   j_cnt<=0;
         ELSE   j_cnt<=j_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;

 PROCESS(clr, clk)
 BEGIN
   IF(clr='1') THEN	 -- After system reset, S array is initialized with P and Q
      s_arr_tmp(0)<=  X"B7E15163"; --Pw
      s_arr_tmp(1)<=  X"5618CB1C"; --Pw+ Qw
      s_arr_tmp(2)<=  X"F45044D5"; --Pw+ 2Qw
		s_arr_tmp(3)<=  X"9287BE8E";
		s_arr_tmp(4)<=  X"30BF3847";
		s_arr_tmp(5)<=  X"CEF6B200";
		s_arr_tmp(6)<=  X"6D2E2BB9";
		s_arr_tmp(7)<=  X"0B65A572";
		s_arr_tmp(8)<=  X"A99D1F2B";
		s_arr_tmp(9)<=  X"47D498E4";
		s_arr_tmp(10)<=  X"E60C129D";
		s_arr_tmp(11)<=  X"84438C56";
		s_arr_tmp(12)<=  X"227B060F";
		s_arr_tmp(13)<=  X"C0B27FC8";
		s_arr_tmp(14)<=  X"5EE9F981";
		s_arr_tmp(15)<=  X"FD21733A";
		s_arr_tmp(16)<=  X"9B58ECF3";
		s_arr_tmp(17)<=  X"399066AC";
		s_arr_tmp(18)<=  X"D7C7E065";
		s_arr_tmp(19)<=  X"75FF5A1E";
		s_arr_tmp(20)<=  X"1436D3D7";
		s_arr_tmp(21)<=  X"B26E4D90";
		s_arr_tmp(22)<=  X"50A5C749";
		s_arr_tmp(23)<=  X"EEDD4102";
		s_arr_tmp(24)<=  X"8D14BABB";
      s_arr_tmp(25)<=  X"2B4C3474"; --Pw+ 25Qw
   ELSIF(clk'EVENT AND clk='1') THEN
     IF(state=ST_KEY_EXP) THEN   s_arr_tmp(i_cnt)<=a_tmp2;
     END IF;
   END IF;
 END PROCESS;
 
 s_pre<=s_arr_tmp(25);

   PROCESS(clr, clk)
   BEGIN
     IF(clr='1') THEN
        FOR i IN 0 TO 3 LOOP
           l_arr(i)<=(OTHERS=>'0');
        END LOOP;
     ELSIF(clk'EVENT AND clk='1') THEN
        IF(state=ST_KEY_INIT) THEN
           l_arr(0)<=ukey(31 DOWNTO 0);
          l_arr(1)<=ukey(63 DOWNTO 32);
          l_arr(2)<=ukey(95 DOWNTO 64);
          l_arr(3)<=ukey(127 DOWNTO 96);
        ELSIF(state=ST_KEY_EXP) THEN
           l_arr(j_cnt)<=b_tmp2;
        END IF;
     END IF;
  END PROCESS;
  
WITH STATE SELECT						
key_rdy <= '1' WHEN ST_READY,
            '0' WHEN OTHERS;
				
process(clk)
begin
  if(state = ST_READY) then
		skey<=s_arr_tmp;
  end if;
end process;


end Behavioral;

