----------------------------------------------------------------------------------------------
--      Hub75.vhd is a state machine that is used to interface with the
--      LED panels, typically found on large outdoor display instillations.
--      Ususally, each panel is anywhere from 32x32 to 64x64 pixels.
--      Each row will have one or more shift register for each color,
--      and the control lines for these shift registers are clock, latch,
--      data_{R,G,B} and blank. The rows are multiplexed (mux_{a, b, c, d, e}),
--      so only one row is on at any given time.
--
--      To make more than 8 colors from the RGB LEDs, the signals need some form of
--      PWM control. Normal PWM would be very data intensive, would offer lower color
--      deepth, and harder to implement. We can fix all of this by using a Binary
--      Coded Digit, where the MSB represents the color being on 50% of the time,
--      and the LSB would represent one time unit, t.
--
--      Definitions:
--          - N:        Number of LED's in a row
--          - M:        Number of LED's in a column
--          - L:        Number of colors in LED (mono vs RGB)
--          - B:        Number of bits in BCD coded data for each LED
--          - MUX:      Current row number
--
--      The state machine works by setting up L number of RAM blocks, one, two or
--      three, for each color LED, and storing the pixel intensity, B.
--      It then reads N number of rows at a time (say, 16) B number of times (say 8) from
--      MSB, down to the LSB. This bits are stored in a register and shifted into the HUB75
--      device, and after the time has passed, latched. This continues, at an decreased time
--      interval until the LSB is latched. Then the row is blanked, the mux set for the next
--      row, and the process is started again, reading from rows [MUX * N] to
--      [MUX * N + N - 1].
---------------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity hub75 is
  generic (
    g_hub_mux     : integer := 4;
    g_clock_freq  : integer := 200_000_000;
    g_color_depth : integer := 8;
    g_num_row     : integer := 4;
    g_num_col     : integer := 4
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
end entity hub75;

architecture rtl of hub75 is

  type hub_sm is (sm_reset, sm_clk_low, sm_clk_hi, sm_delay, sm_latch_hi);

  signal hub_out_sm : hub_sm := sm_reset;

  constant hub_clk_tick : integer := (g_clock_freq / 20_000_000) - 1;

  type tick_array is array (natural range<>) of integer;

  constant disp_tick : tick_array(g_color_depth - 1 downto 0) :=
  (
    408 * (2 ** 7) - 0,
    409 * (2 ** 6) - 0,
    409 * (2 ** 5) - 0,
    409 * (2 ** 4) - 0,
    409 * (2 ** 3) - 0,
    409 * (2 ** 2) - 0,
    409 * (2 ** 1) - 0,
    409 * (2 ** 0) - 0
  );

  signal h_row       : integer range 0 to g_num_row - 1;
  signal h_col       : integer range 0 to g_num_col - 1;
  signal disp_timer  : integer;
  signal clk_timer   : integer range 0 to 100;
  signal bcd_time    : integer range 0 to g_color_depth - 1;
  signal hub_piso_r0 : bit_vector(g_num_col - 1 downto 0);
  signal hub_piso_g0 : bit_vector(g_num_col - 1 downto 0);
  signal hub_piso_b0 : bit_vector(g_num_col - 1 downto 0);

begin
  
  hub_state_machine : process (clk) is
  begin

    if rising_edge(clk) then

      case hub_out_sm is

        -----------------------reset----------------------
        when sm_reset =>

          hub_blank_o <= '1';
          hub_latch_o <= '0';
          hub_clk_o   <= '0';
          hub_mux_o   <= (others => '1');
          bcd_time    <= 0;
          h_row       <= 0;
          h_col       <= 0;
          disp_timer  <= disp_tick(0);
          clk_timer   <= hub_clk_tick;
          hub_reg_f   <= '0';
          hub_mem_f   <= '1';
          if (mem_hub_f = '1') then
            if (reg_hub_f = '1') then -- do I need reg_comp_f?
              hub_piso_r0 <= mem_sipo_r0;
              hub_piso_g0 <= mem_sipo_g0;
              hub_piso_b0 <= mem_sipo_b0;
              hub_out_sm  <= sm_clk_low;
              hub_reg_f   <= '1';
            elsif (reg_hub_f = '0') then
              hub_reg_f  <= '0';
              hub_out_sm <= sm_reset;
            end if;
            elsif (mem_hub_f = '0') then -- need to add this modification to main
              hub_out_sm <= sm_reset;
          end if;

        ----------------------- clk low----------------------
        when sm_clk_low =>

          hub_r0_o <= to_stdulogic(hub_piso_r0(0));
          hub_g0_o <= to_stdulogic(hub_piso_g0(0));
          hub_b0_o <= to_stdulogic(hub_piso_b0(0));

          disp_timer <= disp_timer - 1;
          clk_timer  <= clk_timer - 1;
          if (clk_timer <= (hub_clk_tick / 2)) then
            hub_out_sm <= sm_clk_hi;
            hub_clk_o  <= '1';
          elsif (clk_timer > (hub_clk_tick / 2)) then
            hub_out_sm <= sm_clk_low;
            hub_reg_f  <= '0';
            hub_clk_o  <= '0';
          end if;

        ----------------------- clk high----------------------
        when sm_clk_hi =>

          if (clk_timer = 0) then
            clk_timer  <= hub_clk_tick;                     -- reset timer
            disp_timer <= disp_timer - 1;
            hub_clk_o  <= '0';
            if (h_col < g_num_col - 1) then
              hub_out_sm <= sm_clk_low;                 -- go back and send next bit
              h_col      <= h_col + 1;

              for i in 0 to g_num_col - 2 loop

                hub_piso_r0(i) <= hub_piso_r0(i + 1);
                hub_piso_g0(i) <= hub_piso_g0(i + 1);
                hub_piso_b0(i) <= hub_piso_b0(i + 1);

              end loop;

            else                                      -- just sent the MSB, so now wait
              hub_out_sm <= sm_delay;
            -- report: how much time is left for hub_timer
            end if;
          elsif (clk_timer > 0) then
            disp_timer <= disp_timer - 1;
            clk_timer  <= clk_timer - 1;
            hub_out_sm <= sm_clk_hi;
            hub_clk_o  <= '1';
          end if;

        ----------------------- timer delay----------------------
        when sm_delay =>

          hub_clk_o <= '0';
          if (disp_timer > 0) then
            disp_timer <= disp_timer - 1;
            hub_out_sm <= sm_delay;
          elsif (disp_timer = 0) then
            if (bcd_time = 0) then
              bcd_time <= g_color_depth - 1;
              disp_timer <= disp_tick(g_color_depth - 1);
            else 
              bcd_time <= bcd_time - 1;
              disp_timer <= disp_tick(bcd_time - 1);
            end if;
            clk_timer   <= 20;
            hub_latch_o <= '1';
            hub_out_sm  <= sm_latch_hi;
            if (bcd_time = g_color_depth - 1) then
              if (h_row = g_num_row - 1) then
                h_row <= 0;
              else
                h_row <= h_row + 1;
              end if;
              hub_blank_o <= '1';
              hub_mux_o   <= to_unsigned (h_row, hub_mux_o'length);
            end if;
          end if;

        ----------------------- latch high----------------------
        when sm_latch_hi =>

          disp_timer <= disp_timer - 1;
          if (clk_timer > 0) then
            clk_timer   <= clk_timer - 1;
            hub_out_sm  <= sm_latch_hi;
            hub_latch_o <= '1';
          elsif (clk_timer = 0) then
            if (mem_hub_f = '0') then
              hub_out_sm <= sm_reset;
            elsif (reg_hub_f = '0') then
              hub_out_sm <= sm_latch_hi;
            else
              hub_out_sm <= sm_clk_low;
              h_col <= 0;
              hub_reg_f <= '1';
              clk_timer   <= hub_clk_tick;
              hub_piso_r0 <= mem_sipo_r0;
              hub_piso_g0 <= mem_sipo_g0;
              hub_piso_b0 <= mem_sipo_b0;
            end if;
            hub_latch_o <= '0';
            hub_blank_o <= '0';
          end if;

        when others =>

          null;

      end case;

    end if;

  end process hub_state_machine;

end architecture rtl;