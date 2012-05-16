unit dungeons;

interface
uses crt,mycrt,gener,player,items,monsters,shops,univ;

const
dungnum = 7;
dungname:array[1..dungnum]of string[30] = ('farm','orcish fortress',
	'Silent Chambers monastery','town of Kloth','cave of the spring','palace of L.o.R.D.',
	'arena');
wildsize = 5;
maxdeep:array[1..dungnum]of byte = (1,1,1,1,1,1,1);

var
w_artif:boolean;
wildx,wildy:byte;
wildmap,wilddung:array[1..wildsize,1..wildsize]of byte;
floorchange:array[1..8]of mon;

procedure initdungeons;
procedure clearmap;
procedure newlevel;
procedure newmonster;
procedure storemons;
procedure putmons;
procedure descend;
procedure ascend;
procedure saveloadmap(save:byte);
procedure wildmapdraw;




implementation

type
itnumsptr=^itnums;
itnums=record
	num:integer;
	mb:integer;
	next:itnumsptr;
	end;

var
x,y,f:byte;

procedure initdungeons;
begin
for x:=1 to wildsize do
for y:=1 to wildsize do begin
	wilddung[x,y]:=0;
	wildmap[x,y]:=0;
	end;
for f:=1 to dungnum do begin
	repeat
	x:=random(wildsize)+1;y:=random(wildsize)+1;
	until(wilddung[x,y]=0);
	wilddung[x,y]:=f;
	if(f=1)then begin wildx:=x;wildy:=y;end;
	end;
end;

procedure scanforstairs(down:byte);
var
x,y:byte;
begin
plx:=-1;ply:=y_map-1;
down:=down+5;
for x:=2 to x_map-1 do
for y:=2 to y_map-1 do
if map[x,y]=down then
	begin
	plx:=x;
	ply:=y;
	end;
if(plx=-1)then plx:=2;
end;

procedure stditems(patro:shortint;artif:boolean);
var
luck,common,uncommon,rare:byte;
it:item;
begin
luck:=random(atrib[5]);
if luck>100 then luck:=100;
common:=random(5)+2;
uncommon:=((patro div 2)*luck)div maindepth;if(uncommon>10)then uncommon:=10;
rare:=((patro div 7)*luck)div maindepth;if(rare>4)then rare:=4;
if(wizard)then begin at(1,50);write(luck,' ',common,' ',uncommon,' ',rare);zn:=readkey;end;
for f:=1 to common do
begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1);
	randomitem(-1,99,1,atrib[5],it);
	itemsortinto(itmap[x,y],it);
end;
if(random(5)=0)then begin randomitem(find(131),99,255,50,it);itemsortinto(itmap[x,y],it);end;
if(random(5)=0)then begin randomitem(find(101),99,255,50,it);itemsortinto(itmap[x,y],it);end;
for f:=1 to uncommon do
begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1);
	randomitem(-1,99,2,atrib[5],it);
	itemsortinto(itmap[x,y],it);
end;
for f:=1 to rare do
begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1);
	randomitem(-1,99,3,atrib[5],it);
	itemsortinto(itmap[x,y],it);
end;
if(artif)then
	if(random(maindepth)<((patro-(maindepth div 5)) div 3))or(w_artif=true) then begin
		for f:=1 to 100 do begin
			x:=random(x_map-3)+3;
			y:=random(y_map-2)+2;
			if(map[x,y]=0)then break;
			end;
		if(map[x,y] in [5,6])then dec(x);
		map[x,y]:=1;
		randomitem(-1,99,4,atrib[5],it);
		itemsortinto(itmap[x,y],it);
		if(random(22)<atrib[4])and(it.mb>=0) then begin
			msg('A mighty voice in your head says:');
			msg('"Search thoroughly, mortal."');
			end;
		if(random(5)<align[1])then msg('You sense someting very rare.');
		if(wizard)then msg('artifact');
		end;
end;

