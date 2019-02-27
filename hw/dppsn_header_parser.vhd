LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY dppsn_header_parser IS
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
		out_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                     --       out.data
		out_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                      --          .empty
		out_endofpacket   : OUT STD_LOGIC;                                         --          .endofpacket
		out_ready         : IN  STD_LOGIC                      := '0';             --          .ready
		out_startofpacket : OUT STD_LOGIC;                                         --          .startofpacket
		out_valid         : OUT STD_LOGIC;                                         --          .valid
		out_channel       : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)                     --          .channel
	);
END ENTITY dppsn_header_parser;

ARCHITECTURE rtl OF dppsn_header_parser IS
	SIGNAL s_selector : STD_LOGIC_VECTOR(15 DOWNTO 0);
	TYPE t_delay_data IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL s_delay_data : t_delay_data;
	TYPE t_delay_valid IS ARRAY (0 TO 7) OF STD_LOGIC;
	SIGNAL s_delay_valid : t_delay_valid;
	TYPE t_delay_startofpacket IS ARRAY (0 TO 7) OF STD_LOGIC;
	SIGNAL s_delay_startofpacket : t_delay_startofpacket;
	TYPE t_delay_endofpacket IS ARRAY (0 TO 7) OF STD_LOGIC;
	SIGNAL s_delay_endofpacket : t_delay_endofpacket;
	TYPE t_delay_empty IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_delay_empty : t_delay_empty;
	TYPE t_state IS (S0, S1, S2, S3, S4, S5, S6, S7);
	SIGNAL s_state : t_state;
	SIGNAL s_channel : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL s_channel_temp : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL s_channel_in : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	write_csr: PROCESS (csr_reset_reset_n, csr_clk_clk)
	BEGIN
		IF (csr_reset_reset_n = '0') THEN
			s_selector <= "1000000001000000";
		ELSIF (RISING_EDGE(csr_clk_clk)) THEN
			IF (csr_write = '1') THEN
				s_selector <= csr_writedata(15 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	csr_readdata <= "0000000000000000" & s_selector;
	csr_waitrequest <= '0';
	
	parser: PROCESS (reset_reset_n, clk_clk)
	BEGIN
		IF reset_reset_n = '0' THEN
			s_state <= S0;
			s_channel_temp <= (OTHERS => '0');
			s_channel_in <= (OTHERS => '0');
			s_channel <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_clk) AND out_ready = '1' THEN
			CASE s_state IS
				WHEN S0 =>
					IF in_startofpacket = '1' AND in_valid = '1' THEN
						s_state <= S1;
						IF s_selector(15) = '1' THEN
							s_channel_temp(127 DOWNTO 64) <= in_data;
						END IF;
						IF s_selector(7) = '1' THEN
							s_channel_temp(63 DOWNTO 0) <= in_data;
						END IF;
						s_channel_in <= in_channel(3 DOWNTO 0);
					END IF;
				WHEN S1 =>
					s_state <= S2;
					IF s_selector(14) = '1' AND in_valid = '1' THEN
						s_channel_temp(127 DOWNTO 64) <= in_data;
					END IF;
					IF s_selector(6) = '1' AND in_valid = '1' THEN
						s_channel_temp(63 DOWNTO 0) <= in_data;
					END IF;
				WHEN S2 =>
					s_state <= S3;
					IF s_selector(13) = '1' AND in_valid = '1' THEN
						s_channel_temp(127 DOWNTO 64) <= in_data;
					END IF;
					IF s_selector(5) = '1' AND in_valid = '1' THEN
						s_channel_temp(63 DOWNTO 0) <= in_data;
					END IF;
				WHEN S3 =>
					s_state <= S4;
					IF s_selector(12) = '1' AND in_valid = '1' THEN
						s_channel_temp(127 DOWNTO 64) <= in_data;
					END IF;
					IF s_selector(4) = '1' AND in_valid = '1' THEN
						s_channel_temp(63 DOWNTO 0) <= in_data;
					END IF;
				WHEN S4 =>
					s_state <= S5;
					IF s_selector(11) = '1' AND in_valid = '1' THEN
						s_channel_temp(127 DOWNTO 64) <= in_data;
					END IF;
					IF s_selector(3) = '1' AND in_valid = '1' THEN
						s_channel_temp(63 DOWNTO 0) <= in_data;
					END IF;
				WHEN S5 =>
					s_state <= S6;
					IF s_selector(10) = '1' AND in_valid = '1' THEN
						s_channel_temp(127 DOWNTO 64) <= in_data;
					END IF;
					IF s_selector(2) = '1' AND in_valid = '1' THEN
						s_channel_temp(63 DOWNTO 0) <= in_data;
					END IF;
				WHEN S6 =>
					s_state <= S7;
					IF s_selector(9) = '1' AND in_valid = '1' THEN
						s_channel_temp(127 DOWNTO 64) <= in_data;
					END IF;
					IF s_selector(1) = '1' AND in_valid = '1' THEN
						s_channel_temp(63 DOWNTO 0) <= in_data;
					END IF;
				WHEN S7 =>
					s_state <= S0;
					IF s_selector(8) = '1' AND in_valid = '1' THEN
						s_channel(127 DOWNTO 64) <= in_data;
					ELSE
						s_channel(127 DOWNTO 64) <= s_channel_temp(127 DOWNTO 64);
					END IF;
					IF s_selector(0) = '1' AND in_valid = '1' THEN
						s_channel(63 DOWNTO 0) <= in_data(63 DOWNTO 4) & s_channel_in;
					ELSE
						s_channel(63 DOWNTO 0) <= s_channel_temp(63 DOWNTO 4) & s_channel_in;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
	
	delay: PROCESS (reset_reset_n, clk_clk)
	BEGIN
		IF (reset_reset_n = '0') THEN
			s_delay_data(7) <= (OTHERS => '0');
			s_delay_valid(7) <= '0';
			s_delay_startofpacket(7) <= '0';
			s_delay_endofpacket(7) <= '0';
			s_delay_empty(7) <= (OTHERS => '0');
			
			s_delay_data(6) <= (OTHERS => '0');
			s_delay_valid(6) <= '0';
			s_delay_startofpacket(6) <= '0';
			s_delay_endofpacket(6) <= '0';
			s_delay_empty(6) <= (OTHERS => '0');
			
			s_delay_data(5) <= (OTHERS => '0');
			s_delay_valid(5) <= '0';
			s_delay_startofpacket(5) <= '0';
			s_delay_endofpacket(5) <= '0';
			s_delay_empty(5) <= (OTHERS => '0');
			
			s_delay_data(4) <= (OTHERS => '0');
			s_delay_valid(4) <= '0';
			s_delay_startofpacket(4) <= '0';
			s_delay_endofpacket(4) <= '0';
			s_delay_empty(4) <= (OTHERS => '0');
			
			s_delay_data(3) <= (OTHERS => '0');
			s_delay_valid(3) <= '0';
			s_delay_startofpacket(3) <= '0';
			s_delay_endofpacket(3) <= '0';
			s_delay_empty(3) <= (OTHERS => '0');
			
			s_delay_data(2) <= (OTHERS => '0');
			s_delay_valid(2) <= '0';
			s_delay_startofpacket(2) <= '0';
			s_delay_endofpacket(2) <= '0';
			s_delay_empty(2) <= (OTHERS => '0');
			
			s_delay_data(1) <= (OTHERS => '0');
			s_delay_valid(1) <= '0';
			s_delay_startofpacket(1) <= '0';
			s_delay_endofpacket(1) <= '0';
			s_delay_empty(1) <= (OTHERS => '0');
			
			s_delay_data(0) <= (OTHERS => '0');
			s_delay_valid(0) <= '0';
			s_delay_startofpacket(0) <= '0';
			s_delay_endofpacket(0) <= '0';
			s_delay_empty(0) <= (OTHERS => '0');
		ELSIF (RISING_EDGE(clk_clk) AND out_ready = '1') THEN
			s_delay_data(7) <= s_delay_data(6);
			s_delay_valid(7) <= s_delay_valid(6);
			s_delay_startofpacket(7) <= s_delay_startofpacket(6);
			s_delay_endofpacket(7) <= s_delay_endofpacket(6);
			s_delay_empty(7) <= s_delay_empty(6);
			
			s_delay_data(6) <= s_delay_data(5);
			s_delay_valid(6) <= s_delay_valid(5);
			s_delay_startofpacket(6) <= s_delay_startofpacket(5);
			s_delay_endofpacket(6) <= s_delay_endofpacket(5);
			s_delay_empty(6) <= s_delay_empty(5);
			
			s_delay_data(5) <= s_delay_data(4);
			s_delay_valid(5) <= s_delay_valid(4);
			s_delay_startofpacket(5) <= s_delay_startofpacket(4);
			s_delay_endofpacket(5) <= s_delay_endofpacket(4);
			s_delay_empty(5) <= s_delay_empty(4);
			
			s_delay_data(4) <= s_delay_data(3);
			s_delay_valid(4) <= s_delay_valid(3);
			s_delay_startofpacket(4) <= s_delay_startofpacket(3);
			s_delay_endofpacket(4) <= s_delay_endofpacket(3);
			s_delay_empty(4) <= s_delay_empty(3);
			
			s_delay_data(3) <= s_delay_data(2);
			s_delay_valid(3) <= s_delay_valid(2);
			s_delay_startofpacket(3) <= s_delay_startofpacket(2);
			s_delay_endofpacket(3) <= s_delay_endofpacket(2);
			s_delay_empty(3) <= s_delay_empty(2);
			
			s_delay_data(2) <= s_delay_data(1);
			s_delay_valid(2) <= s_delay_valid(1);
			s_delay_startofpacket(2) <= s_delay_startofpacket(1);
			s_delay_endofpacket(2) <= s_delay_endofpacket(1);
			s_delay_empty(2) <= s_delay_empty(1);
			
			s_delay_data(1) <= s_delay_data(0);
			s_delay_valid(1) <= s_delay_valid(0);
			s_delay_startofpacket(1) <= s_delay_startofpacket(0);
			s_delay_endofpacket(1) <= s_delay_endofpacket(0);
			s_delay_empty(1) <= s_delay_empty(0);
			
			s_delay_data(0) <= in_data;
			s_delay_valid(0) <= in_valid;
			s_delay_startofpacket(0) <= in_startofpacket;
			s_delay_endofpacket(0) <= in_endofpacket;
			s_delay_empty(0) <= in_empty;
		END IF;
	END PROCESS;
	
	in_ready <= out_ready;
	out_data <= s_delay_data(7);
	out_valid <= s_delay_valid(7);
	out_startofpacket <= s_delay_startofpacket(7);
	out_endofpacket <= s_delay_endofpacket(7);
	out_empty <= s_delay_empty(7);
	out_channel <= s_channel;
END ARCHITECTURE rtl; -- of dppsn_header_parser