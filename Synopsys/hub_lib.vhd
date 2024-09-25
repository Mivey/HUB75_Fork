library IEEE;

use IEEE.std_logic_1164.all;
-- use ieee.numeric_std.all;

package 
   CONV_PACK 
   is

-- define attributes
attribute ENUM_ENCODING : STRING;

-- define any necessary types
type UNSIGNED is array (INTEGER range <>) of std_logic;
   
   -- Declarations for conversion functions.
   function BIT_to_std_logic(arg : in BIT) return std_logic;

end 
   CONV_PACK;

package body 
   CONV_PACK 
   is
   
   -- enum type to std_logic function
   function BIT_to_std_logic(arg : in BIT) return std_logic is
   -- synopsys built_in SYN_FEED_THRU;
   begin
      case arg is
         when '0' => return '0';
         when '1' => return '1';
         when others => assert FALSE -- this should not happen.
               report "un-convertible value"
               severity warning;
               return '0';
      end case;
   end;

end 
   CONV_PACK;
