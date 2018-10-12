-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------------------------

entity axi_dbg_master is
  generic (
     
 
    -- AXI4-Lite Parameters 
    C_M_AXI_LITE_ADDR_WIDTH : INTEGER range 32 to 32 := 32;  
      --  width of AXI4 Address Bus (in bits)
             
    C_M_AXI_LITE_DATA_WIDTH : INTEGER range 32 to 32 := 32;  
      --  Width of the AXI4 Data Bus (in bits)
             
    
    -- FPGA Family Parameter      
    C_FAMILY               : String := "virtex6"
      -- Select the target architecture type
      -- see the family.vhd package in the proc_common
      -- library
    );
  port (
    
    -----------------------------------------------------------------------
    -- Clock Input
    -----------------------------------------------------------------------
    aclk            : in  std_logic                           ;-- AXI4
    
    -----------------------------------------------------------------------
    -- Reset Input (active low) 
    -----------------------------------------------------------------------
    aresetn         : in  std_logic                           ;-- AXI4

    
    
    -----------------------------------------------------------------------
    -- Master Detected Error output 
    -----------------------------------------------------------------------
    md_error                   : out std_logic                           ;-- Discrete Out
    
    
     
     
    ----------------------------------------------------------------------------
    -- AXI4 Read Channels
    ----------------------------------------------------------------------------
    --  AXI4 Read Address Channel                                          -- AXI4
    m_axi_lite_arready         : in  std_logic                           ; -- AXI4
    m_axi_lite_arvalid         : out std_logic                           ; -- AXI4
    m_axi_lite_araddr          : out std_logic_vector                      -- AXI4
                                     (C_M_AXI_LITE_ADDR_WIDTH-1 downto 0); -- AXI4
    m_axi_lite_arprot          : out std_logic_vector(2 downto 0)        ; -- AXI4
                                                                           -- AXI4
    --  AXI4 Read Data Channel                                             -- AXI4
    m_axi_lite_rready          : out std_logic                           ; -- AXI4
    m_axi_lite_rvalid          : in  std_logic                           ; -- AXI4
    m_axi_lite_rdata           : in  std_logic_vector                      -- AXI4
                                    (C_M_AXI_LITE_DATA_WIDTH-1 downto 0) ; -- AXI4
    m_axi_lite_rresp           : in  std_logic_vector(1 downto 0)        ; -- AXI4
                         


    -----------------------------------------------------------------------------
    -- AXI4 Write Channels
    -----------------------------------------------------------------------------
    -- AXI4 Write Address Channel
    m_axi_lite_awready         : in  std_logic                           ;    -- AXI4
    m_axi_lite_awvalid         : out std_logic                           ;    -- AXI4
    m_axi_lite_awaddr          : out std_logic_vector                         -- AXI4
                                     (C_M_AXI_LITE_ADDR_WIDTH-1 downto 0);    -- AXI4
    m_axi_lite_awprot          : out std_logic_vector(2 downto 0)        ;    -- AXI4
                                                                              -- AXI4
    -- AXI4 Write Data Channel                                                -- AXI4
    m_axi_lite_wready          : in  std_logic                           ;    -- AXI4
    m_axi_lite_wvalid          : out std_logic                           ;    -- AXI4
    m_axi_lite_wdata           : out std_logic_vector                         -- AXI4
                                     (C_M_AXI_LITE_DATA_WIDTH-1 downto 0);    -- AXI4
    m_axi_lite_wstrb           : out std_logic_vector                         -- AXI4
                                     ((C_M_AXI_LITE_DATA_WIDTH/8)-1 downto 0);-- AXI4
                                                                              -- AXI4
    -- AXI4 Write Response Channel                                            -- AXI4
    m_axi_lite_bready          : out std_logic                           ;    -- AXI4
    m_axi_lite_bvalid          : in  std_logic                           ;    -- AXI4
    m_axi_lite_bresp           : in  std_logic_vector(1 downto 0)        ;    -- AXI4




    -----------------------------------------------------------------------------
    -- IP Master Request/Qualifers
    -----------------------------------------------------------------------------
    address                     : in std_logic_vector(C_M_AXI_LITE_ADDR_WIDTH-1 downto 0);
    mstr_rd                     : in std_logic;
    mstr_wr                     : in std_logic;
    mstr_wr_data                : in std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);
    mstr_rd_data                : out std_logic_vector(C_M_AXI_LITE_DATA_WIDTH-1 downto 0);
    mstr_cmplt                  : out std_logic
    );

end entity axi_dbg_master;


