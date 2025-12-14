{$I darksoft.inc}
{$I present.inc}
{$I rublogo.inc}

{---------------------------------------------------------------------------}
procedure napisik(a:string);
begin
 delay(500);
 GotoXY(40-length(a)div 2,20);
 writeln(a);
 delay(1500);
 GotoXY(40-(length(a)div 2),20);
 writeln('                                                    ');
 delay(500)
end;

{---------------------------------------------------------------------------}
procedure rozpoczecie;
label koniec;
begin
      textcolor(LightGray);
      get_color(pal);
      fade_out(3);
 obraz(darksoft,Screen[ (1*2) + (1*160) -162],darksoft_Length);
 fade_in(25);
 if mouseorkeypressed then goto koniec;
 napisik('Darksoft');
 fade_out(3);
 if mouseorkeypressed then goto koniec;
      clrscr;
      GotoXY(40,13);
      obraz(present,Screen[ (1*2) + (1*160) -162],present_Length);
      fade_in(25);
      if mouseorkeypressed then goto koniec;
      napisik('Prezentuje');
      fade_out(10);
      if mouseorkeypressed then goto koniec;
 clrscr;
 GotoXY(40-(length('a TomasH design game')div 2),13);
 textcolor(White);
 Writeln('a TomasH design game');
 fade_in(10);
 if mouseorkeypressed then goto koniec;
 textcolor(LightGray);
 napisik('tresura ’osia');
 fade_out(10);
 if mouseorkeypressed then goto koniec;
     clrscr;
     GotoXY(40-(length('Idea, code and graphics by TomasH')div 2),13);
     textcolor(White);
     Writeln('Idea, code and graphics by TomasH');
     fade_in(10);
     if mouseorkeypressed then goto koniec;
     textcolor(LightGray);
     napisik('choreografia ’osia');
     fade_out(10);
koniec:
       clrscr;
       Obraz(rubik_o,Screen[ (1*2) + (1*160) -162],rubik_o_Length);
       fade_in(10);
       clearbuffer;
       repeat until mouseorkeypressed;
       delay(100);
       clearbuffer;
       fade_out(0);
end;
{---------------------------------------------------------------------------}
