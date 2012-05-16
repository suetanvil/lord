unit monsters;

interface
uses items,crt,mycrt,player,gener;

type
mon=record
	num:integer;
	hlt:shortint;
	mood:shortint;
	inv:itemptr;
	speed:integer;
	sp:shortint;
	flag:byte;
	align:byte;	{0=enemy,align_companion=companion}
	tag:byte;
	tartag:byte;    {0-player,1-250-monster}
	lx,ly:shortint;	{last x,last y,last movetype}
	level:byte;
	end;
filemonster=record
		name:string[35];
		class:byte;
		athit:shortint;
		atdam:shortint;
		def:shortint;
		color:byte;
		rarity:shortint;
		inv:integer;
		speed:integer;
		spec:word;
		spec2:word;
		hlt:byte;
		int:byte;
		mood:shortint;
		spell:word;
		end;

const
emptymon:mon = (num:-1; hlt:0; mood:0; inv:nil; speed:0; sp:0; flag:0);
align_companion = 1;
maxmons = 150;
var
noofmons,oldnoofmons:byte;
fmons,oldfmons:array[0..maxmons] of ^filemonster;
monmap:array[1..x_map,1..y_map]of ^mon;
lasttag:byte;
guardedlevel:boolean;

procedure initmonsters(filename:string;clearmonmap:boolean);
procedure donemonsters(clearmonmap:boolean);
procedure storefmons;
procedure backfmons;
procedure randommon(num:shortint;filter,rarity:byte;var m:mon);
procedure kill(x,y,perc:byte);
procedure donearena;
procedure angryguards(atttag:byte;cx,cy:shortint);
function attplayer(hit,dam,elem:shortint;atttag:byte;guard:boolean):byte;
function att(x,y,elem:byte;hit,dam:integer;atttag:byte;guard:boolean;perc:byte):byte;
function pmon(vis,art:shortint;m:mon):string;
procedure butcher;
function los(x1,y1,x2,y2:shortint;usemons:boolean):boolean; {line of sight}

implementation
var
zn:char;

procedure initmonsters(filename:string;clearmonmap:boolean);
var
monfile:file of filemonster;
f,g:integer;
begin
assign(monfile,filename);
reset(monfile);
f:=0;
repeat
new(fmons[f]);
read(monfile,fmons[f]^);
inc(f);
until(eof(monfile));
close(monfile);
noofmons:=f;
if(not(clearmonmap))then exit;
for f:=1 to x_map do
for g:=1 to y_map do begin
	new(monmap[f,g]);
	monmap[f,g]^.num:=-1;
	monmap[f,g]^.inv:=nil;
	end;
lasttag:=1;
end;

procedure donemonsters(clearmonmap:boolean);
var
f,g:word;
begin
for f:=0 to noofmons-1 do
	dispose(fmons[f]);
if(not(clearmonmap))then exit;
for f:=1 to x_map do
for g:=1 to y_map do
	dispose(monmap[f,g]);
end;

procedure storefmons;
var
f:word;
begin
for f:=0 to maxmons do
	oldfmons[f]:=fmons[f];
oldnoofmons:=noofmons;
end;

procedure backfmons;
var
f:word;
begin
for f:=0 to maxmons do
	fmons[f]:=oldfmons[f];
noofmons:=oldnoofmons;
end;

procedure randommon(num:shortint;filter,rarity:byte;var m:mon);
var
f,r,n,cl,count:byte;
inn:array[0..3]of integer;
inf,ir:array[0..3]of shortint;	{inv number,filter,rarity}
rar:integer;
fm:filemonster;
it:item;
begin
count:=0;
if num=-1 then
	repeat
	if count=200 then rarity:=255;
	n:=random(noofmons);
	cl:=fmons[n]^.class;
	rar:=fmons[n]^.rarity;
	inc(count);
	until((cl=filter)or(filter=99))and((abs(rar-rarity)<4)or(rarity=255))and(rar>-1)
else n:=num;
fm:=fmons[n]^;
{if fm.rarity=-1 then fmons[n].rarity:=-99;}
m.num:=n;
m.hlt:=fm.hlt;
m.mood:=fm.mood;
m.inv:=nil;
{m.inv.num:=0;}
it.num:=-1;
if(arena)then fm.inv:=-999;
if(fm.inv>-1)then randomitem(fm.inv,99,3,50,it);
if(fm.inv>-500)and(fm.inv<0)then
	if(fm.inv>-100)then randomitem(-1,-fm.inv,(fm.rarity div 40)+1,50,it)
	else begin
		randomitem(find(-fm.inv),99,255,50,it);
{		at(1,50);write('mongen - cl ',cl,' r ',r,' n ',n);zn:=readkey;}
		end;
