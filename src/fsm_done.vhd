
LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY fsm_done IS
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		done : IN std_logic;
		i_start : IN std_logic;
		o_done : OUT std_logic
	);
END fsm_done;

ARCHITECTURE Behavioral OF fsm_done IS
	TYPE S IS (S0, S1, S2);
	SIGNAL curr_state : S := S0;
 
 

BEGIN
	delta_function : PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			curr_state <= S0;
		ELSIF rising_edge(clk) THEN
			IF (curr_state = S0 AND done = '1') THEN
				curr_state <= S1;
			ELSIF (curr_state = S1 AND i_start = '0') THEN
				curr_state <= S2;
			ELSIF (curr_state = S2) THEN
				curr_state <= S0;
			END IF;
		END IF;
	END PROCESS;

 
	lambda_function : PROCESS (curr_state)
	BEGIN
		CASE curr_state IS
			WHEN S0 => 
				o_done <= '0';
 
			WHEN S1 => 
				o_done <= '1';
 
			WHEN S2 => 
				o_done <= '0'; 
 
		END CASE;
	END PROCESS;

 

END Behavioral;