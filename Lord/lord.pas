uses crt,mycrt,gener,items,monsters,gfx,player,shops,spells,univ,potions,dungeons,dos,helper,
	skills,monai,montalk;

const
autostep = 30;
wizardpasswd:string[6] = 'almost forgot to delete this';
newcompanion:boolean = false;

var
x,y:shortint;
it:item;
itptr:itemptr;
autocmnd,cmnd:char;
s:string[20];
autodir,autocount,autorun,loading:byte;
origmode,f:integer;
dirinfo:searchrec;
filename:string[8];


procedure init;
var
x,y:byte;
begin
w_artif:=false;
w_identify:=false;
w_god:=false;
for x:=1 to x_map do
for y:=1 to y_map do
        itmap[x,y]^.num:=-1;
for x:=1 to msg_num do msgtext[x]:='';
txtbuf:=1;
movecount:=0;
inv:=nil;
for x:=0 to equip_num do equip[x].num:=-1;
for x:=0 to 9 do weapskill[x]:=10;
for x:=1 to 40 do msgbuffer[x]:='';
{for x:=0 to skillnum do skill[x]:=1;}
expr:=0;explev:=1;
for f:=0 to spc_num do begin
        origspc[f]:=0;
	spcmodif[f]:=0;
        end;
origspc[4]:=90;
origspc[5]:=4;
origspc[19]:=3000;
origspc[20]:=1000;
ids[0]:=2;
patro:=1;
{if(wizard)then begin writeln('patro:');readln(patro);end;}
end;

procedure bonuses;
var
sel,art:byte;
it:item;
begin
randomitem(-1,1,1,50,equip[4]);
randomitem(-1,3,1,50,equip[3]);
equip[3].mb:=0;equip[3].curse:=false;equip[3].curseid:=true;
equip[4].mb:=0;equip[4].curse:=false;equip[4].curseid:=true;
clrscr;
at(2,2);ink(15);write('You may choose a bonus to start with:');ink(7);
at(3,4);write('a) an uncommon weapon');
at(3,5);write('b) an uncommon armour');
at(3,6);write('c) a rare item');
at(3,7);write('d) half a dozen of scrolls');
if(origatrib[4]>3)then begin
	at(3,8);write('e) an artifact+every attribute lowered by two points');
	art:=1;
	end
else begin
	ink(12);
	at(3,8);write('e) an artifact+every attribute lowered by two points');
	ink(7);
	art:=0;
	end;
at(3,9);write('f) a companion');
repeat
select(6,0,sel);
until(art=1)or(sel<>4);
case sel of
0:randomitem(-1,1,2,255,equip[4]);	{weapon}
1:randomitem(-1,3,2,255,equip[3]);	{armour}
2:begin randomitem(-1,99,3,255,it);itemsortinto(inv,it);end;	{rare}
3:for f:=1 to 6 do begin	{scrolls}
	randomitem(-1,11,2,255,it);
	itemsortinto(inv,it);
	ids[it.num]:=2;
	end;
4:begin		{artifact}
	randomitem(-1,99,4,255,it);
	itemsortinto(inv,it);
	for f:=0 to 4 do dec(origatrib[f],2);
	end;
5:newcompanion:=true;
end;
repeat
randomitem(-1,13,2,255,it);
until(it.num>0);
ids[it.num]:=2;
it.id:=true;
it.curseid:=true;
itemsortinto(inv,it);
wielded:=fitems[equip[4].num]^.subclass;
if(wielded>10)then begin
	dec(wielded,10);
	twohanded:=true;
	end;
for f:=0 to equip_num do
	if(equip[f].num>-1)then begin
		ids[equip[f].num]:=2;
		equip[f].id:=true;
		equip[f].curse:=false;
		equip[f].curseid:=true;
		equip[f].mb:=0;
		end;
{for f:=0 to 17 do
	if(inv[f].num>-1)then begin
		ids[inv[f].num]:=2;
		inv[f].id:=true;
		end;}
end;


procedure drawmap;
var
x,y:byte;
begin
for x:=1 to x_map do
        for y:=1 to y_map do begin
                seemap[x,y]:=1;
		if(map[x,y]=11)then map[x,y]:=12;
                end;
for x:=1 to wildsize do
        for y:=1 to wildsize do
                wildmap[x,y]:=1;
redraw(true);
end;


procedure msgbuf;
var
f:byte;
begin
clrscr;
for f:=1 to 40 do
begin
        at(1,f);write(msgbuffer[f]);
end;
corner;
zn:=readkey;
redraw(true);
end;

procedure weaponacid(m:string);
var
x:byte;
s:string[40];
fake:itemptr;
begin
if(equip[4].num=-1)then begin
        msg('The acid burns your hands.');
        deathverb:='badly wounded';deathreason:=m+'''s acid';
        wound(1);
        exit;
        end;
{s:=pitem(equip[4],true);
if(copy(s,1,2)='a ')then s:=copy(s,3,100)
	else if(copy(s,1,4)='The ')then s:=copy(s,5,100)
                else if(copy(s,1,3)='an ')then s:=copy(s,4,100);
if(fitems[equip[4].num]^.rarity>3)then begin
        msg('Your '+s+' wasn''t affected by '+m+'''s acid skin.');
        exit;
        end;
