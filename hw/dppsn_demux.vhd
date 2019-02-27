LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY dppsn_demux IS
	PORT (
		csr_address       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); --       csr.address
		csr_read          : IN  STD_LOGIC                     := '0';             --          .read
		csr_readdata      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);                    --          .readdata
		csr_write         : IN  STD_LOGIC                     := '0';             --          .write
		csr_writedata     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --          .writedata
		csr_waitrequest   : OUT STD_LOGIC;                                        --          .waitrequest
		csr_clk_clk       : IN  STD_LOGIC                     := '0';             --   csr_clk.clk
		csr_reset_reset_n : IN  STD_LOGIC                     := '0';             -- csr_reset.reset_n
		reset_reset_n      : IN  STD_LOGIC                     := '0';             --     reset.reset_n
		clk_clk            : IN  STD_LOGIC                     := '0';             --       clk.clk
		out0_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                    --      out0.data
		out0_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                     --          .empty
		out0_endofpacket   : OUT STD_LOGIC;                                        --          .endofpacket
		out0_ready         : IN  STD_LOGIC                     := '0';             --          .ready
		out0_startofpacket : OUT STD_LOGIC;                                        --          .startofpacket
		out0_valid         : OUT STD_LOGIC;                                        --          .valid
		out1_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                    --      out1.data
		out1_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                     --          .empty
		out1_endofpacket   : OUT STD_LOGIC;                                        --          .endofpacket
		out1_ready         : IN  STD_LOGIC                     := '0';             --          .ready
		out1_startofpacket : OUT STD_LOGIC;                                        --          .startofpacket
		out1_valid         : OUT STD_LOGIC;                                        --          .valid
		out2_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                    --      out2.data
		out2_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                     --          .empty
		out2_endofpacket   : OUT STD_LOGIC;                                        --          .endofpacket
		out2_ready         : IN  STD_LOGIC                     := '0';             --          .ready
		out2_startofpacket : OUT STD_LOGIC;                                        --          .startofpacket
		out2_valid         : OUT STD_LOGIC;                                        --          .valid
		out3_data          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);                    --      out3.data
		out3_empty         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                     --          .empty
		out3_endofpacket   : OUT STD_LOGIC;                                        --          .endofpacket
		out3_ready         : IN  STD_LOGIC                     := '0';             --          .ready
		out3_startofpacket : OUT STD_LOGIC;                                        --          .startofpacket
		out3_valid         : OUT STD_LOGIC;                                        --          .valid
		in_data            : IN  STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0'); --        in.data
		in_ready           : OUT STD_LOGIC;                                        --          .ready
		in_valid           : IN  STD_LOGIC                     := '0';             --          .valid
		in_startofpacket   : IN  STD_LOGIC                     := '0';             --          .startofpacket
		in_endofpacket     : IN  STD_LOGIC                     := '0';             --          .endofpacket
		in_empty           : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)  := (OTHERS => '0'); --          .empty
		in_channel         : IN  STD_LOGIC_VECTOR(127 DOWNTO 0):= (OTHERS => '0')  --          .channel
	);
END ENTITY dppsn_demux;

ARCHITECTURE rtl OF dppsn_demux IS
BEGIN
	csr_readdata <= "00000000000000000000000000000000";
	csr_waitrequest <= '0';
	
	demux: PROCESS (in_data, in_valid, in_startofpacket, in_endofpacket, in_empty, in_channel, out3_ready, out2_ready, out1_ready, out0_ready)
	BEGIN
		in_ready <= (NOT(in_channel(3)) OR out3_ready) AND (NOT(in_channel(2)) OR out2_ready) AND (NOT(in_channel(1)) OR out1_ready) AND (NOT(in_channel(0)) OR out0_ready);
		CASE in_channel(0) IS
			WHEN '1' =>
				out3_data <= in_data;
				out3_valid <= in_valid;
				out3_startofpacket <= in_startofpacket;
				out3_endofpacket <= in_endofpacket;
				out3_empty <= in_empty;
			WHEN OTHERS =>
				out3_data <= (OTHERS => '0');
				out3_valid <= '0';
				out3_startofpacket <= '0';
				out3_endofpacket <= '0';
				out3_empty <= (OTHERS => '0');
		END CASE;
		CASE in_channel(1) IS
			WHEN '1' =>
				out2_data <= in_data;
				out2_valid <= in_valid;
				out2_startofpacket <= in_startofpacket;
				out2_endofpacket <= in_endofpacket;
				out2_empty <= in_empty;
			WHEN OTHERS =>
				out2_data <= (OTHERS => '0');
				out2_valid <= '0';
				out2_startofpacket <= '0';
				out2_endofpacket <= '0';
				out2_empty <= (OTHERS => '0');
		END CASE;
		CASE in_channel(2) IS
			WHEN '1' =>
				out1_data <= in_data;
				out1_valid <= in_valid;
				out1_startofpacket <= in_startofpacket;
				out1_endofpacket <= in_endofpacket;
				out1_empty <= in_empty;
			WHEN OTHERS =>
				out1_data <= (OTHERS => '0');
				out1_valid <= '0';
				out1_startofpacket <= '0';
				out1_endofpacket <= '0';
				out1_empty <= (OTHERS => '0');
		END CASE;
		CASE in_channel(3) IS
			WHEN '1' =>
				out0_data <= in_data;
				out0_valid <= in_valid;
				out0_startofpacket <= in_startofpacket;
				out0_endofpacket <= in_endofpacket;
				out0_empty <= in_empty;
			WHEN OTHERS =>
				out0_data <= (OTHERS => '0');
				out0_valid <= '0';
				out0_startofpacket <= '0';
				out0_endofpacket <= '0';
				out0_empty <= (OTHERS => '0');
		END CASE;
	END PROCESS;
END ARCHITECTURE rtl; -- of dppsn_demux