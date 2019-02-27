LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DE5_Reference_Switch IS
	PORT (
		BUTTON : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

		--------- CLOCK ---------
		CLOCK_SCL : OUT STD_LOGIC;
		CLOCK_SDA : INOUT STD_LOGIC;

		--------- CPU ---------
		CPU_RESET_n : IN STD_LOGIC;

		--------- FAN ---------
		FAN_CTRL : INOUT STD_LOGIC;

		--------- FLASH ---------
		FLASH_ADV_n : OUT STD_LOGIC;
		FLASH_CE_n : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		FLASH_CLK : OUT STD_LOGIC;
		FLASH_OE_n : OUT STD_LOGIC;
		FLASH_RDY_BSY_n : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		FLASH_RESET_n : OUT STD_LOGIC;
		FLASH_WE_n : OUT STD_LOGIC;

		--------- FSM ---------
		FSM_A : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
		FSM_D : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);

		--------- HEX0 ---------
		HEX0_D : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX0_DP : OUT STD_LOGIC;

		--------- HEX1 ---------
		HEX1_D : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1_DP : OUT STD_LOGIC;

		--------- LED ---------
		LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		LED_BRACKET : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		LED_RJ45_L : OUT STD_LOGIC;
		LED_RJ45_R : OUT STD_LOGIC;


		--------- OSC ////////
		OSC_50_B3B : IN STD_LOGIC;
		OSC_50_B3D : IN STD_LOGIC;
		OSC_50_B4A : IN STD_LOGIC;
		OSC_50_B4D : IN STD_LOGIC;
		OSC_50_B7A : IN STD_LOGIC;
		OSC_50_B7D : IN STD_LOGIC;
		OSC_50_B8A : IN STD_LOGIC;
		OSC_50_B8D : IN STD_LOGIC;

		PLL_SCL : OUT STD_LOGIC;
		PLL_SDA : INOUT STD_LOGIC;

		--------- RS422 ---------
		RS422_DE : OUT STD_LOGIC;
		RS422_DIN : IN STD_LOGIC;
		RS422_DOUT : OUT STD_LOGIC;
		RS422_RE_n : OUT STD_LOGIC;
		RS422_TE : OUT STD_LOGIC;

		--------- RZQ ---------
		RZQ_0 : IN STD_LOGIC;
		RZQ_1 : IN STD_LOGIC;
		RZQ_4 : IN STD_LOGIC;
		RZQ_5 : IN STD_LOGIC;

		---------SPF CLOCK---------
		SFP_REFCLK_p : IN STD_LOGIC;
		
		--------- SFPA ---------
		SFPA_LOS : IN STD_LOGIC;
		SFPA_MOD0_PRSNT_n : IN STD_LOGIC;
		SFPA_MOD1_SCL : OUT STD_LOGIC;
		SFPA_MOD2_SDA : INOUT STD_LOGIC;
		SFPA_RATESEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		SFPA_RX_p : IN STD_LOGIC;
		SFPA_TXDISABLE : OUT STD_LOGIC;
		SFPA_TXFAULT : IN STD_LOGIC;
		SFPA_TX_p : OUT STD_LOGIC;

		--------- SFPB ---------
		SFPB_LOS : IN STD_LOGIC;
		SFPB_MOD0_PRSNT_n : IN STD_LOGIC;
		SFPB_MOD1_SCL : OUT STD_LOGIC;
		SFPB_MOD2_SDA : INOUT STD_LOGIC;
		SFPB_RATESEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		SFPB_RX_p : IN STD_LOGIC;
		SFPB_TXDISABLE : OUT STD_LOGIC;
		SFPB_TXFAULT : IN STD_LOGIC;
		SFPB_TX_p : OUT STD_LOGIC;

		--------- SFPC ---------
		SFPC_LOS : IN STD_LOGIC;
		SFPC_MOD0_PRSNT_n : IN STD_LOGIC;
		SFPC_MOD1_SCL : OUT STD_LOGIC;
		SFPC_MOD2_SDA : INOUT STD_LOGIC;
		SFPC_RATESEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		SFPC_RX_p : IN STD_LOGIC;
		SFPC_TXDISABLE : OUT STD_LOGIC;
		SFPC_TXFAULT : IN STD_LOGIC;
		SFPC_TX_p : OUT STD_LOGIC;

		--------- SFPD ---------
		SFPD_LOS : IN STD_LOGIC;
		SFPD_MOD0_PRSNT_n : IN STD_LOGIC;
		SFPD_MOD1_SCL : OUT STD_LOGIC;
		SFPD_MOD2_SDA : INOUT STD_LOGIC;
		SFPD_RATESEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		SFPD_RX_p : IN STD_LOGIC;
		SFPD_TXDISABLE : OUT STD_LOGIC;
		SFPD_TXFAULT : IN STD_LOGIC;
		SFPD_TX_p : OUT STD_LOGIC;

		--------- SMA ---------
		SMA_CLKIN : IN STD_LOGIC;
		SMA_CLKOUT : OUT STD_LOGIC;

		--------- SW ---------
		SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

		--------- TEMP ---------
		TEMP_CLK : OUT STD_LOGIC;
		TEMP_DATA : INOUT STD_LOGIC;
		TEMP_INT_n : IN STD_LOGIC;
		TEMP_OVERT_n : IN STD_LOGIC;

		RX_CLOCK : OUT STD_LOGIC;
		PHY0_RX : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
		PHY0_TX : OUT STD_LOGIC_VECTOR(71 DOWNTO 0)
	);
