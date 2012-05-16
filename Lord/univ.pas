unit univ;


interface
uses crt,mycrt,monsters,items,gener,player;

const
sunlight:set of byte = [11,41,42,71];

var
monalarm:boolean;

procedure drawtile(x,y:byte);
procedure redraw(cls:boolean);
procedure see(sight:shortint);
function target(var x,y:shortint;range:byte;uselos:boolean):boolean;
procedure collapse(x,y,radius:shortint);
procedure explode(x1,y1,radius:shortint);
procedure traps;

implementation

procedure drawtile(x,y:byte);
var
cl,subcl:byte;
num:integer;
begin
	at(x,y);
	if(seemap[x,y]>1)or(duntype=0)or((duntype*10+patro)in sunlight)then case map[x,y] of
		99:ink(8);
		2:ink(6);
		3:ink(6);
		5:ink(14);
		6:ink(14);
		8:ink(8);
		9:ink(2);
		10:ink(8);
		12:ink(typemap[x,y]+2);
		13:case (typemap[x,y] mod 10) of
			0:ink(1);
			1:ink(9);
			2:ink(6);
			3:ink(2);
			end;
		end
	else ink(8);
	case map[x,y] of
	0:write(#219);  {#219 plny , #178 sedy}
	1:write('.');
	2:write('/');
	3:write('+');
	4:write(#219);
	5:write('<');
	6:write('>');
	7:write('#');
	8:write('^');
	9:write('*');
	10:write('^');
	11:write('.');
	12:write('^');
	13:write('O');
	99:write(#219);
	end;
	ink(7);
	if(itmap[x,y]<>nil)and(map[x,y]<>8)and(seemap[x,y]=2)then
		begin
		num:=itmap[x,y]^.num;
		cl:=fitems[num]^.class;
		subcl:=fitems[num]^.subclass;
		case cl of
		0:ink(14);
		1:ink(11);
		2..6:case subcl of
			1:ink(6);
			2:ink(7);
			3:ink(15);
			end;
		7,8,9,10:ink(subcl);
		11,12:ink(15);
		13:ink(subcl);
		15,16:case subcl of
			1:ink(8);
			2:ink(6);
			3:ink(7);
			end;
		end;
		at(x,y);write(itsymbol[cl]);
		end;
ink(7);
end;

procedure vislos(x1,y1:shortint);
var
rx,ry,cx,cy:real;
x,y:shortint;
begin
if(plx=x1)and(ply=y1)then exit;
x:=x1-plx;y:=y1-ply;
if(abs(x)>abs(y))then begin
	cx:=sgn(x);
	cy:=y/(abs(x));
	end
else begin
	cx:=x/(abs(y));
	cy:=sgn(y);
	end;
rx:=plx;ry:=ply;
if(cx>0)then rx:=rx-0.1;
if(cy>0)then ry:=ry-0.1;
x:=round(rx);y:=round(ry);
repeat
if(not(pass(x,y)))then exit;
rx:=rx+cx;ry:=ry+cy;
x:=round(rx);y:=round(ry);
seemap[x,y]:=2;
until(x=x1)and(y=y1);
end;

procedure see(sight:shortint);
var
x,y,x1,x2,y1,y2,xx1,xx2,yy1,yy2,stealth:shortint;
num:integer;
begin
ink(5);at(plx,ply);write('@');at(plx,ply);ink(7);
{if(spc[23]>0)then exit;}
monalarm:=false;
if((duntype*10+patro)in sunlight)then inc(sight,5);
getbounds(x1,y1,x2,y2,plx,ply,sight);
getbounds(xx1,yy1,xx2,yy2,plx,ply,sight+1);
{x1:=plx-sight;if(x1<1)then x1:=1;
y1:=ply-sight;if(y1<1)then y1:=1;
x2:=plx+sight;if(x2>x_map)then x2:=x_map;
y2:=ply+sight;if(y2>y_map)then y2:=y_map;
xx1:=plx-sight-1;if(xx1<1)then xx1:=1;
yy1:=ply-sight-1;if(yy1<1)then yy1:=1;
xx2:=plx+sight+1;if(xx2>x_map)then xx2:=x_map;
yy2:=ply+sight+1;if(yy2>y_map)then yy2:=y_map;}
for x:=xx1 to xx2 do
	for y:=yy1 to yy2 do
		if(seemap[x,y]>1)then seemap[x,y]:=1;
if(spc[23]=0)then begin
	seemap[plx,ply]:=2;
	for x:=x1+1 to x2-1 do begin
		vislos(x,y1);
		vislos(x,y2);
		end;
	for y:=y1 to y2 do begin
		vislos(x1,y);
		vislos(x2,y);
		end;
	end;
if(wizard)and(arena)then begin
	for x:=12 to 49 do
	for y:=12 to 29 do
		seemap[x,y]:=2;
	xx1:=12;xx2:=49;
	yy1:=12;yy2:=29;
	end;
for x:=xx1 to xx2 do
for y:=yy1 to yy2 do begin
	if(seemap[x,y]>0)then begin
		num:=monmap[x,y]^.num;
		if(num>-1)and(seemap[x,y]=2)then begin
			oldseemap[x,y]:=0;
			stealth:=ord(testbit(fmons[num]^.spec,13))+ord(testbit(fmons[num]^.spec,14))*2;
			if(random(3)>=stealth)then begin
				{if(fmons[num]^.name[1] in ['A'..'Z'])then paper(1);}
				ink(fmons[num]^.color);
				at(x,y);write(monchar[fmons[num]^.class]);
				if(abs(monmap[x,y]^.mood)<99)and(monmap[x,y]^.align=0)
					then monalarm:=true;
				ink(7);
				resetbit(monmap[x,y]^.flag,1);
				{paper(0);}
				end
			else begin
				drawtile(x,y);
				setbit(monmap[x,y]^.flag,1);
				end;
			end
		else begin
			if(oldseemap[x,y]<>seemap[x,y])then drawtile(x,y);
			oldseemap[x,y]:=seemap[x,y];
			end;
		end;
	end;
oldseemap[plx,ply]:=0;
ink(5);at(plx,ply);write('@');at(plx,ply);ink(7);
end;

procedure redraw(cls:boolean);
var
x,y:byte;
begin
if(cls)then clrscr;
for x:=1 to x_map do
for y:=1 to y_map do begin
	if(seemap[x,y]>0)then drawtile(x,y);
	oldseemap[x,y]:=0;
	end;
printstats;
for x:=1 to msg_num do begin
	at(1,41+x);write(msgtext[x]);clreol;
	end;
{ink(5);at(plx,ply);write('@');at(plx,ply);ink(7);}
see(spc[5]);
end;

function target(var x,y:shortint;range:byte;uselos:boolean):boolean;
var
h,e:integer;
s:string[80];
begin
x:=plx;
y:=ply;
at(1,y_map+1);write('Select target.Press 1-9 to move,SPACE to finish.');
repeat
repeat
if(spc[23]=0)then begin
if(itmap[x,y]<>nil)and(map[x,y]<>8)then
	if(seemap[x,y]=2)then
		case(itemcount(itmap[x,y]))of
		1:msg(pitem(itmap[x,y]^,1,true,true));
		2:begin
			msg(pitem(itmap[x,y]^,1,true,true));
			msg(pitem((itmap[x,y]^.next)^,1,true,true));
			end;
		3:begin
			msg(pitem(itmap[x,y]^,1,true,true));
			msg(pitem((itmap[x,y]^.next)^,1,true,true));
			msg(pitem(((itmap[x,y]^.next)^.next)^,1,true,true));
			end;
		else msg('Some items are lying here.');
		end;
if(monmap[x,y]^.num>-1)and(seemap[x,y]=2)and(not(testbit(monmap[x,y]^.flag,1))) then begin
	s:=pmon(2,1,monmap[x,y]^)+' (';
	if(monmap[x,y]^.align=1)then s:=s+'friendly,';
	case monmap[x,y]^.hlt of
	1:s:=s+'weak,';
	2:s:=s+'healthy,';
	3:s:=s+'strong,';
	4:s:=s+'powerful,';
	5:s:=s+'mighty,';
	6:s:=s+'glowing with power,';
	7:s:=s+'demigod,';
	8:s:=s+'titan,';
	9:s:=s+'divine power,';
	else s:=s+'almost immortal,';
	end;
	if(fmons[monmap[x,y]^.num]^.name[1]in['A'..'Z'])then s[length(s)]:=')'
	else begin
		case monmap[x,y]^.level of
		00..10:s:=s+'averagely';
		11..20:s:=s+'fairly';
		21..30:s:=s+'well';
		31..40:s:=s+'greatly';
		41..50:s:=s+'superbly';
		51..100:s:=s+'BUG';
		end;
		s:=s+' experienced)';
		end;
	if(wizard)and(testbit(monmap[x,y]^.flag,2))then s:=s+' (sleeping)';
	msg(s);
	if(wizard)then write(monmap[x,y]^.tag,' ',monmap[x,y]^.tartag);
	end;
if(seemap[x,y]>0)then
	case map[x,y] of
	2:msg('an open door');
	3:msg('a closed door');
	5:msg('a staircase leading upwards');
	6:msg('a staircase leading downwards');
	7:msg('a column');
	8:msg('rubble');
	10:msg('mountains');
	12:case typemap[x,y] of
		2:msg('a fire trap');
		1:msg('a frost trap');
		3:msg('a teleport trap');
		4:msg('a confusion gas trap');
		5:msg('an explosion trap');
		else msg('BUG REPORT: Unknown trap.');
		end;
	13:msg('a pool');
	end;
end;
at(50,y_map+1);
if(uselos)then begin
	target:=true;
	if(not(los(plx,ply,x,y,true)))then begin
		write('No line of sight.');
		target:=false;
		end;
	clreol;
	end;
at(x,y);
for h:=1 to msg_num do msgtext[h]:='';
txtbuf:=1;
zn:=readkey;
msg('');txtbuf:=1;
until(zn in['1'..'9',' ']);
if(zn in['1'..'9'])then
begin
	val(zn,h,e);
	inc(x,pmx[h]);inc(y,pmy[h]);
	if(x<1)then x:=1;
	if(x>x_map)then x:=x_map;
	if(y<1)then y:=1;
	if(y>y_map)then y:=y_map;

	end;
until(zn=' ');
at(1,y_map+1);clreol;
end;

procedure collapse(x,y,radius:shortint);
var
x1,y1:shortint;
f:word;
m:mon;
begin
for f:=0 to (radius*radius+2*(radius+radius)) do begin
	x1:=random(2*radius+1)+x-radius;
		if(x1<2)then x1:=2;
		if(x1>x_map-1)then x1:=x_map-1;
	y1:=random(2*radius+1)+y-radius;
		if(y1<2)then y1:=2;
		if(y1>y_map-1)then y1:=y_map-1;
	if(map[x1,y1] in [1,2,3])then begin
		if(monmap[x1,y1]^.num>-1)then begin
			m:=monmap[x1,y1]^;
			case att(x1,y1,200,(random(5)*50+50),0,0,true,50) of
			2:if(seemap[x1,y1]=2)then msg(pmon(2,2,m)+' is wounded by the rocks.');
			3:msg(pmon(seemap[x1,y1],2,m)+' screams in agony.');
			end;
			end;
		if(monmap[x1,y1]^.num=-1)then map[x1,y1]:=8;
		oldseemap[x1,y1]:=0;
		end;
	if(map[x1,y1]=0)then map[x1,y1]:=1;
	end;
if(map[plx,ply]=8)then begin
	msg('You are hit by falling rocks.');
	map[plx,ply]:=1;
	deathverb:='crushed';deathreason:='falling rocks';
	wound(random(5)+1);
	end;
redraw(false);
end;

procedure explode(x1,y1,radius:shortint);
var
res,x,y,xa,ya,xb,yb:shortint;
namethe:string[30];
wait:boolean;
begin
wait:=false;
getbounds(xa,ya,xb,yb,x1,y1,radius);
for x:=xa to xb do
for y:=ya to yb do begin
	if(seemap[x,y]=2)then begin
		at(x,y);ink(4+random(2)*8);write('*');
		wait:=true;
		end;
	ink(7);
	if(monmap[x,y]^.num>-1)then begin
		namethe:=pmon(2,2,monmap[x,y]^);
		res:=att(x,y,1,100,100,0,true,ord(seemap[x,y]=2)*40);
		if(seemap[x,y]=2)then begin
			burnscrolls(monmap[x,y]^.inv,false);
			freezepotions(monmap[x,y]^.inv,false);
			case res of
			0,1:msg(namethe+' is unharmed.');
			2:msg(namethe+' is wounded.');
			3:msg(namethe+' is killed.');
			end;
			end;
		end;
	if(x=plx)and(y=ply)then begin
		deathverb:='torn asunder';
		deathreason:='an explosion';
		res:=attplayer(100,100,1,0,true);
		case res of
		0,1:msg('You are not injured.');
		2,3:msg('You are wounded.');
		end;
		burnscrolls(inv,true);
		freezepotions(inv,true);
		end;
	end;
corner;
if(wait)then delay(1000);
if(wizard)then zn:=readkey;
redraw(false);
end;

procedure traps;
var
f:shortint;
begin
case typemap[plx,ply] of
	2:begin
		msg('You trigger a fire trap.');
		burnscrolls(inv,true);
		deathverb:='fried';deathreason:='fire trap';
		attplayer(100,100,1,0,true);
		end;
	1:begin
		msg('You trigger a frost trap.');
		freezepotions(inv,true);
		deathverb:='frozen';deathreason:='frost trap';
		attplayer(100,100,2,0,true);
		end;
	3:begin
		msg('You trigger a teleport trap.');
		f:=spc[23];spc[23]:=1;
		see(spc[5]);
		spc[23]:=f;
		repeat
		plx:=random(x_map)+1;
		ply:=random(y_map)+1;
		until(pass(plx,ply))and(monmap[plx,ply]^.num=-1);
		redraw(false);
		end;
	4:begin
		msg('You trigger a confusion gas trap.');
		raisespc(21,random(20)+10,1);
		end;
	5:begin
		msg('You trigger an explosion trap.');
		explode(plx,ply,2);
		end;
	end;
end;



end.
