unit spells;

interface
uses crt,mycrt,items,gener,player,monsters,univ,dungeons;

procedure readsc;
procedure zap;
procedure cast;
procedure study;


implementation
var
f:shortint;
num:integer;
what:string[6];

procedure identify;
var
which:byte;
whattodo:string[8];
it:itemptr;
begin
if ids[num]<2 then whattodo:='affect' else whattodo:='uncurse';
if(num>0)then
	if ids[num]<2 then it:=selwhich('Using a '+what+'.',what,whattodo,which)
	else it:=selwhich('Using a '+what+' of identify.',what,whattodo,which)
else it:=selwhich('Casting Identify.',what,whattodo,which);
if(it<>nil)then begin
	if(not(it^.id))or(not(it^.curseid))then begin
		if(not(it^.id))then begin
			ids[it^.num]:=2;
			it^.id:=true;
			it^.curseid:=true;
			msg('The item is identified as "'+pitem(it^,1,false,true)+'".');
			ids[num]:=2;
			end;
		if(not(it^.curseid))then begin
			it^.curseid:=true;
			if(it^.curse)then msg('It is cursed.')
				else msg('It is not cursed.');
			end;
		end
	else msg('Nothing happens.');
	end
else msg('The effect is wasted.');
if(fitems[it^.num]^.class=11)then for f:=1 to noofitems-1 do
	if(fitems[f]^.class=11)and(fitems[f]^.subclass=fitems[it^.num]^.subclass)then ids[f]:=ids[it^.num];
redraw(true);
end;

procedure uncurse;
var
it:itemptr;
which:byte;
whattodo:string[7];
begin
if ids[num]<2 then whattodo:='affect' else whattodo:='uncurse';
if(num>0)then
	if ids[num]<2 then it:=selwhich('Using a '+what+'.',what,whattodo,which)
	else it:=selwhich('Using a '+what+' of remove curse.',what,whattodo,which)
else it:=selwhich('Casting Remove Curse.',what,whattodo,which);
if(it<>nil)then begin
	if(it^.curse=true)then begin
		it^.curse:=false;
		msg('It glows for a moment.');
		ids[num]:=2;
		end
	else msg('Nothing happens.');
	end
else msg('The effect is wasted.');
redraw(true);
end;

procedure magicmap;
var
x,y,x1,y1,x2,y2:shortint;
begin
x:=plx;y:=ply;
x1:=x-15;if x1<1 then x1:=1;
y1:=y-15;if y1<1 then y1:=1;
x2:=x+15;if x2>x_map then x2:=x_map;
y2:=y+15;if y2>y_map then y2:=y_map;
for x:=x1 to x2 do
for y:=y1 to y2 do seemap[x,y]:=1;
redraw(true);
msg('You sense rooms and tunnels around you!');
ids[num]:=2;
end;

procedure itemdest;
var
it:itemptr;
which:byte;
whattodo:string[7];
begin
if ids[num]<2 then whattodo:='affect' else whattodo:='uncurse';
if(num>0)then
	if ids[num]<2 then it:=selwhich('Using a '+what+'.',what,whattodo,which)
	else it:=selwhich('Using a '+what+' of item destruction.',what,whattodo,which)
else it:=selwhich('Casting Item destruction.',what,whattodo,which);
if(it<>nil)then begin
	if(fitems[it^.num]^.rarity=10) then begin
		msg('You sense some destructive energy.');
		ids[num]:=2;
		end
	else begin
		if(which=0)then it^.num:=-1
		else takeaway(inv,it);
		msg('It crumbles to pieces.');
		ids[num]:=2;
		end
	end
else msg('The effect is wasted.');
redraw(true);
end;

procedure smallquake;
var
x,y:shortint;
begin
redraw(true);
see(spc[5]);
x:=plx;y:=ply;
msg('Select the central spot.');
target(x,y,10,false);
msg('The ground shakes.');
if(duntype<>0)and((duntype<>4)or(patro<>1))then collapse(x,y,4);
ids[num]:=2;
end;

procedure bigquake;
begin
redraw(true);
if(duntype=0)or((duntype=4)and(patro=1))then begin
	msg('The ground shakes strongly.');
	exit;
	end;
msg('The whole dungeon shakes strongly.');
collapse(x_map div 2,y_map div 2,30);
ids[num]:=2;
end;

procedure magicmis;
var
power,x,y,res:shortint;
m:mon;
begin
redraw(true);
see(spc[5]);
at(plx,ply);ink(5);write('@');ink(7);
if(ids[num]=2)then msg('Casting Magic Missile.');
ids[num]:=2;
power:=50;if(num=0)then power:=explev+20;
if(not(target(x,y,spc[5],true)))or(seemap[x,y]<2)then begin
	msg('You cannot see there.');
	exit;
	end;