if(it.num>-1)then if(fitems[it.num]^.rarity<4)and(fitems[it.num]^.class<>15)then
	case(random(10))of
	0,1:if(fm.inv>-999)and(fm.int>2)then it.num:=0;
	2..8:it.num:=-1;
	end;
if(fm.inv=-999)then it.num:=-1;
if(it.num=0)then begin
	{it.mb:=(random(fm.rarity)+1)*10;
	it.id:=true;
	it.curse:=false;
	it.q:=1;}
	randomitem(0,99,(patro div(maindepth div 2))+1,50,it);
	end;
if(it.num>-1)and(not(arena))then itemsortinto(m.inv,it);
if(fm.inv>-999)and(fm.inv<-500)then begin
	for f:=0 to 3 do begin
		inn[f]:=-1;inf[f]:=99;ir[f]:=1;
		end;
	n:=abs(fm.inv)-500;
	case n of
	1..3:begin
		inf[0]:=1;
		inf[1]:=2;
		inf[2]:=3;
		inf[3]:=random(2)+5;
		ir[0]:=n;ir[1]:=n;ir[2]:=n;ir[3]:=n;
		end;
	4:begin
		inf[0]:=1;ir[0]:=1;
		end;
	5,6:begin
		inn[0]:=150+n-4;
		inn[1]:=160+n-4;
{		writeln('FIND BOW n=',n,' ',find(inn[0]),' ',find(inn[1]));}
		end;
	end;
	for f:=0 to 3 do
		if((inf[f]<99)or(inn[f]>-1))and((random(5)=0)or(n in [5,6]))then begin
			randomitem(find(inn[f]),inf[f],ir[f],50,it);
			itemsortinto(m.inv,it);
			end;
	{if(n in[5,6])then itemsel(m.inv,99,'item','bowman',-1);}
	end;
m.speed:=fm.speed;
m.sp:=(fm.int div 2);
m.align:=0;
m.tag:=lasttag;
inc(lasttag);
if(lasttag=250)then lasttag:=1;
m.tartag:=255;
m.level:=1;
while(random(100)>atrib[5])and(m.level<50)do
	inc(m.level,5);
if(m.level>50)then m.level:=50;
if(fm.rarity<1)then m.level:=1;
if(abs(fm.mood)=0)then m.flag:=4
	else m.flag:=0;
if(testbit(fm.spec2,5))then m.flag:=64;
if(fitems[equip[4].num]^.spec=27)and(equip[4].mb=fm.class)then
	msg('Your weapon gleams for a moment.');
if(wizard)then msg('NEW MONSTER:'+fm.name);
end;

function exper(n:byte):word;
var
f:byte;
fm:filemonster;
xp:real;
begin
fm:=fmons[n]^;
xp:=0;
{xp:=(fm.athit/20)*(fm.atdam/20)*(fm.def/20);}
xp:=(sqrt(fm.athit)*sqrt(fm.atdam)*sqrt(fm.def))/15;
xp:=xp+(fm.speed/20)-5;
if(fm.athit>80)then xp:=xp+2;
if(fm.atdam>80)then xp:=xp+2;
if(fm.def>80)then xp:=xp+2;
xp:=xp*((9+fm.hlt)/10);
for f:=0 to 15 do
	if(testbit(fm.spec,f))then xp:=xp*1.1;
for f:=0 to 15 do
	if(testbit(fm.spec2,f))then xp:=xp*1.1;
if(testbit(fm.spec,0))then
	for f:=0 to 15 do
		if(testbit(fm.spell,f))then xp:=xp*1.4;
if(xp<1)then xp:=1;
if(xp>10000)then xp:=10000;
exper:=round(xp);
end;

procedure donearena;
var
x,y:shortint;
begin
donemonsters(false);
backfmons;
plx:=14;
ply:=y_map-7;
monmap[14,y_map-9]^.num:=33;
arena:=false;
for x:=12 to (x_map-11) do
for y:=12 to (y_map-11) do begin
	gotoxy(x,y);write('.');
	end;
inc(movecount,20001-(movecount mod 20000));
end;

procedure checkarenaend;
var
x,y:shortint;
endarena:boolean;
begin
endarena:=true;
for x:=12 to (x_map-11) do
for y:=12 to (y_map-11) do
	if(monmap[x,y]^.num<>-1)then endarena:=false;
