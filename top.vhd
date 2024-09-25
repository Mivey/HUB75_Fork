library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity top is
  generic (
    g_hub_mux     : integer := 3;
    g_clock_freq  : integer := 200_000_000;
    g_color_depth : integer := 8; 
    g_num_row     : integer := 4;
    g_num_col     : integer := 8;
    g_addr_width  : integer := 5;
    g_u_row       : integer := 2;
    g_u_col       : integer := 3
  );
  port (
    clk         : in    std_logic;
    reset       : in    bit;
    top_data    : in    std_logic_vector(24 - 1 downto 0);
    top_dv_i    : in    std_logic;
    top_u_l     : in    std_logic;
    top_ack     : out   std_logic;
    hub_mux_o   : out   unsigned(g_hub_mux - 1 downto 0);
    hub_clk_o   : out   std_logic;
    hub_latch_o : out   std_logic;
    hub_blank_o : out   std_logic;
    hub_g0_o    : out   std_logic;
    hub_b0_o    : out   std_logic;
    hub_r0_o    : out   std_logic
  );
end entity top;

architecture rtl of top is

  component hub75
    generic (
      g_hub_mux     : integer;
      g_clock_freq  : integer;
      g_color_depth : integer;
      g_num_row     : integer;
      g_num_col     : integer
    );
    port (
      clk         : in    std_logic;
      hub_mux_o   : out   unsigned(g_hub_mux - 1 downto 0);
      hub_clk_o   : out   std_logic;
      hub_latch_o : out   std_logic;
      hub_blank_o : out   std_logic;
      hub_g0_o    : out   std_logic;
      hub_b0_o    : out   std_logic;
      hub_r0_o    : out   std_logic;
      mem_sipo_r0 : in    bit_vector(g_num_col - 1 downto 0);
      mem_sipo_g0 : in    bit_vector(g_num_col - 1 downto 0);
      mem_sipo_b0 : in    bit_vector(g_num_col - 1 downto 0);
      hub_reg_f   : out   bit;
      hub_mem_f   : out   bit;
      mem_hub_f   : in    bit;
      reg_hub_f   : in    bit
    );
  end component;

  component sipo_reg
    generic (
      g_color_depth : integer;
      g_num_row     : integer;
      g_num_col     : integer;
      g_addr_width  : integer;
      g_u_row       : integer;
      g_u_col       : integer
    );
    port (
      clk         : in    std_logic;
      mem_sipo_r0 : out   bit_vector(g_num_col - 1 downto 0);
      mem_sipo_g0 : out   bit_vector(g_num_col - 1 downto 0);
      mem_sipo_b0 : out   bit_vector(g_num_col - 1 downto 0);
      mem_out_r0  : in    std_logic_vector(g_color_depth - 1 downto 0);
      mem_out_g0  : in    std_logic_vector(g_color_depth - 1 downto 0);
      mem_out_b0  : in    std_logic_vector(g_color_depth - 1 downto 0);
      addr_i      : out   unsigned(g_addr_width - 1 downto 0);
      reg_hub_f   : out   bit;
      hub_reg_f   : in    bit;
      reg_mem_f   : out   bit;
      mem_reg_f   : in    bit
    );
  end component;

  component input_mem
    generic (
      g_color_depth : integer;
      g_num_row     : integer;
      g_num_col     : integer;
      g_hub_mux     : integer;
      g_addr_width  : integer
    );
    port (
      clk        : in    std_logic;
      reset      : in    bit;
      top_data   : in    std_logic_vector(24 - 1 downto 0);
      top_dv_i   : in    std_logic;
      top_u_l    : in    std_logic;
      top_ack    : out   std_logic;
      mem_out_r0 : out   std_logic_vector(g_color_depth - 1 downto 0);
      mem_out_g0 : out   std_logic_vector(g_color_depth - 1 downto 0);
      mem_out_b0 : out   std_logic_vector(g_color_depth - 1 downto 0);
      addr_i     : in    unsigned(g_addr_width - 1 downto 0);
      mem_hub_f  : out   bit;
      hub_mem_f  : in    bit;
      reg_mem_f  : in    bit;
      mem_reg_f  : out   bit
    );
  end component;

  
  signal mem_sipo_r0 :  bit_vector(g_num_col - 1 downto 0);
  signal mem_sipo_g0 :  bit_vector(g_num_col - 1 downto 0);
  signal mem_sipo_b0 :  bit_vector(g_num_col - 1 downto 0);
  signal reg_hub_f   :  bit;
  signal hub_reg_f   :  bit;
  signal mem_out_r0  :  std_logic_vector(g_color_depth - 1 downto 0);
  signal mem_out_g0  :  std_logic_vector(g_color_depth - 1 downto 0);
  signal mem_out_b0  :  std_logic_vector(g_color_depth - 1 downto 0);
  signal addr_i      :  unsigned(g_addr_width - 1 downto 0);
  signal mem_hub_f   :  bit;
  signal hub_mem_f   :  bit;
  signal reg_mem_f   :  bit;
  signal mem_reg_f   :  bit;
  
