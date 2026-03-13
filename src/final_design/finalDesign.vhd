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
		done_cnt : OUT std_logic;
		init_m : IN std_logic
	);
END cnt;

ARCHITECTURE Behavioral OF cnt IS
	SIGNAL counter : std_logic_vector(9 DOWNTO 0);
BEGIN
	PROCESS (i_clk, i_rst)
	BEGIN
		IF i_rst = '1' THEN
			counter <= (OTHERS => '0');
			done_cnt <= '0';
		ELSIF rising_edge(i_clk) THEN
			IF (init_m = '1') THEN
				counter <= "0000000000";
				done_cnt <= '0';
			ELSIF avanza_cnt = '1' THEN
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
	LIBRARY IEEE;
	USE IEEE.NUMERIC_STD.ALL;
	USE IEEE.STD_LOGIC_1164.ALL;

	USE IEEE.STD_LOGIC_UNSIGNED.ALL;

	ENTITY fsm IS
		PORT (
		clk : IN std_logic;
		rst : IN std_logic;
		i_start : IN std_logic;
		done_cnt : IN std_logic;
		enable_reg : OUT std_logic;
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
		init_m : IN std_logic;
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
				IF (init_m = '1' OR done_cnt = '1') THEN
					curr_state <= INIT;
				ELSIF (curr_state = INIT AND i_start = '1') THEN
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

		LIBRARY IEEE;
		USE IEEE.STD_LOGIC_1164.ALL;
		USE IEEE.NUMERIC_STD.ALL;

		ENTITY reg_std_value IS
			PORT (
			enable_reg : IN std_logic;
			clk : IN std_logic;
			rst : IN std_logic;
			data_in : IN std_logic_vector(7 DOWNTO 0);
			data_out : OUT std_logic_vector(7 DOWNTO 0);
			init_m : IN std_logic
			);
		END reg_std_value;

		ARCHITECTURE Behavioral OF reg_std_value IS
			SIGNAL reg_value : std_logic_vector(7 DOWNTO 0);
		BEGIN
			PROCESS (clk, rst)
			BEGIN
				IF (rst = '1') THEN
					reg_value <= (OTHERS => '0');
				ELSIF rising_edge(clk) THEN
					IF (init_m = '1') THEN
						reg_value <= (OTHERS => '0');
					ELSIF (enable_reg = '1') THEN
						reg_value <= data_in;
					END IF;
				END IF;
			END PROCESS;

			data_out <= reg_value;
			END Behavioral;

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
				dec_count : OUT std_logic_vector(4 DOWNTO 0);
				init_m : IN std_logic
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
						IF (init_m = '1') THEN
							count <= "00000";
						ELSIF (rst_31 = '1') THEN
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
					o_done : OUT std_logic;
					init_m : OUT std_logic
					);
				END fsm_done;

				ARCHITECTURE Behavioral OF fsm_done IS
					TYPE S IS (S0, S1, S2, S3);
					SIGNAL curr_state : S := S0;

				BEGIN
					delta_function : PROCESS (clk, rst)
					BEGIN
						IF rst = '1' THEN

							curr_state <= S0;
						ELSIF rising_edge(clk) THEN
							IF (curr_state = S0 AND done = '1') THEN
								curr_state <= S1;
							ELSIF (curr_state = S1) THEN
								curr_state <= S2;
							ELSIF (curr_state = S2 AND i_start = '0') THEN
								curr_state <= S3;
							ELSIF (curr_state = S3) THEN
								curr_state <= S0;

							END IF;
						END IF;
					END PROCESS;
					lambda_function : PROCESS (curr_state)
					BEGIN
						CASE curr_state IS
							WHEN S0 => 
								o_done <= '0';
								init_m <= '0';

							WHEN S1 => 
								o_done <= '0';
								init_m <= '1';

							WHEN S2 => 
								o_done <= '1';
								init_m <= '0';

							WHEN S3 => 
								o_done <= '0';
								init_m <= '1';

						END CASE;
					END PROCESS;

					END Behavioral;
					LIBRARY IEEE;
					USE IEEE.STD_LOGIC_1164.ALL;
					ENTITY project_reti_logiche IS
						PORT (
						i_clk : IN std_logic;
						i_rst : IN std_logic;
						i_start : IN std_logic;
						i_add : IN std_logic_vector(15 DOWNTO 0);
						i_k : IN std_logic_vector(9 DOWNTO 0);

						o_done : OUT std_logic;

						o_mem_addr : OUT std_logic_vector(15 DOWNTO 0);
						i_mem_data : IN std_logic_vector(7 DOWNTO 0);
						o_mem_data : OUT std_logic_vector(7 DOWNTO 0);
						o_mem_we : OUT std_logic;
						o_mem_en : OUT std_logic
						);
					END project_reti_logiche;

					ARCHITECTURE Behavioral OF project_reti_logiche IS

						SIGNAL done_cnt : std_logic;
						SIGNAL cycle : std_logic_vector(9 DOWNTO 0);
						SIGNAL std_value_in : std_logic_vector(7 DOWNTO 0);
						SIGNAL std_value_out : std_logic_vector(7 DOWNTO 0);
						SIGNAL start_op : std_logic;
						SIGNAL rst_31 : std_logic;
						SIGNAL avanza_cnt : std_logic;
						SIGNAL enable_reg : std_logic;
						SIGNAL dec_count : std_logic_vector(4 DOWNTO 0);
						SIGNAL avanza_dec : std_logic;
						SIGNAL init_m : std_logic;

					BEGIN
						u_cnt : ENTITY work.cnt
							PORT MAP(
								i_clk => i_clk, 
								i_rst => i_rst, 
								avanza_cnt => avanza_cnt, 
								i_k => i_k, 
								cycle => cycle, 
								done_cnt => done_cnt, 
								init_m => init_m
							);
								u_fsm : ENTITY work.fsm
									PORT MAP(
										i_start => i_start, 
										done_cnt => done_cnt, 
										clk => i_clk, 
										rst => i_rst, 

										i_mem_data => i_mem_data, 
										o_mem_data => o_mem_data, 
										o_mem_addr => o_mem_addr, 
										o_mem_we => o_mem_we, 
										o_mem_en => o_mem_en, 
										cycle => cycle, 
										dec_count => dec_count, 
										i_add => i_add, 
										std_value_in => std_value_in, 
										std_value_out => std_value_out, 
										enable_reg => enable_reg, 
										avanza_cnt => avanza_cnt, 
										rst_31 => rst_31, 
										avanza_dec => avanza_dec, 
										init_m => init_m
									);

										u_reg_std_value : ENTITY work.reg_std_value
											PORT MAP(

												enable_reg => enable_reg, 
												clk => i_clk, 
												rst => i_rst, 
												data_in => std_value_out, 
												data_out => std_value_in, 
												init_m => init_m
											);
												u_dec : ENTITY work.dec
													PORT MAP(
														clk => i_clk, 
														rst => i_rst, 
														rst_31 => rst_31, 
														avanza_dec => avanza_dec, 
														dec_count => dec_count, 
														init_m => init_m
													);

														u_fsm_done : ENTITY work.fsm_done
															PORT MAP(
																clk => i_clk, 
																rst => i_rst, 
																done => done_cnt, 
																i_start => i_start, 
																o_done => o_done, 
																init_m => init_m
															);
END Behavioral;