if(not(endarena))then exit;
donearena;
msg('*GREAT! YOU WON THE PRIZE AND ARE PROCLAIMED THE CHAMPION!');
more;
inc(goldown,15000);
end;

procedure kill(x,y,perc:byte);
var
cur:itemptr;
bonus,xp:word;
begin
if(monmap[x,y]^.num=-1)then begin
	msg('BUG REPORT: Trying to kill a nonexisting monster.');
	exit;
	end;
if(monmap[x,y]^.align=align_companion)then msg('You hear a familiar voice screaming in pain.');
if(fmons[monmap[x,y]^.num]^.rarity<0)and(fmons[monmap[x,y]^.num]^.name[1]in ['A'..'Z'])
	then fmons[monmap[x,y]^.num]^.rarity:=-99;
xp:=(exper(monmap[x,y]^.num)*perc)div 100;
inc(expr,xp);
if(vdata[0]=1)and(abs(fmons[monmap[x,y]^.num]^.mood)<>99)then begin
	bonus:=round((xp/nextlev)*100);
	inc(vdata[1],bonus);
	if(vdata[1]>30000)then vdata[1]:=30000;
	end;
if(abs(fmons[monmap[x,y]^.num]^.mood)=99)and(random(2)=0)then begin
	if(not(wizard))then raisespc(12,0,-1)
		else msg('Friendly monster killed.');
	recompute;
	end;
if(monmap[x,y]^.num=27)then vdata[2]:=2;	{Ratman}
monmap[x,y]^.num:=-1;
if(monmap[x,y]^.inv<>nil)then begin
	cur:=monmap[x,y]^.inv;
	repeat
	itemsortinto(itmap[x,y],cur^);
	cur^.q:=1;
	takeaway(monmap[x,y]^.inv,cur);
	cur:=cur^.next;
	until(cur=nil);
	if(monmap[x,y]^.inv<>nil)then begin
		msg('BUG REPORT: Monster inventory not cleared properly.');
		if(iyesorno('Attempt to clear it?'))then destroylist(monmap[x,y]^.inv);
		end;
	end;
if(arena)and(perc=100)then checkarenaend;
end;

procedure angryall;
var
x,y:shortint;
begin
for x:=1 to x_map do
for y:=1 to y_map do
if(abs(monmap[x,y]^.mood)=99)then monmap[x,y]^.mood:=0;
msg('You hear angry screams from all directions!');
end;

procedure angryguards(atttag:byte;cx,cy:shortint);
var
x,y,x1,x2,y1,y2:shortint;
begin
if(wizard)then msg('angryguards');
getbounds(x1,y1,x2,y2,cx,cy,5);
for x:=x1 to x2 do
for y:=y1 to y2 do
if(monmap[x,y]^.num>-1)then
	if(testbit(fmons[monmap[x,y]^.num]^.spec2,6))and(abs(monmap[x,y]^.mood)=99)
	and(los(x,y,cx,cy,false))then begin
		if(wizard)then begin at(x,y);write('*');end;
		monmap[x,y]^.mood:=0;
		monmap[x,y]^.tartag:=atttag;
		if(atttag=0)then resetbit(monmap[x,y]^.flag,6);
		if(atttag=0)and(wizard)then msg('no friend');
		end;
end;

function attplayer(hit,dam,elem:shortint;atttag:byte;guard:boolean):byte;
var
ht,dm:integer;
injury,res:byte;
xx1,yy1,xx2,yy2,x,y:shortint;
begin
if(guardedlevel)and(not(guard))then angryguards(atttag,plx,ply);
getbounds(xx1,yy1,xx2,yy2,plx,ply,3);
for x:=xx1 to xx2 do
for y:=yy1 to yy2 do
	if(monmap[x,y]^.align=align_companion)and((monmap[x,y]^.tartag=0)or(random(2)=0))then
		monmap[x,y]^.tartag:=atttag;
res:=1;
if(elem>0)then res:=spc[14+elem]+spc[18];
dam:=dam-(res*10);
ht:=random(101-hit)+hit;
if random(10)=0 then inc(ht,50);
if(dam>0)then dm:=random(101-dam)+dam else dm:=0;
if random(10)=0 then inc(dm,50);
dec(dm,res div 2);
if((spc[4]div 2)>=ht) then begin
	attplayer:=0;
	exit;
	end;
