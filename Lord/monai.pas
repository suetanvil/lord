unit monai;


interface
uses crt,mycrt,monsters,items,player,gener,montalk,univ;


function movemons:boolean;
procedure speedmons;
function domoves(n:byte;action:string):boolean;
procedure doturn;

implementation

{ ****************************************** }
{ * promenne a procedury pro pohyb monster * }
{ ****************************************** }

var
fm:filemonster;
m:mon;
sight,speed,x1,y1,x2,y2,tx,ty,mood,range,movetype,elem:shortint;
mrar,victimspeed:integer;
isguard,notdoorpass,bard,regen,pals,caster,ranged,rangedpos,blink,thiefi,thiefg:boolean;
pickmis,reinf:boolean;
namea,namethe:string[40];
moveit:array[1..x_map,1..y_map]of byte;
cur,invptr,iptr:itemptr;

procedure steal;
var
what:byte;
num:integer;
from:string[11];
it:itemptr;
itm:item;
begin
angryguards(m.tag,plx,ply);
from:='money pouch';what:=0;
if((thiefi)or(goldown=0))and(itemcount(inv)>0)then begin from:='backpack';what:=1;end;
msg(namethe+' tries to steal from your '+from+'.');
if(random(20+(mrar div 10))<atrib[1])then begin
	msg('You quickly protect it.');
	exit;
	end;
setbit(m.flag,0);
num:=random(fm.rarity*10)+1;
if(num<1)or(num>500)then num:=random(500)+1;
if(num>goldown)then num:=goldown;
if(what=1)then num:=random(itemcount(inv))+1;
if(what=0)then begin
	str(num,from);
	msg(from+' gp was stolen.');
	dec(goldown,num);
	if(m.inv=nil)or(m.inv^.num<>0)then begin
		randomitem(0,0,0,50,itm);
		itm.mb:=num;
		itemsortinto(m.inv,itm);
		end
	else inc(m.inv^.mb,num);
	exit;
	end;
it:=itemget(inv,num);
itm:=it^;
itm.q:=1;
msg(pitem(itm,1,false,true)+' was stolen.');
itemsortinto(m.inv,itm);
takeaway(inv,it);
end;

{procedure dropinv;
begin
if(m.inv=nil)then exit;
itemsortinto(itmap[x1,y1],m.inv);
m.inv.num:=-1;
end;}

procedure acid;
var
x:byte;
fake:itemptr;
begin
repeat
x:=random(equip_num);
until(x in [0,2,3,5..7]);
if(equip[x].num=-1)then begin
	msg('The acid burns your skin.');
	deathverb:='badly wounded';deathreason:=pmon(2,0,m)+'''s acid';
	wound(1);
	exit;
	end;
fake:=nil;
damageitem(fake,@equip[x],true,pmon(2,0,m)+'''s acid');
end;

procedure monxpinc;
begin
if(fm.name[1] in ['A'..'Z'])then exit;
if(random(100)<(50-m.level))then begin
	inc(m.level);
	msg(namethe+' looks a bit more powerful.');
	end;
end;

procedure mon2monmelee;
var
x,y,n,result:byte;
atelem:string[7];
namevictim:string[80];
begin
namevictim:=pmon(seemap[tx,ty],2,monmap[tx,ty]^);
result:=att(tx,ty,elem,fm.athit,fm.atdam,m.tag,isguard,ord(m.align=align_companion)*30);
case elem of
0:atelem:='injures';
1:atelem:='burns';
2:atelem:='freezes';
3:atelem:='zaps';
end;
{case elem of
0:deathverb:='killed';
1:deathverb:='fried';
2:deathverb:='frozen to death';
3:deathverb:='electrocuted';
end;}
if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then
	case result of
	0:msg(namethe+' misses '+namevictim+'.');
	1:msg(namethe+' hits '+namevictim+' but causes no wound.');
	2:msg(namethe+' '+atelem+' '+namevictim+'.');
	3:begin msg(namethe+' kills '+namevictim+'.');
		if(seemap[x1,y1]=2)then monxpinc;
		end;
	end
else if(result=3)then msg('You hear a painful scream.');
if(random(20)=0)and(monmap[tx,ty]^.num>-1)then begin
	if(elem=1)then burnscrolls(monmap[tx,ty]^.inv,false);
	if(elem=2)then freezepotions(monmap[tx,ty]^.inv,false);
	end;
{if(result>0)and(testbit(fm.spec,8))and(wielded>0)and(random(2)=0)then
	if(random(100)>=(weapskill[wielded]+atrib[1]))then begin
		msg(namethe+' disarms you.');
		itemsortinto(itmap[plx,ply],equip[4]);
		equip[4].num:=-1;
		wielded:=0;
		end
	else msg(namethe+' tries to disarm you but fails.');}
{if(result>1)and(testbit(fm.spec,4))and(random(10)=0)then begin
	msg(namethe+' drains your body energy.');
	raisespc(random(4)+8,(random(30)+mrar)div 3,-((mrar)div 20));
	end;}
{if(result>1)and(testbit(fm.spec,15))and(random(10)<3)then begin
	raisespc(22,random(10)+(mrar div 10)+10,(mrar div 20)+1);
	end;}
{if(result>0)and(testbit(fm.spec,11))and(random(10)=0)then acid;}
{monmap[x1,y1]^:=m;
if(spc[30]>0)and(random(10)<spc[30])and(result>0)then begin
	result:=att(x1,y1,1,100,50);
	case result of
	0:msg(namethe+' evades the flames.');
	1:msg(namethe+' is hit but not injured by the flames.');
	2:msg(namethe+' is wounded by the flames.');
	3:msg(namethe+' is burned.');
	end;
	end;
if(spc[31]>0)and(random(10)<spc[31])and(result>0)and(monmap[x1,y1]^.num>-1)then begin
	result:=att(x1,y1,2,100,50);
	case result of
	0:msg(namethe+' evades the frost.');
	1:msg(namethe+' is hit but not injured by the frost.');
	2:msg(namethe+' is wounded by the frost.');
	3:msg(namethe+' is frozen.');
	end;
	end;
m:=monmap[x1,y1]^;}
end;

