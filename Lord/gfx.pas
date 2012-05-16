unit gfx;

interface
uses crt;

procedure titlescreen;
procedure grave;
{procedure help;}
procedure wizhelp;

implementation
var
zn:char;

procedure titlescreen;
var
zn:char;
begin
clrscr;
textcolor(14);
writeln('   _____                                                    __ ');
writeln('  /  \  \ \             \\                      \          /  \');
writeln('  \   |    |             ||                     |          |   ');
writeln('      |    |__    __     ||       __     _    __|      __ -|-  ');
writeln('      |    |  \  /__\    ||      /  \  \/ \  /  |     /  \ |   ');
writeln('   \_/     |  /  \___    ||====  \__/   |    \__|\    \__/ |   ');
textcolor(4);writeln;
writeln('       =====                        ');
writeln('       \\   \\                      ');
writeln('       ||   ||                      ');
writeln('       ||===//   __    __   __      ');
writeln('       ||   \\  /  \  /  \ /__\     ');
writeln('       //    \\ \__/\ \__| \___     ');
  write('                      ___/          ');
		      textcolor(14);writeln('         \');
writeln('                               __   ___    __|');
writeln('                              /  \  |  \  /  |');
writeln('                              \__/\ |  /  \__|');
writeln;textcolor(8);
writeln('                                         =====                         ');
writeln('                                         \\   \\                   \   ');
writeln('                                         ||   ||                   |   ');
writeln('                                         ||   ||   __    __    |   |__ ');
writeln('                                         //   //  /__\  /  \  -|-  |  \');
writeln('                                         =====    \___  \__/\  \_  |  |');
textcolor(15);
gotoxy(45,10);write('                 |   ');
gotoxy(45,11);write('-================|==O');
gotoxy(45,12);write('                 |   ');
gotoxy(1,16);
writeln('   |\_______/|');
writeln('   |         |');
writeln('   |         |');
writeln('   |         |');
writeln('    \       / ');
writeln('     \     /  ');
writeln('      \___/   ');
textcolor(3);
gotoxy(7,18);write('\\|//');
gotoxy(7,19);write('==*==');
gotoxy(7,20);write('//|\\');
textcolor(15);gotoxy(3,30);
write('(C) 1998 Vaclav Jucha');
textcolor(7);gotoxy(10,32);write('Contact address:');
gotoxy(10,35);write('Snail mail: Vaclav Jucha');
gotoxy(22,36);write('J.Gagarina 14');
gotoxy(22,37);write('Havirov-Podlesi');
gotoxy(22,38);write('736 01');
gotoxy(22,39);write('Czech Republic');
gotoxy(10,41);write('E-mail: vaclav.jucha.fei@vsb.cz');
zn:=readkey;
end;

procedure grave;
begin
clrscr;
gotoxy(4,10);write('This is the grave screen.');
end;

{procedure help;
begin
clrscr;
writeln('Not-very-nice-but-still-useful help:');
writeln('o:open door');
writeln('c:close door');
writeln('s:search');
writeln('!:redraw screen');
writeln('i:inventory');
writeln(',:take');
writeln('d:drop');
writeln('e:equipment');
writeln('E:eat');
writeln('M:messagebuffer');
writeln('l:look');
writeln('t:tunnel');
writeln('r:read');
writeln('z:zap wand');
writeln('Z:cast');
writeln('D:drink');
writeln('C:status screen');
writeln('f:fire/throw missile');
writeln('m:memorize scroll (preferably a rune scroll)');
writeln('R:running on/off (makes thirsty)');
writeln('S:save & quit');
writeln('<:ascend');
writeln('>:descend');
writeln('1..9:move');
writeln('_:pray');
writeln('w:walk');
writeln('V:current version number');
writeln('?:help');
writeln('Q:quit');
zn:=readkey;
end;
}

procedure wizhelp;
begin
clrscr;
writeln('^A artifact on every floor');
writeln('^B butcher(reznik => totalni jatka)');
writeln('^D down');
writeln('^G +1000 gold');
writeln('^H heal');
writeln('^I identify all new items');
writeln('^L raise level');
writeln('^M mapa');
writeln('^Q wizhelp');
writeln('^S seemapa');
writeln('^T generate object');
writeln('^U up');
writeln('^W wizard (god) mode');
writeln(' 0 itemlist');
zn:=readkey;
end;


end.
