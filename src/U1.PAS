unit u1;

{==========================================================================}
interface
uses dos,crt;
type
  rgb = record r, g, b : byte; end;
  paltype = array[0..255]of rgb;
  ScreenType = array [0..3999] of Byte;
var
  i : integer;
  pal : paltype;
  X, Y : WORD;
  reg  : REGISTERS;
  ScreenMem : Array [0..24, 0..79, 0..1] of Char Absolute $B800 : 0;
  Screen : ScreenType absolute $B800:0000;


Const
  PageOffs : Array [0..3] of Word = ($0000, $0FA0, $1F40, $2EE0);

{--------------------------------------------------------------------------}
Function IntToStr(I: Longint): String; {zmienia integer na string}
Procedure CursorOff;              {wylacza kursor}
Procedure CursorOn;               {wlacza kursor}
Function  IsKeyPressed: BOOLEAN;   {zwraca, czy nacisniety klawisz}
Procedure waitretrace; {wait for next vertical retrace}
Procedure get_color(var pal : paltype); {save palette}
Procedure set_intensity(intensity : byte); {wewnetrzne}
Procedure set_to_color(r,g,b,h: integer);  {  - // -  }
Procedure fade_out(t : integer); {fades from pal to black}
Procedure fade_in(t : integer);  {fades from black to pal}
Function  InitMouse : WORD;      {wewnetrze}
Procedure ShowMouseCursor;       {pokazuje kursor myszy}
Procedure HideMouseCursor;       {ukrywa kursor myszy}
Procedure SetMouseWindow (X1, Y1, X2, Y2 : WORD);   {ustawia okno myszy}
Procedure GetMousePos_Key (VAR X, Y, button : WORD);{zwraca wsp i klawisze}
Procedure GetMousePosition (VAR X, Y: WORD);        {jw, ale bez klawiszy}
Procedure SetMousePos (X, Y : WORD);                {ustawia wsp. myszy}
Function  MousePRESSED : BOOLEAN;                   {zwraca stan klawiszy}
Function  MouseORKeyPRESSED : BOOLEAN;              {  -  /  /  -  i klawiatury}
Procedure wylaz;                                    {wychodzi i resetuje ekran}
Function  Mysz_w_zakresie(xcur,ycur,xmin,ymin,xmax,ymax:word):boolean;
                         {sprawdza, czy (xcur,ycur) sie miesci w zakresie}
Function  Win3X :BOOLEAN;            {zwraca, czy "idzie" spod winowsa}
Function  IsVGA : Boolean;           {zwraca, czy jest VGA}
Procedure PlFonts;                  {ustawia polskie krzaki w Mazovii}
Procedure clearbuffer;              {czysci bufor klawiatury}
Procedure changeColor(x, y, attrib : Byte); {zmienia kolor pod (x,y)}
Function  HiN(B : Byte) : Byte;     {zwraca starszy nibble}
Function  LoN(B : Byte) : Byte;     {zwraca mlodszy nibble}
Procedure zmienianiekolorow(zjakiego,najaki,xmin,xmax,ymin,ymax:byte);
Procedure PrzesunStrone(zrodlo,cel:byte);
Procedure Obraz (var Addr1,Addr2; BlkLen:Integer);
{--------------------------------------------------------------------------}
CONST
  F1  = 59;   CtrlF1  =  94;   AltF1  = 104;   Homekey   = 71;
  F2  = 60;   CtrlF2  =  95;   AltF2  = 105;   Endkey    = 79;
  F3  = 61;   CtrlF3  =  96;   AltF3  = 106;   PgUp      = 73;
  F4  = 62;   CtrlF4  =  97;   AltF4  = 107;   PgDn      = 81;
  F5  = 63;   CtrlF5  =  98;   AltF5  = 108;   UpArrow   = 72;
  F6  = 64;   CtrlF6  =  99;   AltF6  = 109;   RtArrow   = 77;
  F7  = 65;   CtrlF7  = 100;   AltF7  = 110;   DnArrow   = 80;
  F8  = 66;   CtrlF8  = 101;   AltF8  = 111;   LfArrow   = 75;
  F9  = 67;   CtrlF9  = 102;   AltF9  = 112;   InsertKey = 82;
  F10 = 68;   CtrlF10 = 103;   AltF10 = 113;   DeleteKey = 83;

  AltQ = 16;   AltA = 30;   AltZ = 44;   Alt1 = 120;  ShftF1 = 84;
  AltW = 17;   AltS = 31;   AltX = 45;   Alt2 = 121;  ShftF2 = 85;
  AltE = 18;   AltD = 32;   AltC = 46;   Alt3 = 122;  ShftF3 = 86;
  AltR = 19;   AltF = 33;   AltV = 47;   Alt4 = 123;  ShftF4 = 87;
  AltT = 20;   AltG = 34;   AltB = 48;   Alt5 = 124;  ShftF5 = 88;
  AltY = 21;   AltH = 35;   AltN = 49;   Alt6 = 125;  ShftF6 = 89;
  AltU = 22;   AltJ = 36;   AltM = 50;   Alt7 = 126;  ShftF7 = 90;
  AltI = 23;   AltK = 37;                Alt8 = 127;  ShftF8 = 91;
  AltO = 24;   AltL = 38;                Alt9 = 128;  ShftF9 = 92;
  AltP = 25;   CtrlLf = 115;             Alt0 = 129;  ShftF10= 93;
               CtrlRt = 116;

  CtrlA  = #1;  CtrlK = #11; CtrlU = #21; CtrlB = #2;  CtrlL = #12;
  CtrlV  = #22; CtrlC = #3;  CtrlM = #13; CtrlW = #23; CtrlD = #4;
  CtrlN  = #14; CtrlX = #24; CtrlE = #5;  CtrlO = #15; CtrlY = #25;
  CtrlF  = #6;  CtrlP = #16; CtrlZ = #26; CtrlG = #7;  CtrlQ = #17;
  CtrlS  = #19; CtrlH = #8;  CtrlR = #18; CtrlI = #9;  CtrlJ = #10;
  CtrlT = #20;  BSpace = #8; EscapeKey = #27; EnterKey = #13; NullKey = #0;


  MIO    = $33;  (* Mouse Services       *)
  KBIO   = $16;  (* BIOS Keyboard        *)
  MouseInstalled : Boolean = FALSE;

{==========================================================================}

implementation
{--------------------------------------------------------------------------}
Function IntToStr(I: Longint): String;                  {podfunkcja}
{ Convert any integer type to a string }                {zwracajaca integer}
var                                                     {jako string}
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

{--------------------------------------------------------------------------}
Function MousePressed : BOOLEAN;
VAR B : WORD;
  BEGIN
  Asm
    MOV AX, $0003
    INT $33
    MOV B,  BX
  END;
  MousePressed := (B <> 0);
  if not mouseinstalled then MousePressed:=false;
  END;

{--------------------------------------------------------------------------}
Function MouseORKeyPressed : BOOLEAN;
VAR B : WORD;
  BEGIN
   MouseORKeyPressed := MousePressed OR KeyPressed;
  END;

{--------------------------------------------------------------------------}
Function InitMouse : WORD;
BEGIN
  Asm
    MOV AX, $0000
    INT MIO
    MOV @Result, AX
  END;
END;

{--------------------------------------------------------------------------}
Procedure ShowMouseCursor; Assembler;
Asm
  MOV AX, $0001
  INT MIO
END;

{--------------------------------------------------------------------------}
Procedure HideMouseCursor; Assembler;
Asm
  MOV AX, $0002
  INT MIO
END;

{--------------------------------------------------------------------------}
Procedure GetMousePos_Key (VAR X, Y, Button : WORD);
VAR X1, Y1, b : WORD;
BEGIN
  Asm
    MOV AX, $0003
    INT MIO
    MOV b,  BX
    MOV X1, CX
    MOV Y1, DX
  END;
  X := X1;
  Y := Y1;
  Button := b;
END;

{--------------------------------------------------------------------------}
Procedure GetMousePosition (VAR X, Y: WORD);
VAR X1, Y1 : WORD;
BEGIN
  Asm
    MOV AX, $0003
    INT MIO

    MOV X1, CX
    MOV Y1, DX
  END;
  X := X1;
  Y := Y1;

END;

{--------------------------------------------------------------------------}
Procedure SetMousePos (X, Y : WORD); Assembler;
Asm
  MOV AX, $0004
  MOV CX, X
  MOV DX, Y
  INT MIO
END;

{--------------------------------------------------------------------------}
Procedure SetMouseWindow (X1, Y1, X2, Y2 : WORD);
BEGIN
  reg. AX := $0007;
  reg. CX := X1;
  reg. DX := X2;
  INTR ($33, reg);
  INC (reg. AX, 1);
  reg. CX := Y1;
  reg. DX := Y2;
  INTR (MIO, reg)
END;

{--------------------------------------------------------------------------}
Function IsKeyPressed: BOOLEAN;
BEGIN
     IsKeyPressed := ((MEM[$40:$17] AND $0F) > 0) OR (MEM[$40:$18] > 0)
                     OR KEYPRESSED;
END;

{--------------------------------------------------------------------------}
Procedure CursorOff; Assembler;
Asm
{    push bp            { For old BIOSs }
    xor  ax, ax
    mov  es, ax
    mov  bh, Byte ptr es:[462h]  { get active page }
    mov  ah, 3
    int  10h           { get cursor Characteristics }
    or   ch, 00100000b
    mov  ah, 1
    int  10h           { set cursor Characteristics }
 {   pop  bp            { restore bp For old BIOSs }
end;

{--------------------------------------------------------------------------}
Procedure CursorOn; Assembler;
Asm
  {  push bp            { old BIOSs like this... }
    xor  ax, ax
    mov  es, ax
    mov  bh, Byte ptr es:[462h]  { get active page }
    mov  ah, 3
    int  10h           { get cursor Characteristics }
    and  ch, 00011111b
    mov  ah, 1
    int  10h           { set cursor Characteristics }
   { pop  bp            { ...and this, too }
end;

{--------------------------------------------------------------------------}
Procedure waitretrace;assembler; {wait for next vertical retrace}
asm
  mov dx,$3DA
  @V1: in al,dx; test al,8; jz @v1;
  @V2: in al,dx; test al,8; jnz @v2;
end;

{--------------------------------------------------------------------------}
Procedure get_color(var pal : paltype); {save palette}
var
  i : integer;
begin
  port[$3C7] := $00;
  for i:= 0 to 255 do begin
    pal[i].r := port[$3C9];
    pal[i].g := port[$3C9];
    pal[i].b := port[$3C9];
  end;
end;

{--------------------------------------------------------------------------}
Procedure set_intensity(intensity : byte);
var
  i : integer;
begin
  port[$3C8] := $00;
  for i := 0 to 255 do begin
    port[$3C9] := pal[i].r*intensity div 63;
    port[$3C9] := pal[i].g*intensity div 63;
    port[$3C9] := pal[i].b*intensity div 63;
  end;
end;

{--------------------------------------------------------------------------}
Procedure set_to_color(r,g,b,h: integer);
var
  i : integer;
begin
  port[$3C8] := $00;
  for i := 0 to 255 do begin
    port[$3C9] := pal[i].r+(r-pal[i].r)*h div 63;
    port[$3C9] := pal[i].g+(g-pal[i].g)*h div 63;
    port[$3C9] := pal[i].b+(b-pal[i].b)*h div 63;
  end;
end;

{--------------------------------------------------------------------------}
Procedure fade_out(t : integer); {fades from pal to black}
begin
  for i := 63 downto 0 do begin waitretrace; set_intensity(i); delay(t); end;
end;

{--------------------------------------------------------------------------}
Procedure fade_in(t : integer);  {fades from black to pal}
begin
  for i := 0 to 63 do begin waitretrace; set_intensity(i); delay(t); end;
end;

{--------------------------------------------------------------------------}
Procedure wylaz;
begin
get_color(pal);fade_out(0);cursoron; clrscr; textmode(co80); halt;
end;

{--------------------------------------------------------------------------}
Function Mysz_w_zakresie(xcur,ycur,xmin,ymin,xmax,ymax:word):boolean;
begin
     if (xcur >= xmin) and
        (xcur <  xmax) and
        (ycur >= ymin) and
        (ycur <  ymax) then
          Mysz_w_zakresie:=true else
          Mysz_w_zakresie:=false;
end;

{--------------------------------------------------------------------------}
Function Win3X :BOOLEAN;  ASSEMBLER;
                {  Routine to determine if Windows is currently running }
ASM
  Mov AX,$4680                          {  Win 3.x Standard check       }
  Int $2F                               {  Call Int 2F                  }
  Cmp AX,0                              {  IF AX = 0 Win in real mode   }
  JNE @EnhancedCheck                    {  If not check for enhanced mode}
  Mov AL,1                              {  Set Result to true           }
  Jmp @Exit                             {  Go to end of routine         }
@EnhancedCheck:                         {  Else check for enhanced mode }
  Mov AX,$1600                          {  Win 3.x Enhanced check       }
  Int $2F                               {  Call Int 2F                  }
  Cmp AL,0                              {  Check returned value         }
  Je @False                             {  If not one of the below it   }
  Cmp AL,$80                            {  is NOT installed             }
  Je @False
  Mov AL,1                              {  Nope it must BE INSTALLED    }
  Jmp @Exit
@False:
  Mov AL,0                              {  Set Result to False          }
@Exit:
END;{Win3X}

{--------------------------------------------------------------------------}
  Function IsVGA : Boolean; Assembler;
  ASM
    MOV AH, 12h
    MOV AL, 00h
    MOV BL, 36h
    INT 10h
    MOV AH, 0
    CMP AL, 12h
    JNZ @Nope
    INC AH
    @Nope:
  END;

{--------------------------------------------------------------------------}
Procedure PlFonts;
      const plfnt:array[1..18,0..16] of byte=
      ((143,0,0,16,56,108,198,198,254,198,198,198,198,4,8,0,0),
      (149,4,8,60,102,194,192,192,192,192,194,102,60,0,0,0,0),
      (144,0,0,254,102,98,104,120,104,96,98,102,254,2,4,0,0),
      (156,0,0,240,96,96,100,104,112,96,98,102,254,0,0,0,0),
      (165,8,16,230,230,246,254,222,206,198,198,198,198,0,0,0,0),
      (163,0,2,124,206,214,198,198,198,198,198,198,124,0,0,0,0),
      (152,2,4,124,198,198,96,56,12,6,198,198,124,0,0,0,0),
      (161,0,0,254,198,134,12,126,48,96,194,198,254,0,0,0,0),
      (160,8,16,254,198,134,12,24,48,96,194,198,254,0,0,0,0),
      (134,0,0,0,0,0,120,12,124,204,204,204,118,4,2,0,0),
      (141,0,0,0,4,8,124,198,192,192,192,198,124,0,0,0,0),
      (145,0,0,0,0,0,124,198,254,192,192,198,124,8,4,0,0),
      (146,0,0,56,24,24,28,24,56,24,24,24,60,0,0,0,0),
      (164,0,0,0,4,8,220,102,102,102,102,102,102,0,0,0,0),
      (162,0,0,0,8,16,124,198,198,198,198,198,124,0,0,0,0),
      (158,0,0,0,8,16,124,198,96,56,12,198,124,0,0,0,0),
      (167,0,0,0,16,0,254,204,24,48,96,198,254,0,0,0,0),
      (166,0,0,0,4,8,254,204,24,48,96,198,254,0,0,0,0));
      var regs:registers;
          i:byte;
      begin
      for i:=1 to 18 do
                    begin
        regs.ax:=$1100;
        regs.es:=seg(plfnt[i,1]);
        regs.bp:=ofs(plfnt[i,1]);
        regs.cx:=1;
        regs.dx:=plfnt[i,0];
        regs.bx:=$1000;
        intr($10,regs)
        end
      end;

{--------------------------------------------------------------------------}
Procedure clearbuffer;
begin
 MemW[$0000:$041C] := MemW[$0000:$041A];
end;

{--------------------------------------------------------------------------}
Procedure changeColor(x, y, attrib : Byte);
begin
  screenMem[y - 1, x - 1, 1] := Char(attrib);
end;

{--------------------------------------------------------------------------}
Function HiN(B : Byte) : Byte; Assembler;
ASM
  MOV AL, B
  MOV CL, 4
  SHR AL, CL
END;

{--------------------------------------------------------------------------}
Function LoN(B : Byte) : Byte; Assembler;
ASM
  MOV AL, B
  AND AL, 0Fh
END;

{--------------------------------------------------------------------------}
Procedure zmienianiekolorow(zjakiego,najaki,xmin,xmax,ymin,ymax:byte);
begin
for x:=xmin to xmax do
 for y:= ymin to ymax do
  if lon(Mem[$B800 : 2 * (80 * (y - 1) + x-1 ) + 1]) = zjakiego  then
   begin
    gotoXY(x,y);
    changecolor(x,y,(hin(Mem[$B800 : 2 * (80 * (Y - 1) + X-1 ) + 1])*16+najaki));
   end;
end;

{--------------------------------------------------------------------------}
Procedure PrzesunStrone(zrodlo,cel:byte);
begin
 if (zrodlo<0) or (zrodlo>3) or (cel<0) or (cel>3) then halt(1);
 Move(Mem[$B800 : PageOffs[zrodlo]], Mem[$B800 : PageOffs[cel]], 4000);
end;

{--------------------------------------------------------------------------}
procedure Obraz (var Addr1,Addr2; BlkLen:Integer);
begin
  clrscr;
  inline (
    $1E/               {       PUSH    DS             ;Save data segment.}
    $C5/$B6/ADDR1/     {       LDS     SI,[BP+Addr1]  ;Source Address}
    $C4/$BE/ADDR2/     {       LES     DI,[BP+Addr2]  ;Destination Addr}
    $8B/$8E/BLKLEN/    {       MOV     CX,[BP+BlkLen] ;Length of block}
    $E3/$5B/           {       JCXZ    Done}
    $8B/$D7/           {       MOV     DX,DI          ;Save X coordinate for later.}
    $33/$C0/           {       XOR     AX,AX          ;Set Current attributes.}
    $FC/               {       CLD}
    $AC/               {LOOPA: LODSB                  ;Get next character.}
    $3C/$20/           {       CMP     AL,32          ;If a control character, jump.}
    $72/$05/           {       JC      ForeGround}
    $AB/               {       STOSW                  ;Save letter on screen.}
    $E2/$F8/           {Next:  LOOP    LOOPA}
    $EB/$4C/           {       JMP     Short Done}
                       {ForeGround:}
    $3C/$10/           {       CMP     AL,16          ;If less than 16, then change the}
    $73/$07/           {       JNC     BackGround     ;foreground color.  Otherwise jump.}
    $80/$E4/$F0/       {       AND     AH,0F0H        ;Strip off old foreground.}
    $0A/$E0/           {       OR      AH,AL}
    $EB/$F1/           {       JMP     Next}
                       {BackGround:}
    $3C/$18/           {       CMP     AL,24          ;If less than 24, then change the}
    $74/$13/           {       JZ      NextLine       ;background color.  If exactly 24,}
    $73/$19/           {       JNC     FlashBitToggle ;then jump down to next line.}
    $2C/$10/           {       SUB     AL,16          ;Otherwise jump to multiple output}
    $02/$C0/           {       ADD     AL,AL          ;routines.}
    $02/$C0/           {       ADD     AL,AL}
    $02/$C0/           {       ADD     AL,AL}
    $02/$C0/           {       ADD     AL,AL}
    $80/$E4/$8F/       {       AND     AH,8FH         ;Strip off old background.}
    $0A/$E0/           {       OR      AH,AL}
    $EB/$DA/           {       JMP     Next}
                       {NextLine:}
    $81/$C2/$A0/$00/   {       ADD     DX,160         ;If equal to 24,}
    $8B/$FA/           {       MOV     DI,DX          ;then jump down to}
    $EB/$D2/           {       JMP     Next           ;the next line.}
                       {FlashBitToggle:}
    $3C/$1B/           {       CMP     AL,27          ;Does user want to toggle the blink}
    $72/$07/           {       JC      MultiOutput    ;attribute?}
    $75/$CC/           {       JNZ     Next}
    $80/$F4/$80/       {       XOR     AH,128         ;Done.}
    $EB/$C7/           {       JMP     Next}
                       {MultiOutput:}
    $3C/$19/           {       CMP     AL,25          ;Set Z flag if multi-space output.}
    $8B/$D9/           {       MOV     BX,CX          ;Save main counter.}
    $AC/               {       LODSB                  ;Get count of number of times}
    $8A/$C8/           {       MOV     CL,AL          ;to display character.}
    $B0/$20/           {       MOV     AL,32}
    $74/$02/           {       JZ      StartOutput    ;Jump here if displaying spaces.}
    $AC/               {       LODSB                  ;Otherwise get character to use.}
    $4B/               {       DEC     BX             ;Adjust main counter.}
                       {StartOutput:}
    $32/$ED/           {       XOR     CH,CH}
    $41/               {       INC     CX}
    $F3/$AB/           {       REP STOSW}
    $8B/$CB/           {       MOV     CX,BX}
    $49/               {       DEC     CX             ;Adjust main counter.}
    $E0/$AA/           {       LOOPNZ  LOOPA          ;Loop if anything else to do...}
    $1F);              {Done:  POP     DS             ;Restore data segment.}
end; {UNCRUNCH}


{==========================================================================}

BEGIN
  MouseInstalled := (InitMouse <> 0);
END.