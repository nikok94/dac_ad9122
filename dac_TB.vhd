----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.10.2018 08:42:52
-- Design Name: 
-- Module Name: dac_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity dac_TB is
--  Port ( );
end dac_TB;

architecture Behavioral of dac_TB is

component dac_ad9122_v1_0 is
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
end component;

component axi_dbg_master is
  generic (
    C_M_AXI_LITE_ADDR_WIDTH : INTEGER range 32 to 32 := 32;
    C_M_AXI_LITE_DATA_WIDTH : INTEGER range 32 to 32 := 32;  
    C_FAMILY               : String := "virtex6"
    );
  port (
    aclk            : in  std_logic                           ;
    aresetn         : in  std_logic                           ;
    md_error                   : out std_logic                           ;
    m_axi_lite_arready         : in  std_logic                           ; 
    m_axi_lite_arvalid         : out std_logic                           ; 
    m_axi_lite_araddr          : out std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0); 
    m_axi_lite_arprot          : out std_logic_vector(2 downto 0)        ;                                            
    m_axi_lite_rready          : out std_logic                           ; 
    m_axi_lite_rvalid          : in  std_logic                           ; 
    m_axi_lite_rdata           : in  std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0) ; 
    m_axi_lite_rresp           : in  std_logic_vector(1 downto 0)        ; 
    m_axi_lite_awready         : in  std_logic                           ;    
    m_axi_lite_awvalid         : out std_logic                           ;    
    m_axi_lite_awaddr          : out std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0);    
    m_axi_lite_awprot          : out std_logic_vector(2 downto 0)        ;    
    m_axi_lite_wready          : in  std_logic                           ;    
    m_axi_lite_wvalid          : out std_logic                           ;    
    m_axi_lite_wdata           : out std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);    
    m_axi_lite_wstrb           : out std_logic_vector((C_M_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
    m_axi_lite_bready          : out std_logic                           ;    
    m_axi_lite_bvalid          : in  std_logic                           ;    
    m_axi_lite_bresp           : in  std_logic_vector(1 downto 0)        ;   
    address                     : in std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0);
    mstr_rd                     : in std_logic;
    mstr_wr                     : in std_logic;
    mstr_wr_data                : in std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);
    mstr_rd_data                : out std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);
    mstr_cmplt                  : out std_logic
    );

end component axi_dbg_master;
    constant axi_clk_period             : time      := 10 ns;
    constant axis_clk_period            : time      := 3 ns;
    constant C_M_AXI_LITE_ADDR_WIDTH    : INTEGER   := 32;     
    constant C_M_AXI_LITE_DATA_WIDTH    : INTEGER   := 32; 
    constant C_S00_AXIS_DATA_WIDTH      : INTEGER   := 32;      
    constant C_FAMILY                   : STRING    := "virtex6";
    constant C_DAC_DATA_WIDTH           : INTEGER   := 16;
    
    signal axi_clk                      : std_logic;
    signal aresetn                      : std_logic;
    signal m_axi_lite_arready           : std_logic                           ; 
    signal m_axi_lite_arvalid           : std_logic                           ; 
    signal m_axi_lite_araddr            : std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0); 
    signal m_axi_lite_arprot            : std_logic_vector(2 downto 0)        ; 
    signal m_axi_lite_rready            : std_logic                           ; 
    signal m_axi_lite_rvalid            : std_logic                           ; 
    signal m_axi_lite_rdata             : std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0) ;
    signal m_axi_lite_rresp             : std_logic_vector(1 downto 0)        ;
    signal m_axi_lite_awready           : std_logic                           ;    
    signal m_axi_lite_awvalid           : std_logic                           ;    
    signal m_axi_lite_awaddr            : std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0);    
    signal m_axi_lite_awprot            : std_logic_vector(2 downto 0)        ;
    signal m_axi_lite_wready            : std_logic                           ;   
    signal m_axi_lite_wvalid            : std_logic                           ;   
    signal m_axi_lite_wdata             : std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);    
    signal m_axi_lite_wstrb             : std_logic_vector((C_M_AXI_LITE_DATA_WIDTH/8)-1 downto 0);
    signal m_axi_lite_bready            : std_logic                           ;    
    signal m_axi_lite_bvalid            : std_logic                           ;    
    signal m_axi_lite_bresp             : std_logic_vector(1 downto 0)        ;   
    signal address                      : std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0);
    signal mstr_rd                      : std_logic;
    signal mstr_wr                      : std_logic;
    signal mstr_wr_data                 : std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);
    signal mstr_rd_data                 : std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);
    signal mstr_cmplt                   : std_logic ;
    signal DCI_n                        : std_logic;                                   
    signal DCI_p                        : std_logic;                                                                                                   
    signal FRAME_n                      : std_logic;                                   
    signal FRAME_p                      : std_logic;                                                                                                       
    signal DATA_n                       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal DATA_p                       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal s00_axis_aclk                : std_logic;
    signal s00_axis_tdata               : std_logic_vector(C_S00_AXIS_DATA_WIDTH-1 downto 0);
    signal s00_axis_tready              : std_logic;
    signal s00_axis_tvalid              : std_logic;
    signal i_data                       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal q_data                       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal data_val                     : std_logic;
    signal ref_dac_clk                  : std_logic;
    signal FRAME                        : std_logic;
    signal DCI                          : std_logic;
    signal DATA                         : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    
    