architecture implementation of axi_dbg_master is


  
  -- Signals
  signal sig_master_reset        : std_logic := '0';
  signal master_read_data        : std_logic_vector(31 downto 0);
  signal bus2ip_mstrd_src_rdy_n  : std_logic;
  signal bus2ip_mstwr_dst_rdy_n  : std_logic;
  signal reset                   : std_logic;
  
  
   
                      

begin --(architecture implementation)

reset <= not aresetn;
  ------------------------------------------------------------
  -- Instance: I_RD_WR_CNTLR 
  --
  -- Description:
  --   Instance for the Read/Write Controller Module  
  --
  ------------------------------------------------------------
  I_RD_WR_CNTLR : entity work.axi_master_lite_cntlr
  generic map (
   
    C_M_AXI_LITE_ADDR_WIDTH => C_M_AXI_LITE_ADDR_WIDTH,   
    C_M_AXI_LITE_DATA_WIDTH => C_M_AXI_LITE_DATA_WIDTH,  
    C_FAMILY                => C_FAMILY
    
    )
  port map (

    -----------------------------------
    -- Clock Input
    -----------------------------------
    axi_aclk        => aclk ,            
    
    -----------------------------------
    -- Reset Input (active high) 
    -----------------------------------
    axi_reset      =>  reset,             

    
    
    -----------------------------------
    -- Master Detected Error output 
    -----------------------------------
    md_error       =>  open        ,             
    
    
     
     
    -----------------------------------
    -- AXI4 Read Channels
    -----------------------------------
    --  AXI4 Read Address Channel      
    m_axi_arready  => m_axi_lite_arready ,
    m_axi_arvalid  => m_axi_lite_arvalid ,
    m_axi_araddr   => m_axi_lite_araddr  ,
    m_axi_arprot   => m_axi_lite_arprot  ,
                                      
    --  AXI4 Read Data Channel         
    m_axi_rready   => m_axi_lite_rready  , 
    m_axi_rvalid   => m_axi_lite_rvalid  , 
    m_axi_rdata    => m_axi_lite_rdata   , 
    m_axi_rresp    => m_axi_lite_rresp   , 
                               


    -----------------------------------
    -- AXI4 Write Channels
    -----------------------------------
    -- AXI4 Write Address Channel
    m_axi_awready  => m_axi_lite_awready ,      
    m_axi_awvalid  => m_axi_lite_awvalid ,      
    m_axi_awaddr   => m_axi_lite_awaddr  ,      
    m_axi_awprot   => m_axi_lite_awprot  ,      
                                                                              
    -- AXI4 Write Data Channel                                                
    m_axi_wready   => m_axi_lite_wready  ,      
    m_axi_wvalid   => m_axi_lite_wvalid  ,      
    m_axi_wdata    => m_axi_lite_wdata   ,      
    m_axi_wstrb    => m_axi_lite_wstrb   ,      
                                                                              
    -- AXI4 Write Response Channel                                            
    m_axi_bready   => m_axi_lite_bready  ,      
    m_axi_bvalid   => m_axi_lite_bvalid  ,      
    m_axi_bresp    => m_axi_lite_bresp   ,      




    -----------------------------------
    -- IP Master Request/Qualifers
    -----------------------------------
    ip2bus_mstrd_req        => mstr_rd   ,         
    ip2bus_mstwr_req        => mstr_wr   ,         
    ip2bus_mst_addr         => address    ,         
    ip2bus_mst_be           => b"1111"      ,              
    ip2bus_mst_lock         => '0'    ,         
                                    
    -----------------------------------
    -- IP Request Status Reply                  
    -----------------------------------
    bus2ip_mst_cmdack       => open       ,    
    bus2ip_mst_cmplt        => mstr_cmplt        ,    
    bus2ip_mst_error        => open        ,    
    bus2ip_mst_rearbitrate  => open  ,    
    bus2ip_mst_cmd_timeout  => open  ,    
                               
                               
    -----------------------------------
    -- IPIC Read data                           
    -----------------------------------
    bus2ip_mstrd_d          => mstr_rd_data,    
    bus2ip_mstrd_src_rdy_n  => bus2ip_mstrd_src_rdy_n  ,    
                               
    ----------------------------------
    -- IPIC Write data                         
    ----------------------------------
    ip2bus_mstwr_d          => mstr_wr_data          ,    
    bus2ip_mstwr_dst_rdy_n  => bus2ip_mstwr_dst_rdy_n      
    
    );

        
        
          
          
          
end implementation;
