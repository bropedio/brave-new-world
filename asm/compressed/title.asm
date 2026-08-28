incsrc macros.asm ; Handles norom and symbol map

%baseSet($7E2000) ; Set RAM offset of decompressed code at runtime

%baseOrg($7E2000) ; Ensure "org" is mapped back to norom addresses
warnpc $7E2001

