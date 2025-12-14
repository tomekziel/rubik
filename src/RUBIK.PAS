program Rubik;

{$define full}          {full oznacza, ze rubik komplikuje sie z intrem}

uses crt, u1;
{$I p3.inc}
{$I p4.inc}
{$I p5.inc}
{$I p6.inc}     {Za\ladowanie wszystkich te\l do wersji textowej}
{$I p7.inc}
{$I p8.inc}
{$I p9.inc}
{$I p10.inc}
var bok:byte;                   {aktualna szerokosc planszy}
    znak:char;
    zmianax,zmianay:word;       {wsp. zmiany}
const max_bok=10;               {maksymalny rozmiar planszy}
      wielkosci:array[1..max_bok]of byte=(0,0,3,3,2,2,2,1,1,1);
                                {dlugosci krawedzi elementu na planszy}
                                {UWAGA! Dla wsp X wartosc trzeba podwoic!}
      wspwierzchx:array[1..max_bok] of byte=(0,0,17,17,16,14,12,18,25,15);
      wspwierzchy:array[1..max_bok] of byte=(0,0, 9, 9,11,10, 9,12,11,11);
                                {wspolrzedne poczatku pola elementow
                                 dla kazdego z mozliwych 'bokow'}
{==========================================================================}
{==========================================================================}
type obiekt_tablicy = object                            {pojedyncza kratka }
                      stan:boolean;                     {stan kratki       }
                      X,Y:integer;                      {wsp. kratki       }
                      function check_element:boolean;   {sprawdzenie stanu }
                      procedure change;                 {zmiana stanu      }
                      procedure rysuj(wyroznienie:boolean);{uaktualnienie rys }
                      procedure self_change;            {zmiana i uakt.    }
                      end;
{--------------------------------------------------------------------------}
procedure obiekt_tablicy.change;                        {zmiana stanu kratki}
begin
 stan:=not stan;
end;
{--------------------------------------------------------------------------}
procedure obiekt_tablicy.rysuj(wyroznienie:boolean);    {narysowanie kratki}
begin
 if stan=false then TextBackground(Red) else TextBackground(Green);
 if stan=false then TextColor(LightRed) else TextColor(LightGreen);
 if wyroznienie=true then TextColor(white);

 case wielkosci[bok] of
  1:                                                    {element 2x1}
   begin
    GotoXY(wspwierzchx[bok]+2*(X-1),wspwierzchy[bok]+(Y-1));
    writeln('[]');
   end;

  2:                                                    {element 4x2}
   begin
    GotoXY(wspwierzchx[bok]+4*(X-1),wspwierzchy[bok]+2*(Y-1));
    write('⁄ƒƒø');GotoXY(wspwierzchx[bok]+4*(X-1),wspwierzchy[bok]+1+2*(Y-1));
    write('¿ƒƒŸ');
   end;

  3:                                                    {element 6x3}
   begin
    GotoXY(wspwierzchx[bok]+6*(X-1),wspwierzchy[bok]+3*(Y-1));
    write('⁄ƒƒƒƒø');GotoXY(wspwierzchx[bok]+6*(X-1),wspwierzchy[bok]+1+3*(Y-1));
    write('≥    ≥');GotoXY(wspwierzchx[bok]+6*(X-1),wspwierzchy[bok]+2+3*(Y-1));
    write('¿ƒƒƒƒŸ');
   end;
 end;
 TextBackground(Black);
 TextColor(LightGray);
end;
{---------------------------------------------------------------------------}
procedure obiekt_tablicy.self_change;                   {zmiana stanu kratki}
begin                                                   {i uaktualnienie    }
 change;
 rysuj(false);
end;
{---------------------------------------------------------------------------}
function obiekt_tablicy.check_element:boolean;          {informacja o stanie}
begin                                                   {kratki             }
 check_element:=stan;
end;
{==========================================================================}
{==========================================================================}

type object_licznik = object                            {licznik}
                  stan:word;                            {stan licznika}
                  komputer:word;                        {ile mieszal komputer}
                  function  jaki_stan:word;             {sprawdzenie stanu}
                  function ilekomputer:word;            {   -   /  /   - komputera}
                  procedure zwieksz_stan(oile:byte);    {zwiekszenie stanu}
                  procedure resetuj;                    {zerowanie licznika}
                  procedure wyswietl;                   {wyswietlenie }
                  end;
{---------------------------------------------------------------------------}
function object_licznik.jaki_stan:word;                 {sprawdzenie stanu}
begin
 jaki_stan:=stan;
