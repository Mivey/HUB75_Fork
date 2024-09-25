
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

   entity top_tb is
end;

architecture bench of top_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant g_hub_mux : integer := 3;
  constant g_clock_freq : integer := 200_000_000;
  constant g_color_depth : integer := 8;
  constant g_num_row : integer := 4;
  constant g_num_col : integer := 8;
  constant g_u_row  : integer := 2;
  constant g_u_col  : integer := 3;
  constant g_addr_width  : integer := 5;
  
  -- Ports
  signal clk : std_logic;
  signal reset : bit;
  signal top_data : bit_vector(24 - 1 downto 0);
  signal top_dv_i : bit;
  signal top_u_l : bit;
  signal top_ack : bit;
  signal hub_mux_o : bit_vector(3 - 1 downto 0);
  signal hub_clk_o : bit;
  signal hub_latch_o : bit;
  signal hub_blank_o : bit;
  signal hub_g0_o : bit;
  signal hub_b0_o : bit;
  signal hub_r0_o : bit;
  signal finished : boolean := false;
begin

  top_inst : entity work.top_g_hub_mux3_g_clock_freq200000000_g_color_depth8_g_num_row4_g_num_col8_g_addr_width5_g_u_row2_g_u_col3
  -- generic map (
  --   g_hub_mux => g_hub_mux,
  --   g_clock_freq => g_clock_freq,
  --   g_color_depth => g_color_depth,
  --   g_num_row => g_num_row,
  --   g_num_col => g_num_col,
  --   g_u_row => g_u_row,
  --   g_u_col => g_u_col,
  --   g_addr_width => g_addr_width
  -- )
  port map (
    clk => clk,
    reset => reset,
    top_data => top_data,
    top_dv_i => top_dv_i,
    top_u_l => top_u_l,
    top_ack => top_ack,
    hub_mux_o => hub_mux_o,
    hub_clk_o => hub_clk_o,
    hub_latch_o => hub_latch_o,
    hub_blank_o => hub_blank_o,
    hub_g0_o => hub_g0_o,
    hub_b0_o => hub_b0_o,
    hub_r0_o => hub_r0_o
  );
-- clk <= not clk after clk_period/2;

process is
begin
  clk <= '1';
  wait for clk_period;
  clk <= '0';
  wait for clk_period;
  if finished then
    wait;
  end if;

end process;

process is
  variable temp : unsigned(3 downto 0);
begin

  reset <= '0';
  wait for clk_period * 10;
  reset <= '1';
  wait for clk_period * 2;
  top_dv_i <= '1';
  top_data <= X"AA55AA";
  wait for clk_period * 16;
  for i in 0 to 7 loop
    temp := to_unsigned(i, 4);
    if (temp(0) = '0' ) then
      wait for clk_period * 2;
      top_data <= X"55AA55";
    else
      wait for clk_period * 2;
      top_data <= X"AA55AA";
    end if;
    -- wait for clk_period * 2;
  end loop;
    wait for clk_period * 2;
  top_data <= X"dec0de";
  wait for clk_period * 2;
  top_data <= X"c0ffee";
  -- wait for clk_period * 2;
  
  for i in 0 to 7 loop
    temp := to_unsigned(i, 4);
    if (temp(0) = '0' ) then
      wait for clk_period * 2;
      top_data <= X"55AA55";
    else
      wait for clk_period * 2;
      top_data <= X"AA55AA";
    end if;
    -- wait for clk_period * 2;
  end loop;
    wait for clk_period * 2;

  top_dv_i <= '0';
  wait on top_ack for 1000 * clk_period;
  wait for clk_period * 20;

  for i in 0 to 31 loop
    -- reg_hub_f <= '0';
    wait for clk_period * 800;
    -- mem_sipo_r0 <= X"5";
    -- mem_sipo_g0 <= X"A";
    -- mem_sipo_b0 <= X"5";
    -- reg_hub_f <= '1';
    wait for 60000 * clk_period;
    -- reg_hub_f <= '0';
    wait for clk_period * 80;
    -- mem_sipo_r0 <= X"A";
    -- mem_sipo_g0 <= X"5";
    -- mem_sipo_b0 <= X"A";
    -- reg_hub_f <= '1';
    wait for 60000 * clk_period;
  end loop;


  for i in 0 to 31 loop
    wait for 2 * clk_period;
    -- addr_i <= to_unsigned(i, 4);
  end loop;
    wait for 2 * clk_period;
    wait for clk_period * 2;
    top_dv_i <= '1';
    top_data <= X"AA55AA";
    wait for clk_period * 16;
    for i in 0 to 7 loop
      temp := to_unsigned(i, 4);
      if (temp(0) = '0' ) then
        wait for clk_period * 2;
        top_data <= X"55AA55";
      else
        wait for clk_period * 2;
        top_data <= X"AA55AA";
      end if;
      -- wait for clk_period * 2;
    end loop;
      wait for clk_period * 2;
    top_data <= X"beef1e";
    wait for clk_period * 2;
    top_data <= X"b0d1e5";
    -- wait for clk_period * 2;
    
    for i in 0 to 7 loop
      temp := to_unsigned(i, 4);
      if (temp(0) = '1' ) then
        wait for clk_period * 2;
        top_data <= X"a5a5a5";
      else
        wait for clk_period * 2;
        top_data <= X"969696";
      end if;
      -- wait for clk_period * 2;
    end loop;
      wait for clk_period * 2;
  
    top_dv_i <= '0';
    wait on top_ack for 1000 * clk_period;
    wait for clk_period * 20;
  
  
    for i in 0 to 31 loop
      wait for 2 * clk_period;
      -- addr_i <= to_unsigned(i, 4);
    end loop;
      wait for 2 * clk_period;


  finished <= true;
  wait for clk_period * 2;
  wait;
  
end process;

end;