procedure monmelee;
var
x,y,n,result:byte;
atelem:string[7];
begin
if(thiefi)and(random(3)>0)and(itemcount(inv)>0){and(m.inv=nil)}then begin steal;exit;end;
if(thiefg)and(random(3)>0)and(goldown>0)then begin steal;exit;end;
if(monmap[tx,ty]^.num>-1)then begin
	mon2monmelee;
	exit;
	end;
result:=attplayer(fm.athit,fm.atdam,elem,m.tag,isguard);
case elem of
0:atelem:='injures';
1:atelem:='burns';
2:atelem:='freezes';
3:atelem:='zaps';
end;
case elem of
0:deathverb:='killed';
1:deathverb:='fried';
2:deathverb:='frozen to death';
3:deathverb:='electrocuted';
end;
deathreason:=namea;
case result of
0:msg(namethe+' misses you.');
1:msg(namethe+' hits you but causes no wound.');
2:msg(namethe+' '+atelem+' you.');
3:msg(namethe+' kills you.');
end;
if(hlt=0)then exit;
if(random(20)=0)then begin
	if(elem=1)then burnscrolls(inv,true);
	if(elem=2)then freezepotions(inv,true);
	end;
repeat
n:=random(8);
until(n in[0,2,3,5..7]);
identifyequip(n);
if(result>0)and(testbit(fm.spec,8))and(wielded>0)and(random(2)=0)then
	if(random(100)>=(weapskill[wielded]+atrib[1]))then begin
		msg(namethe+' disarms you.');
		itemsortinto(itmap[plx,ply],equip[4]);
		equip[4].num:=-1;
		wielded:=0;
		end
	else msg(namethe+' tries to disarm you but fails.');
if(result>1)and(testbit(fm.spec,4))and(random(10)=0)then begin
	msg(namethe+' drains your body energy.');
	raisespc(random(4)+8,(random(30)+mrar)div 3,-((mrar)div 20));
	end;
if(result>1)and(testbit(fm.spec,15))and(random(10)<3)then begin
{	msg(namethe+' poisons you.');}
	raisespc(22,random(10)+(mrar div 10)+10,(mrar div 20)+1);
	end;
if(result>0)and(testbit(fm.spec,11))and(random(10)=0)then acid;
dec(move,status[5]*15);
if(move<-(3*spc[4]))and(status[5]=1)then begin
	status[5]:=0;
	msg('You cease to defend actively.');
	end;
monmap[x1,y1]^:=m;
if(spc[30]>0)and(random(10)<spc[30])and(result>0)then begin
{	at(x1,y1);write('*',monmap[x1,y1]^.num);zn:=readkey;}
	result:=att(x1,y1,1,100,50,0,false,100);
	case result of
	0:msg(namethe+' evades the flames.');
	1:msg(namethe+' is hit but not injured by the flames.');
	2:msg(namethe+' is wounded by the flames.');
	3:msg(namethe+' is burned.');
	end;
	end;
if(spc[31]>0)and(random(10)<spc[31])and(result>0)and(monmap[x1,y1]^.num>-1)then begin
{	at(x1,y1);write('*',monmap[x1,y1]^.num);zn:=readkey;}
	result:=att(x1,y1,2,100,50,0,false,100);
	case result of
	0:msg(namethe+' evades the frost.');
	1:msg(namethe+' is hit but not injured by the frost.');
	2:msg(namethe+' is wounded by the frost.');
	3:msg(namethe+' is frozen.');
	end;
	end;
m:=monmap[x1,y1]^;
end;

procedure opendoor;
begin
if(seemap[x2,y2]=2)then
	if(map[x2,y2]=3)then begin
		msg(namethe+' opens the door.');
		map[x2,y2]:=2;
		end
	else if(map[x2,y2]=4)and(fm.int>15)then begin
		msg(namethe+' opens a secret door.');
		map[x2,y2]:=2;
		end;
oldseemap[x2,y2]:=0;
end;

procedure blinkaway;
begin
repeat
x2:=random(x_map-2)+2;
y2:=random(y_map-2)+2;
until(pass(x2,y2))and(monmap[x2,y2]^.num=-1);
monmap[x2,y2]^:=m;
monmap[x1,y1]^.num:=-1;
if(seemap[x1,y1]=2)then msg(namethe+' teleports away.');
resetbit(m.flag,0);
x1:=x2;y1:=y2;
end;

procedure go;
var
way:array[1..10]of shortint;
cur,prev,next,prev2,next2:shortint;
f,g:shortint;
moved:boolean;
begin
way[1]:=0;
moved:=false;
repeat
inc(way[1]);
until(cpmx[way[1]]=sgn(tx-x1))and(cpmy[way[1]]=sgn(ty-y1));
if(movetype=6)then begin
	inc(way[1],4);
	if(way[1]>8)then dec(way[1],8);
	end;
way[2]:=way[1];
for f:=2 to 5 do begin
	way[f*2-1]:=way[f*2-3]-1;if(way[f*2-1]=0)then way[f*2-1]:=8;
	way[f*2]:=way[f*2-2]+1;if(way[f*2]=9)then way[f*2]:=1;
	end;