procedure escort(n:word;x,y:byte);
var
x1,y1,g,f:shortint;
begin
if(wizard)then msg('escorts');
for g:=1 to 10 do begin
	for f:=1 to 100 do begin
		repeat
		x1:=x+random(5)-2;
		y1:=y+random(5)-2;
		until(x1 in [1..x_map])and(y1 in [1..y_map]);
		if(pass(x1,y1))and(monmap[x1,y1]^.num=-1)then break;
		x1:=99;y1:=99;
		end;
	if(x1<>99)and(y1<>99)then randommon(n,99,255,monmap[x1,y1]^);
	end;
end;

procedure genmon(r,f,x,y:byte);
begin
randommon(-1,f,r,monmap[x,y]^);
if(testbit(fmons[monmap[x,y]^.num]^.spec,12))then escort((monmap[x,y]^.num)+1,x,y);
end;

procedure stdmons(patro:byte);
var
r:integer;
begin
repeat
x:=random(x_map-2)+2;
y:=random(y_map-2)+2;
until(map[x,y]=1)and(monmap[x,y]^.num=-1);
r:=(patro*100)div maindepth;
r:=(r+18)-(random(atrib[5])div 3);
if(r<1)then r:=1;
if(r>100)then r:=100;
genmon(r,99,x,y);
end;

procedure newmonster;
var
f,r:byte;
begin
repeat
x:=random(x_map-2)+2;
y:=random(y_map-2)+2;
until(pass(x,y))and(monmap[x,y]^.num=-1);
case duntype of
0:if(not(wizard))then
	case random(2)of
	0:randommon(-1,6,255,monmap[x,y]^);
	1:randommon(-1,2,255,monmap[x,y]^);
	end;
1:if(patro>1)then randommon(28,99,255,monmap[x,y]^);	{rats}
2:randommon(-1,0,255,monmap[x,y]^);
3:;
4:if(patro=1){and(random(5)=0)}then begin
	r:=random(30)+1;
	case random(2)of
	0:randommon(-1,6,255,monmap[x,y]^);
	1:randommon(-1,2,r,monmap[x,y]^);
	end;
	end;
5:;
6:stdmons(patro);
end;
end;

procedure specmon(n,chance:byte);
var
x,y:byte;
begin
if(fmons[n]^.rarity<>-1)then exit;
if(random(10)>chance)and(wizard=false)then begin
	fmons[n]^.rarity:=-99;
	exit;
	end;
repeat
x:=random(x_map-2)+2;
y:=random(y_map-2)+2;
until(map[x,y]=1)and(monmap[x,y]^.num=-1);
randommon(n,99,255,monmap[x,y]^);
if(testbit(fmons[monmap[x,y]^.num]^.spec,12))then escort((monmap[x,y]^.num)+1,x,y);
msg('You feel the smell of battle.');
end;

procedure maindung;
var
luck,common,uncommon,rare,f,r,p:byte;
begin
r:=random(10)+8;
p:=random(r div 2)+(r div 2);
if(patro=25)then r:=99;
if(patro=(maindepth-1))then r:=100;
mapgen(r,p);
stditems(patro,true);
for f:=1 to 10 do stdmons(patro);
case patro of
5:specmon(2,5);		{Grind}
15:specmon(9,5);	{Rothead}
20:specmon(4,5);	{Wu-Wei}
30:specmon(0,5);	{Aardan}
40:specmon(7,5);	{Shirka}
45:specmon(1,5);	{Xythor}
50:specmon(10,10);	{Lord}
end;
if(patro=maindepth)then begin
	scanforstairs(1);
	map[plx,ply]:=1;
	end;
end;

procedure wilderness;
var
it:item;
begin
for x:=1 to x_map do
for y:=1 to y_map do begin
	if(random(4)=0)then map[x,y]:=9
		else map[x,y]:=1;
	seemap[x,y]:=1;
	end;
if(wilddung[wildx,wildy]>0)then map[random(10)-5+(x_map div 2),random(10)-5+(y_map div 2)]:=6;
if(wildx=1)then
	for y:=1 to y_map do
	for x:=1 to random(3)+2 do
		map[x,y]:=10;
if(wildy=1)then
	for x:=1 to x_map do
	for y:=1 to random(3)+2 do
		map[x,y]:=10;
if(wildx=wildsize)then
	for y:=1 to y_map do
	for x:=x_map-random(3)-1 to x_map do
		map[x,y]:=10;
