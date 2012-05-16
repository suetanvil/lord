unit helper;

interface
uses mycrt,crt,dos;


procedure help;




implementation

procedure typefile(filename:string);
var
fl:text;
txt:string;
i,f:byte;
line,pos:integer;
redr:boolean;
begin
clrscr;
if(not(exist(filename)))then begin
	write('File ');ink(14);write(filename);
	ink(7);writeln(' not found.');
	zn:=readkey;
	exit;
	end;
assign(fl,filename);
reset(fl);
line:=1;pos:=1;redr:=true;
repeat
if(redr)then begin
	clrscr;
	for f:=pos to line-1 do
		readln(fl,txt);
	i:=0;
	while(not(eof(fl)))and(i<49)do begin
		readln(fl,txt);
		writeln(txt);
		inc(i);
		end;
pos:=line+i;
	at(1,50);ink(14);write('''SPACE'' - exit   ''+'' - next page   ''-'' - previous page');
	ink(7);
	end;
repeat
zn:=readkey;
until(zn in ['+','-',' ']);
redr:=false;
case zn of
'+':if(i=49)then begin
	redr:=true;
	inc(line,49);
	end;
'-':if(pos>50)then begin
	redr:=true;
	pos:=1;
	dec(line,49);
	if(line<1)then line:=1;
	reset(fl);
	end;
end;
until(zn=' ');
close(fl);
end;

procedure help;
begin
repeat;
clrscr;
at(5,5);ink(15);write('Select file to view:');
ink(7);
at(7,7); ink(14);write('1)');ink(7);write(' command keys (keyboard.txt)');
at(7,8); ink(14);write('2)');ink(7);write(' manual (manual.txt)');
at(7,9); ink(14);write('3)');ink(7);write(' spells & skills (spelskil.txt)');
at(7,15);ink(14);write('0)');ink(7);write(' other file');
at(3,16);ink(14);write('SPACE');ink(7);write(' exit');
zn:=readkey;
case zn of
'0':begin
	at(5,30);write('Enter filename:');
	typefile(txinput(7,31,12,''));
	end;
'1':typefile('keyboard.txt');
'2':typefile('manual.txt');
'3':typefile('spelskil.txt');
end;
until(zn=' ');
end;

end.
