library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all; 
use work.all;

entity tinyjambu_top is 
    port(
        input : inout std_logic_vector(127 downto 0);
        nonce : in std_logic_vector(95 downto 0);
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;

        tag : out std_logic_vector(63 downto 0)
    );
end tinyjambu_top;

architecture behavioral of tinyjambu_top is
	signal t_aks: STD_LOGIC_VECTOR(63 downto 0);
	signal feedback : std_logic;
	signal t: STD_LOGIC_VECTOR(63 downto 0);
	signal s: STD_LOGIC_VECTOR(127 downto 0);
	signal key : std_logic_vector(127 downto 0);
	signal framebits: std_logic_vector(2 downto 0);
	signal m: STD_LOGIC_VECTOR(63 downto 0);
	signal c: STD_LOGIC_VECTOR(63 downto 0);
	signal index : integer;
    signal ad: STD_LOGIC_VECTOR(63 downto 0);

component initialization is
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        nonce : in STD_LOGIC_VECTOR(95 downto 0); 
        feedback : inout std_logic; 
        s : inout STD_LOGIC_VECTOR(127 downto 0);
        proceed : in STD_LOGIC
    );
end component;

component process_ad is
    port(
        ad : in std_logic_vector (63 downto 0); 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;
        s: inout std_logic_vector(127 downto 0) 
        );
end component;

component encryption is
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed: in std_logic;
        s : inout STD_LOGIC_VECTOR (127 downto 0); 
        m : in STD_LOGIC_VECTOR (63 downto 0); 
        c : inout STD_LOGIC_VECTOR (63 downto 0)
        );
end component;

component finalization is
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;
        s : inout STD_LOGIC_VECTOR (127 downto 0); 
        t : out STD_LOGIC_VECTOR (63 downto 0)
    );
end component;

component decryption is
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed: in std_logic;
        s : inout STD_LOGIC_VECTOR (127 downto 0); 
        m : inout STD_LOGIC_VECTOR (63 downto 0); 
        c : out STD_LOGIC_VECTOR (63 downto 0)
    );
end component;

component verification is
    port(
		clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;
        s : inout STD_LOGIC_VECTOR (127 downto 0); 
        t : out STD_LOGIC_VECTOR (63 downto 0); 
        t_aks : out STD_LOGIC_VECTOR (63 downto 0)
    );
end component;

begin
inisialisasi: initialization 
    port map(
        clk => clk,
        reset => reset,
        proceed => proceed,
        nonce => nonce,
        s => s,
        feedback => feedback
    );

proses_ad: process_ad 
    port map(
        ad => ad,
        clk => clk,
        reset => reset,
        proceed => proceed,
        s => s
    );

enkripsi: encryption 
    port map(
        clk => clk,
        reset => reset,
        proceed => proceed,
        s => s,
        m => m, 
        c => c
    );

finalisasi: finalization 
    port map(
        clk => clk,
        reset => reset,
        proceed => proceed,
        s => s,
        t => t
    );

dekripsi: decryption 
    port map(
        clk => clk,
        reset => reset,
        proceed => proceed,
        s => s,
        m => m,
        c => c
    );


verifikasi: verification 
    port map(
        clk => clk,
        reset => reset,
        proceed => proceed, 
        s => s,
        t => t, 
        t_aks => t_aks
    );

end behavioral;

