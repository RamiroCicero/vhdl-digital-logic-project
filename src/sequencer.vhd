LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sequencer IS
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
 
		i_start : IN std_logic;
 
		start_op : OUT std_logic
	);
END sequencer;

ARCHITECTURE Behavioral OF sequencer IS

BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
 
			start_op <= '0';
		ELSIF rising_edge(clk) THEN
 
			IF (i_start = '1') THEN
				start_op <= '1';
			ELSE
				start_op <= '0';
			END IF;

 

		END IF;
	END PROCESS;

END Behavioral;