end;
{---------------------------------------------------------------------------}
procedure object_licznik.zwieksz_stan(oile:byte);       {zwiekszenie licznika}
begin                                                   {o wartosc 'oile'    }
 stan:=stan+oile;
end;
{---------------------------------------------------------------------------}
procedure object_licznik.resetuj;                       {zerowanie licznika}
begin
 stan:=0;
end;
{---------------------------------------------------------------------------}
procedure object_licznik.wyswietl;                      {wyswietlenie }
begin                                                   {licznika}
 TextBackground(Blue);
 GotoXY(64-(length(IntToStr(jaki_stan))div 2),7);
 Write(jaki_stan);
 TextBackground(Black);
end;
{---------------------------------------------------------------------------}
function object_licznik.ilekomputer:word;               {sprawdzenie, ile razy}
begin                                                   {komputer mieszal}
 ilekomputer:=komputer;
end;
{==========================================================================}
{==========================================================================}
type t_przycisk=object                                  {przycisk ekranowy}
                x1,y1,x2,y2:integer;                    {w menu}
                constructor init(xx1,xx2,yy1,yy2:integer);
                function czy_myszka_trafila(xmouse, ymouse:integer):boolean;
                end;
{---------------------------------------------------------------------------}
function t_przycisk.czy_myszka_trafila(xmouse, ymouse:integer):boolean;
begin                                 {... w przycisk}
czy_myszka_trafila:=mysz_w_zakresie(xmouse,ymouse,x1,y1,x2,y2);
end;
{---------------------------------------------------------------------------}
constructor t_przycisk.init(xx1,xx2,yy1,yy2:integer);
var x,y:word;                                       {inicjalizacja przycisku}
begin
 x1:=xx1;
 x2:=xx2;
 y1:=yy1;
 y2:=yy2;
end;
{==========================================================================}
{==========================================================================}

type type_pole=array[1..max_bok,1..max_bok] of obiekt_tablicy;
                                                   {definicja typu pola gry}
{==========================================================================}

var pole:type_pole;                                    {definicja pola gry}
    licznik:object_licznik;                            {definicja licznika}
    temp:integer;                                      {temporary variable}
    preferowana_mysz,zatrzymanie,pierwszyraz:boolean;
{==========================================================================}

function czykoniec:boolean;                            {sprawdzenie, czy }
var temp1,temp2:integer;                               {gra zakoczyla sie}
begin
 czykoniec:=true;
  for temp1:= 1 to bok do
   for temp2 := 1 to bok do
    if pole[temp1,temp2].check_element=false then czykoniec:=false;
end;

{---------------------------------------------------------------------------}
Procedure zmiana_krzyzyka(x,y:integer);            {Zmiana i wyswietlenie   }
begin                                              {zmiany stanu elementow  }
 pole[x, y].self_change;                           {"na krzyz" poczawszy od }
 if x>1 then                                       {elementu o wsp. X,Y     }
  pole[x-1, y].self_change;
 if x<bok then
  pole[x+1, y].self_change;
 if y>1 then
  pole[x, y-1].self_change;
 if y<bok then
  pole[x, y+1].self_change;
end;
{---------------------------------------------------------------------------}

