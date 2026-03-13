LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY cnt IS
	PORT (
		i_clk : IN std_logic; 
		i_rst : IN std_logic; 
		avanza_cnt : IN std_logic; 
		i_k : IN std_logic_vector(9 DOWNTO 0); 
		cycle : OUT std_logic_vector(9 DOWNTO 0); 
		done_cnt : OUT std_logic 
	);
END cnt;

ARCHITECTURE Behavioral OF cnt IS
	SIGNAL counter : std_logic_vector(9 DOWNTO 0) ;
BEGIN
	PROCESS (i_clk, i_rst)
	BEGIN
		IF i_rst = '1' THEN
			counter <= (OTHERS => '0');
			done_cnt <= '0';
		ELSIF rising_edge(i_clk) THEN
			IF avanza_cnt = '1' THEN
				IF counter = i_k - 1 THEN
					done_cnt <= '1';
				ELSE
					counter <= counter + 1;
					done_cnt <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;

	cycle <= counter;

END Behavioral;