msg(m+'''s acid skin has damaged your '+s+'.');
if(fitems[equip[4].num]^.spec<>2)then begin
        repeat
        inc(equip[4].num);
        until(fitems[equip[4].num]^.spec=2);
        equip[4].mb:=0;
        equip[4].id:=true;
        ids[equip[4].num]:=2;
        msg('It lost its magic power.');
        exit;
        end;
dec(equip[4].mb);}
fake:=nil;
damageitem(fake,@equip[4],true,m+'''s acid skin');
end;

procedure melee(x,y:byte);
var
result,name:string[80];
res,crit,spec:byte;
slay:boolean;
begin
name:=pmon(seemap[x,y],2,monmap[x,y]^);
slay:=false;
if(testbit(monmap[x,y]^.flag,2))and(spc[23]=0)then begin
        case random(4) of
        0:msg('You stab silently.');
        1:msg('You whisper: "Surprise, surprise."');
        2:msg('You stab with icy smile.');
        3:msg('In the last moment '+name+' notices you.');
        end;
        crit:=200;
        inc(spc[1],50);
        end
else crit:=100;
spec:=2;
if(wielded>0)then begin
        spec:=fitems[equip[4].num]^.spec;
	if(testbit(equip[4].flag,2))then spec:=30;
        if(testbit(equip[4].flag,3))then spec:=31;
        end;
case spec of
27:if(equip[4].mb=fmons[monmap[x,y]^.num]^.class)then
	begin res:=att(x,y,0,spc[1],spc[2]*2,0,false,100);slay:=true;end
	else res:=att(x,y,0,spc[1],spc[2],0,false,100);
30:res:=att(x,y,1,spc[1],spc[2],0,false,100);
31:res:=att(x,y,2,spc[1],spc[2],0,false,100);
else res:=att(x,y,0,spc[1],spc[2],0,false,100);
end;
if(spec=30)and(wizard)then msg('FLAMING ATTACK');
if(spec=31)and(wizard)then msg('FREEZING ATTACK');
if(wielded>0)then crit:=crit div fitems[equip[4].num]^.weight
        else crit:=crit div 20;
identifyequip(4);
inc(crit,align[1]);
if(res>0)and(random(100)<sqr(align[1]))and(random(170-skill[sk_crithit])<crit)then begin
        res:=4;
	if(monmap[x,y]^.num>-1)then kill(x,y,100);
        end;
case res of
0:result:='You miss '+name+'.';
1:result:='You hit '+name+' but cause no wound.';
2:result:='You injure '+name+'.';
3:result:='You kill '+name+'.';
4:result:='You manage to deliver a critical blow!';
end;
msg(result);
if(slay)then msg('Your weapon glows brightly.');
if(res in [1,2])then if(testbit(fmons[monmap[x,y]^.num]^.spec,11))and(random(10)=0)then
        weaponacid(pmon(seemap[x,y],0,monmap[x,y]^));
if(res>0)and(random(100)>=weapskill[wielded])and
        ((random(6)<align[0])or((random(3)=0)and(wielded=mainweap)))then inc(weapskill[wielded]);
{       random0-5<fighter1-5 OR(     33 %    AND  wield = rodova zbran )  }
end;

{procedure monaway;
var
x,y,x1,x2,y1,y2:shortint;
begin
x1:=plx-spc[5]-1;if x1<1 then x1:=1;
x2:=plx+spc[5]+1;if x2>x_map then x2:=x_map;
y1:=ply-spc[5]-1;if y1<1 then y1:=1;
y2:=ply+spc[5]+1;if y2>y_map then y2:=y_map;
for x:=x1 to x2 do
        for y:=y1 to y2 do begin
                if(seemap[x,y]=1)and(oldseemap[x,y]=2)then begin seemap[x,y]:=1;drawtile(x,y);end;
                oldseemap[x,y]:=seemap[x,y];
                end;
end;}

procedure moveme(zn:char);
var
m,mov,f,g:byte;
e:integer;
begin
val(zn,mov,e);
if(mov<>5)and(spc[21]>0)then mov:=random(9)+1;
inc(plx,pmx[mov]);
inc(ply,pmy[mov]);
if(map[plx,ply]=12)and(autorun>0)then begin
	autorun:=0;
	dec(plx,pmx[mov]);
	dec(ply,pmy[mov]);
	exit;
	end;
if((plx=1)or(plx=x_map)or(ply=1)or(ply=y_map))and(duntype<>0)and(pass(plx,ply))then begin
	autorun:=0;
	dec(plx,pmx[mov]);
	dec(ply,pmy[mov]);
	if(yesorno('Do you want to leave the '+dungname[duntype]+'?',false))then ascend;
	exit;
	end;
if(duntype=0)then begin
	if(plx=1)then begin plx:=2;storemons;saveloadmap(1);
		dec(wildx);plx:=x_map-1;saveloadmap(0);
		putmons;redraw(true);end;
	if(ply=1)then begin ply:=2;storemons;saveloadmap(1);
		dec(wildy);ply:=y_map-1;saveloadmap(0);
		putmons;redraw(true);end;
	if(plx=x_map)then begin plx:=x_map-1;storemons;saveloadmap(1);
		inc(wildx);plx:=2;saveloadmap(0);
		putmons;redraw(true);end;
	if(ply=y_map)then begin ply:=y_map-1;storemons;saveloadmap(1);
		inc(wildy);ply:=2;saveloadmap(0);
		putmons;redraw(true);end;
	end;
if(monmap[plx,ply]^.num>-1)and(status[2]=1)then begin
	msg('You cannot attack while running!');
	dec(plx,pmx[mov]);
	dec(ply,pmy[mov]);
	exit;
	end;
if(monmap[plx,ply]^.num>-1)and(monmap[plx,ply]^.align=align_companion)then begin
	monmap[plx-pmx[mov],ply-pmy[mov]]^:=monmap[plx,ply]^;
	monmap[plx,ply]^:=emptymon;
	end;
if(monmap[plx,ply]^.num>-1)then begin
	if(abs(monmap[plx,ply]^.mood)=99)then begin
		if(duntype=7)and(not(arena))then begin
			msg('Some magical force prevents you from using your weapon.');
			dec(plx,pmx[mov]);
			dec(ply,pmy[mov]);
			autorun:=0;
			inc(move,100);
			exit;
			end;
		if(yesorno('Do you want to attack this non-hostile creature?',false))then melee(plx,ply)
		else begin inc(move,100);autorun:=0;end;
		end
	else melee(plx,ply);
	dec(plx,pmx[mov]);
	dec(ply,pmy[mov]);
	dec(move,100);
	exit;
	end;
dec(move,100-50*status[2]);
m:=map[plx,ply];
if(m=3)and(autorun=0)then
        if yesorno('Do you want to open the door?',true)=true then begin
		map[plx,ply]:=2;
                oldseemap[plx,ply]:=0;
                dec(plx,pmx[mov]);
                dec(ply,pmy[mov]);
                exit;
                end;
at(plx-pmx[mov],ply-pmy[mov]);write(' ');
if(pass(plx,ply)=false)then begin
        if(autorun=0)then msg('Bang!');
        dec(plx,pmx[mov]);
        dec(ply,pmy[mov]);
        {inc(move,100);}
        autorun:=0;
        end;
{else
        monaway;}
if(m=2)or(m=5)or(m=6)then autorun:=0;
if(mov<>5)and(map[plx,ply]=12)and(random(20)<atrib[1])then begin
        msg('You avoid the trap.');
        exit;
        end;
if(mov<>5)and(map[plx,ply]in[11,12])then begin
        map[plx,ply]:=12;
	traps;
	end;
end;

procedure open;
var
dir,x,y:byte;
begin
dir:=direct;
x:=plx;y:=ply;
inc(x,pmx[dir]);
inc(y,pmy[dir]);
if map[x,y]=3 then
        begin
        map[x,y]:=2;
        see(0);
        dec(move,100);
        end
else
        msg('Nothing to open there.');
end;

procedure closedoor;
var
dir,x,y:byte;
begin
dir:=direct;
x:=plx;y:=ply;
inc(x,pmx[dir]);
inc(y,pmy[dir]);
if(map[x,y]=2)then
	if(itmap[x,y]<>nil)or(monmap[x,y]^.num>-1)then begin
                msg('Something blocks the door.');
                end
        else begin
                map[x,y]:=3;
                oldseemap[x,y]:=0;
                see(0);
                dec(move,100);
        end
else
        msg('Nothing to close there.');
end;

procedure tunnel;
var
dir,x,y:byte;
begin
if autorun=0 then dir:=direct else dir:=autodir;
x:=plx;y:=ply;
inc(x,pmx[dir]);
inc(y,pmy[dir]);
case map[x,y] of
0,4:begin
	if(not(domoves(5,'tunneling')))then exit;
	if random(100)<spc[14] then begin
		map[x,y]:=1;
		autorun:=0;
		msg('You dig through.');
		end
	else if autorun=0 then msg('The rock resists.');
	identifyequip(14);
	see(0);
	{dec(move,200);}
	end;
7:begin
	msg('You break the column.');
	map[x,y]:=1;oldseemap[x,y]:=0;
	if(random(3)=0)then msg('The dungeon ceiling holds firmly.')
	else begin
		msg('The ceiling collapses.');
		oldseemap[x,y]:=0;
		collapse(x,y,3);
		{monaway;}
		end;
	autorun:=0;
	end;
8:begin
	if random(50)<spc[14] then begin
		map[x,y]:=1;
		autorun:=0;
		msg('You remove the rubble.');
		if(itmap[x,y]^.num>-1)then msg('You found something under it.');
		end
	else if autorun=0 then msg('The rubble resists.');
	identifyequip(14);
	see(0);
	dec(move,100);
        end;
99:begin msg('That rock is REALLY hard.');autorun:=0;end;
else begin msg('You cannot tunnel in this direction.');autorun:=0;end;
end;
end;

procedure search(bonus:shortint);
var
x,y:byte;
begin
if(spc[23]>0)then begin
        if(bonus>0)then msg('Not while blinded.');
        exit;
        end;
for x:=plx-1 to plx+1 do
for y:=ply-1 to ply+1 do
if(random(200)<(spc[6]+bonus))then
        case map[x,y] of
        4:begin
                map[x,y]:=3;
                oldseemap[x,y]:=0;
		msg('You found a secret door!');
		autorun:=0;
		end;
	11:begin
                map[x,y]:=12;
                oldseemap[x,y]:=0;
                msg('You found a trap!');
                autorun:=0;
                end;
        end;
if bonus>0 then dec(move,200);
end;

procedure inventory;
begin
itemsel(inv,99,'','',-1);
redraw(true);
end;

procedure eat;
var
mv,sel:byte;
it:itemptr;
begin
if(status[3]=4)then begin
	msg('You are full enough.');
	exit;
	end;
it:=itemsel(inv,13,'food','eat',-1);
if(it=nil)then begin redraw(true);exit;end;
mv:=fitems[it^.num]^.weight*2;
mv:=(mv div 100)+1;
redraw(true);
if(not(domoves(mv,'eating')))then exit;
inc(origspc[19],fitems[it^.num]^.bonus*100);
msg('Yum yum.');
if(fitems[it^.num]^.spec>0)then raisespc(fitems[it^.num]^.spec,0,fitems[it^.num]^.mb);
ids[it^.num]:=2;
takeaway(inv,it);
{redraw(true);}
end;

procedure take;
var
it:itemptr;
begin
if(itemcount(itmap[plx,ply])=0)then exit;
if(itemcount(itmap[plx,ply])=1)or(cmnd=';')then it:=itmap[plx,ply]
	else begin
		it:=itemsel(itmap[plx,ply],99,'item','take',-1);
		redraw(true);
		end;
if(it=nil)then exit;
if(it^.num=0)then begin
	inc(goldown,it^.mb);
	takeaway(itmap[plx,ply],it);
	exit;
	end;
if(itemcmp(it^,equip[13]))then begin
	msg('Missiles added to missile slot.');
	inc(equip[13].q,it^.q);
	it^.q:=1;takeaway(itmap[plx,ply],it);
	dec(move,100);
	exit;
	end;
itemsortinto(inv,it^);
msg('You pick up '+pitem(it^,1,true,true)+'.');
if(testbit(it^.flag,2))or(testbit(it^.flag,3))or(fitems[it^.num]^.spec in[30,31])then begin
	msg('OUCH!');
	wound(1);
	end;
it^.q:=1;takeaway(itmap[plx,ply],it);
dec(move,100);
end;

procedure drop;
var
sel:byte;
temp:word;
it:itemptr;
it2:item;
begin
it:=itemsel(inv,99,'item','drop',-1);
redraw(true);
if(it=nil)then exit;
temp:=it^.q;
if(temp>1)and(not(yesorno('Drop all?',true)))then temp:=1;
it2:=it^;it2.q:=temp;
msg('You drop '+pitem(it2,1,true,true)+'.');
itemsortinto(itmap[plx,ply],it2);
it^.q:=it^.q-temp+1;
takeaway(inv,it);
dec(move,100);
end;

procedure fire;
var
x,y,wtype,mtype,result:shortint;
hit,dam:integer;
act:string[80];
victim:string[30];
it:item;
begin
if(spc[21]>0)then begin
        msg('You are too confused.');
	exit;
        end;
if(equip[13].num=-1)then begin
	msg('You should use some missiles.');
	exit;
	end;
x:=plx;y:=ply;
if(not(target(x,y,spc[5],true)))or(seemap[x,y]<2)then begin
        msg('You cannot see there.');
        exit;
        end;
if(x=plx)and(y=ply)then exit;
if(not(pass(x,y)))then begin
        msg('Why should you do that?');
        exit;
        end;
if(rangedw>0)then act:='shoot'
        else act:='throw';
hit:=spc[24];
dam:=spc[25];
act:='You '+act+' '+pitem(equip[13],1,false,false);
if(rangedw>0)then identifyequip(12);
identifyequip(13);
it:=equip[13];
it.q:=1;
if(monmap[x,y]^.num=-1)then begin
        msg(act+'.');
	if(fitems[it.num]^.spec=26)and(random(10)<it.mb)then
                msg('The missile returns.')
        else begin
		itemsortinto(itmap[x,y],it);
		oldseemap[x,y]:=0;
		dec(equip[13].q);
		if(equip[13].q=0)then equip[13].num:=-1;
                if(equip[13].num=-1)then msg('You are out of ammo.');
                end;
        dec(move,100);
        exit;
        end;
victim:=pmon(2,2,monmap[x,y]^);
result:=att(x,y,hit,dam,0,0,false,100);
case result of
0:msg(act+' but miss.');
1:msg(act+' and hit but cause no wound.');
2:msg(act+' and injure '+victim+'.');
3:msg(act+' and kill '+victim+'.');
end;
if(result>0)and(random(100)>=weapskill[rangedw+6])and(random(5)<align[3])then begin
        inc(weapskill[rangedw+6],random(align[3])+1);
        if(weapskill[rangedw+6]>100)then weapskill[rangedw+6]:=100;
        end;
if(fitems[it.num]^.spec=26)and(random(10)<it.mb)then
        msg('The missile returns.')
else begin
	if(random(2)=0)or((fitems[it.num]^.spec=26)and(random(5)=0))or(fitems[it.num]^.rarity>3)
                then itemsortinto(itmap[x,y],it);
        dec(equip[13].q);
	if(equip[13].q=0)then equip[13].num:=-1;
	if(equip[13].num=-1)then msg('You are out of ammo.');
	end;
dec(move,100);
end;

procedure drinkpool;
begin
if(origspc[20]>1000)then begin
	msg('You feel too watery to drink from the pool.');
	more;
	drink;
	exit;
	end;
if(not(yesorno('Do you want to drink from the pool?',true)))then begin
	drink;
	exit;
	end;
dec(move,100);
if((typemap[plx,ply] mod 10)=0)then inc(typemap[plx,ply],random(3)+1);
case (typemap[plx,ply] mod 10) of
1:begin
	msg('Aaah, very refreshing.');
	inc(origspc[20],1500);
	end;
2:begin
	msg('Uuh, it tastes like mud.');
	inc(origspc[20],700);
	end;
3:begin
	msg('Aaarrrgghh, it is poisoned!');
	raisespc(22,random(5)+3,1);
	inc(origspc[20],300);
	end;
end;
dec(typemap[plx,ply],10);
if((typemap[plx,ply] div 10)=0)then begin
	msg('The pool is empty.');
	map[plx,ply]:=1;
	typemap[plx,ply]:=0;
	end;
end;

procedure fillflask;
var
itp:itemptr;
it:item;
begin
if(map[plx,ply]<>13)then begin
	msg('First find a pool to fill from!');
	exit;
	end;
if((typemap[plx,ply]mod 10)=0)then begin
	msg('You wouldn''t want to drink from an unknown pool, would you?');
	exit;
	end;
itp:=itemsel(inv,10,'potion','pour out',-1);
redraw(true);
if(itp=nil)then exit;
takeaway(inv,itp);
randomitem(find(100+(typemap[plx,ply]mod 10)),99,255,50,it);
itemsortinto(inv,it);
if(random(2)=0)then begin
	dec(typemap[plx,ply],10);
	if((typemap[plx,ply] div 10)=0)then begin
		msg('The pool is empty.');
		map[plx,ply]:=1;
		typemap[plx,ply]:=0;
		end;
	end;
{redraw(true);}
end;

procedure statusscreen;
var
f:byte;
begin
recompute;
clrscr;
ink(15);
at(2,2); write(guildname[vdata[0]],' ',name,' ',title);
at(2,3); write(racename[race]);
ink(7);
at(2,5); write('STRENGTH:     ',scale20(origatrib[0]div 4));
at(2,6); write('AGILITY:      ',scale20(origatrib[1]div 4));
at(2,7); write('LEARNING:     ',scale20(origatrib[2]div 4));
at(2,8); write('CONSTITUTION: ',scale20(origatrib[3]div 4));
at(2,9); write('PIETY:        ',scale20(origatrib[4]div 4));
at(2,10);write('LUCK:         ',scale100(origatrib[5]div 10));
at(2,12);write('HIT:          ',scale100(spc[1]div 10));
at(2,13);write('DAMAGE:       ',scale100(spc[2]div 10));
at(2,14);write('DEFENCE:      ',scale100(spc[3]div 10));
at(2,15);write('PERCEPTION:   ',scale100((spc[6]+atrib[1])div 10));
at(2,16);write('TUNNELING:    ',scale100(spc[14]div 10));
at(2,17);write('STEALTH:      ',scale100(spc[29]div 10));
at(2,18);write('SPEED:        ');
if spc[4]<200 then write(scale100(spc[4]div 20)) else write(scale100(10));
at(2,20);write('GOLD:         ',goldown);
ink(15);
at(50,3); write('Weapon skills:');
ink(7);
if wielded=0 then ink(14);
at(50,5); write('HANDS:    ',scale100(weapskill[0]div 10));
ink(7);
if wielded=1 then ink(14);
at(50,6); write('DAGGERS:  ',scale100(weapskill[1]div 10));
ink(7);
if wielded=2 then ink(14);
at(50,7); write('SWORDS:   ',scale100(weapskill[2]div 10));
ink(7);
if wielded=3 then ink(14);
at(50,8); write('AXES:     ',scale100(weapskill[3]div 10));
ink(7);
if wielded=4 then ink(14);
at(50,9); write('HAMMERS:  ',scale100(weapskill[4]div 10));
ink(7);
if wielded=5 then ink(14);
at(50,10);write('STAVES:   ',scale100(weapskill[5]div 10));
ink(7);
if mainweap<>99 then begin at(43,mainweap+5);write('(main)');end;
if(rangedw=0)then ink(14);
at(50,12);write('THROWN:   ',scale100(weapskill[6]div 10));
ink(7);
if(rangedw=1)then ink(14);
at(50,13);write('SLINGS:   ',scale100(weapskill[7]div 10));
ink(7);
if(rangedw=2)then ink(14);
at(50,14);write('BOWS:     ',scale100(weapskill[8]div 10));
ink(7);
if(rangedw=3)then ink(14);
at(50,15);write('CROSSBOWS:',scale100(weapskill[9]div 10));
ink(15);
at(2,22);write('Professions:');
ink(7);
at(2,24);write('FIGHTER: ',scale20(align[0]-1));
at(2,25);write('THIEF:   ',scale20(align[1]-1));
at(2,26);write('WIZARD:  ',scale20(align[2]-1));
at(2,27);write('RANGER:  ',scale20(align[3]-1));
at(2,28);write('PRIEST:  ',scale20(align[4]-1));
corner;
if(wizard)then begin
        at(1,50);write('resist F',spc[15],' C',spc[16],' L',spc[17],' *',spc[18]);
	write('   flaming ',spc[30],'   freezing ',spc[31]);
        end;
zn:=readkey;
clrscr;ink(15);
at(2,2);write('Your skills:');
ink(7);
typeskills;
corner;
zn:=readkey;
redraw(true);
end;

procedure saveloadgame(save:byte);      {0-load,1-save}
var
f,g:integer;
size:word;
begin
filename:=name;
if(loading=0)then begin
{       if(save=0)and(not(yesorno('Are you sure you want to load a game?',false)))then exit;}
	if(save=1)and(not(iyesorno('Are you sure you want to save and quit?')))then exit;
        filename:=name;
{       if(save=0)then begin
		at(1,y_map+1);write('Type the name of the hero you want to load:');
                filename:=input(44,y_map+1,8,name);
                at(1,y_map+1);clreol;
                if(not(exist(filename+'\'+filename+'.sav')))then begin
			msg('No such file exists.');
                        exit;
                        end;
                end;}
        end;
if(save=1)then begin cmnd:='Q';loading:=10;end;
chdir(filename);
assign(savefile,filename+'.sav');
{if(save=1)and(exist(filename))and
	(not(yesorno('File "'+filename+'.sav" already exists.Do you want to overwrite it?',false)))then
        begin chdir('..');exit;end;}
if(save=1)then begin
        rewrite(savefile);
        msg('Saving...');
        end
else begin
        reset(savefile);
{       msg('Loading...');}
        end;
diskop(@name,sizeof(name),save);
diskop(@title,sizeof(title),save);
diskop(@race,sizeof(race),save);
diskop(@expr,sizeof(expr),save);
diskop(@explev,sizeof(explev),save);
diskop(@nextlev,sizeof(nextlev),save);
size:=sizeof(weapskill[0]);
for f:=0 to 9 do diskop(@weapskill[f],size,save);
diskop(@mainweap,sizeof(mainweap),save);
diskop(@wielded,sizeof(wielded),save);
diskop(@twohanded,sizeof(twohanded),save);
size:=sizeof(spellskill[0]);
for f:=0 to spellnum do diskop(@spellskill[f],size,save);
for f:=0 to skillnum do diskop(@skill[f],size,save);
case save of
0:begin
        destroylist(inv);
	loadlist(inv);
        end;
1:savelist(inv);
end;
size:=sizeof(equip[0]);
for f:=0 to equip_num do diskop(@equip[f],size,save);
for f:=0 to spc_num do begin
        diskop(@origspc[f],sizeof(origspc[f]),save);
        diskop(@spctime[f],sizeof(spctime[f]),save);
        diskop(@spcmodif[f],sizeof(spcmodif[f]),save);
        end;
size:=sizeof(status[0]);
for f:=0 to stat_num do diskop(@status[f],size,save);
diskop(@move,sizeof(move),save);
diskop(@move2,sizeof(move2),save);
diskop(@patro,sizeof(patro),save);
diskop(@wildx,sizeof(wildx),save);
diskop(@wildy,sizeof(wildy),save);
diskop(@duntype,sizeof(duntype),save);
size:=sizeof(wilddung[1,1]);
for f:=1 to wildsize do
for g:=1 to wildsize do
        diskop(@wilddung[f,g],size,save);
size:=sizeof(wildmap[1,1]);
for f:=1 to wildsize do
for g:=1 to wildsize do
        diskop(@wildmap[f,g],size,save);
diskop(@goldown,sizeof(goldown),save);
diskop(@movecount,sizeof(movecount),save);
for f:=0 to 4 do diskop(@align[f],sizeof(align[f]),save);
for f:=0 to 5 do diskop(@origatrib[f],sizeof(origatrib[f]),save);
diskop(@plx,sizeof(plx),save);
diskop(@ply,sizeof(ply),save);
diskop(@orighlt,sizeof(orighlt),save);
diskop(@hlt,sizeof(hlt),save);
diskop(@origspl,sizeof(origspl),save);
diskop(@spl,sizeof(spl),save);
for f:=0 to noofitems-1 do begin
	diskop(@(fitems[f]^.rarity),sizeof(byte),save);
        diskop(@ids[f],sizeof(ids[f]),save);
	end;
for f:=0 to noofmons-1 do diskop(@(fmons[f]^.rarity),sizeof(shortint),save);
size:=sizeof(vdata[0]);
for f:=0 to vdatanum do diskop(@vdata[f],size,save);
diskop(@arena,1,save);
if(wizard)then writeln('SHOPS');
size:=sizeof(shoptype);
for f:=0 to shop_num do begin
	diskop(shop[f],size,save);
	case save of
	0:begin
		{destroylist(shop[f]^.inv);}
		shop[f]^.inv:=nil;
		loadlist(shop[f]^.inv);
		end;
	1:savelist(shop[f]^.inv);
	end;
	end;
chdir('..');
close(savefile);
saveloadmap(save);
{chdir('..');}
redraw(true);
msg('Disk operation complete.');
end;

procedure walk;
begin
if(spc[21]>0)then begin msg('Not while confused.');exit;end;
if(spc[22]>0)then begin msg('Not while poisoned.');exit;end;
if(spc[23]>0)then begin msg('Not while blind.');exit;end;
if(status[3]<2)then begin msg('Not while hungry.');exit;end;
if(status[4]<2)then begin msg('Not while thirsty.');exit;end;
at(1,y_map+1);write('Enter a walk command.');clreol;
zn:=readkey;
at(1,y_map+1);clreol;
autocmnd:=zn;
autorun:=0;
autocount:=0;
case autocmnd of
'1'..'9':begin
        autodir:=0;
	autorun:=1;
        end;
't':begin
        autodir:=direct;
        autorun:=1;
        end;
's':begin
        autodir:=0;
        autorun:=1;
        end;
else
        msg('Not a walk command.');
end;
if autorun=1 then autocount:=autostep;
end;








{
        HLAVNI PROGRAM
}
begin
origmode:=lastmode;
textmode(co80+font8x8);
if(not(wizard))then begin titlescreen;levelsaving:=true;end;
randomize;
loading:=0;name:='';
if(paramstr(1)='-l')and(paramstr(2)<>'')then begin loading:=1;name:=paramstr(2);end;
if(loading=1)and(not(exist(name+'\'+name+'.sav')))then begin loading:=2;name:='';end;
if(loading<>1)then begin
        ink(7);clrscr;
        at(5,10);write('Do you want to load a game? ');
	ink(14);write('(y/N)');ink(7);
        zn:=readkey;
	if(zn='y')or(zn='Y')then begin
		at(4,12);write('Type the name of the hero you want to load:');
		filename:=txinput(4,13,8,name);
                at(1,y_map+1);clreol;
                if(not(exist(filename+'\'+filename+'.sav')))then begin
			at(4,15);write('No savegame exists for this hero.');
                        zn:=readkey;
                        end
                else begin
                        name:=filename;
                        loading:=1;
                        end;
                end;
        end;

inititems;
initmonsters('monster.dat',true);
initdungeons;
init;
if(loading<>1)then begin
	character;
	bonuses;
	end;
initskills;
initshops;
if(loading<>1)then begin
	plx:=random(10)+20;ply:=random(10)+15;duntype:=0;patro:=0;newlevel;
	redraw(true);
	{scanforstairs(1);}
	if(newcompanion)then begin
		randommon(-1,99,random(10)+1,monmap[plx-1,ply-1]^);
		monmap[plx-1,ply-1]^.align:=align_companion;
		monmap[plx-1,ply-1]^.flag:=0;
		end;
	nextlev:=nextlv(1);
	see(spc[5]);
	end
else saveloadgame(0);



{        zacatek hlavni smycky        }
repeat
printstats;
if(wizard)then begin at(62,39);write('water:',origspc[20],' ');end;
at(plx,ply);

{<WHILE>}
while(move>0)and(cmnd<>'Q') do
begin
if(monmap[plx,ply]^.num>-1)then begin
        msg('You telefraged '+pmon(2,1,monmap[plx,ply]^)+'.');
	kill(plx,ply,0);
	end;
if(arena)and(hlt=0)then begin
	donearena;
	hlt:=orighlt;
	msg('*You were defeated.');
	msg('Bad luck, no prize! But surely next time YOU will be the Winner!');
	end;
if(hlt=0)then begin
	msg('You die.');more;
	cmnd:='Q';
	loading:=0;
	break;
	end;
if(hlt=2)then msg('You are near death!');
if(hlt=1)then msg('YOU ARE NEAR DEATH!');
while(expr>=nextlev)and(explev<50)do begin
	dec(expr,nextlev);
        inc(explev);nextlev:=nextlv(explev);
        msg('You have reached a new level!');
        more;
        raiseskill;
	if(vdata[0]=2)and((explev mod 2)=0)then inc(vdata[1]);
	if(vdata[0]=4)then dec(vdata[1],1);
        end;
printstats;
if map[plx,ply]=5 then msg('There is a staircase leading upwards here.');
if map[plx,ply]=6 then begin
	if(duntype<>0)then msg('There is a staircase leading downwards here.')
        else msg('You see an entrance here.');
        if(patro=0)then msg('It leads to the '+dungname[wilddung[wildx,wildy]]+'.');
	end;
if(map[plx,ply]=13)then msg('There is a small pool of water here.');
if(itmap[plx,ply]<>nil)then
if(itmap[plx,ply]^.num=0)then begin
        inc(goldown,itmap[plx,ply]^.mb);
	msg('You pick up '+pitem(itmap[plx,ply]^,1,false,true)+'.');
        itptr:=itmap[plx,ply];
        takeaway(itmap[plx,ply],itptr);
        end;
if(itemcount(itmap[plx,ply])>0)then begin
	if(spc[23]=0)then
		case(itemcount(itmap[plx,ply]))of
                1:msg('You see '+pitem(itmap[plx,ply]^,1,true,true)+'.');
                2:begin
			msg('You see '+pitem(itmap[plx,ply]^,1,true,true)+'.');
                        msg('You see '+pitem((itmap[plx,ply]^.next)^,1,true,true)+'.');
                        end;
                3:begin
                        msg('You see '+pitem(itmap[plx,ply]^,1,true,true)+'.');
                        msg('You see '+pitem((itmap[plx,ply]^.next)^,1,true,true)+'.');
                        msg('You see '+pitem(((itmap[plx,ply]^.next)^.next)^,1,true,true)+'.');
                        end;
                else msg('Some items are lying here.');
		end
	else msg('Something is lying here.');
        if autocount<autostep then autorun:=0;
        end;
search(0);
see(spc[5]);
if(monalarm)then autorun:=0;
if(hlt=orighlt)and(spl=origspl)and(autorun=1)and(autocmnd='5')then autorun:=0;
if(autorun=0)and(spc[28]=0)then
	cmnd:=readkey
else if(spc[28]>0)then cmnd:='5'
        else begin
                cmnd:=autocmnd;
                dec(autocount);
		if autocount=0 then autorun:=0;
		end;
if(spc[28]=0)then begin
        for f:=1 to msg_num do begin
		at(1,y_map+f+1);clreol;msgtext[f]:='';
                end;
        txtbuf:=1;
        end;
move2:=move;
case cmnd of
#1 :if(wizard)then w_artif:=not(w_artif);               {^A artefakt na kazdem patre}
#2 :if(wizard)then butcher;                             {^B reznik}
#3 :if(wizard)then origspc[28]:=1-origspc[28];          {^C blindness}
#4 :if(wizard)then inc(patro);                          {^D down o 1 patro}
#5 :if(wizard)then monmap[plx+1,ply]^.align:=1;		{^E friEnd to the East}
#7 :if(wizard)then inc(goldown,1000);                   {^G +1000 gold}
#8 :if(wizard)then hlt:=orighlt;                        {^H heal}
#9 :if(wizard)then w_identify:=not(w_identify);         {^I ident.vseho na novem patre}
#10:if(wizard)then dec(hlt);                            {^J inJury}
#12:if(wizard)then begin
	inc(explev);nextlev:=nextlv(explev);end;        {^L gain level}
#13:if(wizard)then drawmap;                             {^M mapa}
#17:if(wizard)then wizhelp;                             {^Q wizhelp}
#19:if(wizard)then inc(movecount,100);			{^S steps}
#20:if(wizard)then begin                                {^T konkretni item}
	at(1,y_map+1);write('Number:');readln(f);
	randomitem(f,99,255,atrib[5],it);
	itemsortinto(itmap[plx,ply],it);
	end;
#22:if(wizard)then dec(origspc[20],100);		{^V thirst}
#23:if(wizard)then w_god:=not(w_god);                   {^W god mode}
#21:if(wizard)then dec(patro);                          {^U up o 1 patro}
#24:if(wizard)then begin                                {^X examine}
	itptr:=itemsel(inv,99,'','',-1);
	writeln;
	writeln('NUM:',itptr^.num);
	writeln('MB:',itptr^.mb);
	zn:=readkey;
	end;
#25:if(wizard)then vdata[0]:=0;				{^Y no guild}
#26:if(wizard)then begin                                {^Z turn off WIZARD}
	wizard:=false;
	msg('You are no longer WIZARD.');
	w_god:=false;
	end
	else begin
		at(1,y_map+1);write('Enter WIZARD mode password:');
		if(txinput(28,y_map+1,10,'')=wizardpasswd)then wizard:=true;
                end;
'0':if(wizard)then seznam;                              {NULA seznam vsech predmetu}
'a':status[5]:=1-status[5];
'A':mask;
'b':scribe;
'c':closedoor;
'C':statusscreen;
'd':drop;
'D':if(map[plx,ply]=13)then drinkpool else drink;
'e':begin equipme;redraw(true);end;
'E':eat;
'f':fire;
'F':fillflask;
'i':inventory;
'l':target(x,y,spc[5],false);
{'L':saveloadgame(0);}
'm':study;
'M':msgbuf;
'o':open;
'p':wildmapdraw;
'r':readsc;
'R':status[2]:=1-status[2];
's':search(spc[6]*4);
'S':if(arena)then
	msg('No saving in the Arena!')
	else saveloadgame(1);
't':tunnel;
'V':version;
'w':walk;
'W':beep;
'z':zap;
'Z':cast;
'^':disarm;
'<':if(map[plx,ply]=5)then ascend;
'>':if(map[plx,ply]=6)then descend;
'1'..'9':moveme(cmnd);
'!':redraw(true);
',',';':take;
'_':pray;
'#':begin
        clrscr;
        for f:=1 to 50 do begin
                nextlev:=nextlv(f);
                writeln(nextlev);
		end;
	nextlev:=nextlv(explev);
	end;
'?':begin help;redraw(true);end;
'Q':if(wizard)or(iyesorno('Do you really want to quit without saving?'))then begin
		cmnd:='Q';deathverb:='brutally murdered';deathreason:='quitting';
		end
	else cmnd:=' ';
else begin
	msg('Press ''?'' to get help.');
	if(wizard)then msg('Press CTRL-Q to get wizard help.');
	end;
end;
see(spc[5]);
if(atrib[4]=1)then begin
	msg('A thundering voice in your head says:');
	msg('"Enough, sinner!"');
	hlt:=0;
	deathverb:='killed';deathreason:='divine wrath';
	end;
if(hlt=0)then begin
	msg('You die.');more;
	cmnd:='Q';
	loading:=0;
	break;
	end;
if((move-move2)<>0)then movemons;
end;
{</WHILE>}

doturn;
if(movestodo=-1)then movestodo:=-99;
if(movecount mod 70)=0 then newmonster;
until(cmnd='Q');

if(loading<>10)then begin
	grave;
	at(1,1);write(guildname[vdata[0]],' ',name,' ',title,' (',racename[race]);
	if(deathreason<>'')then write(') was ',deathverb,' by ',deathreason,'.')
		else write(') has ',deathverb,'.');
	zn:=readkey;
	if(not(wizard))then begin
		chdir(name);
		FindFirst('*.*', Anyfile, DirInfo);
		while DosError = 0 do begin
			if(exist(dirinfo.name))then begin
                                assign(savefile,DirInfo.Name);
				erase(savefile);
{                                close(savefile);}
                                end;
                        FindNext(DirInfo);
                        end;
                chdir('..');
                end;
        end;
scoring;
textmode(origmode);
doneitems;
donemonsters(true);
doneshops;
end.