case movetype of
1,13:begin
{	if(m.align=align_companion)and(wizard)then begin at(m.lx,m.ly);write('*');end;}
	for f:=2 to 9 do begin
		x2:=x1+cpmx[way[f]];
		y2:=y1+cpmy[way[f]];
{		at(x2,y2);write(f);}
		if(map[x2,y2]in[3,4])and(fm.int>4)and((not(notdoorpass))or(not(testbit(m.flag,6))))
			then begin opendoor;exit;end;
		if(map[x2,y2]in[2..4])and(notdoorpass)and(testbit(m.flag,6))then continue;
		if(not(pass(x2,y2)))or(monmap[x2,y2]^.num>-1)or((x2=plx)and(y2=ply))
			or((x2=m.lx)and(y2=m.ly))then continue
		else break;
		end;
	if(f>4)then begin
		for g:=2 to 9 do begin
			x2:=x1+cpmx[way[g]];
			y2:=y1+cpmy[way[g]];
			if(monmap[x2,y2]^.num>-1)and(monmap[x2,y2]^.align<>m.align)then begin
				m.tartag:=monmap[x2,y2]^.tag;
				x2:=x1;y2:=y1;
				exit;
				end;
			end;
		if(f=10)then begin x2:=x1;y2:=y1;end
			else begin x2:=x1+cpmx[way[f]];y2:=y1+cpmy[way[f]];end;
		end;
{		x2:=x1+cpmx[cur];y2:=y1+cpmy[cur];
		if(monmap[x2,y2]^.num>-1)and(monmap[x2,y2]^.align<>m.align)then begin
			m.tartag:=monmap[x2,y2]^.tag;
			x2:=x1;y2:=y1;
			exit;
			end;
		x2:=x1+cpmx[next];y2:=y1+cpmy[next];
		if(monmap[x2,y2]^.num>-1)and(monmap[x2,y2]^.align<>m.align)then begin
			m.tartag:=monmap[x2,y2]^.tag;
			x2:=x1;y2:=y1;
			exit;
			end;
		x2:=x1+cpmx[prev];y2:=y1+cpmy[prev];
		if(monmap[x2,y2]^.num>-1)and(monmap[x2,y2]^.align<>m.align)then begin
			m.tartag:=monmap[x2,y2]^.tag;
			x2:=x1;y2:=y1;
			exit;
			end;
		x2:=x1;y2:=y1;
{		end;}
	end;
2:begin
	repeat
	x2:=x1+random(3)-1;
	y2:=y1+random(3)-1;
	until(x2<>plx)or(y2<>ply);
	if((abs(m.mood)=99)or(testbit(m.flag,6)))and(notdoorpass)and(map[x2,y2]=2)then begin
		x2:=x1;y2:=y1;
		end;
	end;
6:begin
	x2:=x1+cpmx[cur];
	y2:=y1+cpmy[cur];
	if(map[x2,y2]in[3,4])and(fm.int>4)then begin opendoor;exit;end;
	if(not(pass(x2,y2)))or(monmap[x2,y2]^.num>-1)or((x2=plx)and(y2=ply))then begin
		x2:=x1+cpmx[prev];
		y2:=y1+cpmy[prev];
		end;
	if(map[x2,y2]in[3,4])and(fm.int>4)then begin opendoor;exit;end;
	if(not(pass(x2,y2)))or(monmap[x2,y2]^.num>-1)or((x2=plx)and(y2=ply))then begin
		x2:=x1+cpmx[next];
		y2:=y1+cpmy[next];
		end;
	if(map[x2,y2]in[3,4])and(fm.int>4)then begin opendoor;exit;end;
	if(not(pass(x2,y2)))or(monmap[x2,y2]^.num>-1)or((x2=plx)and(y2=ply))then begin
		x2:=x1+cpmx[prev2];
		y2:=y1+cpmy[prev2];
		end;
	if(map[x2,y2]in[3,4])and(fm.int>4)then begin opendoor;exit;end;
	if(not(pass(x2,y2)))or(monmap[x2,y2]^.num>-1)or((x2=plx)and(y2=ply))then begin
		x2:=x1+cpmx[next2];
		y2:=y1+cpmy[next2];
		end;
	if(map[x2,y2]in[3,4])and(fm.int>4)then begin opendoor;exit;end;
	if((not(pass(x2,y2)))or(monmap[x2,y2]^.num>-1)or((x2=plx)and(y2=ply)))
		and(range=1)then begin
		if(blink)then begin
			blinkaway;
			exit;
			end;
		if(random(25)<fm.int)then msg(namethe+' begs for mercy.')
			else monmelee;
		exit;
		end;
	end;
end;
if(x2<1)or(x2>x_map)or(y2<1)or(y2>y_map)then begin x2:=x1;y2:=y1;end;
if(pass(x2,y2))and(monmap[x2,y2]^.num=-1)then begin
	monmap[x2,y2]^:=m;
	{monmap[x1,y1]^.num:=-1;}
	if(x1<>x2)or(y1<>y2)then moved:=true;
	x1:=x2;y1:=y2;
	end;
if(map[x1,y1]in[11,12])and(moved)then
	case(random(20)<fm.int)of
	true:if(map[x1,y1]=12)and(seemap[x1,y1]=2)then msg(namethe+' avoids the trap.');
	false:begin
		if(seemap[x1,y1]=2)then map[x1,y1]:=12;
		oldseemap[x1,y1]:=0;
		case typemap[x1,y1] of
		2:begin
			if(seemap[x1,y1]=2)then msg(namethe+' triggers a fire trap.');
			burnscrolls(m.inv,false);
			if(att(x1,y1,1,100,100,0,true,ord(seemap[x1,y1]=2)*40)=3)then begin
				if(seemap[x1,y1]=2)then	msg(namethe+' is burned.');
				m.num:=-1;
				end;
			end;
		1:begin
			if(seemap[x1,y1]=2)then msg(namethe+' triggers a frost trap.');
			freezepotions(m.inv,false);
			if(att(x1,y1,2,100,100,0,true,ord(seemap[x1,y1]=2)*40)=3)then begin
				if(seemap[x1,y1]=2)then	msg(namethe+' is frozen.');
				m.num:=-1;
				end;
			end;
		3:begin
			if(seemap[x1,y1]=2)then msg(namethe+' triggers a teleport trap.');
			blinkaway;
			end;
		4:begin
			if(seemap[x1,y1]=2)then msg(namethe+' triggers a confusion gas trap.');
			inc(m.mood,random(10)+10);
			{msg(pmon(2,2,m)+' is confused.');}
			end;
		5:begin
			if(seemap[x1,y1]=2)then msg(namethe+' triggers an explosion trap.')
				else msg('You hear an explosion.');
			explode(x1,y1,2);
			end;
		end;
		m:=monmap[x1,y1]^;
		end;
	end;
end;

procedure mon2monranged(at:byte;act:string;what:string);
var
result:shortint;
it:item;
resstr:string[80];
namevictim:string[80];
begin
namevictim:=pmon(seemap[tx,ty],2,monmap[tx,ty]^);
case at of
1..3:begin
	result:=att(tx,ty,at,fm.athit,50,m.tag,isguard,ord(m.align=align_companion)*40);
	case result of
	0:resstr:='on '+namevictim+' but misses';
	1:resstr:='and hits but '+namevictim+' resists';
	2:case at of
		1:resstr:='and burns '+namevictim;
		2:resstr:='and freezes '+namevictim;
		3:resstr:='and zaps '+namevictim;
		end;
	3:resstr:='and kills '+namevictim;
	end;
	if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then
		msg(namethe+' '+act+' '+what+' '+resstr+'.');
	if(result=3)then monxpinc;
	if(random(10)=0)and(monmap[tx,ty]^.num>-1)then begin
		if(elem=1)then burnscrolls(monmap[tx,ty]^.inv,false);
		if(elem=2)then freezepotions(monmap[tx,ty]^.inv,false);
		end;
	end;
4:if(random(22)>=atrib[2])then begin
	if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then
		msg(namethe+' casts confusion on '+namevictim+' successfully.');
	inc(monmap[tx,ty]^.mood,random(10)+2);
	end
	else if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then msg(namethe+' casts confusion but '+namevictim+' resists.');
5:if(random(22)>=atrib[3])then begin
	if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then
		msg(namethe+' casts blindness on '+namevictim+' successfully.');
	inc(monmap[tx,ty]^.mood,random(10)+2);
	end
	else if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then msg(namethe+' casts blindness but '+namevictim+' resists.');
7:begin
	result:=random(4);
	if(random(100)<mrar)then inc(result);
	if(random(100)>mrar)then dec(result);
	case result of
	-1:what:='horrible';
	0:what:='nice';
	1:what:='beautiful';
	2:what:='wonderful';
	3:what:='fantastic';
	4:what:='heavenly';
	end;
	if(seemap[x1,y1]=2)then msg(namethe+' sings a '+what+' tune.');
	case result of
	-1:begin
		if(seemap[x1,y1]=2)then msg(namethe+' sits down and starts to cry heart-breakingly.');
		m.mood:=-5;
		end;
	0..3:if(random((result*5)+10)>=fmons[monmap[tx,ty]^.num]^.int)then begin
			if(seemap[tx,ty]=2)then msg(namevictim+' can''t resist to listen.');
			dec(monmap[tx,ty]^.mood,random(result*2)+2);
			end;
	4:begin
		if(seemap[tx,ty]=2)then msg(namevictim+' can''t resist to listen.');
		inc(monmap[tx,ty]^.mood,random(10)+5);
		end;
	end;
	end;
6:begin
	it:=m.inv^;it.q:=1;what:=fitems[it.num]^.name0;
	if(m.inv^.next<>nil)then act:='shoots'
		else act:='throws';
{	gotoxy(1,49);write((fm.atdam div 5)+fitems[it.num]^.bonus);}
	result:=att(tx,ty,0,fm.athit,(fm.atdam div 5)+fitems[it.num]^.bonus,m.tag,isguard,ord(m.align=align_companion)*40);
	if(seemap[tx,ty]=2)or(seemap[x1,y1]=2)then
	case result of
	0:msg(namethe+' '+act+' '+what+' on '+namevictim+' but misses.');
	1:msg(namethe+' '+act+' '+what+' on '+namevictim+' and hits but causes no wound.');
	2:msg(namethe+' '+act+' '+what+' and injures '+namevictim+'.');
	3:begin msg(namethe+' '+act+' '+what+' and kills '+namevictim+'.');
		monxpinc;end;
	end
	else if(result=3)then msg('You hear a painful scream.');
	if(fitems[it.num]^.spec=26)and(random(10)<it.mb)and(seemap[x1,y1]=2)then
		msg('The missile returns.')
	else begin
		if(random(2)=0)then itemsortinto(itmap[tx,ty],it);
		iptr:=m.inv;
		takeaway(m.inv,iptr);
		{itemsel(m.inv,99,'item','bow',-1);}
		if(m.inv<>nil)then
			if(fitems[m.inv^.num]^.class<>15)and(seemap[x1,y1]=2)then msg(namethe+' seems to be out of ammo.');
		if(m.inv=nil)and(seemap[x1,y1]=2)then msg(namethe+' seems to be out of ammo.');
		end;
	end;
end;
if(caster)and(m.sp=0)and(seemap[x1,y1]=2)then msg(namethe+' looks exhausted.');
end;

procedure monranged;
var
at:byte;
x,y,result:shortint;
it:item;
act:string[6];
what:string[20];
resstr:string[80];
begin
at:=0;
act:='makes';what:='something undefined';
if(caster)then begin
	at:=ord(testbit(fm.spell,0));						{1-fire}
	if((random(2)=0)or(at=0))and(testbit(fm.spell,1))then at:=2;		{2-cold}
	if((random(2)=0)or(at=0))and(testbit(fm.spell,2))then at:=3;		{3-lite}
	if((random(2+2*spc[21])=0)or(at=0))and(testbit(fm.spell,3))then at:=4;	{4-confuse}
	if((random(2+2*spc[23])=0)or(at=0))and(testbit(fm.spell,4))then at:=5;	{5-blind}
	act:='casts';dec(m.sp);
	end;
if((random(2)=0)or(at=0))and((testbit(fm.spec,1))or(testbit(fm.spec,2)))then begin
	at:=ord(testbit(fm.spec,1))+ord(testbit(fm.spec,2))*2;
	act:='spits';
	end;
if((random(2)=0)or(at=0))and(bard)then at:=7;	{bard}
if(at=0)then at:=6;
if(not(los(tx,ty,x1,y1,true)))then
	if(bard)then at:=7
		else exit;
case at of
1:what:='fire';
2:what:='ice';
3:what:='lightning';
end;
if(monmap[tx,ty]^.num>-1)then begin
	mon2monranged(at,act,what);
	exit;
	end;
for x:=plx-1 to plx+1 do
for y:=ply-1 to ply+1 do
	if(monmap[x,y]^.align=align_companion)and(monmap[x,y]^.tartag=0)then
		monmap[x,y]^.tartag:=m.tag;
deathreason:=namea;
case at of
4..6:deathverb:='killed';
1:deathverb:='fried';
2:deathverb:='frozen to death';
3:deathverb:='electrocuted';
end;
case at of
1..3:begin
	result:=attplayer(fm.athit,50,at,m.tag,isguard);
	case result of
	0:resstr:='but misses';
	1:resstr:='and hits but you resist';
	2:case at of
		1:resstr:='and burns you';
		2:resstr:='and freezes you';
		3:resstr:='and zaps you';
		end;
	3:resstr:='and kills you';
	end;
	msg(namethe+' '+act+' '+what+' '+resstr+'.');
	if(random(10)=0)then begin
		if(elem=1)then burnscrolls(inv,true);
		if(elem=2)then freezepotions(inv,true);
		end;
	end;
4:if(random(22)>=atrib[2])then begin
	msg(namethe+' casts confusion successfully.');
	raisespc(21,random(22-atrib[2])+3,1);
	end
	else msg(namethe+' casts confusion but you resist.');
5:if(random(22)>=atrib[3])then begin
	msg(namethe+' casts blindness successfully.');
	raisespc(23,random(22-atrib[3])+3,1);
	end
	else msg(namethe+' casts blindness but you resist.');
7:begin
	result:=random(4);
	if(random(100)<mrar)then inc(result);
	if(random(100)>mrar)then dec(result);
	case result of
	-1:what:='horrible';
	0:what:='nice';
	1:what:='beautiful';
	2:what:='wonderful';
	3:what:='fantastic';
	4:what:='heavenly';
	end;
	msg(namethe+' sings a '+what+' tune.');
	case result of
	-1:begin
		msg(namethe+' sits down and starts to cry heart-breakingly.');
		m.mood:=-5;
		end;
	0..3:if(random((result*5)+10)>=atrib[2])then begin
			msg('You can''t resist to listen.');
			raisespc(28,random(5)+3,1);
			end
		else msg('You ignore it.');
	4:begin
		msg('You can''t resist to listen.');
		raisespc(28,random(8)+5,1);
		end;
	end;
	end;
6:begin
	it:=m.inv^;it.q:=1;what:=fitems[it.num]^.name0;
	if(m.inv^.next<>nil)then act:='shoots'
		else act:='throws';
{	gotoxy(1,49);write((fm.atdam div 5)+fitems[it.num]^.bonus);}
	result:=attplayer(fm.athit,(fm.atdam div 5)+fitems[it.num]^.bonus,0,m.tag,isguard);
	case result of
	0:msg(namethe+' '+act+' '+what+' but misses.');
	1:msg(namethe+' '+act+' '+what+' and hits but causes no wound.');
	2:msg(namethe+' '+act+' '+what+' and injures you.');
	3:msg(namethe+' '+act+' '+what+' and kills you.');
	end;
	if(fitems[it.num]^.spec=26)and(random(10)<it.mb)then
		msg('The missile returns.')
	else begin
		if(random(2)=0)then itemsortinto(itmap[plx,ply],it);
		iptr:=m.inv;
		takeaway(m.inv,iptr);
		{itemsel(m.inv,99,'item','bow',-1);}
		if(m.inv<>nil)then
			if(fitems[m.inv^.num]^.class<>15)then msg(namethe+' seems to be out of ammo.');
		if(m.inv=nil)then msg(namethe+' seems to be out of ammo.');
		end;
	end;
end;
if(caster)and(m.sp=0)and(seemap[x1,y1]=2)then msg(namethe+' looks exhausted.');
end;

procedure regenerate;
begin
if(caster)then begin
	if(seemap[x1,y1]=2)then msg(namethe+' casts healing on self.');
	inc(m.hlt);
	dec(m.sp,2);
	exit;
	end;
inc(m.hlt);
if(seemap[x1,y1]=2)then msg(namethe+' regenerates.');
end;

procedure getfast;
begin
if(seemap[x1,y1]=2)then msg(namethe+' casts speed on self.');
setbit(m.flag,5);
dec(m.sp,3);
end;

procedure summon;
var
n:integer;
x,y,xa,xb,ya,yb,max:shortint;
mesg:boolean;
begin
max:=ord(testbit(fm.spell,6))+ord(testbit(fm.spell,7))*2+ord(testbit(fm.spell,8))*4;
mesg:=false;
getbounds(xa,ya,xb,yb,x1,y1,1);
for x:=xa to xb do
for y:=ya to yb do
	if(pass(x,y))and(x<>plx)and(y<>ply)and(monmap[x,y]^.num=-1)and(random(10)<5)then begin
		n:=m.num+random(max)+1;
		randommon(n,99,255,monmap[x,y]^);
		moveit[x,y]:=0;
		monmap[x,y]^.speed:=0;
		monmap[x,y]^.align:=m.align;
		resetbit(monmap[x,y]^.flag,2);
		if(seemap[x,y]=2)then mesg:=true;
		dec(m.sp,3);
		if(m.sp<0)then m.sp:=0;
		if(m.sp=0)then break;
		end;
if(mesg)then msg(namethe+' summons some monsters.');
if(m.sp=0)and(seemap[x1,y1]=2)then msg(namethe+' looks exhausted.');
end;

procedure callreinf;
var
x,y,xx,yy:shortint;
begin
msg(namethe+' calls for reinforcements.');
yy:=y1-10;
if(yy>1)then
	for x:=x1-10 to x1+10 do begin
		if(x<1)or(x>x_map)then continue;
		if(pass(x,yy))and(monmap[x,yy]^.num=-1)and(random(4)=0)then begin
			randommon(m.num+1,99,255,monmap[x,yy]^);
			monmap[x,yy]^.flag:=0;
			monmap[x,yy]^.align:=m.align;
			end;
		end;
yy:=y1+10;
if(yy<y_map)then
	for x:=x1-10 to x1+10 do begin
		if(x<1)or(x>x_map)then continue;
		if(pass(x,yy))and(monmap[x,yy]^.num=-1)and(random(4)=0)then begin
			randommon(m.num+1,99,255,monmap[x,yy]^);
			monmap[x,yy]^.flag:=0;
			monmap[x,yy]^.align:=m.align;
			end;
		end;
xx:=x1-10;
if(xx>1)then
	for y:=y1-10 to y1+10 do begin
		if(y<1)or(y>y_map)then continue;
		if(pass(xx,y))and(monmap[xx,y]^.num=-1)and(random(4)=0)then begin
			randommon(m.num+1,99,255,monmap[xx,y]^);
			monmap[xx,y]^.flag:=0;
			monmap[xx,y]^.align:=m.align;
			end;
		end;
xx:=x1+10;
if(xx<x_map)then
	for y:=y1-10 to y1+10 do begin
		if(y<1)or(y>y_map)then continue;
		if(pass(xx,y))and(monmap[xx,y]^.num=-1)and(random(4)=0)then begin
			randommon(m.num+1,99,255,monmap[xx,y]^);
			monmap[xx,y]^.flag:=0;
			monmap[xx,y]^.align:=m.align;
			end;
		end;
end;

procedure pickmissile;
begin
cur:=itmap[x1,y1];
while(cur<>nil)do begin
	if(fitems[cur^.num]^.class=15)and
	((fitems[cur^.num]^.subclass=(-fm.inv-504))or(m.inv=nil))
		then break;
	cur:=cur^.next;
	end;
if(cur=nil)then begin
	msg('Bug report:PICKMISSILE error.');
	exit;
	end;
itemsortinto(m.inv,cur^);
if(seemap[x1,y1]=2)then msg(namethe+' picks up '+pitem(cur^,1,true,true)+'.');
cur^.q:=1;
takeaway(itmap[x1,y1],cur);
end;

procedure decidemon(x,y:byte);
var
xx,yy,xx1,yy1,xx2,yy2,lx,ly:shortint;
begin
x1:=x;y1:=y;
m:=monmap[x1,y1]^;
fm:=fmons[m.num]^;
inc(fm.athit,m.level);
if(fm.athit>100)then fm.athit:=100;
inc(fm.atdam,m.level div 2);
if(fm.atdam>100)then fm.atdam:=100;
inc(fm.def,m.level div 2);
if(fm.def>100)then fm.def:=100;
namea:=pmon(seemap[x1,y1],1,m);
namethe:=pmon(seemap[x1,y1],2,m);
tx:=0;ty:=0;
range:=abs(x1-plx);
sight:=5;
if((duntype*10+patro)in sunlight)then inc(sight,5);
if(abs(y1-ply)>range)then range:=abs(y1-ply);
if(m.tartag=0)then
	if(range<6)or(m.align<>align_companion)then begin
		tx:=plx;
		ty:=ply;
		end
	else m.tartag:=255;
if(m.tartag in[1..250])then begin
	getbounds(xx1,yy1,xx2,yy2,x1,y1,sight);
	for xx:=xx1 to xx2 do
	for yy:=yy1 to yy2 do
		if(monmap[xx,yy]^.tag=m.tartag)and(monmap[xx,yy]^.num>-1)then begin
			tx:=xx;ty:=yy;
			end;
	if(tx=0)then
		if(m.align<>align_companion)then m.tartag:=255
			else m.tartag:=0;
	end;
if(m.tartag=255)then begin
	getbounds(xx1,yy1,xx2,yy2,x1,y1,sight);
	for xx:=xx1 to xx2 do
	for yy:=yy1 to yy2 do begin
		if(xx=x1)and(yy=y1)then continue;
		if((monmap[xx,yy]^.align<>m.align)or(arena))and(monmap[xx,yy]^.num>-1)then begin
			tx:=xx;ty:=yy;m.tartag:=monmap[xx,yy]^.tag;
			end;
		if(xx=plx)and(yy=ply)and(m.align<>align_companion)then begin
			m.tartag:=0;tx:=plx;ty:=ply;
			end;
		end;
{	if(wizard)and(m.tartag=255)and(arena)then begin
		msg(namethe+' suitable target not found.');
		at(x1,y1);write('#');
		end;}
	if(m.align=align_companion)then begin
		m.tartag:=0;tx:=plx;ty:=ply;
		end;
	end;
if(m.tartag=0)then victimspeed:=spc[4]
	else victimspeed:=fmons[monmap[tx,ty]^.num]^.speed;
if(m.tartag=0)and(testbit(m.flag,6))then m.mood:=fm.mood;
mood:=m.mood;
if(m.tartag=255)and(mood=0)then mood:=99;
{invptr:=monmap[x1,y1]^.inv;
monmap[x1,y1]^.inv:=nil;}
monmap[x1,y1]^:=emptymon;
if(mood>0)and(mood<50)and(random(20)<fm.int)then dec(m.mood);
if(mood<0)and(mood>-50)and(random(10)<fm.hlt)then inc(m.mood);
namea:=pmon(seemap[x1,y1],1,m);
namethe:=pmon(seemap[x1,y1],2,m);
elem:=ord(testbit(fm.spec,1))+ord(testbit(fm.spec,2))*2;
mrar:=fm.rarity;if(mrar<1)then mrar:=50;
if((movecount mod 100)=mrar)then m.hlt:=fm.hlt;

notdoorpass:=testbit(fm.spec2,3);
isguard:=testbit(fm.spec2,6);

pickmis:=testbit(fm.spec,10);
if(pickmis)and(m.inv<>nil)then
	if(fitems[m.inv^.num]^.class=15)then pickmis:=false;
if(pickmis)then begin
	pickmis:=false;
	cur:=itmap[x1,y1];
	while(cur<>nil)do begin
		if(fitems[cur^.num]^.class=15)and
		((fitems[cur^.num]^.subclass=(-fm.inv-504))or(m.inv=nil))
			then pickmis:=true;
		cur:=cur^.next;
		end;
	end;

caster:=testbit(fm.spec,0);
if(m.sp<1)then caster:=false;
if(random(20)>=fm.int)then caster:=false;

ranged:=false;
if(m.inv<>nil)then
	if(fitems[m.inv^.num]^.class=15)and(testbit(fm.spec,10))then ranged:=true;
if(testbit(fm.spec,3))then ranged:=true;
if(caster)then
	if(testbit(fm.spell,0))or(testbit(fm.spell,1))or(testbit(fm.spell,2))or
	(testbit(fm.spell,3))or(testbit(fm.spell,4))then ranged:=true;
rangedpos:=ranged;
bard:=testbit(fm.spec2,1);
if(spc[28]>0)then bard:=false;
{if(bard)then ranged:=true;}
if(bard)then begin
	rangedpos:=true;
	if(random(3)=0)then ranged:=true
		else bard:=false;
	end;
if(not(los(tx,ty,x1,y1,not(bard))))or(random(5)=0)then ranged:=false;
if(random(10)=0)or((testbit(fm.spec,3))and(random(3)<>0))then rangedpos:=false;

blink:=testbit(fm.spec,9);
if(caster)and(not(blink))then blink:=testbit(fm.spell,5);

regen:=false;
if(testbit(fm.spec,7))and(m.hlt<fm.hlt)then regen:=true;
if(caster)and(testbit(fm.spell,9))and(m.hlt<fm.hlt)then regen:=true;
if(random(4)>0)then regen:=false;

if(caster)and(random(5)=0)then pals:=(testbit(fm.spell,6))or(testbit(fm.spell,7))or(testbit(fm.spell,8))
	else pals:=false;

thiefi:=testbit(fm.spec,5);
thiefg:=testbit(fm.spec,6);

range:=abs(x1-tx);
if(abs(y1-ty)>range)then range:=abs(y1-ty);

if(testbit(fm.spec2,4))and(random(10+ord(m.align=align_companion)*20)=0)and(range<3)then
	reinf:=true
	else reinf:=false;

if(testbit(m.flag,2))and(random(100)>=spc[29])and((range<(fm.int div 2))or(range<5))
	and(m.align=0)then begin
	resetbit(m.flag,2);
	if(namethe<>'something')then msg(namethe+' notices you.');
	end;
speed:=ord(testbit(m.flag,3))+ord(testbit(m.flag,4))*2+ord(testbit(m.flag,5))*4;
if(speed>0)then begin dec(m.flag,(speed*8));inc(m.flag,(speed-1)*8);end;
if(speed>0)and(wizard)then begin
	msg(namethe+' speed ');
	writeln(speed);
	end;
movetype:=0;									{0-do nothing}
if(not(testbit(m.flag,2)))and(mood=0)then movetype:=1;				{1-go to}
if(movetype=1)and(m.align=align_companion)and(m.tartag=0)then movetype:=13;	{13-follow}		{13-follow}
if(movetype=13)and(range=1)then movetype:=0;
if(mood>0)then movetype:=2;							{2-go random}
if(pals)and(range<sight)and(movetype=1)then movetype:=9;			{9-summon}
if(reinf)and(movetype=1)then movetype:=12;					{12-reinforce}
if(regen)and(mood=0)then movetype:=7;						{7-regenerate}
if(rangedpos)and((fm.speed>victimspeed)or(blink)or(speed>0))and(range<2)and(movetype=1)
	then movetype:=6;							{6-go away}
if(rangedpos)and(range<3)and(spc[28]>0)and(mood=0)then movetype:=6;
if(testbit(m.flag,0))and(mood=0)then movetype:=6;
{if((thiefi)or(thiefg))and(m.inv<>nil)then movetype:=6;}
if(blink)and(movetype=6)and(speed=0)then movetype:=3;				{3-teleport}
if(caster)and(testbit(fm.spell,10))and(range<4)and(movetype in[1,6])and(speed=0)
	then movetype:=11;							{11-cast speed}
{if((thiefi)or(thiefg))and(range>10)then movetype:=8;				{8-drop inv}
if(pickmis)then movetype:=10;							{10-pick mis}
if(range>1)and(range<sight)and(ranged)and(movetype=1)then movetype:=5;		{5-ranged}
if(range=1)and(movetype=1)then movetype:=4;					{4-melee}
if(((ranged)and(range<3))or(range=1))and(random(10)=0)and(m.align=0)then
	mtalk(m.num,fmons[m.num]^.class,namethe);
if(rangedpos)and(movetype=1)then movetype:=0;
{if(movetype<>0)then begin at(x1,y1);write(movetype);zn:=readkey;end;}
lx:=x1;ly:=y1;
case movetype of
1,2,6,13:go;
3:blinkaway;
4:monmelee;
5:monranged;
7:regenerate;
{8:dropinv;}
9:summon;
10:pickmissile;
11:getfast;
12:callreinf;
end;
m.lx:=0;m.ly:=0;
if(movetype in [1,13])then begin
	m.lx:=lx;m.ly:=ly;
	end;
dec(m.speed,100);
if(m.sp<(fm.int div 2))and(random(100)<fm.int)then inc(m.sp);
if(mood>0)and(mood<50)then begin
	dec(m.mood);
	if(m.mood>0)and(random(22)<fm.int)then dec(m.mood);
	end;
monmap[x1,y1]^:=m;
if(monmap[x1,y1]^.num=-1)and(monmap[x1,y1]^.inv<>nil)then begin
	msg('BUG REPORT: Dead monster with inventory.(AI)');
{	msg('Pointer will be cleared to prevent crash but some memory will remain allocated');
	msg(' until you exit the program.');}
	monmap[x1,y1]^.inv:=nil;
	if(wizard)then delay(1000);
	end;
{monmap[x1,y1]^.inv:=invptr;}
if(moveit[x1,y1]=1)then moveit[x1,y1]:=0;
{if(ranged)then begin at(x1,y1);write('*');zn:=readkey;end;}
end;

function movemons:boolean;
var
x,y:byte;
again:boolean;
begin
again:=false;
for x:=1 to x_map do
for y:=1 to y_map do
	if(moveit[x,y]=0)then moveit[x,y]:=1;
for x:=1 to x_map do
for y:=1 to y_map do
	if(monmap[x,y]^.num>-1)and(monmap[x,y]^.speed>0)and(moveit[x,y]>0)then begin
		decidemon(x,y);
		again:=true;
		end;
movemons:=again;
end;

procedure speedmons;
var
x,y:byte;
begin
for x:=1 to x_map do
for y:=1 to y_map do begin
	inc(monmap[x,y]^.speed,fmons[monmap[x,y]^.num]^.speed);
	if(testbit(monmap[x,y]^.flag,3))or(testbit(monmap[x,y]^.flag,4))or(testbit(monmap[x,y]^.flag,5))then
		inc(monmap[x,y]^.speed,fmons[monmap[x,y]^.num]^.speed);
	end;
end;


procedure doturn;
var
f:byte;
begin
repeat
if(movestodo=-1)then exit;
until (not(movemons));
speedmons;
inc(move,spc[4]);
if(not(arena))then inc(movecount);
dec(origspc[19]);
if(origspc[19]<3)then begin
	deathverb:='starved to death';
	deathreason:='';
	hlt:=0;
	end;
if((movecount mod 10)=0)or(status[2]=1)then dec(origspc[20]);
case(movecount mod 20000)of
18000:msg('*The heroes championship in the Arena will begin soon!');
18500:msg('*The heroes championship in the Arena will begin very soon!');
19000:begin
	msg('*The heroes championship in the Arena has just begun!');
	msg('Hurry up! Now is the time to show who is the best!');
	end;
0:msg('*The heroes championship in the Arena has just ended!');
end;
if(origspc[20]<3)then begin
	deathverb:='gone totally dehydrated';
	deathreason:='';
	hlt:=0;
	end;
if(hlt<orighlt)and(random(200-skill[sk_heal])<atrib[3])then inc(hlt);
if(spl<origspl)and(random(200-skill[sk_medit])<atrib[2])then inc(spl);
if(spctime[22]>3)and(random(22)<atrib[3])then dec(spctime[22]);
if(random(20)<origspc[22])then begin
	msg('The poison makes you sick.');
	deathverb:='killed';deathreason:='poison';
	wound(1);
	end;
for f:=21 to 23 do
	if(spc[f]>0)and(random(120)<skill[sk_purify])then lowerspc(f);
for f:=0 to spc_num do begin
	if(spctime[f]>1)then dec(spctime[f]);
	if(spctime[f]=1)then lowerspc(f);
	end;
end;

function domoves(n:byte;action:string):boolean;
begin
movestodo:=n;
domoves:=false;
repeat

repeat
dec(move,100);
dec(movestodo);
movemons;
see(spc[5]);
if(hlt=0)then movestodo:=-1;
if(movestodo=0)then begin
	domoves:=true;
	exit;
	end;
if(monalarm)and(movestodo>0)then
	if(iyesorno('A monster is nearby. Do you want to interrupt '+action+'?'))then movestodo:=-1;
if(movestodo=-1)then begin
	movestodo:=-99;
	exit;
	end;
until(move<1);

doturn;
until(movestodo=-1);
movestodo:=-99;
end;









end.
