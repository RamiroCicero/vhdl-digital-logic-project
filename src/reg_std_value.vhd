LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY reg_std_value IS
	PORT (
		enable_reg : IN std_logic;
		clk : IN std_logic;
		rst : IN std_logic;
		data_in : IN std_logic_vector(7 DOWNTO 0);
		data_out : OUT std_logic_vector(7 DOWNTO 0)
	);
END reg_std_value;

ARCHITECTURE Behavioral OF reg_std_value IS
	SIGNAL reg_value : std_logic_vector(7 DOWNTO 0) ;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF (rst = '1') THEN
			reg_value <= (OTHERS => '0');
		ELSIF rising_edge(clk) THEN
 
			if(enable_reg = '1') then reg_value <= data_in; end if;
		END IF;
	END PROCESS;

	data_out <= reg_value;
END Behavioral;