END DE5_Reference_Switch;

ARCHITECTURE arch_DE5_Reference_Switch OF DE5_Reference_Switch IS
	SIGNAL user_reset_n : STD_LOGIC;
	SIGNAL clk_type : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL clock_freq_result : STD_LOGIC;
	SIGNAL si570_controller_start : STD_LOGIC;
	SIGNAL si570_config_ready : STD_LOGIC;
	SIGNAL reset_n : STD_LOGIC;
	SIGNAL clk_125 : STD_LOGIC;
	SIGNAL xcvr_refclk_hb : STD_LOGIC;
	SIGNAL clk125_hb : STD_LOGIC;
	SIGNAL xgmii_rx_clk_clk : STD_LOGIC;
	SIGNAL phy_0_xgmii_tx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_0_xgmii_rx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_1_xgmii_tx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_1_xgmii_rx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_2_xgmii_tx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_2_xgmii_rx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_3_xgmii_tx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL phy_3_xgmii_rx_data : STD_LOGIC_VECTOR(71 DOWNTO 0);
	
	COMPONENT si570_controller IS
		PORT(
			iCLK : IN STD_LOGIC;
			iRST_n : IN STD_LOGIC;
			iStart : IN STD_LOGIC;
			I2C_CLK : OUT STD_LOGIC;
			I2C_DATA : INOUT STD_LOGIC;
			oSI570_ONE_CLK_CONFIG_DONE : OUT STD_LOGIC;
			oREAD_Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			iFREQ_MODE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			oController_Ready : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT edge_detector IS
		PORT(
			iCLK : IN STD_LOGIC;
			iRST_n : IN STD_LOGIC;
			iIn : IN STD_LOGIC;
			oFallING_EDGE : OUT STD_LOGIC;
			oRISING_EDGE : OUT STD_LOGIC;
			oDEBOUNCE_OUT : OUT STD_LOGIC;
			rst_cnt : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT heart_beat IS
		PORT(
			clk : IN STD_LOGIC;
			led : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT mgmt_pll IS
		PORT(
			refclk : IN  STD_LOGIC;
			rst : IN  STD_LOGIC;
			outclk_0 : OUT STD_LOGIC;
			locked : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT phy_10gbaser IS
		PORT(
			pll_ref_clk          : IN  STD_LOGIC                      := '0';
			xgmii_rx_clk         : OUT STD_LOGIC;
			rx_block_lock        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			rx_hi_ber            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			tx_ready             : OUT STD_LOGIC;
			xgmii_tx_clk         : IN  STD_LOGIC                      := '0';
			rx_ready             : OUT STD_LOGIC;
			rx_data_ready        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			xgmii_rx_dc_0        : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			rx_serial_data_0     : IN  STD_LOGIC                      := '0';
			xgmii_rx_dc_1        : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			rx_serial_data_1     : IN  STD_LOGIC                      := '0';
			xgmii_rx_dc_2        : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			rx_serial_data_2     : IN  STD_LOGIC                      := '0';
			xgmii_rx_dc_3        : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			rx_serial_data_3     : IN  STD_LOGIC                      := '0';
			xgmii_tx_dc_0        : IN  STD_LOGIC_VECTOR(71 DOWNTO 0)  := (OTHERS => '0');
			tx_serial_data_0     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			xgmii_tx_dc_1        : IN  STD_LOGIC_VECTOR(71 DOWNTO 0)  := (OTHERS => '0');
			tx_serial_data_1     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			xgmii_tx_dc_2        : IN  STD_LOGIC_VECTOR(71 DOWNTO 0)  := (OTHERS => '0');
			tx_serial_data_2     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			xgmii_tx_dc_3        : IN  STD_LOGIC_VECTOR(71 DOWNTO 0)  := (OTHERS => '0');
			tx_serial_data_3     : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			reconfig_from_xcvr   : OUT STD_LOGIC_VECTOR(367 DOWNTO 0);
			reconfig_to_xcvr     : IN  STD_LOGIC_VECTOR(559 DOWNTO 0) := (OTHERS => '0');
			phy_mgmt_clk         : IN  STD_LOGIC                      := '0';
			phy_mgmt_clk_reset   : IN  STD_LOGIC                      := '0';
			phy_mgmt_address     : IN  STD_LOGIC_VECTOR(8 DOWNTO 0)   := (OTHERS => '0');
			phy_mgmt_read        : IN  STD_LOGIC                      := '0';
			phy_mgmt_readdata    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			phy_mgmt_write       : IN  STD_LOGIC                      := '0';
			phy_mgmt_writedata   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0)  := (OTHERS => '0');
			phy_mgmt_waitrequest : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT DE5_Reference_Switch_Qsys IS
		PORT(
			eth_10g_mac_0_xgmii_rx_data : IN  STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_0_xgmii_tx_data : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_1_xgmii_rx_data : IN  STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_1_xgmii_tx_data : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_2_xgmii_rx_data : IN  STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_2_xgmii_tx_data : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_3_xgmii_rx_data : IN  STD_LOGIC_VECTOR(71 DOWNTO 0);
			eth_10g_mac_3_xgmii_tx_data : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
			in_clk_125_clk : IN  STD_LOGIC;
			in_reset_reset_n : IN  STD_LOGIC;
			jtag_master_0_master_reset_reset : OUT STD_LOGIC;
			phy_clk156_clk : IN  STD_LOGIC
		);
	END COMPONENT;
BEGIN
	user_reset_n <= BUTTON(0);

	FAN_CTRL <= '1'; 					-- turn on the fan
	LED_RJ45_L <= clk125_hb; 		-- heart beat of clk125
	LED_RJ45_R <= xcvr_refclk_hb; -- heart beat of xcvr refclk

	RX_CLOCK <= xgmii_rx_clk_clk;
	PHY0_RX <= phy_0_xgmii_rx_data(71) & phy_0_xgmii_rx_data (62) & phy_0_xgmii_rx_data(53) & phy_0_xgmii_rx_data(44) & phy_0_xgmii_rx_data(35) & phy_0_xgmii_rx_data(26) & phy_0_xgmii_rx_data(17) & phy_0_xgmii_rx_data(8) & phy_0_xgmii_rx_data(70 DOWNTO 63) & phy_0_xgmii_rx_data(61 DOWNTO 54) & phy_0_xgmii_rx_data(52 DOWNTO 45) & phy_0_xgmii_rx_data(43 DOWNTO 36) & phy_0_xgmii_rx_data(34 DOWNTO 27) & phy_0_xgmii_rx_data(25 DOWNTO 18) & phy_0_xgmii_rx_data(16 DOWNTO 9) & phy_0_xgmii_rx_data(7 DOWNTO 0);
	PHY0_TX <= phy_0_xgmii_tx_data(71) & phy_0_xgmii_tx_data (62) & phy_0_xgmii_tx_data(53) & phy_0_xgmii_tx_data(44) & phy_0_xgmii_tx_data(35) & phy_0_xgmii_tx_data(26) & phy_0_xgmii_tx_data(17) & phy_0_xgmii_tx_data(8) & phy_0_xgmii_tx_data(70 DOWNTO 63) & phy_0_xgmii_tx_data(61 DOWNTO 54) & phy_0_xgmii_tx_data(52 DOWNTO 45) & phy_0_xgmii_tx_data(43 DOWNTO 36) & phy_0_xgmii_tx_data(34 DOWNTO 27) & phy_0_xgmii_tx_data(25 DOWNTO 18) & phy_0_xgmii_tx_data(16 DOWNTO 9) & phy_0_xgmii_tx_data(7 DOWNTO 0);
	
	-- configure external pll Si570 which provides xcvr ref clock 322.26Mhz
	si570_controller_inst : si570_controller PORT MAP(
		iCLK => OSC_50_B3B,
		iRST_n => user_reset_n, -- system reset
		iStart => si570_controller_start, -- giving 1 50Mhz cycle high pulse to set frequency
		iFREQ_MODE => "101", -- clock frequency mode   000:100Mhz, 001: 125Mhz, 010:156.25Mhz, 011:250Mhz, 100:312.5Mhz , 101:322.26Mhz , 110:644.53Mhz ,111:100Mhz 
		I2C_CLK => CLOCK_SCL,
		I2C_DATA => CLOCK_SDA
	);
	edge_detector_inst : edge_detector PORT MAP(
		iCLK => OSC_50_B3B,
		iRST_n => user_reset_n,
		iIn => BUTTON(1),
		oDEBOUNCE_OUT => si570_controller_start
	);
	
	-- generate clk125 for phy_mgmt
	mgmt_pll_inst : mgmt_pll PORT MAP(
		refclk => OSC_50_B3B,
		rst => '0',
		outclk_0 => clk_125,
		locked => reset_n
	);
	
	phy_10gbaser_inst : phy_10gbaser PORT MAP(
		pll_ref_clk => SFP_REFCLK_p,
		xgmii_rx_clk => xgmii_rx_clk_clk,
		xgmii_tx_clk => xgmii_rx_clk_clk,
		rx_block_lock => LED_BRACKET,
		rx_hi_ber => LED,
		xgmii_rx_dc_0 => phy_0_xgmii_rx_data,
		xgmii_tx_dc_0 => phy_0_xgmii_tx_data,
		xgmii_rx_dc_1 => phy_1_xgmii_rx_data,
		xgmii_tx_dc_1 => phy_1_xgmii_tx_data,
		xgmii_rx_dc_2 => phy_2_xgmii_rx_data,
		xgmii_tx_dc_2 => phy_2_xgmii_tx_data,
		xgmii_rx_dc_3 => phy_3_xgmii_rx_data,
		xgmii_tx_dc_3 => phy_3_xgmii_tx_data,
		rx_serial_data_0 => SFPA_RX_p,
		tx_serial_data_0(0) => SFPA_TX_p,
		rx_serial_data_1 => SFPB_RX_p,
		tx_serial_data_1(0) => SFPB_TX_p,
		rx_serial_data_2 => SFPC_RX_p,
		tx_serial_data_2(0) => SFPC_TX_p,
		rx_serial_data_3 => SFPD_RX_p,
		tx_serial_data_3(0) => SFPD_TX_p,
		phy_mgmt_clk => OSC_50_B3B,
		phy_mgmt_clk_reset => NOT reset_n
	);
	
	DE5_Reference_Switch_Qsys_inst : DE5_Reference_Switch_Qsys PORT MAP(
		eth_10g_mac_0_xgmii_tx_data => phy_0_xgmii_tx_data,
		eth_10g_mac_0_xgmii_rx_data => phy_0_xgmii_rx_data,
		eth_10g_mac_1_xgmii_tx_data => phy_1_xgmii_tx_data,
		eth_10g_mac_1_xgmii_rx_data => phy_1_xgmii_rx_data,
		eth_10g_mac_2_xgmii_tx_data => phy_2_xgmii_tx_data,
		eth_10g_mac_2_xgmii_rx_data => phy_2_xgmii_rx_data,
		eth_10g_mac_3_xgmii_tx_data => phy_3_xgmii_tx_data,
		eth_10g_mac_3_xgmii_rx_data => phy_3_xgmii_rx_data,
		in_clk_125_clk => clk_125,
		in_reset_reset_n => reset_n,
		phy_clk156_clk => xgmii_rx_clk_clk
	);
END arch_DE5_Reference_Switch;