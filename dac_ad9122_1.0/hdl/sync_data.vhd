----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.09.2018 10:31:28
-- Design Name: 
-- Module Name: sync_data - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sync_data is
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
end sync_data;

architecture Behavioral of sync_data is         
    signal req_init         : std_logic:='0';
    signal req_up           : std_logic;
    signal req_up_rcv_vec   : std_logic_vector(C_NUM_SYNCHRONIZER_STAGES+1 downto 0);
    signal req_up_rcvd      : std_logic;
    signal req_delay        : std_logic:= '0';
    signal send             : std_logic;
    signal data_reg         : std_logic_vector(C_WIDTH-1 downto 0);
    signal val_up_rcv_vec   : std_logic_vector(C_NUM_SYNCHRONIZER_STAGES downto 0):= (others => '0');           

begin

--req_delay_proc  : process(from_clk)
--    begin
--        if rising_edge(from_clk) then
--            req_delay <= req;
--            send <= not req_delay and req;
--        end if;
--    end process;


req_inst_push : FDRE 
         GENERIC MAP (
                    INIT => '0'
         )
         PORT MAP ( C => from_clk, 
                    R => '0', 
                    CE => '1', 
                    D => req, 
                    Q => req_up
         );

req_up_rcv_vec(0) <= req_up;

val_up_rcv_vec(0) <= req_up_rcv_vec(C_NUM_SYNCHRONIZER_STAGES+1);

req_vec_rout : for i in 0 to C_NUM_SYNCHRONIZER_STAGES generate
trig_vec_inst   : FDRE 
         GENERIC MAP (
                    INIT => '0'
         )
         PORT MAP ( C => to_clk, 
                    R => '0', 
                    CE => '1', 
                    D => req_up_rcv_vec(i), 
                    Q => req_up_rcv_vec(i+1)
         );

end generate; 

req_up_rcvd <= req_up_rcv_vec(C_NUM_SYNCHRONIZER_STAGES) and not req_up_rcv_vec(C_NUM_SYNCHRONIZER_STAGES+1); 



val_vec_rout : for i in 0 to C_NUM_SYNCHRONIZER_STAGES-1 generate
trig1_vec_inst   : FDRE 
         GENERIC MAP (
                    INIT => '0'
         )
         PORT MAP ( C => from_clk, 
                    R => '0', 
                    CE => '1', 
                    D => val_up_rcv_vec(i), 
                    Q => val_up_rcv_vec(i+1)
         );

end generate;


ack <= val_up_rcv_vec(C_NUM_SYNCHRONIZER_STAGES);


data_out_proc  : process(to_clk)
begin
    if rising_edge(to_clk) then
        if req_up_rcvd = '1' then
        data_valid <= '1';
        data_out <= data_in;
        else 
        data_valid <= '0';
        end if;
    end if;
end process;



end Behavioral;