procedure init;                                     {Rysowanie poczatkowe }
var a,b,tempx,tempy:byte;                           {planszy i nadanie    }
begin                                               {'wartosci' kratkom   }
 clrscr;                                            {Przygotowanie planszy}
 case bok of                                        {dla boku 'bok'       }
  3:  obraz(P3,Screen[ (1*2) + (1*160) -162],P3_Length);
  4:  obraz(P4,Screen[ (1*2) + (1*160) -162],P4_length);
  5:  obraz(P5,Screen[ (1*2) + (1*160) -162],p5_Length);
  6:  obraz(P6,Screen[ (1*2) + (1*160) -162],p6_Length);
  7:  obraz(P7,Screen[ (1*2) + (1*160) -162],p7_Length);
  8:  obraz(P8,Screen[ (1*2) + (1*160) -162],p8_Length);
  9:  obraz(P9,Screen[ (1*2) + (1*160) -162],p9_Length);
  10: obraz(P10,Screen[ (1*2) + (1*160) -162],p10_Length);
 end;
 for tempx:=1 to bok do                       {narysowanie elementow}
  for tempy:=1 to bok do                      {jednolicie prawidlowych}
   begin
    pole[tempx,tempy].stan:=true;  {Uwaga: Bez dalszego losowania
                                    gra skonczylaby sie od razu}
    pole[tempx,tempy].X:=tempx;    {Kazda kratka dostaje wlasne}
    pole[tempx,tempy].Y:=tempy;    {X i Y. Od razu rysowana jest}
    pole[tempx,tempy].rysuj(false);       {biezaca kratka }
   end;
 Randomize;
 licznik.komputer:=random(3*bok)+2*bok;            {stopien trudnosci }
 TextBackground(Blue);          {wyswietlenie, ile razy komputer przekladal}
 GotoXY(64,15);                 {elementy w czasie losowania               }
 write(licznik.komputer);       {wyswietlenie licznika komputera}
 TextBackground(Black);
 repeat
  for a:=1 to licznik.komputer do          {wylosowanie 'a' zmian na planszy i...}
   begin
    tempx:=random(bok)+1;
    tempy:=random(bok)+1;
    zmiana_krzyzyka(tempx,tempy);        {... wyswietlenie ich.
                                          Dzieki temu gra nie skonczy
                                          sie zaraz po starcie.}
   end;

 until not czykoniec;      {zabezpieczenie przeciwko wylosowaniu ukladu
                            bedacego w pelni ulozona plansza gry}
 fade_in(0);               {pokazanie gotowej planszy            }
 zmianax:=1; zmianay:=1;
end;

{---------------------------------------------------------------------------}

Procedure KeybTxtRead(var zmiana_urzadzenia:boolean); {odczytywanie ruchow
                                                      z klawiatury}
var Xmouse,Ymouse,Xmouseold,Ymouseold:word;
    znak:char;
begin
 zmiana_urzadzenia:=false;                       {default - klawiatura zostaje}
 if MouseInstalled then                         {-----}
  begin                                         {zabezpieczenie przeciwko }
   GetMousePosition(Xmouse,Ymouse);             {nieobecnosci myszy...    }
   Xmouse := Xmouse div 8 +1;                   {Zabezpieczenie faktu, ze }
   Ymouse := Ymouse div 8 +1;                   {bez ruszania mysza domyslny}
   XmouseOld:=Xmouse;                           {pozostaje tryb wyboru    }
   YmouseOld:=Ymouse;                           {klawiatura               }
  end;                                          {-------}

 repeat
  highvideo;
  pole[zmianax,zmianay].rysuj(true);               {wyroznienie biezacej kratki}
  lowvideo;
  repeat                                  {sprawdzenie, czy nie zostala}
   if MouseInstalled then                 {poruszona _istniejaca_ mysz}
    begin
     GetMousePosition(Xmouse,Ymouse);
     Xmouse := Xmouse div 8 +1;
     Ymouse := Ymouse div 8 +1;
     if (xmouseold<>xmouse) or (ymouseold<>ymouse) then
      begin                                        {Jesli tak, to:}
       zmiana_urzadzenia:=true;                    {zmienic urzadzenie,}
       pole[zmianax,zmianay].rysuj(false);                {usunac wyroznienie,}
       exit;                                       {wrocic do procedury}
      end;
    end;                                           { wyboru}
  until iskeypressed;

  znak:=upcase(readkey);                  {Jesli wcisnieto klawisz, to}
                                             {rozpoznac go i zinterpretowac}
  if ord(znak)=DnArrow then                       {Oczko w dol}
   begin
    pole[zmianax,zmianay].rysuj(false);
    if zmianay<bok then zmianay:=zmianay+1;
   end;
  if ord(znak)=UpArrow then                       {Oczko w gore}
   begin
    pole[zmianax,zmianay].rysuj(false);
    if zmianay>1 then zmianay:=zmianay-1;
   end;
  if ord(znak)=RtArrow then                       {Oczko w prawo}
   begin
    pole[zmianax,zmianay].rysuj(false);
    if zmianax<bok then zmianax:=zmianax+1;
   end;
  if ord(znak)=LfArrow then                       {Oczko w lewo}
   begin
    pole[zmianax,zmianay].rysuj(false);
    if zmianax>1 then zmianax:=zmianax-1;
   end;

  if (znak=EscapeKey) or (upcase(znak)='W') then zatrzymanie:=true;{Wyjscie z gry do menu}
 until (znak=EnterKey) or (znak=' ') or zatrzymanie;{Dopoki nie zatwierdzone
                                                     Enterem lub spacja}
