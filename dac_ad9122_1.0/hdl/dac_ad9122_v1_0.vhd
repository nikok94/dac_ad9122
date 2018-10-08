library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_ad9122_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4;
		C_S00_AXIS_DATA_WIDTH	: integer	:= 32;
		C_DAC_DATA_WIDTH        : integer   := 16
		
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;
		
		-- DAC AXIS DATA PORT
		s00_axis_aclk   : in std_logic;
		s00_axis_aresetn: in std_logic;
		s00_axis_tdata  : in std_logic_vector(C_S00_AXIS_DATA_WIDTH-1 downto 0);
		s00_axis_tvalid : in std_logic;
		s00_axis_tready : out std_logic;
		
		-- REF DAC CLK
		ref_dac_clk     : in std_logic;
		-- LVDS OUTS
		DCI_n           : inout std_logic;  
		DCI_p           : inout std_logic;
		
		FRAME_n         : inout std_logic;
		FRAME_p         : inout std_logic;
		
		DATA_n          : inout std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
		DATA_p          : inout std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0)
		
	);
end dac_ad9122_v1_0;

architecture arch_imp of dac_ad9122_v1_0 is
    
    constant ad_cnt_reg_width   : integer := 4;

	-- component declaration
	component dac_ad9122_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		sync_req         : out std_logic;
        sync_ack         : in std_logic;
        dac_cntr_reg     : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
		);
	end component dac_ad9122_v1_0_S00_AXI;
	
	component b_ad9122 is
        generic (
            C_TX_DATA_WIDTH         : integer := 32;
            C_DAC_DATA_WIDTH        : integer := 16;
            C_CNTR_REG_WIDTH        : integer := 32
          );
          Port ( 
            control_reg             : in std_logic_vector(C_CNTR_REG_WIDTH-1 downto 0);
            control_reg_en          : in std_logic;
            
            aclk                    : in std_logic;
            s_tdata                 : in std_logic_vector(C_TX_DATA_WIDTH-1 downto 0);
            s_tvalid                : in std_logic;
            s_tready                : out std_logic;
            
            fifo_rst                : out std_logic;
            fifo_ack                : in  std_logic;
            
            DCI_n                   : inout std_logic;                                   
            DCI_p                   : inout std_logic;                                   
                                                                                         
            FRAME_n                 : inout std_logic;                                   
            FRAME_p                 : inout std_logic;                                   
                                                                                         
            DATA_n                  : inout std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
            DATA_p                  : inout std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0)
          );
    end component b_ad9122;
    
    component sync_data is
        generic (
        C_WIDTH : integer := 32;
        C_NUM_SYNCHRONIZER_STAGES : integer := 2
        );
        port (
            from_clk    : in std_logic;
            req         : in std_logic;
            ack         : out std_logic;
            data_in     : in std_logic_vector(C_WIDTH-1 downto 0);
            
            to_clk      : in std_logic;
            data_valid  : out std_logic;
            data_out    : out std_logic_vector(C_WIDTH-1 downto 0)
        );
    end component sync_data;
    
    component fifo_generator_0 is
      PORT (
        wr_rst_busy : OUT STD_LOGIC;
        rd_rst_busy : OUT STD_LOGIC;
        m_aclk : IN STD_LOGIC;
        s_aclk : IN STD_LOGIC;
        s_aresetn : IN STD_LOGIC;
        s_axis_tvalid : IN STD_LOGIC;
        s_axis_tready : OUT STD_LOGIC;
        s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_tvalid : OUT STD_LOGIC;
        m_axis_tready : IN STD_LOGIC;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    end component fifo_generator_0;
    
    component pulse_sync is
        generic (
        C_NUM_SYNCHRONIZER_STAGES : integer := 2
        );
        port (
            from_clk    : in std_logic;
            req         : in std_logic;
            ack         : out std_logic;
    
            to_clk      : in std_logic;
            sync_out    : out std_logic
        );
    end component pulse_sync;
   
    constant C_NUM_SYNCHRONIZER_STAGES  : integer := 2;
    signal sync_req             : std_logic;
    signal sync_ack             : std_logic;
    signal dac_cntr_reg         : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal sync_dac_cntr_reg    : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal sync_val_cntr_reg    : std_logic;
    signal q_form_chi_dat       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal q_form_chq_dat       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal ad9122control_reg    : std_logic_vector(ad_cnt_reg_width-1 downto 0);
    signal ad_tx_en             : std_logic:= '0';
    signal fifo_wr_rst_busy     : std_logic;
    signal fifo_rd_rst_busy     : std_logic;
    signal tx_data              : std_logic_vector(31 downto 0);
    signal tx_data_val          : std_logic;
    signal block_ready          : std_logic;
    signal block_ad_fifo_rst    : std_logic;
    signal block_ad_fifo_ack    : std_logic;
    signal block_ad_rst_sync    : std_logic;
    signal fifo_rst_n           : std_logic;
    
    
begin

    fifo_rst_n <= (s00_axis_aresetn and (not block_ad_rst_sync)) when rising_edge(s00_axis_aclk);

-- Instantiation of Axi Bus Interface S00_AXI
dac_ad9122_v1_0_S00_AXI_inst : dac_ad9122_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	    => s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	    => s00_axi_wdata,
		S_AXI_WSTRB	    => s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	    => s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	    => s00_axi_rdata,
		S_AXI_RRESP	    => s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		sync_req        => sync_req,
        sync_ack        => sync_ack,
        dac_cntr_reg    => dac_cntr_reg
	);
	
	