if(wildy=wildsize)then
	for x:=1 to x_map do
	for y:=y_map-random(3)-1 to y_map do
		map[x,y]:=10;
if(random(10)=0)then begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1);
	randomitem(-1,13,255,atrib[5],it);
	itemsortinto(itmap[x,y],it);
	end;
for f:=1 to random(5) do begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1)and(monmap[x,y]^.num=-1);
	randommon(-1,6,255,monmap[x,y]^);
	end;
wildmap[wildx,wildy]:=1;
end;

procedure orcfort;
var
luck,common,uncommon,rare,f,r,p:byte;
begin
r:=random(10)+8;
p:=random(r div 2)+(r div 2);
mapgen(r,p);
stditems(patro*2,false);
for f:=1 to 10 do begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1)and(monmap[x,y]^.num=-1);
	randommon(-1,0,255,monmap[x,y]^);
	end;
if(patro=10)then begin
	specmon(5,10);
	scanforstairs(1);
	map[plx,ply]:=1;
	end;
end;

procedure clearmap;
var
x,y:byte;
begin
guardedlevel:=false;
for x:=1 to x_map do
for y:=1 to y_map do begin
	if(itmap[x,y]<>nil)then begin
		if(wizard)then msg('CLEAR ITMAP');
		destroylist(itmap[x,y]);
		end;
	if(monmap[x,y]^.inv<>nil)then begin
		if(wizard)then msg('CLEAR MONMAP');
{			at(x,y);writeln('*',monmap[x,y]^.num);end;}
		if(monmap[x,y]^.num=-1)then msg('BUG REPORT: Dead monster with inventory.(CM)')
			else destroylist(monmap[x,y]^.inv);
		end;
	monmap[x,y]^.num:=-1;
	seemap[x,y]:=0;oldseemap[x,y]:=0;typemap[x,y]:=0;
	end;
end;

procedure monastery;
begin
mapgen(5,4);
msg('BUG REPORT: This map should be pre-designed !');
if(patro=10)then begin
	specmon(12,10);
	scanforstairs(1);
	map[plx,ply]:=1;
	end;
end;

procedure town;
begin
mapgen(5,4);
msg('BUG REPORT: This map should be pre-designed !');
if(patro=2)then begin
	scanforstairs(1);
	map[plx,ply]:=1;
	end;
end;

procedure lakecave;
var
f,r,p:byte;
begin
r:=random(10)+8;
p:=random(r div 2)+(r div 2);
mapgen(r,p);
stditems(patro,true);
for f:=1 to 10 do stdmons(patro);
if(patro=5)then begin
	msg('BUG REPORT: This level should be pre-designed !');
	scanforstairs(1);
	map[plx,ply]:=1;
	end;
end;

procedure familyfarm;
var
f,r,p:byte;
begin
r:=random(10)+8;
p:=random(r div 2)+(r div 2);
mapgen(r,p);
{stditems(patro,true);}
for f:=1 to 10 do begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until(map[x,y]=1)and(monmap[x,y]^.num=-1);
	randommon(28,99,255,monmap[x,y]^);	{rats}
	end;
{ratman 27}
if(patro=1)then	msg('BUG REPORT: This level should be pre-designed !');
if(patro=4)then begin
	scanforstairs(1);
	map[plx,ply]:=1;
	specmon(27,10);
	end;
end;

procedure arena;
begin
mapgen(5,4);
msg('BUG REPORT: This map should be pre-designed !');
if(patro=1)then begin
	scanforstairs(1);
	map[plx,ply]:=1;
	end;
end;

procedure newlevel;
begin
clearmap;
case duntype of
0:wilderness;
1:familyfarm;
2:orcfort;
3:monastery;
4:town;
5:lakecave;
6:maindung;
7:arena;
end;
if((duntype*10+patro)in sunlight)and(patro<10)then
	for x:=1 to x_map do
	for y:=1 to y_map do begin
		if(random(4)=0)then map[x,y]:=9
			else map[x,y]:=1;
		seemap[x,y]:=1;
		end;
end;

procedure addtoitmap(x,y,num,mb:integer);
var
it:item;
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
	if(it.mb<0)then it.curse:=true;
	end;
