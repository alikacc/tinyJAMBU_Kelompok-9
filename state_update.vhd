library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity state_update is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;
        signal key : in STD_LOGIC_VECTOR(127 downto 0); 
        signal index : in INTEGER; 
        signal s: inout STD_LOGIC_VECTOR(127 downto 0);
        signal feedback : inout std_logic
    );
end state_update;

architecture behavior of state_update is
    type state is (init, s0, s1, s2);
    signal cState, nState: state;
    signal j: integer := 0;
    
    begin
    process( reset, clk ) 
        begin 
        if( reset = '1' ) then 
            cState <= init; 
        elsif( clk'event and clk = '1' ) then 
            cState <= nState; 
        end if; 
        end process; 
        
        process(proceed, cState)
        begin
        case cState is
        when init => 
        if (proceed = '0') then
            nState <= init;
        else
            nState <= s0;
        end if;
        
        when s0 =>
            feedback <= s (0) xor s (47) xor not (s(70) and s (85)) xor s (91) xor key(index mod 128);
            nState <= s1;
        
        when s1 =>  
            for j in 0 to 126 loop
                s(j) <= s(j+1);
            end loop;
            nState <= s2;
        
        when s2 =>
            s(127) <= feedback;
    end case;
    end process;
end behavior;
