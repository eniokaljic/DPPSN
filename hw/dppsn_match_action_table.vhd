LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dppsn_match_action_table IS
	PORT (
		csr_address       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)  := (OTHERS => '0'); --       csr.address
		csr_read          : IN  STD_LOGIC                      := '0';             --          .read
		csr_readdata      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);                     --          .readdata
		csr_write         : IN  STD_LOGIC                      := '0';             --          .write
		csr_writedata     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0)  := (OTHERS => '0'); --          .writedata
		csr_waitrequest   : OUT STD_LOGIC;                                         --          .waitrequest
		csr_clk_clk       : IN  STD_LOGIC                      := '0';             --   csr_clk.clk
		csr_reset_reset_n : IN  STD_LOGIC                      := '0';             -- csr_reset.reset_n
		reset_reset_n     : IN  STD_LOGIC                      := '0';             --     reset.reset_n
		clk_clk           : IN  STD_LOGIC                      := '0';             --       clk.clk
		in_data           : IN  STD_LOGIC_VECTOR(63 DOWNTO 0)  := (OTHERS => '0'); --        in.data
		in_ready          : OUT STD_LOGIC;                                         --          .ready
		in_valid          : IN  STD_LOGIC                      := '0';             --          .valid
		in_startofpacket  : IN  STD_LOGIC                      := '0';             --          .startofpacket
		in_endofpacket    : IN  STD_LOGIC                      := '0';             --          .endofpacket
		in_empty          : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)   := (OTHERS => '0'); --          .empty
		in_channel        : IN  STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0'); --          .channel
		out_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                     --      out0.data
		out_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                      --          .empty
		out_endofpacket   : OUT STD_LOGIC;                                         --          .endofpacket
		out_ready         : IN  STD_LOGIC                      := '0';             --          .ready
		out_startofpacket : OUT STD_LOGIC;                                         --          .startofpacket
		out_valid         : OUT STD_LOGIC;                                         --          .valid
		out_channel       : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)                     --          .channel
	);
END ENTITY dppsn_match_action_table;

ARCHITECTURE rtl of dppsn_match_action_table IS
	SIGNAL s_csr_address_base : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_csr_address_offset : STD_LOGIC_VECTOR(5 DOWNTO 0);
	TYPE t_data_table IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL s_data_table : t_data_table;
	TYPE t_mask_table IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL s_mask_table : t_mask_table;
	TYPE t_action_table IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_action_table : t_action_table;
	TYPE t_counter_table IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_counter_table : t_counter_table;
	--attribute ramstyle : string;
	--attribute ramstyle of s_counter_table : signal is "logic";
	SIGNAL s_data : STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL s_valid : STD_LOGIC;
	SIGNAL s_startofpacket : STD_LOGIC;
	SIGNAL s_endofpacket : STD_LOGIC;
	SIGNAL s_empty : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_channel : STD_LOGIC_VECTOR(127 DOWNTO 0);
