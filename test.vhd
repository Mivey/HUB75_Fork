
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CONV_PACK_top_g_hub_mux3_g_clock_freq200000000_g_color_depth8_g_num_row4_g_num_col8_g_addr_width5_g_u_row2_g_u_col3_tb is
end;

architecture bench of CONV_PACK_top_g_hub_mux3_g_clock_freq200000000_g_color_depth8_g_num_row4_g_num_col8_g_addr_width5_g_u_row2_g_u_col3_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
begin

  CONV_PACK_top_g_hub_mux3_g_clock_freq200000000_g_color_depth8_g_num_row4_g_num_col8_g_addr_width5_g_u_row2_g_u_col3_inst : entity work.CONV_PACK_top_g_hub_mux3_g_clock_freq200000000_g_color_depth8_g_num_row4_g_num_col8_g_addr_width5_g_u_row2_g_u_col3
  port map (
  );
-- clk <= not clk after clk_period/2;

end;