begin

gen_axi_clk_proc : process
    begin
        axi_clk <= '0';
        wait for axi_clk_period/2;
        axi_clk <= '1';
        wait for axi_clk_period/2;               
    end process;

reset_gen_proc  : process
    begin
        aresetn <= '0';
        wait for 100 ns;
        wait until rising_edge(axi_clk);
        aresetn <= '1';
        wait;
    end process;

master_proc : process 
    begin
        mstr_rd <= '0';
        mstr_wr <= '0';
        wait until aresetn = '1';
        wait for 5*axi_clk_period;
        wait until rising_edge(axi_clk);
        mstr_wr <= '1';
        address <= (others => '0');
        mstr_wr_data <= x"0000_0001";
        wait for axi_clk_period;
        mstr_wr <= '0';
        wait for 100*axi_clk_period;
        wait until rising_edge(axi_clk);
        mstr_wr <= '1';
        address <= (others => '0');
        mstr_wr_data <= x"0000_0002";
        wait for axi_clk_period;
        mstr_wr <= '0';
        wait;
        
    end process;
    
axi_master_inst : axi_dbg_master
      generic map( 
        C_M_AXI_LITE_ADDR_WIDTH => C_M_AXI_LITE_ADDR_WIDTH,                  
        C_M_AXI_LITE_DATA_WIDTH => C_M_AXI_LITE_DATA_WIDTH,  
        C_FAMILY                => C_FAMILY
        )
      port map (
        aclk                    => axi_clk,
        aresetn                 => aresetn,
        md_error                => open,                                      
        m_axi_lite_arready      => m_axi_lite_arready,
        m_axi_lite_arvalid      => m_axi_lite_arvalid,
        m_axi_lite_araddr       => m_axi_lite_araddr ,
        m_axi_lite_arprot       => m_axi_lite_arprot,
        m_axi_lite_rready       => m_axi_lite_rready,
        m_axi_lite_rvalid       => m_axi_lite_rvalid,
        m_axi_lite_rdata        => m_axi_lite_rdata ,
        m_axi_lite_rresp        => m_axi_lite_rresp ,
        m_axi_lite_awready      => m_axi_lite_awready ,
        m_axi_lite_awvalid      => m_axi_lite_awvalid ,
        m_axi_lite_awaddr       => m_axi_lite_awaddr  ,                 
        m_axi_lite_awprot       => m_axi_lite_awprot ,
        m_axi_lite_wready       => m_axi_lite_wready ,  
        m_axi_lite_wvalid       => m_axi_lite_wvalid ,  
        m_axi_lite_wdata        => m_axi_lite_wdata  ,  
        m_axi_lite_wstrb        => m_axi_lite_wstrb  ,
        m_axi_lite_bready       => m_axi_lite_bready ,  
        m_axi_lite_bvalid       => m_axi_lite_bvalid ,  
        m_axi_lite_bresp        => m_axi_lite_bresp  ,  
        address                 => address      ,
        mstr_rd                 => mstr_rd      ,
        mstr_wr                 => mstr_wr      ,
        mstr_wr_data            => mstr_wr_data ,
        mstr_rd_data            => mstr_rd_data ,
        mstr_cmplt              => mstr_cmplt   
        );