end;


{---------------------------------------------------------------------------}
Procedure MouseTxtRead(var zmiana_urzadzenia:boolean);  {Odczytywanie ruchow}
var Xmouse,Ymouse,Kmouse,Xmouseold,Ymouseold:word;      {mysza      }

begin
 ShowMouseCursor;
 repeat                        {petla 'dopoki nie trafiono w pole gry'}
  repeat                       {petla 'dopoki nie trafiono w obiekt ekranowy'}
   repeat                      {petla 'dopoki nie kliknieto bez przesuniecia'}
    while not (MousePressed or Keypressed) do
     begin
      GetMousePosition(Xmouse,Ymouse);   {potrzebne do sprawdzenia potem,}
      Xmouse := Xmouse div 8 +1;         {czy nie przesunieto myszy w    }
      Ymouse := Ymouse div 8 +1;         {stosunku do pozycji w momencie }
      Xmouseold := Xmouse;               {klikania                       }
      Ymouseold := Ymouse;
     end;

    if Keypressed then
     begin                                   {Jesli to klawisz, to:      }
      if (readkey=escapekey) then zatrzymanie:=true;
      HideMouseCursor;                       {ukryj kursor myszy         }
      zmiana_urzadzenia:=true;               {zmien urzadzenie           }
      exit;                                  {powroc do procedury        }
    end;                                     {nadrzednej                 }

    repeat until not MousePressed;           {Jesli to klawisz myszy, to }
                                             {czekaj na puszczenie go    }
    GetMousePosition(Xmouse,Ymouse);
    Xmouse := Xmouse div 8 +1;
    Ymouse := Ymouse div 8 +1;

   until not ((Xmouse<>xmouseold) or (Ymouse<>ymouseold));
                                             {Petla zabezpieczajaca przed}
                                             {wleczeniem myszy z wcisnietym}
                                             {klawiszem                     }
  until (Mysz_w_zakresie(
                 Xmouse,Ymouse,                        {Petla kontrolujaca}
                 wspwierzchx[bok],                     {czy kliknieto w   }
                 wspwierzchy[bok],                     {jakims obszarze   }
                 wspwierzchx[bok]+bok*2*wielkosci[bok],{z polem gry lub...}
                 wspwierzchy[bok]+bok*wielkosci[bok]))
  or
        (Mysz_w_zakresie(
                 Xmouse,Ymouse,                  {...przyciskiem ekranowym}
                 72, 23, 81, 26))
                 ;

 if Mysz_w_zakresie(xmouse,ymouse,72,23,81,26) then
  begin
   zatrzymanie:=true;
   exit;
  end;

 until Mysz_w_zakresie(
                   Xmouse,Ymouse,                   {Petla kontrolujaca}
                   wspwierzchx[bok],                {czy kliknieto w   }
                   wspwierzchy[bok],                {polu gry          }
                   wspwierzchx[bok]+bok*2*wielkosci[bok],
                   wspwierzchy[bok]+bok*wielkosci[bok]);

 zmianax:=((Xmouse-wspwierzchx[bok]) div (wielkosci[bok]))div 2+1;
 zmianay:=((Ymouse-wspwierzchy[bok]) div (wielkosci[bok]))+1;
 {skomplikowane wzory okreslajace wspolrzedne zmiany}

 HideMouseCursor; {Schowaj kursor, aby nie zamazal ekranu}
end;

{---------------------------------------------------------------------------}
Procedure Odczyt_Wsp;
var zmiana_urzadzenia:boolean;
begin
 repeat
  zmiana_urzadzenia:=false;                     {zasadniczo pozostac przy
                                                 tym samym urzadzeniu}
   if preferowana_mysz then MouseTxtRead(zmiana_urzadzenia)
    else KeybTxtRead(zmiana_urzadzenia);
   if zmiana_urzadzenia then                    {chyba, ze trzeba zmienic}
    begin
     preferowana_mysz:=not preferowana_mysz;
    end;
 until not zmiana_urzadzenia or zatrzymanie;
end;

