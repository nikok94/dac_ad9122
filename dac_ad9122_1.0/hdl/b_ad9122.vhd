----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.10.2018 16:48:16
-- Design Name: 
-- Module Name: b_ad9122 - Behavioral
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
USE ieee.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity b_ad9122 is
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
end b_ad9122;

architecture Behavioral of b_ad9122 is
    type RAM is array (0 to 7) of std_logic_vector(C_DAC_DATA_WIDTH-1 downto 0);
    signal mem_chi  : RAM;
    signal mem_chq  : RAM;
    signal chi_raddr: std_logic_vector(2 downto 0);
    signal chq_raddr: std_logic_vector(2 downto 0);
    signal waddr    : std_logic_vector(2 downto 0);
    signal wr_en    : std_logic;
    signal rd_en    : std_logic;
    signal chi_rd_en : std_logic:= '0';
    signal chq_rd_en : std_logic:= '0';
    
    signal wr_en_reg : std_logic_vector(2 downto 0):= (others => '0');
    
    signal chq_d_valid : std_logic:= '0';
    signal chi_d_valid : std_logic:= '0';
    
    signal frm_s_valid : std_logic:= '0';
    
    signal tready           : std_logic;
    signal rst              : std_logic:='1';
    signal req_fifo_rst     : std_logic:='0';
    
    signal cntrl_reg        : std_logic_vector(C_CNTR_REG_WIDTH-1 downto 0):= (others => '0');
    signal frame_mod        : std_logic_vector(1 downto 0);
    
    signal q_chq_frm        : std_logic := '0';
    signal q_chi_frm        : std_logic := '0';
    
    signal s_chq_frm        : std_logic := '0';
    signal s_chi_frm        : std_logic := '0';
    
    signal d_chq_frm        : std_logic := '0';
    signal d_chi_frm        : std_logic := '0';
    
    signal q_chi_data       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 00) := (others => '0');
    signal q_chq_data       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 00) := (others => '0');
    
    signal frm_chi_data     : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 00) := (others => '0');
    signal frm_chq_data     : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 00) := (others => '0');
    
    signal q_chi_clk        : std_logic;
    signal q_chq_clk        : std_logic;
    
    signal w_ddr_data       : std_logic_vector(C_DAC_DATA_WIDTH-1 downto 00);
    signal w_ddr_frm        : std_logic;
    signal w_ddr_clk        : std_logic;
    
    signal byte_frame_form  : std_logic:= '1';   
    signal nibble_frame_form: std_logic:= '1';   
    
begin 

READ_CNTRL_REG_PROC : process(aclk)
    begin
        if (rising_edge(aclk)) then
            if (control_reg_en = '1') then
                 cntrl_reg(C_CNTR_REG_WIDTH-1 downto 0) <= control_reg(C_CNTR_REG_WIDTH-1 downto 0);
            end if;
        end if;
    end process;
 
frame_mod <= cntrl_reg(1 downto 0);

RESET_GEN_PROCESS : process(aclk)
    variable rst_reg : std_logic_vector(7 downto 0):= (others => '0');
    begin
        if (rising_edge(aclk)) then
            if (control_reg_en = '1') then
                req_fifo_rst <= '1';
            elsif (fifo_ack = '1') then
                req_fifo_rst <= '0';
            end if;
        end if;
    end process;

fifo_rst <= req_fifo_rst;
rst <= req_fifo_rst or fifo_ack;
tready <= not rst;
s_tready <= tready;

wr_en <= (s_tvalid and tready);
rd_en <= '1' when ((chi_rd_en = '1') or (chq_rd_en = '1')) else '0';

chi_rd_en <= s_chi_frm and chi_d_valid;
chq_rd_en <= (not s_chq_frm) and chq_d_valid;

frm_chi_data <= mem_chi(to_integer(unsigned(chi_raddr(2 downto 0)))) when (s_chi_frm = '1') else mem_chq(to_integer(unsigned(chq_raddr(2 downto 0))));
frm_chq_data <= mem_chi(to_integer(unsigned(chi_raddr(2 downto 0) + b"001"))) when (s_chq_frm = '1') else mem_chq(to_integer(unsigned(chq_raddr(2 downto 0)+ b"001")));