dac_inst : dac_ad9122_v1_0 
        generic map(
            C_S00_AXI_DATA_WIDTH    => C_M_AXI_LITE_ADDR_WIDTH,
            C_S00_AXI_ADDR_WIDTH    => C_M_AXI_LITE_ADDR_WIDTH,
            C_S00_AXIS_DATA_WIDTH   => C_S00_AXIS_DATA_WIDTH,
            C_DAC_DATA_WIDTH        => C_DAC_DATA_WIDTH   
        )
        port map(
            s00_axi_aclk    => axi_clk    ,
            s00_axi_aresetn => aresetn ,
            s00_axi_awaddr  => m_axi_lite_awaddr  ,
            s00_axi_awprot  => m_axi_lite_awprot  ,
            s00_axi_awvalid => m_axi_lite_awvalid ,
            s00_axi_awready => m_axi_lite_awready ,
            s00_axi_wdata   => m_axi_lite_wdata   ,
            s00_axi_wstrb   => m_axi_lite_wstrb   ,
            s00_axi_wvalid  => m_axi_lite_wvalid  ,
            s00_axi_wready  => m_axi_lite_wready  ,
            s00_axi_bresp   => m_axi_lite_bresp   ,
            s00_axi_bvalid  => m_axi_lite_bvalid  ,
            s00_axi_bready  => m_axi_lite_bready  ,
            s00_axi_araddr  => m_axi_lite_araddr  ,
            s00_axi_arprot  => m_axi_lite_arprot  ,
            s00_axi_arvalid => m_axi_lite_arvalid ,
            s00_axi_arready => m_axi_lite_arready ,
            s00_axi_rdata   => m_axi_lite_rdata   ,
            s00_axi_rresp   => m_axi_lite_rresp   ,
            s00_axi_rvalid  => m_axi_lite_rvalid  ,
            s00_axi_rready  => m_axi_lite_rready  ,
             
            s00_axis_aclk   => s00_axis_aclk,
            s00_axis_aresetn=> aresetn,
            s00_axis_tdata  => s00_axis_tdata,
            s00_axis_tvalid => s00_axis_tvalid,
            s00_axis_tready => s00_axis_tready,

            ref_dac_clk    => ref_dac_clk,
            -- LVDS OUTS
            DCI_n          => DCI_n , 
            DCI_p          => DCI_p ,
            
            FRAME_n        => FRAME_n,
            FRAME_p        => FRAME_p,
            
            DATA_n         => DATA_n,
            DATA_p         => DATA_p   
        );
axis_clk_gen_proc   : process 
begin
s00_axis_aclk <= '0';
wait for axis_clk_period/2;
s00_axis_aclk <= '1';
wait for axis_clk_period/2;
end process;

ref_dac_clk <= s00_axis_aclk after 1ns;

s00_axis_tvalid <= data_val when rising_edge(s00_axis_aclk);
s00_axis_tdata  <= Q_data & i_data when rising_edge(s00_axis_aclk);
axis_data   : process(s00_axis_aclk)
    begin
        if aresetn = '0' then
            i_data <= (others => '0');
            q_data <= (others => '0');
            data_val <= '0';
        elsif rising_edge(s00_axis_aclk) then
            if s00_axis_tready = '1' then     
                i_data <= i_data + 1;
                Q_DATA <= Q_DATA + 2;
                data_val <= '1';
            else
                data_val <= '0';
            end if;
       end if;  
    end process;
    
    
   FRAME_IBUFDS_inst : IBUFDS
    generic map (
       DQS_BIAS => "FALSE"  -- (FALSE, TRUE)
    )
    port map (
       O => FRAME,   -- 1-bit output: Buffer output
       I => FRAME_p,   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
       IB => FRAME_n  -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );
   CLK_IBUFDS_inst : IBUFDS
     generic map (
        DQS_BIAS => "FALSE"  -- (FALSE, TRUE)
     )
     port map (
        O => DCI,   -- 1-bit output: Buffer output
        I => DCI_p,   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
        IB => DCI_n  -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
     );
     
   DATA_IBUF : for i in 0 to C_DAC_DATA_WIDTH-1 generate
     DATA_IBUFDS_inst : IBUFDS
       generic map (
          DQS_BIAS => "FALSE"  -- (FALSE, TRUE)
       )
       port map (
          O => DATA(i),   -- 1-bit output: Buffer output
          I => DATA_p(i),   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
          IB => DATA_n(i)  -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
       );
     end generate;
    

end Behavioral;
