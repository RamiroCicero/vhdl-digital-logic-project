LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dec IS
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		rst_31 : IN std_logic;
		avanza_dec : IN std_logic;
		dec_count : OUT std_logic_vector(4 DOWNTO 0)
	);
END dec;

ARCHITECTURE Behavioral OF dec IS
	SIGNAL count : std_logic_vector(4 DOWNTO 0);
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			count <= "00000";

		ELSIF rising_edge(clk) THEN
			IF (rst_31 = '1') THEN
				count <= "11111";
			ELSE
				IF avanza_dec = '1' THEN
					IF (count /= "00000") THEN
						count <= count - 1;
					END IF;

				END IF;
			END IF;
		END IF;
	END PROCESS;
	dec_count <= count;
END Behavioral;