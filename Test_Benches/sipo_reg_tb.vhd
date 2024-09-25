library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity sipo_reg_tb is
end;

architecture bench of sipo_reg_tb is
  -- Clock period
  constant clk_period : time := 1 ns;
  -- Generics
  constant g_color_depth : integer := 8;
  constant g_num_row : integer := 8;
  constant g_num_col : integer := 8;
  -- Ports
  signal clk : std_logic := '0';
  signal mem_sipo_r0 : bit_vector(g_color_depth - 1 downto 0);
  signal mem_sipo_g0 : bit_vector(g_color_depth - 1 downto 0);
  signal mem_sipo_b0 : bit_vector(g_color_depth - 1 downto 0);
  signal mem_sipo_r1 : bit_vector(g_color_depth - 1 downto 0);
  signal mem_sipo_g1 : bit_vector(g_color_depth - 1 downto 0);
  signal mem_sipo_b1 : bit_vector(g_color_depth - 1 downto 0);
  signal mem_out_r0 : std_logic_vector(g_color_depth - 1 downto 0) := X"00";
  signal mem_out_g0 : std_logic_vector(g_color_depth - 1 downto 0) := X"55";
  signal mem_out_b0 : std_logic_vector(g_color_depth - 1 downto 0) := X"55";
  signal mem_out_r1 : std_logic_vector(g_color_depth - 1 downto 0) := X"55";
  signal mem_out_g1 : std_logic_vector(g_color_depth - 1 downto 0) := X"55";
  signal mem_out_b1 : std_logic_vector(g_color_depth - 1 downto 0) := X"55";
  signal addr_i : unsigned(6 - 1 downto 0);
  signal reg_hub_f : bit;
  signal hub_reg_f : bit := '0';
  signal reg_mem_f : bit;
  signal mem_reg_f : bit := '0';
  signal finished : boolean := false;
begin

  sipo_reg_inst : entity work.sipo_reg
  generic map (
    g_color_depth => g_color_depth,
    g_num_row => g_num_row,
    g_num_col => g_num_col
  )
  port map (
    clk => clk,
    mem_sipo_r0 => mem_sipo_r0,
    mem_sipo_g0 => mem_sipo_g0,
    mem_sipo_b0 => mem_sipo_b0,
    mem_sipo_r1 => mem_sipo_r1,
    mem_sipo_g1 => mem_sipo_g1,
    mem_sipo_b1 => mem_sipo_b1,
    mem_out_r0 => mem_out_r0,
    mem_out_g0 => mem_out_g0,
    mem_out_b0 => mem_out_b0,
    mem_out_r1 => mem_out_r1,
    mem_out_g1 => mem_out_g1,
    mem_out_b1 => mem_out_b1,
    addr_i => addr_i,
    reg_hub_f => reg_hub_f,
    hub_reg_f => hub_reg_f,
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
begin

  mem_reg_f <= '1';
  wait for 4 * clk_period;
  
    for a in 0 to 20 loop
      for b in 0 to 1 loop

      end loop;
        wait for 50 * clk_period;
      wait for clk_period * 2;
      mem_out_b0 <= X"0a";
      hub_reg_f <= '1';
      wait on addr_i for 4 * clk_period;
      hub_reg_f <= '0';
 
      mem_out_b0 <= X"ad";
      wait on addr_i for 4 * clk_period;
      mem_out_b0 <= X"2f";
      wait on addr_i for 4 * clk_period;
      mem_out_b0 <= X"af";
      wait on addr_i for 4 * clk_period;
      mem_out_b0 <= X"a5";
      wait on addr_i for 4 * clk_period;
      mem_out_b0 <= X"0e";
      wait on addr_i for 4 * clk_period;
      mem_out_b0 <= X"79";
      wait on addr_i for 4 * clk_period;
      mem_out_b0 <= X"7f";

      wait for 10 * clk_period;

    end loop;
  finished <= true;
  wait;
end process;
end;