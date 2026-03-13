
LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY fsm IS
	PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		enable_reg : OUT std_logic;
		start_op : IN std_logic;
		cycle : IN std_logic_vector(9 DOWNTO 0);
		dec_count : IN std_logic_vector (4 DOWNTO 0);
		avanza_cnt : OUT std_logic;

		rst_31 : OUT std_logic;
		avanza_dec : OUT std_logic;
		i_mem_data : IN std_logic_vector(7 DOWNTO 0);
		i_add : IN std_logic_vector(15 DOWNTO 0);
		o_mem_we : OUT std_logic;
		o_mem_en : OUT std_logic;
		o_mem_data : OUT std_logic_vector(7 DOWNTO 0);

		o_mem_addr : OUT std_logic_vector(15 DOWNTO 0);
 
		std_value_out : OUT std_logic_vector(7 DOWNTO 0);
		std_value_in : IN std_logic_vector(7 DOWNTO 0)
	);
END fsm;

ARCHITECTURE Behavioral OF fsm IS
	TYPE S IS (INIT, LETTURA_1, LETTURA_2, SCRITTURA_1, SCRITTURA_2, SCRITTURA_3, SCRITTURA_4);
	SIGNAL curr_state : S := INIT;
 

BEGIN
	delta_function : PROCESS (clk, rst)
	BEGIN
		IF (rst = '1') THEN
			curr_state <= INIT;
		ELSIF (rising_edge(clk)) THEN
			IF (curr_state = INIT AND start_op = '1') THEN
				curr_state <= LETTURA_1;
			ELSIF (curr_state = LETTURA_1) THEN
				curr_state <= LETTURA_2;
			ELSIF (curr_state = LETTURA_2) THEN
				curr_state <= SCRITTURA_1;
			ELSIF (curr_state = SCRITTURA_1) THEN
				curr_state <= SCRITTURA_2;
			ELSIF (curr_state = SCRITTURA_2) THEN
				curr_state <= SCRITTURA_3; 
			ELSIF (curr_state = SCRITTURA_3) THEN
				curr_state <= SCRITTURA_4; 
			ELSIF (curr_state = SCRITTURA_4) THEN
				curr_state <= INIT; 	
			END IF;
		END IF;
	END PROCESS;

 
	lambda_function : PROCESS (curr_state)
	BEGIN
		CASE curr_state IS
			WHEN INIT => 
				enable_reg <= '0';
				std_value_out <= std_value_in;
				avanza_cnt <= '0';
				rst_31 <= '0';
				avanza_dec <= '0';
				o_mem_we <= '0';
				o_mem_en <= '0';
				o_mem_data <= "00000000";
				o_mem_addr <= "0000000000000000";

			WHEN LETTURA_1 => 
				enable_reg <= '0';
				std_value_out <= std_value_in;
				avanza_dec <= '0';
				avanza_cnt <= '0';
				rst_31 <= '0';
				o_mem_data <= "00000000";
				o_mem_en <= '1';
				o_mem_we <= '0';
				o_mem_addr <= std_logic_vector(unsigned(i_add) + (unsigned("000000" & cycle) SLL 1));

			WHEN LETTURA_2 => 
				enable_reg <= '1';
				std_value_out <= std_value_in;
				rst_31 <= '0';
				avanza_dec <= '0';
				o_mem_en <= '1';
				o_mem_we <= '0';
				avanza_cnt <= '0';
				o_mem_addr <= std_logic_vector(unsigned(i_add) + (unsigned("000000" & cycle) SLL 1));
				o_mem_data <= "00000000";

			WHEN SCRITTURA_1 => 
			IF (i_mem_data /= "00000000") THEN
					std_value_out <= i_mem_data; 
					rst_31 <= '1';
					avanza_dec <= '0';
				ELSE
					std_value_out <= std_value_in; 
					rst_31 <= '0';
					avanza_dec <= '1';
				END IF;
				enable_reg <= '1';
				o_mem_data <= std_value_in; 
				 --std_value_out <= std_value_in;
				avanza_cnt <= '0';
				o_mem_addr <= std_logic_vector(unsigned(i_add) + (unsigned("000000" & cycle) SLL 1));
				o_mem_en <= '1';
				o_mem_we <= '1';
					
			WHEN SCRITTURA_2 => 
				enable_reg <= '0';
				o_mem_data <= std_value_in; 
				std_value_out <= std_value_in;
				avanza_cnt <= '0';
				o_mem_addr <= std_logic_vector(unsigned(i_add) + (unsigned("000000" & cycle) SLL 1));
				o_mem_en <= '1';
				o_mem_we <= '1';
				avanza_dec <= '0';
				rst_31 <= '0';
				
				WHEN SCRITTURA_3 => 
				enable_reg <= '0';
				o_mem_data <= std_value_in; 
				std_value_out <= std_value_in;
				avanza_cnt <= '0';
				o_mem_addr <= std_logic_vector(unsigned(i_add) + (unsigned("000000" & cycle) SLL 1));
				o_mem_en <= '1';
				o_mem_we <= '1';
				avanza_dec <= '0';
				rst_31 <= '0';
				
			WHEN SCRITTURA_4 => 
				enable_reg <= '0';
				o_mem_data <= "000" & dec_count; 
				std_value_out <= std_value_in;
				avanza_cnt <= '1';
				o_mem_addr <= std_logic_vector(unsigned(i_add) + (unsigned("000000" & cycle) SLL 1) + 1);
				o_mem_en <= '1';
				o_mem_we <= '1';
				avanza_dec <= '0';
				rst_31 <= '0';
		END CASE;
	END PROCESS;

 

END Behavioral;