{---------------------------------------------------------------------------}
procedure info_o;                              {efekt przycisku 'about')}
{$I about.inc}
begin
 if mouseinstalled then hidemousecursor;
 fade_out(0);
 clearbuffer;
 przesunstrone(0,2);                             {chowaj, znikaj, instruuj}
 obraz(about,Screen[ (1*2) + (1*160) -162],about_Length);
 fade_in(0);
 repeat until mouseorkeypressed;
 if mousepressed then repeat until not mousepressed;
 while keypressed do readkey;
 fade_out(0);
 przesunstrone(2,0);
 fade_in(0);
 clearbuffer;
 if mouseinstalled then showmousecursor;         {przywracaj, pokaz      }
end;

{---------------------------------------------------------------------------}
procedure instrukcja;                          {efekt przycisku instrukcja  }
{$I instr_.inc}
begin
 if mouseinstalled then hidemousecursor;
 fade_out(0);
 clearbuffer;
 przesunstrone(0,2);                             {chowaj, znikaj, instruuj}
 obraz(instr_obraz,Screen[ (1*2) + (1*160) -162],instr_obraz_Length);
 fade_in(0);
 repeat until mouseorkeypressed;
 if mousepressed then repeat until not mousepressed;
 while keypressed do readkey;
 fade_out(0);
 przesunstrone(2,0);
 fade_in(0);
 clearbuffer;
 if mouseinstalled then showmousecursor;         {przywracaj, pokaz      }
end;

{---------------------------------------------------------------------------}
{$I cyferki.inc}
{$I menu.inc}
procedure menu_startowe;                        {Menu startowe}

var up,down,play,about,instr,exit:^t_przycisk;
    temp1,temp2,xmouse,ymouse:word;

    procedure mix(ymin,ymax,dlugosc:byte);      {Mruganie kolorem zoltym}
     begin
      for temp:=0 to dlugosc do
       begin
        zmienianiekolorow(yellow,red,1,80,ymin,ymax);
        waitretrace;
        zmienianiekolorow(red,yellow,1,80,ymin,ymax);
        waitretrace;
       end;

end;

begin
 clearbuffer;
 new(up,   init(54,61,6,8));
 new(down, init(29,35,8,10));
 new(play, init(31,59,15,20));
 new(exit, init(72,81,23,26));         {inicjalizacja przyciskow ekranowych}
 new(instr,init(14,26,23,26));
 new(about,init(1,9,23,26));
 if mouseinstalled then HideMouseCursor;
 Obraz(Menu,Screen[ (1*2) + (1*160) -162],menu_Length);  {wyswietlenie obrazu menu}
 if mouseinstalled then ShowMouseCursor;
 if zatrzymanie then zatrzymanie:=false; {jesli powrot to kasuj znacznik }
 TextColor(lightgreen);
 Pisz_cyferke(39,6,bok);
 fade_in(0);
 clearbuffer;
 if mouseinstalled then ShowMouseCursor;
 repeat                                 {Petla 'dopoki nie zacznij gry'}
  Pisz_cyferke(39,6,bok);
  if pierwszyraz then               {Jesli pierwszy raz, to mrugaj:...}
   begin
    if mouseinstalled then Hidemousecursor;
    mix(22,25,20);                      { guzikami...}
    mix(1,11,25);                       { strzalkami...}
    mix(15,20,30);                      { i Startem     }
    pierwszyraz:=false;
    if mouseinstalled then showmousecursor;
   end;
  znak:=' ';

  repeat until mouseorkeypressed;     {odczytanie akcji myszy lub klawiatury}

  if keypressed then
   begin
    znak:=readkey;
    preferowana_mysz:=false;
    if (ord(znak)=RtArrow) then if bok<10 then inc(bok);        { +1 }
    if(ord(znak)=LfArrow) then if bok>3 then dec(bok);            { -1 }
    if (znak=escapekey) or (upcase(znak)='W') then wylaz;         { wyjscie }
    if (upcase(znak)='I') then instrukcja;                        {instrukcja}
    if (upcase(znak)='O') then info_o;                            {about}
   end;

  if Mousepressed then
   begin
    repeat until not mousepressed;
    preferowana_mysz:=true;
    GetMousePosition(xmouse, ymouse);
    xmouse:=xmouse div 8 + 1 ;
    ymouse:=ymouse div 8 + 1 ;

    if up^.czy_myszka_trafila(xmouse,ymouse) then if bok<10 then inc(bok);
       { +1 }
    if down^.czy_myszka_trafila(xmouse,ymouse) then if bok>3 then dec(bok);
       { -1 }
    if exit^.czy_myszka_trafila(xmouse,ymouse) then wylaz;
       { wyjscie }
    if instr^.czy_myszka_trafila(xmouse,ymouse) then  instrukcja;
       {instrukcja}
    if about^.czy_myszka_trafila(xmouse,ymouse)  then info_o;
       {about}
   end;

 until (play^.czy_myszka_trafila(xmouse,ymouse)) or (znak=EnterKey);
                                                    {dopoki nie gra}
 if mouseinstalled then HideMouseCursor;
 dispose(up);
 dispose(down);
 dispose(play);
 dispose(exit);
 dispose(instr);
 dispose(about);
 fade_out(0);
 textcolor(lightgray);