if(dm<=spc[3]) then attplayer:=1
else begin
	injury:=1;
	if((dm-spc[3])>50)then injury:=2;
	wound(injury);
	attplayer:=2;
	end;
{if(elem=1)then burnscrolls(inv,true);
if(elem=2)then freezepotions(inv,true);}
end;

function att(x,y,elem:byte;hit,dam:integer;atttag:byte;guard:boolean;perc:byte):byte;
var
fm:filemonster;
injury,monelem:byte;
xx1,yy1,xx2,yy2,xx,yy:shortint;
ht,dm:integer;
begin
if(guardedlevel)and(not(guard))then angryguards(atttag,x,y);
if(abs(monmap[x,y]^.mood)=99)then begin
	monmap[x,y]^.mood:=0;
	if(testbit(fmons[monmap[x,y]^.num]^.spec2,2))then angryall;
	end;
getbounds(xx1,yy1,xx2,yy2,x,y,3);
if(not(guard))then
for xx:=xx1 to xx2 do
for yy:=yy1 to yy2 do
	if(monmap[xx,yy]^.num>-1)then
		if(monmap[xx,yy]^.align=monmap[x,y]^.align)and(random(2)=0)then
			monmap[xx,yy]^.tartag:=atttag;
if(elem=0)and(hit=0)and(dam=0)then exit;
if(testbit(monmap[x,y]^.flag,2))then resetbit(monmap[x,y]^.flag,2);
if(testbit(monmap[x,y]^.flag,6))then resetbit(monmap[x,y]^.flag,6);
fm:=fmons[monmap[x,y]^.num]^;
monelem:=ord(testbit(fm.spec,1))+ord(testbit(fm.spec,2))*2;
if((elem=1)and(monelem=2))or((elem=2)and(monelem=1))then dam:=dam*2;
if(elem=10)then fm.def:=1;	{mental attack}
ht:=random(101-hit)+hit;
if(random(100)<(atrib[5]div 10))then inc(ht,50);
if(dam<100)then dm:=random(101-dam)+dam else dm:=100;
if(elem=monelem)and(elem<>0)then dm:=-1;
if(random(100)<(atrib[5]div 10))and(dm<>-1)then inc(dm,50);
if((fm.speed div 2)>=ht) then begin
	att:=0;
	exit;
	end;
{if(dm=-1)then begin att:=5;exit;end;}
if(dm=-1)then
	if(random(4)=0)then dm:=random(100)+1
		else dm:=random(50)+1;
if(dm<=fm.def)then att:=1
else begin
	injury:=1;
	while((dm-fm.def)>50)do begin
		inc(injury);
		dec(dm,50);
		end;
	dec(monmap[x,y]^.hlt,injury);
	if(monmap[x,y]^.hlt<1)then begin
		kill(x,y,perc);
		att:=3;
		end
	else att:=2;
	end;
end;

function pmon(vis,art:shortint;m:mon):string;
var
name:string[40];
begin
name:=fmons[m.num]^.name;
if(name[1]=upcase(name[1]))then art:=0;
if(art=1)then
	if(name[1] in ['a','e','i','o','u'])then name:='an '+name
	else name:='a '+name;
if(art=2)then name:='the '+name;
if(vis<2)then name:='something';
pmon:=name;
end;

procedure butcher;
var
x,y:byte;
begin
for x:=1 to x_map do
for y:=1 to y_map do
	if(monmap[x,y]^.num>-1)then kill(x,y,0);
end;

function los(x1,y1,x2,y2:shortint;usemons:boolean):boolean;
var
rx,ry,cx,cy:real;
x,y:shortint;
begin
{if(wizard)then begin at(1,25);write('los ',x1,' ',y1,' ',x2,' ',y2);end;}
los:=true;
if(x1=x2)and(y1=y2)then exit;
x:=x2-x1;y:=y2-y1;
if(abs(x)>abs(y))then begin
	cx:=sgn(x);
	cy:=y/(abs(x));
	end
else begin
	cx:=x/(abs(y));
	cy:=sgn(y);
	end;
rx:=x1;ry:=y1;
if(cx>0)then rx:=rx-0.1;
if(cy>0)then ry:=ry-0.1;
x:=round(rx);y:=round(ry);
repeat
if(not(pass(x,y)))or((monmap[x,y]^.num>-1)and(usemons)and(x<>x1)and(y<>y1))then los:=false;
rx:=rx+cx;ry:=ry+cy;
x:=round(rx);y:=round(ry);
until(x=x2)and(y=y2);
end;



end.