
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hub75_tb is
end;

architecture bench of hub75_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant g_hub_mux : integer := 4;
  constant g_clock_freq : integer := 200_000_000;
  constant g_color_depth : integer := 8;
  constant g_num_row : integer := 4;
  constant g_num_col : integer := 4;
  -- Ports
  signal clk : std_logic := '0';
  signal hub_mux_o : unsigned(g_hub_mux - 1 downto 0);
  signal hub_clk_o : std_logic;
  signal hub_latch_o : std_logic;
  signal hub_blank_o : std_logic;
  signal hub_g0_o : std_logic;
  signal hub_b0_o : std_logic;
  signal hub_r0_o : std_logic;
  signal mem_sipo_r0 : bit_vector(g_num_col - 1 downto 0) := (others => '0') ;
  signal mem_sipo_g0 : bit_vector(g_num_col - 1 downto 0) := (others => '0') ;
  signal mem_sipo_b0 : bit_vector(g_num_col - 1 downto 0) := (others => '0') ;
  signal hub_reg_f : bit;
  signal hub_mem_f : bit;
  signal mem_hub_f : bit:= '0';
  signal reg_hub_f : bit:= '0';
  signal finished : boolean := false;
begin

  hub75_inst : entity work.hub75
  generic map (
    g_hub_mux => g_hub_mux,
    g_clock_freq => g_clock_freq,
    g_color_depth => g_color_depth,
    g_num_row => g_num_row,
    g_num_col => g_num_col
  )
  port map (
    clk => clk,
    hub_mux_o => hub_mux_o,
    hub_clk_o => hub_clk_o,
    hub_latch_o => hub_latch_o,
    hub_blank_o => hub_blank_o,
    hub_g0_o => hub_g0_o,
    hub_b0_o => hub_b0_o,
    hub_r0_o => hub_r0_o,
    mem_sipo_r0 => mem_sipo_r0,
    mem_sipo_g0 => mem_sipo_g0,
    mem_sipo_b0 => mem_sipo_b0,
    hub_reg_f => hub_reg_f,
    hub_mem_f => hub_mem_f,
    mem_hub_f => mem_hub_f,
    reg_hub_f => reg_hub_f
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
    reg_hub_f <= '0';
    mem_hub_f <= '0';
    wait for clk_period * 4;
    mem_sipo_r0 <= X"A";
    mem_sipo_g0 <= X"5";
    mem_sipo_b0 <= X"A";
    wait for clk_period * 2;
    reg_hub_f <= '1';
    wait for clk_period * 4;
    reg_hub_f <= '0';
    wait for clk_period * 2;
    mem_hub_f <= '1';
    wait for clk_period * 4;
    reg_hub_f <= '1';
    wait on hub_reg_f for clk_period * 4;
    
    for i in 0 to 31 loop
      reg_hub_f <= '0';
      wait for clk_period * 800;
      mem_sipo_r0 <= X"5";
      mem_sipo_g0 <= X"A";
      mem_sipo_b0 <= X"5";
      reg_hub_f <= '1';
      wait on hub_reg_f for 60000 * clk_period;
      reg_hub_f <= '0';
      wait for clk_period * 80;
      mem_sipo_r0 <= X"A";
      mem_sipo_g0 <= X"5";
      mem_sipo_b0 <= X"A";
      reg_hub_f <= '1';
      wait on hub_reg_f for 60000 * clk_period;

    end loop;


      -- wait for clk_period * 10;
      finished <= true;
      wait;


  end process;

end;