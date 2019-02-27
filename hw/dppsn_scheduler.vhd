LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dppsn_scheduler IS
	PORT (
		csr_address       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); --       csr.address
		csr_read          : IN  STD_LOGIC                     := '0';             --          .read
		csr_readdata      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);                    --          .readdata
		csr_write         : IN  STD_LOGIC                     := '0';             --          .write
		csr_writedata     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --          .writedata
		csr_waitrequest   : OUT STD_LOGIC;                                        --          .waitrequest
		csr_clk_clk       : IN  STD_LOGIC                     := '0';             --   csr_clk.clk
		csr_reset_reset_n : IN  STD_LOGIC                     := '0';             -- csr_reset.reset_n
		clk_clk           : IN  STD_LOGIC                     := '0';             --       clk.clk
		reset_reset_n     : IN  STD_LOGIC                     := '0';             --     reset.reset_n
		in0_data          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0'); --       in0.data
		in0_ready         : OUT STD_LOGIC;                                        --          .ready
		in0_valid         : IN  STD_LOGIC                     := '0';             --          .valid
		in0_startofpacket : IN  STD_LOGIC                     := '0';             --          .startofpacket
		in0_endofpacket   : IN  STD_LOGIC                     := '0';             --          .endofpacket
		in0_empty         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)  := (OTHERS => '0'); --          .empty
		in1_data          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0'); --       in1.data
		in1_ready         : OUT STD_LOGIC;                                        --          .ready
		in1_valid         : IN  STD_LOGIC                     := '0';             --          .valid
		in1_startofpacket : IN  STD_LOGIC                     := '0';             --          .startofpacket
		in1_endofpacket   : IN  STD_LOGIC                     := '0';             --          .endofpacket
		in1_empty         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)  := (OTHERS => '0'); --          .empty
		in2_data          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0'); --       in2.data
		in2_ready         : OUT STD_LOGIC;                                        --          .ready
		in2_valid         : IN  STD_LOGIC                     := '0';             --          .valid
		in2_startofpacket : IN  STD_LOGIC                     := '0';             --          .startofpacket
		in2_endofpacket   : IN  STD_LOGIC                     := '0';             --          .endofpacket
		in2_empty         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)  := (OTHERS => '0'); --          .empty
		in3_data          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0'); --       in3.data
		in3_ready         : OUT STD_LOGIC;                                        --          .ready
		in3_valid         : IN  STD_LOGIC                     := '0';             --          .valid
		in3_startofpacket : IN  STD_LOGIC                     := '0';             --          .startofpacket
		in3_endofpacket   : IN  STD_LOGIC                     := '0';             --          .endofpacket
		in3_empty         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)  := (OTHERS => '0'); --          .empty
		out_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                    --       out.data
		out_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                     --          .empty
		out_endofpacket   : OUT STD_LOGIC;                                        --          .endofpacket
		out_ready         : IN  STD_LOGIC                     := '0';             --          .ready
		out_startofpacket : OUT STD_LOGIC;                                        --          .startofpacket
		out_valid         : OUT STD_LOGIC;                                        --          .valid
		out_channel       : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)                    --          .channel
	);
END ENTITY dppsn_scheduler;

ARCHITECTURE rtl OF dppsn_scheduler IS
	SIGNAL s_selector : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_quantum0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL s_quantum1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL s_quantum2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL s_quantum3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL s_deficit0 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL s_deficit1 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL s_deficit2 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL s_deficit3 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	
	SIGNAL s_g0, s_g1, s_g2, s_g3: STD_LOGIC;
	TYPE STATE_TYPE IS (S0, S1, S2, S3);
	SIGNAL s_state : STATE_TYPE;
	SIGNAL s_data : STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL s_valid : STD_LOGIC;
	SIGNAL s_startofpacket : STD_LOGIC;
	SIGNAL s_endofpacket : STD_LOGIC;
	SIGNAL s_empty : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_channel : STD_LOGIC_VECTOR(127 DOWNTO 0);