if(x=plx)and(y=ply)then begin
	msg('A magic missile zaps you.');
	deathverb:='killed';deathreason:='a magic missile';
	attplayer(100,power,0,0,true);
	exit;
	end;
if(not(pass(x,y)))or(monmap[x,y]^.num=-1)then begin
	msg('The missile hits nothing.');
	exit;
	end;
m:=monmap[x,y]^;
res:=att(x,y,0,atrib[1]*4,power,0,false,100);
case res of
0:msg('The missile misses.');
1:msg('The missile hits '+pmon(2,2,m)+' but causes no wound.');
2:msg('The missile injures '+pmon(2,2,m)+'.');
3:msg('The missile kills '+pmon(2,2,m)+'.');
end;
end;

procedure bolt(n:byte);
var
elem,power,x,y,res:shortint;
m:mon;
bolttype:string[9];
begin
case n of
0:bolttype:='fire';
1:bolttype:='frost';
2:bolttype:='lightning';
end;
redraw(true);
see(spc[5]);
at(plx,ply);ink(5);write('@');ink(7);
if(ids[num]=2)then msg('Casting '+bolttype+' bolt.');
ids[num]:=2;
power:=80;if(num=0)then power:=explev*3;
if(not(target(x,y,spc[5],true)))or(seemap[x,y]<2)then begin
	msg('You cannot see there.');
	exit;
	end;
if(x=plx)and(y=ply)then begin
	msg('A '+bolttype+' bolt zaps you.');
	deathverb:='killed';deathreason:=bolttype+' bolt';
	attplayer(100,power,0,0,true);
	exit;
	end;
if(not(pass(x,y)))or(monmap[x,y]^.num=-1)then begin
	msg('The bolt hits nothing.');
	exit;
	end;
m:=monmap[x,y]^;
res:=att(x,y,n+1,atrib[1]*4,power,0,false,100);
case res of
0:msg('The '+bolttype+' bolt misses.');
1:msg('The '+bolttype+' bolt hits '+pmon(2,2,m)+' but causes no wound.');
2:msg('The '+bolttype+' bolt injures '+pmon(2,2,m)+'.');
3:msg('The '+bolttype+' bolt kills '+pmon(2,2,m)+'.');
5:msg(pmon(2,2,m)+' seems to be immune.');
end;
end;

procedure brainburn;
var
power,x,y,res:shortint;
m:mon;
begin
redraw(true);
see(spc[5]);
at(plx,ply);ink(5);write('@');ink(7);
if(ids[num]=2)then msg('Casting brainburn.');
power:=15;if(num=0)then power:=atrib[2];
if(not(target(x,y,spc[5],true)))or(seemap[x,y]<2)then begin
	msg('You cannot see there.');
	exit;
	end;
if(x=plx)and(y=ply)then begin
	msg('Your brain is burning with pain.');
	deathverb:='killed';deathreason:='burning his brain';
	attplayer(100,power+atrib[2],0,0,true);
	ids[num]:=2;
	exit;
	end;
if(not(pass(x,y)))or(monmap[x,y]^.num=-1)then begin
	msg('The effect is wasted.');
	ids[num]:=1;
	exit;
	end;
ids[num]:=2;
m:=monmap[x,y]^;
res:=att(x,y,10,150,power+(fmons[m.num]^.int)*6,0,false,100);
if(res=0)then res:=1;
case res of
1:msg('The brainburn causes no wound to '+pmon(2,2,m)+'.');
2:msg('The brainburn injures '+pmon(2,2,m)+'.');
3:msg('The brainburn kills '+pmon(2,2,m)+'.');
end;
end;

procedure minorcure;
begin
redraw(true);
if(hlt=orighlt)then begin
	msg('Nothing happens.');
	exit;
	end;
msg('You feel slightly better.');
inc(hlt);
ids[num]:=2;
end;

procedure maxcure;
begin
redraw(true);
if(hlt=orighlt)then begin
	msg('Nothing happens.');
	exit;
	end;
msg('You feel much better.');
hlt:=orighlt;
ids[num]:=2;
end;

procedure astralportal;
begin
if(patro=0)then
	if(wilddung[wildx,wildy]=0)then begin
		msg('The scroll crumbles to dust.');
		redraw(true);
		exit;
		end
	else begin
		msg('You are pulled downwards.');
		duntype:=wilddung[wildx,wildy];
		patro:=maxdeep[wilddung[wildx,wildy]]-1;
{		map[plx,ply]:=6;}
		descend;
		ids[num]:=2;
		exit;
		end;
msg('You are pulled upwards.');
patro:=1;
{map[plx,ply]:=5;}
ascend;
ids[num]:=2;
end;

procedure satiation;
begin
redraw(true);
if(status[3]=4)then begin
	deathverb:='killed';deathreason:='eating too much magic food';
	wound(20);
	exit;
	end;
