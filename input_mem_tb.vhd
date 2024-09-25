
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_mem_tb is
end;

architecture bench of input_mem_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant g_color_depth : integer := 8;
  constant g_num_row : integer := 4;
  constant g_num_col : integer := 4;
  constant g_hub_mux : integer := 4;
  -- Ports
  signal clk : std_logic := '0';
  signal reset : bit := '0';
  signal top_data : std_logic_vector(24 - 1 downto 0) := (others => '0') ;
  signal top_dv_i : std_logic := '0';
  signal top_u_l : std_logic := '0';
  signal top_ack : std_logic;
  signal mem_out_r0 : std_logic_vector(g_color_depth - 1 downto 0);
  signal mem_out_g0 : std_logic_vector(g_color_depth - 1 downto 0);
  signal mem_out_b0 : std_logic_vector(g_color_depth - 1 downto 0);
  signal addr_i : unsigned(4 - 1 downto 0);
  signal mem_hub_f : bit;
  signal hub_mem_f : bit := '0';
  signal reg_mem_f : bit := '0';
  signal mem_reg_f : bit;
  signal finished : boolean := false;
begin

  input_mem_inst : entity work.input_mem
  generic map (
    g_color_depth => g_color_depth,
    g_num_row => g_num_row,
    g_num_col => g_num_col,
    g_hub_mux => g_hub_mux
  )
  port map (
    clk => clk,
    reset => reset,
    top_data => top_data,
    top_dv_i => top_dv_i,
    top_u_l => top_u_l,
    top_ack => top_ack,
    mem_out_r0 => mem_out_r0,
    mem_out_g0 => mem_out_g0,
    mem_out_b0 => mem_out_b0,
    addr_i => addr_i,
    mem_hub_f => mem_hub_f,
    hub_mem_f => hub_mem_f,
    reg_mem_f => reg_mem_f,
    mem_reg_f => mem_reg_f
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
    wait for 2 * clk_period;
    addr_i <= to_unsigned(i, 4);
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
      wait for 2 * clk_period;
      addr_i <= to_unsigned(i, 4);
    end loop;
      wait for 2 * clk_period;


  finished <= true;
  wait for clk_period * 2;
  wait;
  
end process;


end;