itemsortinto(itmap[x,y],it);
end;

procedure loadscheme(ext:string);
var
cur:itnums;
mmap:integer;
integf:file of integer;
itnf:file of itnums;
bytef:file of byte;
begin
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
	read(integf,mmap);
	if(mmap>-1)then randommon(mmap,99,255,monmap[x,y]^)
		else monmap[x,y]^.num:=-1;
	end;
close(integf);
assign(itnf,'item.'+ext);
reset(itnf);
for x:=1 to x_map do
for y:=1 to y_map do begin
	read(itnf,cur);
	while not((cur.num=-1)and(cur.mb=99))do begin
		addtoitmap(x,y,cur.num,cur.mb);
		read(itnf,cur);
		end;
	end;
close(itnf);
end;

procedure checkforguards;
var
x,y:shortint;
begin
for x:=1 to x_map do
for y:=1 to y_map do
	if(monmap[x,y]^.num>-1)then
		if(testbit(fmons[monmap[x,y]^.num]^.spec2,6))then guardedlevel:=true;
end;

procedure saveloadmap(save:byte);	{0-load,1-save}
const
dummy :byte = 0;
dummy1:byte = 1;
var
filename:string[12];
what:string[7];
ext:string[3];
f,g,n,size:byte;
begin
if(not(levelsaving))and(save=1)then exit;
if(save=0)then clearmap;
case save of
0:what:='Loading';
1:what:='Saving';
end;
{if(duntype=0)and(save=1)then exit;}
str(patro,ext);
ext:=chr(duntype+64)+ext;
if(duntype=0)then begin
	str(wildx*10+wildy,ext);
	ext:='@'+ext;
	{filename:=name+'.@'+ext;}
	end;
chdir(name);
if(save=0)then
	if(exist(name+'.'+ext))then
		filename:=name+'.'+ext
	else begin
		chdir('..');
		chdir('maps');
		if(exist('map.'+ext))then begin
			loadscheme(ext);
			chdir('..');
			checkforguards;
			exit;
			end
		else begin
			chdir('..');newlevel;checkforguards;exit;
			end;
		end
else filename:=name+'.'+ext;
if(wizard)then begin msg('FILENAME: '+filename);more;end;
assign(savefile,filename);
case save of
0:reset(savefile);
1:rewrite(savefile);
end;
at(1,y_map+1);write(what,' map...');clreol;
size:=sizeof(map[1,1]);
for f:=1 to x_map do
for g:=1 to y_map do diskop(@map[f,g],size,save);
size:=sizeof(typemap[1,1]);
for f:=1 to x_map do
for g:=1 to y_map do diskop(@typemap[f,g],size,save);
at(1,y_map+1);write(what,' items...');clreol;
case save of
0:for f:=1 to x_map do
	for g:=1 to y_map do begin
		{if(itmap[f,g]<>nil)then destroylist(itmap[f,g]);}
{		itmap[f,g]:=nil;}
		if(itmap[f,g]<>nil)then msg('BUG REPORT: ITMAP not cleared properly.');
		loadlist(itmap[f,g]);
		end;
1:for f:=1 to x_map do
	for g:=1 to y_map do
		if(itmap[f,g]<>nil)then savelist(itmap[f,g])
			else diskop(@dummy,1,1);
end;
at(1,y_map+1);write(what,' visibility map...');clreol;
size:=sizeof(seemap[1,1]);
for f:=1 to x_map do
for g:=1 to y_map do diskop(@seemap[f,g],size,save);
at(1,y_map+1);write(what,' monsters...');clreol;
size:=sizeof(mon);
case save of
0:for f:=1 to x_map do
	for g:=1 to y_map do begin
		{if(monmap[f,g]^.inv<>nil)then destroylist(monmap[f,g]^.inv);}
		{monmap[f,g]^.inv:=nil;}
		diskop(@n,1,0);
		if(n=0)then begin
			monmap[f,g]^.num:=-1;
			monmap[f,g]^.inv:=nil;
			continue;
			end;
		diskop(monmap[f,g],size,0);
		monmap[f,g]^.inv:=nil;
		loadlist(monmap[f,g]^.inv);
		end;