end;

{---------------------------------------------------------------------------}
procedure zakonczenie;                    {zakonczenie gry}
var przebieg,x,x1,y,y1:word;              {DO ZMIANY!}
begin
 textbackground(green);
 textcolor(lightgreen);
 for przebieg:=0 to 3 do
  begin
   delay(250);
   for y:=wspwierzchy[bok] to wspwierzchy[bok]+bok*wielkosci[bok]-1 do
   for x:=wspwierzchx[bok] to wspwierzchx[bok]+bok*wielkosci[bok]*2-1 do
   begin
    gotoXY(x,y);
    case przebieg of
     0: write('∞');
     1: write('±');
     2: write('≤');
     3: write('€');
    end;
   end;
  end;
  TextBackground(Black);
  TextColor(Yellow);
  GotoXY(wspwierzchx[bok]+(bok*wielkosci[bok]-15 div 2),
         wspwierzchy[bok]+((bok*wielkosci[bok]-1) div 2 -1));
  Write('⁄ƒƒƒƒƒƒƒƒƒƒƒƒø');
  GotoXY(wspwierzchx[bok]+(bok*wielkosci[bok]-15 div 2),
         wspwierzchy[bok]+((bok*wielkosci[bok]-1) div 2 ));
  Write('≥   Brawo!   ≥');
  GotoXY(wspwierzchx[bok]+(bok*wielkosci[bok]-15 div 2),
         wspwierzchy[bok]+((bok*wielkosci[bok]-1) div 2+1));
  Write('¿ƒƒƒƒƒƒƒƒƒƒƒƒŸ');

  textbackground(black);
  textcolor(lightgray);
end;


{---------------------------------------------------------------------------}
procedure gra;
begin
 repeat                                 {Petla glowna}
  menu_startowe;
  init;                                 {Przygotowanie ekranu }
  licznik.resetuj;
  licznik.wyswietl;
  repeat
   Odczyt_Wsp;
   if not zatrzymanie then
    begin
     zmiana_krzyzyka(zmianax,zmianay);
     licznik.zwieksz_stan(1);
     licznik.wyswietl;
     sound(3225);
     delay(1);
     nosound;
    end;
  until czykoniec or zatrzymanie;
  if czykoniec then
   begin
    zakonczenie;
    repeat until mouseorkeypressed;
    while keypressed do readkey;
   end;
  fade_out(1);
 until false;
end;

{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}
{$i start.inc}

begin
 textmode(co80);

 if not isvga then
  begin
   clrscr;
   writeln('Niestety, Rubik nie wykryl karty VGA. Jest ona niezbedna...');
   halt;
  end;

 PLFonts;

 if win3X then
  begin
   clrscr;
   writeln('            Uruchamiasz Rubika spod systemu Windows.');
   writeln('Bedzie on dziaíaí w peíni poprawnie tylko wtedy, gdy uruchomisz go');
   writeln('                  w trybie peínoekranowym.');
   writeln;
   writeln('                      Czy kontynuowaç?');
   repeat znak:=readkey until (upcase(znak)='T') or (upcase(znak)='N');
   if znak='n' then halt;
   repeat until not KeyPressed;
   ClearBuffer;
  end;

 lowvideo;
 cursoroff;
 TextBackground(Black);                         {kosmetyka}
 TextColor(LightGreen);
 bok:=7;
 zatrzymanie:=false;pierwszyraz:=true;
 if MouseInstalled then preferowana_mysz:=true else preferowana_mysz:=false;
{$ifdef full}
 Rozpoczecie;                                   {czolowka i wstep}
{$endif}
{$ifndef full}
clrscr;
get_color(pal);
{$endif}
 Gra;                                           {Petla glowna gry}
end.
{---------------------------------------------------------------------------}