rst_fifo_sync   : pulse_sync 
        generic map (
        C_NUM_SYNCHRONIZER_STAGES =>  C_NUM_SYNCHRONIZER_STAGES
        )
        port map(
            from_clk        => ref_dac_clk,
            req             => block_ad_fifo_rst,
            ack             => block_ad_fifo_ack,
    
            to_clk          => s00_axis_aclk,
            sync_out        => block_ad_rst_sync
        );

	-- Add user logic here
stream_fifo_inst    :   fifo_generator_0
          port map (
            wr_rst_busy     => fifo_wr_rst_busy,
            rd_rst_busy     => fifo_rd_rst_busy,
            m_aclk          => ref_dac_clk,
            s_aclk          => s00_axis_aclk,
            s_aresetn       => fifo_rst_n,
            s_axis_tvalid   => s00_axis_tvalid,
            s_axis_tready   => s00_axis_tready,
            s_axis_tdata    => s00_axis_tdata,
            m_axis_tvalid   => tx_data_val,
            m_axis_tready   => block_ready,
            m_axis_tdata    => tx_data
          );

dac_cntr_reg_sinc_proc  : sync_data 
            generic map(
            C_WIDTH                     => C_S00_AXI_DATA_WIDTH,
            C_NUM_SYNCHRONIZER_STAGES   => 2
            )
            port map(
                from_clk    => s00_axi_aclk,
                req         => sync_req,
                ack         => sync_ack,
                data_in     => dac_cntr_reg,
                
                to_clk      => ref_dac_clk,
                data_valid  => sync_val_cntr_reg,
                data_out    => sync_dac_cntr_reg
            );

block_ad9122_inst : b_ad9122
        generic map (
              C_TX_DATA_WIDTH  => C_S00_AXIS_DATA_WIDTH,
              C_DAC_DATA_WIDTH => C_DAC_DATA_WIDTH,
              C_CNTR_REG_WIDTH => C_S00_AXI_DATA_WIDTH
             )
        port map(
              control_reg     => sync_dac_cntr_reg,
              control_reg_en  => sync_val_cntr_reg,
              aclk            => ref_dac_clk,
              s_tdata         => tx_data,
              s_tvalid        => tx_data_val,
              s_tready        => block_ready,
              
              fifo_rst        => block_ad_fifo_rst,
              fifo_ack        => block_ad_fifo_ack,
              
              
              DCI_n           => DCI_n ,                                   
              DCI_p           => DCI_p,                                   
                                                                                   
              FRAME_n         => FRAME_n,                                   
              FRAME_p         => FRAME_p,                                   
                                                                                   
              DATA_n          => DATA_n,
              DATA_p          => DATA_p
             );
	-- User logic ends

end arch_imp;
