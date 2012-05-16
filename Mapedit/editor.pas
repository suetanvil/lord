uses crt,mycrt,dungeons,items,monsters,gener,player;

type
itnumsptr=^itnums;
itnums=record
	num:integer;
	mb:integer;
	next:itnumsptr;
	end;

const
nullitm:itnums=(num:-1; mb:99; next:nil);

var
{patro,duntype:integer;}
ty,x,y,cx,cy:shortint;
origmode,brush:integer;
cmnd,zn:char;
mmap:array[1..x_map,1..y_map]of integer;
imap:array[1..x_map,1..y_map]of itnumsptr;
itnptr:itnumsptr;
itptr:itemptr;
tempstr:string[15];

function getnum(str:string):integer;
var
num:integer;
begin
at(1,y_map+1);clreol;
write(str,':');
readln(num);
getnum:=num;
end;

{procedure createitem(num,mb:integer;var it:item);
begin
case num of
0..499:randomitem(num,99,255,50,it);
500..999:repeat
	randomitem(-1,num-500,255,50,it);
	until(fitems[it.num]^.rarity<4);
1000..1999:randomitem(find(num-1000),99,255,50,it);
end;
if(mb<>99)and((num>499)or(num=0))then begin
	it.mb:=mb;
	if(it.mb>0)then it.curse:=false;
	end;
end;}

procedure addtoimap(x,y,num,mb:integer);
var
cur:itnumsptr;
it:item;
begin
cur:=imap[x,y];
if(cur=nil)then begin
	new(cur);
	imap[x,y]:=cur;
	imap[x,y]^.num:=num;
	imap[x,y]^.mb:=mb;
	imap[x,y]^.next:=nil;
	{createitem(num,mb,it);
	itemsortinto(itmap[x,y],it);}
	exit;
	end;
while(cur^.next<>nil)do cur:=cur^.next;
new(cur^.next);
cur:=cur^.next;
cur^.num:=num;
cur^.mb:=mb;
cur^.next:=nil;
{createitem(num,mb,it);
itemsortinto(itmap[x,y],it);}
end;

procedure takeaway2(x,y:shortint);
var
itnptr:itnumsptr;
begin
if(imap[x,y]<>nil)then begin
	itnptr:=imap[cx,cy];
	imap[x,y]:=imap[x,y]^.next;
	dispose(itnptr);
	end;
end;

