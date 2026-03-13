

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

BEGIN
	u_cnt : ENTITY work.cnt
		PORT MAP(
			i_clk => i_clk, 
			i_rst => i_rst, 
			avanza_cnt => avanza_cnt, 
			i_k => i_k, 
			cycle => cycle, 
			done_cnt => done_cnt 
		);

 
			u_fsm : ENTITY work.fsm
				PORT MAP(
					clk => i_clk, 
					rst => i_rst, 
					start_op => start_op, 
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
					avanza_dec => avanza_dec 
				);

 
					u_sequencer : ENTITY work.sequencer
						PORT MAP(
							clk => i_clk, 
							rst => i_rst, 
 
							i_start => i_start, 
							start_op => start_op  
						);
 
							u_reg_std_value : ENTITY work.reg_std_value
								PORT MAP(
									enable_reg => enable_reg, 
									clk => i_clk, 
									rst => i_rst, 
									data_in => std_value_out, 
									data_out => std_value_in 
 
								);
									u_dec : ENTITY work.dec
										PORT MAP(
											clk => i_clk, 
											rst => i_rst, 
											rst_31 => rst_31, 
											avanza_dec => avanza_dec, 
											dec_count => dec_count  
										);
 
											u_fsm_done : ENTITY work.fsm_done
												PORT MAP(
													clk => i_clk, 
													rst => i_rst, 
													done => done_cnt, 
													i_start => i_start, 
													o_done => o_done
												);
 

END Behavioral;