WRITE_POINTER : process(aclk)
    begin
        if (rst = '1') then
            waddr <= (others => '0'); 
        elsif (rising_edge(aclk)) then
            if wr_en = '1' then
              waddr <= waddr + B"001";
            end if;
        end if;
    end process;  
    
MEM_WR_DATA_PROC : process(aclk)
    begin
        if (rising_edge(aclk)) then
            if (wr_en = '1') then
                mem_chi(to_integer(unsigned(waddr(2 downto 0)))) <= s_tdata(C_DAC_DATA_WIDTH-1 downto 0);
                mem_chq(to_integer(unsigned(waddr(2 downto 0)))) <= s_tdata(2*C_DAC_DATA_WIDTH-1 downto C_DAC_DATA_WIDTH);            
            end if;
        end if;
    end process;

CHI_DATA_VAL_PROCC : process (aclk)
    begin
        if (rising_edge(aclk)) then
            if waddr > chi_raddr + 2 then
                chi_d_valid <= '1';
            elsif waddr = chi_raddr then
                chi_d_valid <= '0';
            end if;
        end if; 
    end process;
    
FRM_SIG_VAL_PROCC : process (aclk)
        begin
            if (rising_edge(aclk)) then
                if waddr > chi_raddr then
                    frm_s_valid <= '1';
                elsif waddr = chi_raddr then
                    frm_s_valid <= '0';
                end if;
            end if; 
        end process;
    
    
    
CHQ_DATA_VAL_PROCC : process (aclk)
        begin
            if (rising_edge(aclk)) then
                    if waddr > chq_raddr + 2 then
                        chq_d_valid <= '1';
                    elsif waddr = chq_raddr then
                        chq_d_valid <= '0';
                    end if;
            end if; 
        end process;

--CHI_RD_EN_PROC  : process (aclk)
--    begin
--        if (rising_edge(aclk)) then
--            if (chi_d_valid = '1') then
--                chi_rd_en <= s_chi_frm;
--            else
--                chi_rd_en <= '0';
--            end if;
--         end if;
--    end process;

--CHQ_RD_EN_PROC  : process (aclk)
--    begin
--        if (rising_edge(aclk)) then
--            if (chq_d_valid = '1') then
--                chq_rd_en <= not s_chq_frm;
--            else
--                chq_rd_en <= '0';
--            end if;
--         end if;
--    end process;    
    
    
--chi_rd_en <= s_chi_frm when chi_d_valid = '1' else '0';
--chq_rd_en <= (not s_chq_frm) when chq_d_valid = '1' else '0'; 
   
    
CHI_READ_POINTER : process(aclk)
    begin
        if (rst = '1') then
            chi_raddr <= (others => '0');
        elsif rising_edge(aclk) then
            if (chi_rd_en = '1') then
                case frame_mod is 
                    when b"00" =>
                        chi_raddr <= chi_raddr + B"001";
                    when others =>
                        chi_raddr <= chi_raddr + B"010";
                end case;
            end if;
        end if;          
    end process;
    
CHQ_READ_POINTER : process(aclk)
    begin
        if (rst = '1') then
            chq_raddr <= (others => '0');
        elsif rising_edge(aclk) then
            if (chq_rd_en = '1') then
                case frame_mod is 
                    when b"00" =>
                        chq_raddr <= chq_raddr + B"001";
                    when others =>
                        chq_raddr <= chq_raddr + B"010";
                end case;
            end if;
        end if;          
    end process;

FRAME_GEN_PROC  : process(aclk, frame_mod)
    begin
        if (rst = '1') then
            s_chq_frm <= '0';
            s_chi_frm <= '0';
        elsif (rising_edge(aclk)) then
                case frame_mod is
                    when b"00" => 
                        s_chi_frm <= '0';
                        s_chq_frm <= '0';
                    when b"01" => 
                        s_chi_frm <= byte_frame_form;
                        s_chq_frm <= byte_frame_form;
                    when b"10" => 
                        s_chi_frm <= nibble_frame_form;
                        s_chq_frm <= nibble_frame_form;
                    when others => 
                        s_chq_frm <= '0';
                        s_chi_frm <= '0'; 
                end case;
        end if;
    end process; 
  