begin

  registers: sipo_reg
    generic map (
      g_color_depth => g_color_depth,
      g_num_row     => g_num_row,
      g_num_col     => g_num_col,
      g_addr_width  => g_addr_width,
      g_u_col       => g_u_col,
      g_u_row       => g_u_row
    )
    port map (
      clk   => clk,
      mem_sipo_r0 => mem_sipo_r0,
      mem_sipo_g0 => mem_sipo_g0,
      mem_sipo_b0 => mem_sipo_b0,
      mem_out_r0  => mem_out_r0,
      mem_out_g0  => mem_out_g0,
      mem_out_b0  => mem_out_b0,
      addr_i      => addr_i,
      reg_hub_f   => reg_hub_f,
      hub_reg_f   => hub_reg_f,
      reg_mem_f   => reg_mem_f,
      mem_reg_f   => mem_reg_f
    );

  load_n_store: input_mem
    generic map (
      g_color_depth => g_color_depth,
      g_num_row     => g_num_row,
      g_num_col     => g_num_col,
      g_hub_mux     => g_hub_mux,
      g_addr_width  => g_addr_width
    )
    port map (
      clk        => clk,
      reset      => reset,
      top_data   => top_data,
      top_dv_i   => top_dv_i,
      top_u_l    => top_u_l,
      top_ack    => top_ack,
      mem_out_r0 => mem_out_r0,
      mem_out_g0 => mem_out_g0,
      mem_out_b0 => mem_out_b0,
      addr_i     => addr_i,
      mem_hub_f  => mem_hub_f,
      hub_mem_f  => hub_mem_f,
      reg_mem_f  => reg_mem_f,
      mem_reg_f  => mem_reg_f      
      );
  
  display_out: hub75
    generic map (
      g_hub_mux     => g_hub_mux,
      g_clock_freq  => g_clock_freq,
      g_color_depth => g_color_depth,
      g_num_row     => g_num_row,
      g_num_col     => g_num_col
    )
    port map (
      clk   => clk,
      hub_mux_o   =>  hub_mux_o,
      hub_clk_o   =>  hub_clk_o,
      hub_latch_o =>  hub_latch_o,
      hub_blank_o =>  hub_blank_o,
      hub_g0_o    =>  hub_g0_o,
      hub_b0_o    =>  hub_b0_o,
      hub_r0_o    =>  hub_r0_o,
      mem_sipo_r0 =>  mem_sipo_r0,
      mem_sipo_g0 =>  mem_sipo_g0,
      mem_sipo_b0 =>  mem_sipo_b0,
      hub_reg_f   =>  hub_reg_f,
      hub_mem_f   =>  hub_mem_f,
      mem_hub_f   =>  mem_hub_f,
      reg_hub_f   =>  reg_hub_f
      
    );
end architecture;