1:for f:=1 to x_map do
	for g:=1 to y_map do
		if(monmap[f,g]^.num=-1)then diskop(@dummy,1,1)
		else begin
			diskop(@dummy1,1,1);
			monmap[f,g]^.hlt:=fmons[monmap[f,g]^.num]^.hlt;
			diskop(monmap[f,g],size,save);
			if(monmap[f,g]^.inv<>nil)then savelist(monmap[f,g]^.inv)
				else diskop(@dummy,1,1);
			end;
end;




{	diskop(itmap[f,g],sizeof(item),save);
	diskop(@seemap[f,g],sizeof(seemap[f,g]),save);
	diskop(monmap[f,g],sizeof(mon),save);
	end;}
close(savefile);
chdir('..');
checkforguards;
end;

procedure storemons;
var
f,x,y:byte;
begin
for f:=1 to 8 do begin
	floorchange[f]:=monmap[plx+cpmx[f],ply+cpmy[f]]^;
	monmap[plx+cpmx[f],ply+cpmy[f]]^:=emptymon;
	end;
end;

procedure putmons;
var
f,x,y:byte;
begin
for f:=1 to 8 do begin
	if((floorchange[f].num=-1)and(floorchange[f].inv<>nil))then msg('NUG REPORT: Storemons does strange things.');
	if(floorchange[f].num>-1)then begin
		if(monmap[plx+cpmx[f],ply+cpmy[f]]^.inv<>nil)then begin
			destroylist(monmap[plx+cpmx[f],ply+cpmy[f]]^.inv);
			if(wizard)then msg('replacing monster.');
			end;
		monmap[plx+cpmx[f],ply+cpmy[f]]^:=floorchange[f];
		end;
	end;
end;

procedure descend;
var
f:byte;
begin
storemons;
saveloadmap(1);
if(duntype=6)then
	for f:=0 to 5 do
	if(shop[f]^.patro=patro) then begin
		msg('While going down you encounter a shop entrance.');
		more;
		txtbuf:=1;
		visitshop(f);
		end;
inc(patro);
if(duntype>0)then if(patro>maxdeep[duntype])then maxdeep[duntype]:=patro;
if(patro=1)then duntype:=wilddung[wildx,wildy];
saveloadmap(0);
scanforstairs(0);
putmons;
redraw(true);
end;

procedure ascend;
begin
storemons;
saveloadmap(1);
if patro=1 then duntype:=0;
dec(patro);
if(duntype=6)then
	for f:=0 to 5 do
	if(shop[f]^.patro=patro) then begin
		msg('While going up you encounter a shop entrance.');
		more;
		txtbuf:=1;
		visitshop(f);
		end;
saveloadmap(0);
scanforstairs(1);
putmons;
redraw(true);
end;

procedure wildmapdraw;
var
x,y:shortint;
begin
clrscr;
ink(15);
at(3,3);write('The wilderness map:');
ink(8);
for x:=0 to wildsize+1 do begin
	at(x+7,10);write('^');
	at(x+7,wildsize+11);write('^');
	end;
for y:=0 to wildsize+1 do begin
	at(7,y+10);write('^');
	at(wildsize+8,y+10);write('^');
	end;
ink(15);at(40,9);write('Map key:');
for x:=1 to wildsize do
for y:=1 to wildsize do
	if(wildmap[x,y]=1)then begin
		at(x+7,y+10);
		case wilddung[x,y] of
		0:ink(10);
		else ink(14);
		end;
		if(x=wildx)and(y=wildy)then inc(textattr,blink);
		case wilddung[x,y] of
		0:write('.');
		else begin
			write(wilddung[x,y]);
			at(40,wilddung[x,y]+10);ink(14);write(wilddung[x,y],' ');
			ink(7);write(dungname[wilddung[x,y]]);
			end;
		end;
		if(textattr>blink)then dec(textattr,blink);
		end;
{for y:=1 to dungnum do begin
	at(40,y+10);ink(14);write(y,' ');
	ink(7);write(dungname[y]);
	end;}
corner;
zn:=readkey;
redraw(true);
end;







end.