msg('You are magically satiated.');
ids[num]:=2;
inc(origspc[19],2000);
end;

procedure confusion;
var
power,x,y,res:shortint;
m:mon;
begin
redraw(true);
see(spc[5]);
at(plx,ply);ink(5);write('@');ink(7);
if(ids[num]=2)then msg('Casting confusion.');
power:=15;if(num=0)then power:=atrib[2];
x:=direct;
y:=ply+pmy[x];
x:=plx+pmx[x];
{if(not(target(x,y,spc[5],true)))or(seemap[x,y]<2)then begin
	msg('You cannot see there.');
	exit;
	end;}
if(x=plx)and(y=ply)then begin
	raisespc(21,random(4)+2,1);
	ids[num]:=2;
	exit;
	end;
if(not(pass(x,y)))or(monmap[x,y]^.num=-1)then begin
	msg('The effect is wasted.');
	ids[num]:=1;
	exit;
	end;
ids[num]:=2;
m:=monmap[x,y]^;
power:=atrib[2]-fmons[m.num]^.int+random(5);
if(power>40)then power:=40;
att(x,y,0,0,0,0,true,100);
if(power<1)then begin
	msg(pmon(2,2,m)+' resists.');
	exit;
	end;
if(monmap[x,y]^.mood<0)then monmap[x,y]^.mood:=0;
inc(monmap[x,y]^.mood,power);
msg(pmon(2,2,m)+' is confused.');
end;

procedure manashort;
var
x,y,x1,x2,y1,y2:shortint;
nm:integer;
begin
redraw(true);
x1:=plx-4;if(x1<1)then x1:=1;
x2:=plx+4;if(x2>x_map)then x2:=x_map;
y1:=ply-4;if(y1<1)then y1:=1;
y2:=ply+4;if(y2>y_map)then y2:=y_map;
for x:=x1 to x2 do
for y:=y1 to y2 do begin
	nm:=monmap[x,y]^.num;
	if(nm>-1)and(monmap[x,y]^.sp>0)and(testbit(fmons[nm]^.spec,0))then begin
		monmap[x,y]^.sp:=0;
		if(seemap[x,y]=2)then begin
			msg(pmon(2,2,monmap[x,y]^)+' seems to be exhausted.');
			ids[num]:=2;
			end;
		end;
	end;
if(spl>0)then begin
	spl:=0;
	ids[num]:=2;
	msg('You magic is drained away!');
	end;
end;

procedure aura;
begin
redraw(true);
if(num=0)then raisespc(3,explev*3,20)
	else raisespc(3,80,20);
ids[num]:=2;
end;

procedure shroudofdeath;
var
x,y,x1,x2,y1,y2:shortint;
hl:integer;
begin
redraw(true);
getbounds(x1,y1,x2,y2,plx,ply,4);
{x1:=plx-4;if(x1<1)then x1:=1;
x2:=plx+4;if(x2>x_map)then x2:=x_map;
y1:=ply-4;if(y1<1)then y1:=1;
y2:=ply+4;if(y2>y_map)then y2:=y_map;}
msg('You feel the presence of some strange force.');
for x:=x1 to x2 do
for y:=y1 to y2 do begin
	if(monmap[x,y]^.num=-1)then continue;
	hl:=monmap[x,y]^.hlt;
	if(random(100)<90)then dec(monmap[x,y]^.hlt);
	if(random(100)<65)then dec(monmap[x,y]^.hlt);
	if(random(100)<40)then dec(monmap[x,y]^.hlt);
	if(random(100)<15)then dec(monmap[x,y]^.hlt);
	if(monmap[x,y]^.hlt<1)then begin
		msg(pmon(seemap[x,y],2,monmap[x,y]^)+' dies in great pain.');
		kill(x,y,100);
		ids[num]:=2;
		end
	else if(hl<>monmap[x,y]^.hlt)and(seemap[x,y]=2)then begin
		msg(pmon(2,2,monmap[x,y]^)+' is injured by some mystic force.');
		ids[num]:=2;
		end;
	end;
if(random(10)=0)then raisespc(random(4)+8,0,-1);
end;

procedure recharge;
var
it:itemptr;
begin
if(ids[num]=2)then it:=itemsel(inv,12,'wand','recharge',-1)
	else it:=itemsel(inv,12,'item','affect',-1);
redraw(true);
if(it=nil)then begin
	msg('The effect is wasted.');
	exit;
	end;
if(random(20)<it^.mb)then begin
	if(ids[num]<2)then msg('The spell fails.')
		else msg('You fail to charge the wand.');
	exit;
	end;
msg('The wand is charged.');
if(num=0)then inc(it^.mb,(spellskill[19]div 20)+1+random(3))
	else inc(it^.mb,3+random(3));
ids[num]:=2;
end;