NIBBLE_FRAME_FORM_GEN : process(aclk)
      variable nibble_fram_reg : std_logic_vector(1 downto 0):= b"00";
      begin
          if (rising_edge(aclk)) then
              if (rst = '1' or frm_s_valid = '0') then
                  nibble_fram_reg := b"00";
              else
                  nibble_fram_reg := nibble_fram_reg + 1; 
              end if;
              nibble_frame_form <= nibble_fram_reg(0) xor nibble_fram_reg(1); 
           end if;        
      end process;
      
      
BYTE_FRAME_FORM_GEN : process(aclk)
        begin        
            if rising_edge(aclk) then
                if (rst = '1' or frm_s_valid = '0') then
                    byte_frame_form <= '0';
                else
                    byte_frame_form <= not byte_frame_form;
                end if;
            end if;
        end process;
                
READ_DATA_PROC  : process (aclk, frame_mod)
    begin
         if (rising_edge(aclk)) then
                if (rd_en = '1') then
                    case frame_mod is
                    when b"00" => 
                        q_chi_data <= mem_chi(to_integer(unsigned(chi_raddr(2 downto 0))));
                        q_chq_data <= mem_chq(to_integer(unsigned(chq_raddr(2 downto 0))));
                    when others => 
                        q_chi_data <= frm_chi_data;
                        q_chq_data <= frm_chq_data;                        
                    end case;
                else
                        q_chi_data  <= (others => '0');
                        q_chq_data  <= (others => '0');
                end if;
        end if;
    end process;

OUT_GEN_PROC  : process(aclk)
    begin
       if (rising_edge(aclk)) then
            if  (s_tvalid = '1') and (chi_d_valid = '0') then
                d_chi_frm <= '1';
                d_chq_frm <= '1';
            else
                d_chi_frm <= s_chi_frm;
                d_chq_frm <= s_chq_frm;  
            end if;
        end if;
    end process;

DCI_GEN_PROC    : process(aclk)
    begin
        if rising_edge(aclk) then
            q_chi_clk<= '1';
            q_chq_clk<= '0'; 
        end if;
    end process;   
    
--delay_frame_proc : process(aclk)
--    begin
--        if rising_edge(aclk) then
--            d_chi_frm <= s_chi_frm;
--            d_chq_frm <= s_chq_frm;
--        end if;
--    end process;

dac_fmc_ddr_frm_inst : ODDR
   generic map (
       DDR_CLK_EDGE    => "SAME_EDGE",
       INIT            => '0',
       SRTYPE            => "ASYNC"
   ) 
   port map (
       Q                => w_ddr_frm,
       C                => aclk,
       CE                => '1',
       D1                => d_chi_frm,
       D2                => d_chq_frm,
       R                => rst,
       S                => '0'
   );    
    dac_ddr_clk_inst : ODDR
            generic map (
                DDR_CLK_EDGE    => "SAME_EDGE",
                INIT            => '0',
                SRTYPE            => "ASYNC"
            ) 
            port map (
                Q                => w_ddr_clk,
                C                => aclk,
                CE                => '1',
                D1                => q_chi_clk,
                D2                => q_chq_clk,
                R                => rst,
                S                => '0'
            );
            
    -- double data rate for dac frame

    -- generate double data rate for dac data
        dac_ddr_dat_gnrt : for i in 0 to C_DAC_DATA_WIDTH-1 generate 
            
        -- double data rate for dac data
            dac_fmc_ddr_dat_inst : ODDR
                generic map (
                    DDR_CLK_EDGE    => "SAME_EDGE",
                    INIT            => '0',
                    SRTYPE            => "ASYNC"
                ) 
                port map (
                    Q                => w_ddr_data(i),
                    C                => aclk,
                    CE               => '1',
                    D1               => q_chi_data(i),
                    D2               => q_chq_data(i),
                    R                => rst,
                    S                => '0'
                );
                            
        end generate dac_ddr_dat_gnrt;
             
lvds_out_buf :  for i in 0 to C_DAC_DATA_WIDTH-1 generate
        dac_buf_data_inst : OBUFDS port map (O => DATA_p(i), OB => DATA_n(i), I => w_ddr_data(i) );
    end generate lvds_out_buf;

dac_buf_dci_inst : OBUFDS  port map (O => DCI_p,  OB => DCI_n, I => w_ddr_clk  );     
dac_buf_frm_inst : OBUFDS port map ( O => FRAME_p, OB => FRAME_n, I => w_ddr_frm);
    

end Behavioral;
