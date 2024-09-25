library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity bram_xfer is
  generic (
    g_addr_width : integer := 8;
    g_color_depth : integer := 8
  );
  port (
    clk        : in    std_logic;
    en         : in    std_logic;
    we_i       : in    std_logic;
    addr_i     : in    unsigned(g_addr_width - 1 downto 0);
    data_in_i  : in    std_logic_vector(g_color_depth - 1 downto 0);
    data_out_o : out   std_logic_vector(g_color_depth - 1 downto 0)
  );
end entity bram_xfer;

architecture rtl of bram_xfer is

  type t_ram is array(2 ** g_addr_width - 1 downto 0) of std_logic_vector(g_color_depth - 1 downto 0);

  signal block_ram_r : t_ram;

begin

  ram_operation : process (clk) is
  begin

    if rising_edge(clk) then
      if (en = '1') then
        if (we_i = '1') then
          block_ram_r (to_integer(addr_i)) <= data_in_i;
          data_out_o <= data_in_i;
        else
          data_out_o <= block_ram_r(to_integer(addr_i));
        end if;
      end if;
    end if;

  end process ram_operation;

end architecture rtl;