library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity input_mem is
  generic (
    g_color_depth : integer := 8;
    g_num_row     : integer := 8;
    g_num_col     : integer := 8;
    g_hub_mux     : integer := 3;
    g_addr_width  : integer := 6
  );
  port (
    clk         : in    std_logic;
    reset       : in    bit;
    top_data    : in    std_logic_vector(24 - 1 downto 0);
    top_dv_i    : in    std_logic;
    top_u_l     : in    std_logic;
    top_ack     : out   std_logic;
    mem_out_r0  : out   std_logic_vector(g_color_depth - 1 downto 0);
    mem_out_g0  : out   std_logic_vector(g_color_depth - 1 downto 0);
    mem_out_b0  : out   std_logic_vector(g_color_depth - 1 downto 0);
    addr_i      : in    unsigned(g_addr_width - 1 downto 0);
    mem_hub_f   : out   bit;
    hub_mem_f   : in    bit;
    reg_mem_f   : in    bit;
    mem_reg_f   : out   bit
  );
end entity input_mem;

architecture rtl of input_mem is

  component bram_xfer
    generic (
      g_addr_width : integer;
      g_color_depth : integer
    );
    port (
      clk : in std_logic;
      en : in std_logic;
      we_i : in std_logic;
      addr_i : in unsigned(g_addr_width - 1 downto 0);
      data_in_i : in std_logic_vector(g_color_depth - 1 downto 0);
      data_out_o : out std_logic_vector(g_color_depth - 1 downto 0)
    );
  end component;

  type mem_sm is (sm_load, sm_complete, sm_read);

  signal simple_mem_sm : mem_sm := sm_complete;
  type temp_mem is array (0 to 2) of std_logic_vector(g_color_depth - 1 downto 0);

  signal lazy_out : temp_mem;
  signal lazy_in : temp_mem;
  
  signal mem_timer   : integer range 0 to 20;
  signal we_i : std_logic;
  signal s_addr : unsigned(g_addr_width - 1 downto 0);
  signal mem_full : bit;
  constant c_max_mem : unsigned(g_addr_width - 1 downto 0) := (others => '1');

  begin

  RGB_Array : for i in lazy_out'range generate
    RGB_Array: bram_xfer
      generic map (
        g_addr_width => g_addr_width,
        g_color_depth => g_color_depth 
      )
      port map (
        clk   => clk,
        en => '1',
        we_i => we_i,
        addr_i => s_addr,
        data_in_i => lazy_in(i),
        data_out_o => lazy_out(i)
      );
  end generate;

  mem_loader : process (clk) is
  begin

---- this process needs to see that both reg and hub are in a state of reset before it releases its own reset.
    if rising_edge(clk) then

      if (reset = '0') then
        simple_mem_sm <= sm_complete;
        mem_reg_f     <= '0';
        mem_hub_f     <= '0';
        we_i          <= '0';
      elsif (reset = '1') then

        case simple_mem_sm is

          when sm_load =>

            if (top_dv_i = '0' or (mem_full = '1')) then
              top_ack       <= '1';
              simple_mem_sm <= sm_complete;
              we_i <= '0';
              mem_timer <= 0;
            else
              -- we_i <= '1';
              lazy_in(2) <= top_data(3 * g_color_depth - 1 downto 2 * g_color_depth);
              lazy_in(1) <= top_data(2 * g_color_depth - 1 downto 1 * g_color_depth);
              lazy_in(0) <= top_data(1 * g_color_depth - 1 downto 0 * g_color_depth);
              if (s_addr = c_max_mem) then
                mem_full <= '1';
                s_addr <= (others => '0');
              else
                -- mem_full <= '0';
                s_addr <= s_addr + 1;
              end if;
              -- s_addr <= s_addr + 1;
              simple_mem_sm <= sm_load;
            end if;

          when sm_complete =>

          if (reset = '0') then
            mem_hub_f <= '0';
            mem_hub_f <= '0';
            mem_full <= '0';
          elsif (reset = '1') then
            if (top_dv_i = '1') then
              if (mem_full = '1') then
                simple_mem_sm <= sm_complete;
              elsif (mem_full = '0') then
                if (mem_timer < 7) then
                  simple_mem_sm <= sm_complete;
                  mem_timer <= mem_timer + 1;
                elsif (mem_timer >= 7) then
                  simple_mem_sm <= sm_load;
                  mem_full <= '0';
                  s_addr <= (others => '0');
                  mem_timer <= 0;
                  top_ack <= '0';
                  mem_hub_f <= '0';
                  mem_reg_f <= '0';
                  we_i <= '1';
                end if;
              end if;
            elsif (top_dv_i = '0') then
              mem_timer <= 0;
              mem_hub_f <= '1';
              mem_reg_f <= '1';
              simple_mem_sm <= sm_read;
              s_addr <= addr_i;
              we_i <= '0';
            end if;
          end if; 

          when sm_read =>

            --do thing
            if (top_dv_i = '0') then
              s_addr <= addr_i;
              mem_out_r0 <= lazy_out(2);
              mem_out_g0 <= lazy_out(1);
              mem_out_b0 <= lazy_out(0);
              mem_hub_f <= '1';
              mem_reg_f <= '1';
            elsif (top_dv_i = '1') then
              simple_mem_sm <= sm_complete;
              mem_hub_f <= '0';
              mem_reg_f <= '0';
              mem_full <= '0';
            end if;
          when others =>

            null;

        end case;

      end if;
    end if;

  end process mem_loader;

end architecture rtl;