procedure drawtile2(x,y:shortint);
var
cl,subcl:byte;
num:integer;
begin
at(x,y);
{if(seemap[x,y]>1)or(duntype=0)then }
case map[x,y] of
99:ink(8);
1:ink(8);
2:ink(6);
3:ink(6);
5:ink(14);
6:ink(14);
8:ink(8);
9:ink(2);
10:ink(8);
12:ink(typemap[x,y]+2);
else ink(7);
end;
case map[x,y] of
0:write(#219);  {#219 white , #178 gray}
1:write('.');
2:write('/');
3:write('+');
4:write('#');
5:write('<');
6:write('>');
7:write('#');
8:write('^');
9:write('*');
10:write('^');
11:write('!');
12:write('^');
13:write('O');
99:write(#219);
end;
ink(7);
end;


procedure savescheme;
var
cur:itnumsptr;
ext:string[3];
integf:file of integer;
itnf:file of itnums;
bytef:file of byte;
begin
duntype:=getnum('duntype');
patro:=getnum('depth');
str(patro,ext);
ext:=chr(duntype+64)+ext;
if(duntype=0)then begin
	str(patro,ext);
	ext:='@'+ext;
	{filename:=name+'.@'+ext;}
	end;
assign(integf,'map.'+ext);
rewrite(integf);
for x:=1 to x_map do
for y:=1 to y_map do
	write(integf,map[x,y]);
close(integf);
assign(bytef,'type.'+ext);
rewrite(bytef);
for x:=1 to x_map do
for y:=1 to y_map do
	write(bytef,typemap[x,y]);
close(bytef);
assign(integf,'monster.'+ext);
rewrite(integf);
for x:=1 to x_map do
for y:=1 to y_map do
	write(integf,mmap[x,y]);
close(integf);
assign(itnf,'item.'+ext);
rewrite(itnf);
for x:=1 to x_map do
for y:=1 to y_map do begin
	cur:=imap[x,y];
	while(cur<>nil)do begin
{		writeln(x,' ',y,' !!!!');}
		write(itnf,cur^);
		cur:=cur^.next;
		end;
	write(itnf,nullitm);
	end;
close(itnf);
end;

procedure loadscheme;
var
cur:itnums;
ext:string[3];
integf:file of integer;
itnf:file of itnums;
bytef:file of byte;
begin
duntype:=getnum('duntype');
patro:=getnum('depth');
str(patro,ext);
ext:=chr(duntype+64)+ext;
if(duntype=0)then begin
	str(patro,ext);
	ext:='@'+ext;
	end;
clearmap;
assign(integf,'map.'+ext);
reset(integf);
for x:=1 to x_map do
for y:=1 to y_map do
	read(integf,map[x,y]);
close(integf);
assign(bytef,'type.'+ext);
reset(bytef);
for x:=1 to x_map do
for y:=1 to y_map do
	read(bytef,typemap[x,y]);
close(bytef);
assign(integf,'monster.'+ext);
reset(integf);
for x:=1 to x_map do
for y:=1 to y_map do begin
	read(integf,mmap[x,y]);
{	if(mmap[x,y]>-1)then randommon(mmap[x,y],99,255,monmap[x,y]^)
		else monmap[x,y]^.num:=-1;}
	end;
close(integf);
assign(itnf,'item.'+ext);
reset(itnf);
for x:=1 to x_map do
for y:=1 to y_map do begin
	while(imap[x,y]<>nil)do takeaway2(x,y);
	read(itnf,cur);
	while not((cur.num=-1)and(cur.mb=99))do begin
		addtoimap(x,y,cur.num,cur.mb);
		read(itnf,cur);
		end;
	end;
close(itnf);
for x:=1 to x_map do
for y:=1 to y_map do begin
	drawtile2(x,y);
	if(imap[x,y]<>nil)then begin at(x,y);write('(');end;
	if(mmap[x,y]>-1)then begin at(x,y);write('*');end;
	end;
end;








begin
origmode:=lastmode;
textmode(co80+font8x8);
inititems;
initmonsters;
chdir('maps');
clearmap;
mapgen(99,1);
for x:=1 to x_map do
for y:=1 to y_map do begin
	mmap[x,y]:=-1;
	imap[x,y]:=nil;
	drawtile2(x,y);
	end;
cx:=1;cy:=1;
brush:=-1;
levelsaving:=true;
name:='maps';
at(x_map+2,1);write('Monster:');
at(x_map+2,5);write('Type:');
at(x_map+2,8);write('Items:');
repeat
if(brush>-1)then map[cx,cy]:=brush;
at(x_map+2,6);write(typemap[cx,cy]);
at(x_map+2,2);
if(mmap[cx,cy]>-1)then begin
	write(mmap[cx,cy]);
	tempstr:=fmons[mmap[cx,cy]]^.name;
	at(x_map+2,3);write(tempstr);
	at(cx,cy);write('*');
	end
else begin
	write('    ');
	at(x_map+2,3);write('                   ');
	drawtile2(cx,cy);
	end;
ty:=9;
if(imap[cx,cy]<>nil)then begin
	at(cx,cy);write('(');
	itnptr:=imap[cx,cy];
	while(itnptr<>nil)do begin
		case itnptr^.num of
		0..499:tempstr:=fitems[itnptr^.num]^.name1;
		500..999:tempstr:='filter';
		1000..9999:tempstr:='find';
		end;
		at(x_map+2,ty);clreol;write(itnptr^.num,' ',itnptr^.mb);
		at(x_map+2,ty+1);write(tempstr);
		itnptr:=itnptr^.next;
		inc(ty,2);
		end;
	at(x_map+2,ty);write('---------------');
	end
else begin at(x_map+2,ty);write('---------------');end;
at(cx,cy);
cmnd:=readkey;
case cmnd of
'0':map[cx,cy]:=0;
'1':map[cx,cy]:=1;
'2':map[cx,cy]:=2;
'3':map[cx,cy]:=3;
'4':map[cx,cy]:=4;
'5':map[cx,cy]:=5;
'6':map[cx,cy]:=6;
'7':map[cx,cy]:=7;
'8':map[cx,cy]:=8;
'9':map[cx,cy]:=9;
'a':map[cx,cy]:=10;
'b':map[cx,cy]:=11;
'c':map[cx,cy]:=12;
'd':map[cx,cy]:=13;
'+':map[cx,cy]:=99;
'M':begin
	mmap[cx,cy]:=getnum('monster');
{	if(mmap[cx,cy]>-1)then randommon(mmap[cx,cy],99,255,monmap[cx,cy]^)
		else monmap[cx,cy]^.num:=-1;}
	writeln('MONMAP ',monmap[cx,cy]^.num);
	end;
'B':brush:=getnum('brush');
'I':addtoimap(cx,cy,getnum('item num'),getnum('itemmb'));
		{500-999 filter,1000-1999 FIND}
'T':begin
	while(imap[cx,cy]<>nil)do takeaway2(cx,cy);
	while(itmap[cx,cy]<>nil)do begin
		itptr:=itmap[cx,cy];
		takeaway(itmap[cx,cy],itptr);
		end;
	end;
't':typemap[cx,cy]:=getnum('type of tile');
'S':savescheme;
'L':loadscheme;
{'C':compile;}
'G':begin
	mapgen(getnum('rooms'),getnum('paths'));
	for x:=1 to x_map do
	for y:=1 to y_map do begin
		drawtile2(x,y);
		if(imap[x,y]<>nil)then begin at(x,y);write('(');end;
		if(mmap[x,y]>-1)then begin at(x,y);write('*');end;
		end;
	end;
#0:begin
	cmnd:=readkey;
	case cmnd of
	#80:begin inc(cy);if(cy>y_map)then cy:=y_map;end;
	#72:begin dec(cy);if(cy<1)then cy:=1;end;
	#77:begin inc(cx);if(cx>x_map)then cx:=x_map;end;
	#75:begin dec(cx);if(cx<1)then cx:=1;end;
	end;
	end;
end;
{write(ord(cmnd));}
if(map[cx,cy]=11)then begin at(cx,cy);write('!');end;
until(cmnd='Q');
chdir('..');
textmode(origmode);
end.