BEGIN
	write_csr: PROCESS (csr_reset_reset_n, csr_clk_clk)
	BEGIN
		IF (csr_reset_reset_n = '0') THEN
			s_selector <= "0000";
		ELSIF (RISING_EDGE(csr_clk_clk)) THEN
			IF (csr_write = '1') THEN
				s_selector <= csr_writedata(31 DOWNTO 28);
				s_quantum0 <= csr_writedata(27 DOWNTO 21);
				s_quantum1 <= csr_writedata(20 DOWNTO 14);
				s_quantum2 <= csr_writedata(13 DOWNTO 7);
				s_quantum3 <= csr_writedata(6 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	csr_readdata <= s_selector & s_quantum0 & s_quantum1 & s_quantum2 & s_quantum3;
	csr_waitrequest <= '0';
	
	sched: PROCESS (reset_reset_n, clk_clk)
	BEGIN
		IF reset_reset_n = '0' THEN
			s_state <= S0;
			s_deficit0(12 DOWNTO 6) <= s_quantum0;
			s_deficit0(5 DOWNTO 0) <= (OTHERS => '0');
			s_deficit1(12 DOWNTO 6) <= s_quantum1;
			s_deficit1(5 DOWNTO 0) <= (OTHERS => '0');
			s_deficit2(12 DOWNTO 6) <= s_quantum2;
			s_deficit2(5 DOWNTO 0) <= (OTHERS => '0');
			s_deficit3(12 DOWNTO 6) <= s_quantum3;
			s_deficit3(5 DOWNTO 0) <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_clk) THEN
			IF s_selector = "0000" THEN
				s_state <= S0;
			ELSIF s_selector = "0001" THEN
				CASE s_state IS
					WHEN S0 =>
						IF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_state <= S1;
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_state <= S2;
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_state <= S3;
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_state <= S0;
						END IF;
					WHEN S1 =>
						IF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_state <= S2;
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_state <= S3;
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_state <= S0;
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_state <= S1;
						END IF;
					WHEN S2 =>
						IF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_state <= S3;
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_state <= S0;
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_state <= S1;
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_state <= S2;
						END IF;
					WHEN S3 =>
						IF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_state <= S0;
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_state <= S1;
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_state <= S2;
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_state <= S3;
						END IF;
				END CASE;
			ELSIF s_selector = "0010" THEN
				CASE s_state IS
					WHEN S0 =>
						IF in0_endofpacket = '1' AND in0_valid = '1' THEN
							IF s_deficit0(12 DOWNTO 6) = 0 THEN
								s_deficit0(12 DOWNTO 6) <= s_quantum0;
								s_deficit0(5 DOWNTO 0) <= (OTHERS => '0');
								s_state <= S1;
							END IF;
						ELSIF s_g0 = '1' THEN
							IF s_deficit0(12 DOWNTO 6) > 0 THEN
								s_deficit0 <= s_deficit0 - 1;
							END IF;
						END IF;
					WHEN S1 =>
						IF in1_endofpacket = '1' AND in1_valid = '1' THEN
							IF s_deficit1(12 DOWNTO 6) = 0 THEN
								s_deficit1(12 DOWNTO 6) <= s_quantum1;
								s_deficit1(5 DOWNTO 0) <= (OTHERS => '0');
								s_state <= S2;
							END IF;
						ELSIF s_g1 = '1' THEN
							IF s_deficit1(12 DOWNTO 6) > 0 THEN
								s_deficit1 <= s_deficit1 - 1;
							END IF;
						END IF;
					WHEN S2 =>
						IF in2_endofpacket = '1' AND in2_valid = '1' THEN
							IF s_deficit2(12 DOWNTO 6) = 0 THEN
								s_deficit2(12 DOWNTO 6) <= s_quantum2;
								s_deficit2(5 DOWNTO 0) <= (OTHERS => '0');
								s_state <= S3;
							END IF;
						ELSIF s_g2 = '1' THEN
							IF s_deficit2(12 DOWNTO 6) > 0 THEN
								s_deficit2 <= s_deficit2 - 1;
							END IF;
						END IF;
					WHEN S3 =>
						IF in3_endofpacket = '1' AND in3_valid = '1' THEN
							IF s_deficit3(12 DOWNTO 6) = 0 THEN
								s_deficit3(12 DOWNTO 6) <= s_quantum3;
								s_deficit3(5 DOWNTO 0) <= (OTHERS => '0');
								s_state <= S0;
							END IF;
						ELSIF s_g3 = '1' THEN
							IF s_deficit3(12 DOWNTO 6) > 0 THEN
								s_deficit3 <= s_deficit3 - 1;
							END IF;
						END IF;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	arbiter: PROCESS (reset_reset_n, clk_clk)
	BEGIN
		IF reset_reset_n = '0' THEN
			s_g0 <= '0'; s_g1 <= '0'; s_g2 <= '0'; s_g3 <= '0';
		ELSIF RISING_EDGE(clk_clk) THEN
			IF s_g0 = '1' AND in0_endofpacket = '1' AND in0_valid = '1' THEN
				s_g0 <= '0';
				CASE s_state IS
					WHEN S0 =>
						IF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						END IF;
					WHEN S1 =>
						IF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						END IF;
					WHEN S2 =>
						IF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						END IF;
					WHEN S3 =>
						IF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						END IF;
				END CASE;
			ELSIF s_g1 = '1' AND in1_endofpacket = '1' AND in1_valid = '1' THEN
				s_g1 <= '0';
				CASE s_state IS
					WHEN S0 =>
						IF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						END IF;
					WHEN S1 =>
						IF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						END IF;
					WHEN S2 =>
						IF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						END IF;
					WHEN S3 =>
						IF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						END IF;
				END CASE;
			ELSIF s_g2 = '1' AND in2_endofpacket = '1' AND in2_valid = '1' THEN
				s_g2 <= '0';
				CASE s_state IS
					WHEN S0 =>
						IF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						END IF;
					WHEN S1 =>
						IF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						END IF;
					WHEN S2 =>
						IF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						END IF;
					WHEN S3 =>
						IF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						END IF;
				END CASE;
			ELSIF s_g3 = '1' AND in3_endofpacket = '1' AND in3_valid = '1' THEN
				s_g3 <= '0';
				CASE s_state IS
					WHEN S0 =>
						IF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						END IF;
					WHEN S1 =>
						IF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						END IF;
					WHEN S2 =>
						IF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						END IF;
					WHEN S3 =>
						IF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						END IF;
				END CASE;
			ELSIF s_g0 = '0' AND s_g1 = '0' AND s_g2 = '0' AND s_g3 = '0' THEN
				CASE s_state IS
					WHEN S0 =>
						IF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						END IF;
					WHEN S1 =>
						IF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						END IF;
					WHEN S2 =>
						IF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						ELSIF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						END IF;
					WHEN S3 =>
						IF in3_startofpacket = '1' AND in3_valid = '1' THEN
							s_g3 <= '1';
						ELSIF in0_startofpacket = '1' AND in0_valid = '1' THEN
							s_g0 <= '1';
						ELSIF in1_startofpacket = '1' AND in1_valid = '1' THEN
							s_g1 <= '1';
						ELSIF in2_startofpacket = '1' AND in2_valid = '1' THEN
							s_g2 <= '1';
						END IF;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	mux: PROCESS (reset_reset_n, clk_clk)
	BEGIN
		IF reset_reset_n = '0' THEN
			s_data <= (OTHERS => '0');
			s_valid <= '0';
			s_startofpacket <= '0';
			s_endofpacket <= '0';
			s_empty <= (OTHERS => '0');
			s_channel <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_clk) THEN
			IF s_g0 = '1' THEN
				s_data <= in0_data;
				s_valid <= in0_valid;
				s_startofpacket <= in0_startofpacket;
				s_endofpacket <= in0_endofpacket;
				s_empty <= in0_empty;
				s_channel(127 DOWNTO 4) <= (OTHERS => '0');
				s_channel(3 DOWNTO 0) <= "1000";
			ELSIF s_g1 = '1' THEN
				s_data <= in1_data;
				s_valid <= in1_valid;
				s_startofpacket <= in1_startofpacket;
				s_endofpacket <= in1_endofpacket;
				s_empty <= in1_empty;
				s_channel(127 DOWNTO 4) <= (OTHERS => '0');
				s_channel(3 DOWNTO 0) <= "0100";
			ELSIF s_g2 = '1' THEN
				s_data <= in2_data;
				s_valid <= in2_valid;
				s_startofpacket <= in2_startofpacket;
				s_endofpacket <= in2_endofpacket;
				s_empty <= in2_empty;
				s_channel(127 DOWNTO 4) <= (OTHERS => '0');
				s_channel(3 DOWNTO 0) <= "0010";
			ELSIF s_g3 = '1' THEN
				s_data <= in3_data;
				s_valid <= in3_valid;
				s_startofpacket <= in3_startofpacket;
				s_endofpacket <= in3_endofpacket;
				s_empty <= in3_empty;
				s_channel(127 DOWNTO 4) <= (OTHERS => '0');
				s_channel(3 DOWNTO 0) <= "0001";
			ELSE
				s_data <= (OTHERS => '0');
				s_valid <= '0';
				s_startofpacket <= '0';
				s_endofpacket <= '0';
				s_empty <= (OTHERS => '0');
				s_channel <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;

	in0_ready <= s_g0 AND out_ready;
	in1_ready <= s_g1 AND out_ready;
	in2_ready <= s_g2 AND out_ready;
	in3_ready <= s_g3 AND out_ready;
	out_data <= s_data;
	out_valid <= s_valid;
	out_startofpacket <= s_startofpacket;
	out_endofpacket <= s_endofpacket;
	out_empty <= s_empty;
	out_channel <= s_channel;
END ARCHITECTURE rtl; -- of dppsn_scheduler