procedure invoke(spell:byte);
begin
case spell of
0:magicmis;
1:smallquake;
2:magicmap;
3:itemdest;
4:minorcure;
5:uncurse;
6:confusion;
7..9:bolt(spell-7);
10:maxcure;
11:satiation;
12:identify;
13:bigquake;
14:brainburn;
15:astralportal;
16:manashort;
17:aura;
18:shroudofdeath;
19:recharge;
end;
end;

procedure readsc;
var
spell,sel:byte;
it:itemptr;
f:word;
begin
if(spc[23]>0)then begin
	msg('You cannot read while blinded.');
	exit;
	end;
if(spc[21]>0)then begin
	msg('Your cannot concentrate on reading.');
	exit;
	end;
it:=itemsel(inv,11,'scroll','read',-1);
if(it=nil)then begin redraw(true);exit;end;
num:=it^.num;
spell:=fitems[num]^.subclass;
takeaway(inv,it);
what:='scroll';
invoke(spell);
if(ids[num]=0)then ids[num]:=1;
for f:=1 to noofitems-1 do
	if(fitems[f]^.class=11)and(fitems[f]^.subclass=spell)then ids[f]:=ids[num];
if(random(100)<(atrib[2]*4))and(ids[num]=2)then
	if random(100)>=spellskill[spell] then inc(spellskill[spell],random(align[2])+1);
dec(move,100);
end;


procedure zap;
var
spell,sel:byte;
it:itemptr;
begin
it:=itemsel(inv,12,'wand','zap',-1);
if(it=nil)then begin redraw(true);exit;end;
num:=it^.num;
spell:=fitems[num]^.subclass;
if(it^.mb=0)then begin
	msg('Nothing happens.');
	if(ids[num]=0)then ids[num]:=1;
	if(ids[num]=2)then it^.id:=true;
	redraw(true);
	exit;
	end;
dec(it^.mb);
what:='wand';
invoke(spell);
if(ids[num]=0)then ids[num]:=1;
if(ids[num]=2)and(it^.id)and(it^.mb=0)then msg('This was the last charge.');
dec(move,100);
end;

procedure cast;
var
sel,cost:byte;
begin
if(spc[21]>0)then begin
	msg('You are unable to concentrate.');
	exit;
	end;
if(spl=0)then begin msg('Not enough MP.');exit;end;
clrscr;ink(15);
at(2,2);write('Known spells:');
for f:=0 to spellnum do
	if spellskill[f]>0 then begin
		cost:=spellcost[f]+3-(spellskill[f]div 30);	{also change below}
		at(2,f+4);ink(14);write(chr(97+f),') ');
		ink(7);write(spellname[f],': ',scale100(spellskill[f]div 10),
			' - ',cost,' MP');
		end;
corner;
select(spellnum+1,1,sel);
if(sel=99)then begin redraw(true);exit;end;
if(spellskill[sel]=0)then begin redraw(true);msg('You don''t know that spell');exit;end;
cost:=spellcost[sel]+3-(spellskill[sel]div 30);	{also change above}
if(spl<cost)then begin redraw(true);msg('Not enough MP.');exit;end;
dec(move,100);
if(random(100)>=spellskill[sel])then begin
	if(random(25)<atrib[2])then inc(spellskill[sel]);
	redraw(true);
	msg('You fail to cast the spell.');
	dec(spl,cost);
	exit;
	end;
num:=0;what:='spell';
invoke(sel);
dec(spl,cost);
if random(22)<(atrib[2]) then
	if random(100)>=spellskill[sel] then inc(spellskill[sel],random(align[2])+1);
end;

procedure study;
var
spell,sel,prev:byte;
num:integer;
it:itemptr;
res:string[80];
begin
it:=itemsel(inv,11,'scroll','memorize',-1);
if(it=nil)then begin redraw(true);exit;end;
num:=it^.num;
if(ids[num]<2)then begin
	redraw(true);
	msg('You have no idea what this scroll does.');
	exit;
	end;
spell:=fitems[num]^.subclass;
if(spell>spellnum)then begin
	redraw(true);
	msg('You are unable to concentrate on this glyph.');
	exit;
	end;
prev:=spellskill[spell]div 10;
num:=(100-spellskill[spell])div 5;
num:=(num*align[2]*atrib[2])div 100;
if(pos('rune',fitems[it^.num]^.name1)=0)then num:=num div 5;
takeaway(inv,it);
inc(spellskill[spell],num);
if(spellskill[spell]>100)then spellskill[spell]:=100;
redraw(true);
if(num=0)then res:='You are not able to memorize anything'
else if(spellskill[spell]div 10=prev)then res:='You improve your skill a bit'
	else res:='Your skill is now '+scale100(spellskill[spell]div 10);
while(res[length(res)]=' ') do delete(res,length(res),1);
res:=res+'.';
msg(res);
dec(move,200);
end;




end.
