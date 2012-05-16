unit mycrt;

interface
uses crt;

const
cur_version = 'Alpha 1.5b';
wizard:boolean = false;
levelsaving:boolean = false;
arena:boolean = false;
mbtimes5:set of byte = [1..4,6,13,14,24,25,29];
maindepth = 50;
pmx:array[1..9]of shortint = (-1,0,1,-1,0,1,-1,0,1);
pmy:array[1..9]of shortint = (1,1,1,0,0,0,-1,-1,-1);
cpmx:array[1..8]of shortint = (-1,0,1,1,1,0,-1,-1);
cpmy:array[1..8]of shortint = (1,1,1,0,-1,-1,-1,0);
itsymbol:array[0..17]of char = ('$','(',')','[',']',']',']','=','&',']','!','?','\','%','}','/','{','&');
racename:array[0..6]of string[12] = ('human','elf','hobbit','troll','dwarf','orc','fallen angel');
spellnum = 19;
spellname:array[0..spellnum]of string[15] = (
'Magic Missile  ','Minor Quake    ','Sense Rooms    ','Destruction    ','Minor Cure     ',
'Remove Curse   ','Confusion      ','Fire Bolt      ','Frost Bolt     ','Lightning Bolt ',
'Major Cure     ','Satiation      ','Identify       ','Major Quake    ','Brain Burn     ',
'Astral Portal  ','Mana Short     ','Aura           ','Shroud of Death','Recharge       ');
spellcost:array[0..spellnum]of byte = (1,2,2,2,1, 3,2,2,2,2, 3,3,3,4,3, 4,3,2,5,3);
choice:string[52] = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
msg_num = 5;
skillnum = 9;
sk_melee=0; sk_ranged=1; sk_heal=2; sk_medit=3; sk_weapid=5; sk_crithit=6; sk_purify=9;
sk_disarm=4; sk_track=8; sk_scribe=7;
alignname:array[0..4]of string[7] = ('fighter','thief','wizard','ranger','priest');
x_map = 60;
y_map = 40;
movestodo:shortint = -99;

var
zn:char;
goldown:longint;
msgtext:array[1..msg_num]of string[80];
msgbuffer:array[1..40]of string[80];
skillname:array[0..skillnum]of string[15];
skilldepend:array[0..skillnum]of byte;
txtbuf,race:byte;
deathverb:string[40];
deathreason:string[40];
skill:array[0..skillnum]of byte;
savefile:file of byte;

procedure ink(i:shortint);
procedure paper(p:shortint);
procedure at(x,y:shortint);
function direct:byte;
function yesorno(caption:string;default:boolean):boolean;
function iyesorno(caption:string):boolean;
function testbit(num:integer;which:byte):boolean;
procedure setbit(var num:byte;which:byte);
procedure resetbit(var num:byte;which:byte);
function sgn(n:integer):shortint;
procedure select(kolik,allowexit:byte;var sel:byte);
procedure msg(mes:string);
procedure more;
procedure corner;
function scale100(n:shortint):string;
function scale20(n:shortint):string;
function exist(filename:string):boolean;
function txinput(x,y,len:byte;st:string):string;
procedure version;
procedure diskop(where:pointer;amount:word;save:byte);
procedure getbounds(var x1,y1,x2,y2:shortint;cx,cy,radius:byte);
procedure beep;

implementation

procedure corner;
begin
at(80,50);
end;

procedure ink(i:shortint);
begin
textcolor(i);
end;

procedure paper(p:shortint);
begin
textbackground(p);
end;

procedure at(x,y:shortint);
begin
gotoxy(x,y);
end;

function direct:byte;
var
mov:byte;
e:integer;
begin
at(1,y_map+1);write('Which direction?');
repeat
zn:=readkey;
until(zn>='1')and(zn<='9');
val(zn,mov,e);
at(1,y_map+1);clreol;
zn:=' ';
direct:=mov;
end;

function yesorno(caption:string;default:boolean):boolean;
begin
at(1,y_map+1);write(caption);
ink(14);
if default=true then write(' (Y/n)')
		else write(' (y/N)');
ink(7);
corner;
zn:=readkey;
at(1,y_map+1);clreol;
yesorno:=default;
if zn='y' then yesorno:=true;
if zn='n' then yesorno:=false;
end;

function iyesorno(caption:string):boolean;
begin
at(1,y_map+1);write(caption);
ink(14);
write(' (y/n)');
ink(7);
corner;
repeat
zn:=readkey;
until(zn='y')or(zn='n');
at(1,y_map+1);clreol;
if zn='y' then iyesorno:=true;
if zn='n' then iyesorno:=false;
end;

function testbit(num:integer;which:byte):boolean;
begin
if odd(num shr which) then testbit:=true
        else testbit:=false;
end;

procedure setbit(var num:byte;which:byte);
begin
num:=num or (1 shl which);
end;

procedure resetbit(var num:byte;which:byte);
begin
num:=num and not(1 shl which);
end;

function sgn(n:integer):shortint;
begin
if n<>0 then sgn:=n div abs(n) else sgn:=0;
end;

procedure select(kolik,allowexit:byte;var sel:byte);
begin
repeat
repeat
corner;
zn:=readkey;
until(zn in['a'..'z','A'..'Z'])or((zn=' ')and(allowexit>=1));
if(zn in ['a'..'z'])then sel:=ord(zn)-97	{'a' ASCII 97 -> choice 0}
	else sel:=ord(zn)-39;                   {'A' ASCII 65 -> choice 26}
if zn=' ' then sel:=99;
until(sel<kolik)or(sel=99);
end;

procedure msg(mes:string);
var
f:byte;
begin
if(mes[1]='*')then begin
	delete(mes,1,1);
	sound(300);
	delay(200);
	nosound;
	end;
mes[1]:=upcase(mes[1]);
if txtbuf=msg_num+1 then
	begin
	at(70,y_map+msg_num+2);write('-more-');
	zn:=readkey;
	at(70,y_map+msg_num+2);write('      ');
	for f:=1 to msg_num do msgtext[f]:='';
	txtbuf:=1;
	end;
if(mes<>'')then begin
	for f:=1 to 39 do msgbuffer[f]:=msgbuffer[f+1];
	msgbuffer[40]:=mes;
	end;
msgtext[txtbuf]:=mes;
inc(txtbuf);
for f:=1 to msg_num do begin
	at(1,y_map+f+1);write(msgtext[f]);clreol;
	end;
end;

procedure more;
var
f:byte;
begin
for f:=1 to msg_num do
	msg('');
for f:=1 to msg_num do msgtext[f]:='';
txtbuf:=1;
end;

function scale100(n:shortint):string;
begin
case n of
0:scale100:='Disastrous   ';
1:scale100:='Bad          ';
2:scale100:='Very poor    ';
3:scale100:='Poor         ';
4:scale100:='Below average';
5:scale100:='Average      ';
6:scale100:='Above average';
7:scale100:='Good         ';
8:scale100:='Very good    ';
9:scale100:='Excellent    ';
10:scale100:='Best         ';
else scale100:='>100 BUG     ';
end;
end;



function scale20(n:shortint):string;
begin
case n of
0:scale20:='Very low ';
1:scale20:='Low      ';
2:scale20:='Average  ';
3:scale20:='High     ';
4:scale20:='Very high';
5:scale20:='Maximal  ';
6..100:scale20:='Demigod  ';
end;
end;

function exist(filename:string):boolean;
var
f:file;
begin
Assign(F,filename);
{$I-}
Reset(F);
{$I+}
if(IOResult=0)and(filesize(F)>0)then exist:=true
	else exist:=false;
{$I-}
close(F);
{$I+}
if(IOResult=0)then ;
end;

function txinput(x,y,len:byte;st:string):string;
var
c:byte;
begin
repeat
c:=length(st);
at(x,y);write(st,' ');at(x+c,y);
zn:=readkey;
case zn of
#8:if(c>0)then delete(st,c,1);
#13:;
else if(c<len)then st:=st+zn;
end;
until(zn=#13);
txinput:=st;
end;

procedure version;
begin
msg('The current version is '+cur_version+'.');
end;

procedure diskop(where:pointer;amount:word;save:byte);
var
f:byte;
p:^byte;
begin
p:=where;
case save of
0:begin
	for f:=1 to amount do begin
		read(savefile,p^);
		inc(p);
		end;
	end;
1:begin
	for f:=1 to amount do begin
		write(savefile,p^);
		inc(p);
		end;
	end;
end;
end;

procedure getbounds(var x1,y1,x2,y2:shortint;cx,cy,radius:byte);
begin
x1:=cx-radius;if(x1<1)then x1:=1;
x2:=cx+radius;if(x2>x_map)then x2:=x_map;
y1:=cy-radius;if(y1<1)then y1:=1;
y2:=cy+radius;if(y2>y_map)then y2:=y_map;
end;

procedure beep;
begin
sound(1000);
delay(150);
nosound;
end;








end.