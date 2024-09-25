library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity sipo_reg is
  generic (
    g_color_depth : integer := 8; 
    g_num_row     : integer := 8;
    g_u_row       : integer := 3;
    g_num_col     : integer := 8;
    g_u_col       : integer := 3;
    g_addr_width  : integer := 4
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
end entity sipo_reg;

architecture rtl of sipo_reg is

  type reg_sm is (sm_stop, sm_load, sm_done);

  signal mem_to_reg : reg_sm := sm_stop;

  signal reg_col_inc   : integer range 0 to g_num_col - 1;
  signal reg_row       : integer range 0 to g_num_row - 1;
  signal reg_cd        : integer range 0 to g_color_depth - 1;
  signal s_mem_sipo_r0 : bit_vector(g_num_col - 1 downto 0);
  signal s_mem_sipo_g0 : bit_vector(g_num_col - 1 downto 0);
  signal s_mem_sipo_b0 : bit_vector(g_num_col - 1 downto 0);
  signal s_delay       : unsigned(1 downto 0);
  

begin

  reg_loader : process (clk) is
  begin

    if rising_edge(clk) then

      case mem_to_reg is

        when sm_stop =>

          reg_hub_f <= '0';
          if (mem_reg_f = '1') then
            mem_to_reg  <= sm_load;
            reg_row     <= 0;
            reg_cd      <= 0;
            reg_col_inc <= 0;
            addr_i      <= (others => '0');
            addr_i <= to_unsigned(reg_row, g_u_row) & to_unsigned(reg_col_inc, g_u_col);
          elsif (mem_reg_f <= '0') then
            mem_to_reg <= sm_stop;
          end if;

        when sm_load =>

          if (mem_reg_f = '1') then
            for i in g_num_col - 2 downto 0 loop
              s_mem_sipo_r0(i) <= s_mem_sipo_r0(i + 1);
              s_mem_sipo_g0(i) <= s_mem_sipo_g0(i + 1);
              s_mem_sipo_b0(i) <= s_mem_sipo_b0(i + 1);
            end loop;

            s_mem_sipo_r0(g_num_col - 1) <= to_bit(mem_out_r0(reg_cd));
            s_mem_sipo_g0(g_num_col - 1) <= to_bit(mem_out_g0(reg_cd));
            s_mem_sipo_b0(g_num_col - 1) <= to_bit(mem_out_b0(reg_cd));

            addr_i <= to_unsigned(reg_row, g_u_row) & to_unsigned(reg_col_inc, g_u_col);
            if (reg_col_inc < g_num_col - 1) then
              mem_to_reg  <= sm_load;
              reg_hub_f   <= '0';
              reg_col_inc <= reg_col_inc + 1;
            elsif (reg_col_inc >= g_num_col - 1) then
              mem_to_reg  <= sm_done;
              s_delay <= "11";
              reg_hub_f   <= '0';
              reg_col_inc <= 0;
              if (reg_cd < g_color_depth - 1) then
                reg_cd <= reg_cd + 1;
              elsif (reg_cd >= g_color_depth - 1) then
                reg_cd  <= 0;
                if (reg_row < g_num_row - 1) then
                  reg_row <= reg_row + 1;
                elsif (reg_row >= g_num_row - 1) then
                  reg_row <= 0;
                end if;
              end if;
            end if;
          elsif (mem_reg_f = '0') then
            mem_to_reg  <= sm_stop;
            reg_hub_f   <= '0';
            reg_col_inc <= 0;
          end if;

        when sm_done =>

          mem_sipo_r0 <= s_mem_sipo_r0;
          mem_sipo_g0 <= s_mem_sipo_g0;
          mem_sipo_b0 <= s_mem_sipo_b0;
          if (s_delay = "00") then
            if (mem_reg_f = '1') then
              if (hub_reg_f = '0') then
                mem_to_reg <= sm_done;
                reg_hub_f  <= '1';
              elsif (hub_reg_f = '1') then
                mem_to_reg <= sm_load;
                reg_hub_f  <= '0';
              end if;
            elsif (mem_reg_f = '0') then
              mem_to_reg <= sm_stop;
              reg_hub_f  <= '0';
            end if;
          else
            s_delay <= s_delay - 1;
            reg_hub_f   <= '1';
          end if;
              

        when others =>

          null;

      end case;

    end if;

  end process reg_loader;

end architecture rtl;