BEGIN
	s_csr_address_base <= csr_address(9 DOWNTO 6);
	s_csr_address_offset <= csr_address(5 DOWNTO 0);
		
	write_csr: PROCESS (csr_reset_reset_n, csr_clk_clk)
	BEGIN
		IF csr_reset_reset_n = '0' THEN
			FOR i IN 15 DOWNTO 0 LOOP
				s_data_table(i) <= (OTHERS => '0');
				s_mask_table(i) <= (OTHERS => '1');
				s_action_table(i) <= (OTHERS => '0');
				--s_counter_table(i) <= (OTHERS => '0');
			END LOOP;
		ELSIF (RISING_EDGE(csr_clk_clk)) THEN
			IF csr_write = '1' THEN
				CASE s_csr_address_offset IS
					WHEN "000000" =>
						s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(127 DOWNTO 96) <= csr_writedata;
					WHEN "000100" =>
						s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(95 DOWNTO 64) <= csr_writedata;
					WHEN "001000" =>
						s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(63 DOWNTO 32) <= csr_writedata;
					WHEN "001100" =>
						s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(31 DOWNTO 0) <= csr_writedata;
					WHEN "010000" =>
						s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(127 DOWNTO 96) <= csr_writedata;
					WHEN "010100" =>
						s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(95 DOWNTO 64) <= csr_writedata;
					WHEN "011000" =>
						s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(63 DOWNTO 32) <= csr_writedata;
					WHEN "011100" =>
						s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(31 DOWNTO 0) <= csr_writedata;
					WHEN "100000" =>
						s_action_table(TO_INTEGER(UNSIGNED(s_csr_address_base))) <= csr_writedata;
					WHEN "100100" =>
						--s_counter_table(TO_INTEGER(UNSIGNED(s_csr_address_base))) <= csr_writedata;
					WHEN OTHERS =>
						--NOP
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	read_csr: PROCESS (csr_read)
	BEGIN
		CASE s_csr_address_offset IS
			WHEN "000000" =>
				csr_readdata <= s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(127 DOWNTO 96);
			WHEN "000100" =>
				csr_readdata <= s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(95 DOWNTO 64);
			WHEN "001000" =>
				csr_readdata <= s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(63 DOWNTO 32);
			WHEN "001100" =>
				csr_readdata <= s_data_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(31 DOWNTO 0);
			WHEN "010000" =>
				csr_readdata <= s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(127 DOWNTO 96);
			WHEN "010100" =>
				csr_readdata <= s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(95 DOWNTO 64);
			WHEN "011000" =>
				csr_readdata <= s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(63 DOWNTO 32);
			WHEN "011100" =>
				csr_readdata <= s_mask_table(TO_INTEGER(UNSIGNED(s_csr_address_base)))(31 DOWNTO 0);
			WHEN "100000" =>
				csr_readdata <= s_action_table(TO_INTEGER(UNSIGNED(s_csr_address_base)));
			WHEN "100100" =>
				csr_readdata <= s_counter_table(TO_INTEGER(UNSIGNED(s_csr_address_base)));
			WHEN OTHERS =>
				csr_readdata <= (OTHERS => '0');
		END CASE;
		csr_waitrequest <= '0';
	END PROCESS;
	
	mat: PROCESS (reset_reset_n, clk_clk)
		VARIABLE v_match : STD_LOGIC;
		VARIABLE v_address : STD_LOGIC_VECTOR(3 DOWNTO 0);
	BEGIN
		IF reset_reset_n = '0' THEN
			s_data <= (OTHERS => '0');
			s_valid <= '0';
			s_startofpacket <= '0';
			s_endofpacket <= '0';
			s_empty <= (OTHERS => '0');
			s_channel <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_clk) THEN
			v_match := '0';
			IF in_startofpacket = '1' AND in_valid = '1' THEN
				FOR i IN 15 DOWNTO 0 LOOP
					IF (s_data_table(i) AND s_mask_table(i)) = (in_channel AND s_mask_table(i)) THEN
						v_match := '1';
						v_address := STD_LOGIC_VECTOR(TO_UNSIGNED(i,4));
					END IF;
				END LOOP;
				IF v_match = '1' THEN
					s_channel(31 DOWNTO 0) <= s_action_table(TO_INTEGER(UNSIGNED(v_address)));
					s_counter_table(TO_INTEGER(UNSIGNED(v_address))) <= s_counter_table(TO_INTEGER(UNSIGNED(v_address))) + 1;
				ELSE
					s_channel <= (OTHERS => '0');
				END IF;
			END IF;
			s_data <= in_data;
			s_valid <= in_valid;
			s_startofpacket <= in_startofpacket;
			s_endofpacket <= in_endofpacket;
			s_empty <= in_empty;
		END IF;
	END PROCESS;
	
	in_ready <= out_ready;
	out_data <= s_data;
	out_valid <= s_valid;
	out_startofpacket <= s_startofpacket;
	out_endofpacket <= s_endofpacket;
	out_empty <= s_empty;
	out_channel <= s_channel;
END ARCHITECTURE rtl; -- of dppsn_match_action_table
