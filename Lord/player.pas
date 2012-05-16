unit player;

interface

uses crt,mycrt,items,gfx,dos;

const
stat_num = 5;
status:array[0..stat_num]of shortint = (0,0,0,2,2,0);
guildnum = 4;
guildname:array[0..guildnum]of string[15] = ('adventurer','mercenary','warlock','monk','gladiator');
vdatanum = 2;
vdata:array[0..vdatanum]of integer = (0,0,0);{various data}

var
name:string[8];
title:string[15];
plx,ply,hlt,orighlt,spl,origspl:shortint;
mainweap,wielded,rangedw,explev:byte;
twohanded:boolean;
weapskill:array[0..9]of byte;
spellskill:array[0..spellnum]of byte;
origspc,spc,spctime,spcmodif:array[0..spc_num]of integer;
move,move2,gold,patro,duntype:integer;
{               ^^^^^ ^^^^^^^          }
{      zmenu hlasit v editoru !!!      }

movecount,expr,nextlev:longint;
align:array[0..4]of byte;
origatrib,atrib:array[0..5]of shortint;
w_god:boolean;

{procedure savepl(name:string);}
procedure character;
procedure recompute;
procedure printstats;
procedure wound(dam:shortint);
procedure raisespc(n:byte;time:integer;amount:shortint);
procedure lowerspc(n:byte);
procedure scoring;
procedure pray;
function nextlv(n:byte):longint;
procedure equipme;


implementation



procedure character;
var
atmin:array[0..4]of byte;
{path:string[80];}
sel,f:byte;
dirinfo:searchrec;
filename:file of byte;
begin
clrscr;
if(wizard)then begin
	at(1,49);write('WIZARD mode is active. Please notify the author at ');
	ink(14);write('vaclav.jucha.fei@vsb.cz');
	ink(7);
	at(1,50);writeln('Press CTRL-Z during the game to disable it.');
	end;
at(5,2);write('Choose your race:');
at(2,4);writeln('a) Human');
writeln(' b) Elf');
writeln(' c) Hobbit');
writeln(' d) Troll');
writeln(' e) Dwarf');
writeln(' f) Orc');
writeln(' g) Fallen angel');
select(7,0,race);
case race of
0:for f:=0 to 4 do atmin[f]:=6;
1:begin {elf}
	atmin[0]:=5;
	atmin[1]:=8;
	atmin[2]:=8;
	atmin[3]:=3;
	atmin[4]:=6;
	end;
2:begin {hobbit}
	atmin[0]:=3;
	atmin[1]:=8;
	atmin[2]:=6;
	atmin[3]:=7;
	atmin[4]:=6;
	end;
3:begin {troll}
	atmin[0]:=10;
	atmin[1]:=4;
	atmin[2]:=1;
	atmin[3]:=9;
	atmin[4]:=6;
	end;
4:begin {dwarf}
	atmin[0]:=8;
	atmin[1]:=3;
	atmin[2]:=4;
	atmin[3]:=8;
	atmin[4]:=8;
	end;
5:begin {orc}
	atmin[0]:=8;
	atmin[1]:=7;
	atmin[2]:=4;
	atmin[3]:=6;
	atmin[4]:=5;
	end;
6:begin {fallen angel}
	for f:=0 to 3 do atmin[f]:=10;
	atmin[4]:=1;
	end;
end;
repeat
clrscr;
origatrib[5]:=105;
for f:=0 to 4 do
begin
	origatrib[f]:=random(9)+atmin[f];
	if origatrib[f]<2 then origatrib[f]:=2;
	if(f=4)and(race=6)and(origatrib[4]>5) then origatrib[4]:=5;
	dec(origatrib[5],origatrib[f]);
end;
if race=2 then inc(origatrib[5],10);
if race=6 then dec(origatrib[5],10);if origatrib[5]<5 then origatrib[5]:=5;
at(2,3);write(racename[race]);
at(4,5);write('STR: ',scale20(origatrib[0]div 4));
at(4,6);write('AGI: ',scale20(origatrib[1]div 4));
at(4,7);write('LEA: ',scale20(origatrib[2]div 4));
at(4,8);write('CON: ',scale20(origatrib[3]div 4));
at(4,9);write('PIE: ',scale20(origatrib[4]div 4));
at(4,10);write('LCK: ',scale100(origatrib[5]div 10));
until(yesorno('Keep this character?',true)=true);
at(41,5);writeln('a) Fighter');
at(41,6);writeln('b) Thief');
at(41,7);writeln('c) Wizard');
at(41,8);writeln('d) Ranger');
at(41,9);writeln('e) Priest');
for f:=0 to 4 do align[f]:=0;
for f:=5 downto 1 do
begin
	at(35,3);write('Which aspect will be rated ',scale20(f-1));
	repeat
	select(5,0,sel);
	until(align[sel]=0);
	align[sel]:=f;
	inc(origatrib[sel],(align[sel]-3)*2);
	if(origatrib[sel]<3) then origatrib[sel]:=3;
	if(origatrib[sel]>20)then origatrib[sel]:=20;
	at(52,sel+5);write('- ',scale20(f-1));
end;
orighlt:=(origatrib[3] div 4)+align[3]+1;
hlt:=orighlt;
origspl:=(origatrib[2] div 4)+align[2];
spl:=origspl;
mainweap:=99;
if(align[1]=5)then mainweap:=1;
if(align[2]=5)then mainweap:=5;
if(align[3]=5)then mainweap:=2;
if(align[4]=5)then mainweap:=4;
at(35,3);clreol;
at(4,5);write('STR: ',scale20(origatrib[0]div 4));
at(4,6);write('AGI: ',scale20(origatrib[1]div 4));
at(4,7);write('LEA: ',scale20(origatrib[2]div 4));
at(4,8);write('CON: ',scale20(origatrib[3]div 4));
at(4,9);write('PIE: ',scale20(origatrib[4]div 4));
at(4,10);write('LCK: ',scale100(origatrib[5]div 10));
if race=4 then begin dec(origspc[4],10);inc(origspc[5]);end;
if race=6 then inc(origspc[4],20);
origspc[6]:=(align[1]+align[3])*2;
repeat
at(2,15);write('Now name the newborn hero:');
at(4,17);clreol;at(4,22);clreol;
at(4,18);write('^^^^^^^^');
name:=txinput(4,17,8,'');
for f:=1 to 8 do
	while(name[f] in [' ','.',#128..#255])and(length(name)>0)do
		delete(name,f,1);
if(name='')then name:='Hero';
at(4,17);write(name);clreol;
if(name<>'Hero')then begin
	at(2,20);write('Now select your title:');
	at(4,23);write('^^^^^^^^^^^^^^^');
	title:=txinput(4,22,15,'');
	end
else title:='the Heroic';
{$I-}
mkdir(name);
{$I+}
if(ioresult=0)then ;
if(exist(name+'\'+name+'.sav'))then begin
	if(yesorno('A savegame for this hero already exists. Do you want to delete it?',false))
	then begin
		chdir(name);
		FindFirst('*.*', Anyfile, DirInfo);
		while DosError = 0 do begin
			if(exist(dirinfo.name))then begin
				assign(filename,DirInfo.Name);
				erase(filename);
{				close(filename);}
				end;
			FindNext(DirInfo);
			end;
		chdir('..');
		end
	else name:='';
	end;
until(name<>'');
if align[4]=5 then begin randomitem(find(81),99,1,50,equip[1]);equip[1].id:=true;ids[31]:=2;end;
end;

procedure countweight;
var
cur:itemptr;
f:byte;
begin
weight:=0;eqweight:=0;
cur:=inv;
while(cur<>nil)do begin
	inc(weight,(fitems[cur^.num]^.weight)*cur^.q);
	cur:=cur^.next;
	end;
for f:=0 to equip_num do
	if(equip[f].num>-1)then inc(eqweight,fitems[equip[f].num]^.weight*equip[f].q);
end;

procedure recompute;
var
f,m:byte;
num:integer;
begin
countweight;
m:=1;
if(equip[12].num>-1)and(equip[13].num>-1)then
	m:=fitems[equip[12].num]^.subclass-fitems[equip[13].num]^.subclass;
if(m=0)then rangedw:=fitems[equip[12].num]^.subclass else
	if(equip[13].num>-1)then rangedw:=0 else
		rangedw:=99;
for f:=0 to 5 do atrib[f]:=origatrib[f];
for f:=0 to spc_num do spc[f]:=origspc[f];
for f:=0 to equip_num do
begin
	num:=equip[f].num;
	if num>-1 then
	begin
		if(f=12)and(m<>0)then continue;
		case fitems[num]^.class of
		1:inc(spc[2],fitems[num]^.bonus);
		2..6,9:inc(spc[3],fitems[num]^.bonus);
		end;
		if(testbit(equip[f].flag,0))or(testbit(equip[f].flag,1))then
			inc(spc[ord(testbit(equip[f].flag,0))+ord(testbit(equip[f].flag,1))*2+14]);
		if(fitems[num]^.spec=7)then begin
			inc(spc[7],equip[f].mb*50);
			continue;
			end;
		if(testbit(equip[f].flag,2))and(f in[0,2,3,5..7])then inc(spc[30]);
		if(testbit(equip[f].flag,3))and(f in[0,2,3,5..7])then inc(spc[31]);
		if(fitems[num]^.spec in[30,31])and(f=4)then continue;
		inc(spc[fitems[num]^.spec],equip[f].mb);
	end;
end;
for f:=0 to 4 do
begin
	if(origspc[f+8]<>0)then begin
		inc(origatrib[f],origspc[f+8]);
		origspc[f+8]:=0;
		end;
	if((origatrib[f]-spcmodif[f+8])>20)then begin
		msg('Your body is unable to hold so much power permanently.');
		raisespc(f+8,0,20-(origatrib[f]-spcmodif[f+8]));
		end;
	inc(atrib[f],spc[f+8]);
	if atrib[f]<1 then atrib[f]:=1;
{	if atrib[f]>20 then atrib[f]:=20;}
end;
f:=orighlt-hlt;
orighlt:=(atrib[3] div 4)+1;
if(align[3]>align[0])then inc(orighlt,align[3])
	else inc(orighlt,align[0]);
if(orighlt>11)then orighlt:=11;
hlt:=orighlt-f;if(hlt<0)then begin
	hlt:=0;
	deathverb:='killed';deathreason:='sudden weakness';
	end;
f:=origspl-spl;
origspl:=(atrib[2] div 4)+align[2];
spl:=origspl-f;
if(spl<0)then spl:=0;
inc(atrib[5],spc[13]);
if atrib[5]<0 then atrib[5]:=0;
if atrib[5]>100 then atrib[5]:=100;
inc(spc[1],weapskill[wielded]);
inc(spc[2],atrib[0]);
inc(spc[3],atrib[1]);
inc(spc[4],atrib[1]);
inc(spc[5],(skill[sk_track]div 24));
if(duntype=0)then inc(spc[5],2);
inc(spc[14],atrib[0]);
inc(spc[24],atrib[1]);
inc(spc[29],atrib[1]*3);
if(rangedw<99)then inc(spc[25],fitems[equip[13].num]^.bonus);
if(rangedw in [1..5])then inc(spc[25],fitems[equip[13].num]^.bonus+equip[13].mb);
if(rangedw<>99)then inc(spc[24],weapskill[rangedw+6]);
spc[1]:=(spc[1]*skill[sk_melee])div 100;
spc[2]:=(spc[2]*skill[sk_melee])div 100;
spc[3]:=((spc[3]div 2)*(100+skill[sk_melee]))div 100;
inc(spc[3],status[5]*(weapskill[wielded]div 4 +10));
for f:=0 to spc_num do
begin
	if(f>6)and(f<14)then continue;
	if spc[f]<0 then spc[f]:=0;
	if f=4 then continue;
	if spc[f]>100 then spc[f]:=100;
end;
spc[24]:=(spc[24]*skill[sk_ranged])div 100;
spc[25]:=(spc[25]*skill[sk_ranged])div 100;
carcap:=atrib[0]*80;
inc(carcap,spc[7]);
status[0]:=0;status[1]:=0;
if weight>carcap then begin spc[4]:=trunc(spc[4]*0.9);status[0]:=1;end;
if weight>(carcap*2) then begin spc[4]:=trunc(spc[4]*0.7);status[0]:=2;end;
if weight>(carcap*3) then begin spc[4]:=trunc(spc[4]*0.5);status[0]:=3;end;
if eqweight>carcap then begin spc[1]:=trunc(spc[1]*0.3);status[1]:=1;end;
if(wielded=0)and(equip[5].num=-1)and(status[1]=0)then inc(spc[2],(weapskill[0])div 2);
if(spc[2]>100)then spc[2]:=100;
case origspc[19] of
0..14:status[3]:=-1;
15..100:status[3]:=0;
101..200:status[3]:=1;
4000..5000:status[3]:=3;
5001..30000:status[3]:=4;
else status[3]:=2
end;
if(status[3]=3)then begin spc[3]:=trunc(spc[3]*0.9);spc[4]:=trunc(spc[4]*0.9);end;
if(status[3]=4)then begin spc[3]:=trunc(spc[3]*0.7);spc[4]:=trunc(spc[4]*0.6);end;
case origspc[20] of
0..7:status[4]:=-1;
8..30:status[4]:=0;
31..100:status[4]:=1;
else status[4]:=2;
end;
end;

function nextlv(n:byte):longint;
begin
{nextlev:=10;}
if(n=1)then nextlv:=10
else nextlv:=round(nextlv(n-1)*1.2);
{else nextlev:=2*nextlv(n-1);}
end;

procedure printstats;
begin
recompute;
at(62,1);write(name);
at(62,2);write(title);
at(62,3);write('(',guildname[vdata[0]],')   ');
case spcmodif[8] of
-20..-1:ink(12);
0:ink(7);
1..20:ink(10);
end;
at(62,5);write('STR: ',scale20(atrib[0]div 4));
case spcmodif[9] of
-20..-1:ink(12);
0:ink(7);
1..20:ink(10);
end;
at(62,6);write('AGI: ',scale20(atrib[1]div 4));
case spcmodif[10] of
-20..-1:ink(12);
0:ink(7);
1..20:ink(10);
end;
at(62,7);write('LEA: ',scale20(atrib[2]div 4));
case spcmodif[11] of
-20..-1:ink(12);
0:ink(7);
1..20:ink(10);
end;
at(62,8);write('CON: ',scale20(atrib[3]div 4));
case spcmodif[12] of
-20..-1:ink(12);
0:ink(7);
1..20:ink(10);
end;
at(62,9);write('PIE: ',scale20(atrib[4]div 4));
case spcmodif[13] of
-99..-1:ink(12);
0:ink(7);
1..99:ink(10);
end;
at(62,10);write('LCK: ',scale100(atrib[5]div 10));
ink(7);
at(62,12);write('-Melee');
case status[5] of
0:write(' (P)');
1:write(' (A)');
end;
case spcmodif[1] of
-99..-1:ink(12);
0:ink(7);
1..99:ink(10);
end;
at(62,13);write('HIT: ',scale100(spc[1]div 10));
case spcmodif[2] of
-99..-1:ink(12);
0:ink(7);
1..99:ink(10);
end;
at(62,14);write('DAM: ',scale100(spc[2]div 10));
case spcmodif[3] of
-99..-1:ink(12);
0:ink(7);
1..99:ink(10);
end;
at(62,15);write('DEF: ',scale100(spc[3]div 10));
ink(7);
at(62,16);write('-Ranged');
if(rangedw=99)then begin
	at(62,17);write('HIT:');
	at(62,18);write('DAM:');
	end
else begin
	case spcmodif[24] of
	-99..-1:ink(12);
	0:ink(7);
	1..99:ink(10);
	end;
	at(62,17);write('HIT: ',scale100(spc[24]div 10));
	case spcmodif[25] of
	-99..-1:ink(12);
	0:ink(7);
	1..99:ink(10);
	end;
	at(62,18);write('DAM: ',scale100(spc[25]div 10));
	end;
if(hlt<orighlt)then ink(12)
	else ink(7);
at(62,20);
if(hlt>0)then write('HP:  ',hlt,' (',orighlt,') ')
	 else write('HP:  Dead         ');
ink(7);
if(spl<origspl)then ink(12);
at(62,21);write('MP:  ',spl,' (',origspl,') ');
case spcmodif[4] of
-200..-1:ink(12);
0:ink(7);
1..200:ink(10);
end;
at(62,22);if spc[4]<200 then write('SPD: ',scale100((spc[4]div 20)+1)) else write('SPD: ',scale100(10));
ink(7);
at(62,24);write('DEPTH:',patro,'  ');
at(62,25);write('GOLD: ',goldown,'      ');
at(62,26);write('MOVE: ',movecount);
at(62,28);write('EXP: ',expr,' / ');clreol;
at(67,29);write(nextlev);
at(62,30);write('LEV: ',explev);
at(1,50);
case status[3] of
-1:begin ink(31);write('DYING !');end;
0:begin ink(28);write('STARVING ');end;
1:begin ink(12);write('Hungry! ');end;
3:begin ink(10);write('Full ');end;
4:begin ink(2);write('Gorged ');end;
end;
case status[4] of
-1:begin ink(31);write('DYING !');end;
0:begin ink(28);write('VERY THIRSTY ');end;
1:begin ink(12);write('Thirsty! ');end;
{10000..11000:write('Full');
11001..30000:write('Gorged');}
end;
ink(7);
case status[0] of
1:write('Burdened ');
2:write('Strained ');
3:write('Overburdened ');
end;
if(status[1]=1)then write('Heavy equipment ');
if(spc[21]>0)then write('Confused ');
if(spc[22]>0)then write('Poisoned ');
if(spc[23]>0)then write('Blind ');
if(spc[28]>0)then write('Paralyzed ');
if(status[2]=1)then write('Running');
clreol;
end;

procedure wound(dam:shortint);
begin
if(dam<0)then exit;
if(not(w_god))then dec(hlt,dam);
if(hlt<0)then hlt:=0;
printstats;
end;

procedure good(n:byte);
begin
case n of
1:msg('You feel more accurate.');
2:msg('You feel more able to cause damage.');
3:msg('You feel more protected.');
4:msg('You feel faster.');
5:msg('Your vision improves.');
6:msg('You feel more perceptive.');
7:msg('Your carrying capacity improves.');
8:msg('You feel stronger.');
9:msg('You feel more agile.');
10:msg('You feel more intelligent.');
11:msg('You feel more sturdy.');
12:msg('You feel more pious.');
13:msg('You feel more lucky.');
14:msg('Your tunneling ability improves.');
15:msg('You feel resistant to fire.');
16:msg('You feel resistant to cold.');
17:msg('You feel resistant to lightning.');
18:msg('You feel resistant to elements.');
21:msg('You are confused.');
22:msg('You are poisoned.');
23:msg('You cannot see.');
28:msg('You are paralyzed.');
29:msg('You move more stealthy.');
end;
end;

procedure bad(n:byte);
begin
case n of
1:msg('You feel less accurate.');
2:msg('You feel less able to cause damage.');
3:msg('You feel less protected.');
4:msg('You feel slower.');
5:msg('Your vision returns to normal.');
6:msg('You feel less perceptive.');
7:msg('Your carrying capacity returns to normal.');
8:msg('You feel weaker.');
9:msg('You feel clumsier.');
10:msg('You feel more stupid.');
11:msg('You feel more delicate.');
12:msg('You feel less pious.');
13:msg('You feel less lucky.');
14:msg('Your tunneling ability returns to normal.');
15:msg('You feel less resistant to fire.');
16:msg('You feel less resistant to cold.');
17:msg('You feel less resistant to lightning.');
18:msg('You feel less resistant to elements.');
21:msg('You are no longer confused.');
22:msg('You are no longer poisoned.');
23:msg('You can see again.');
28:msg('You can move again.');
29:msg('You move less stealthy.');
end;
end;

procedure raisespc(n:byte;time:integer;amount:shortint);
begin
if(n=28)and(amount>0)and(status[5]>0)then begin
	msg('You cease to defend actively.');
	status[5]:=0;
	end;
if(n=28)and(amount>0)then movestodo:=-1;
if(spctime[n]>0)and(time>0)and(sgn(amount)=sgn(spcmodif[n]))then begin
	inc(spctime[n],time);
	if(spctime[n]>300)then spctime[n]:=300;
	if(amount>spcmodif[n])then spcmodif[n]:=amount;
	msg('The effect is prolonged.');
	exit;
	end;
{if(spctime[n]>0)and(time>0)and(sgn(amount)=sgn(spcmodif[n]))then begin
	inc(spctime[n],time);
	if(amount>spcmodif[n])then spcmodif[n]:=amount;
	msg('The effect is prolonged.');
	exit;
	end;}
inc(origspc[n],amount);
if(amount>0)then good(n) else bad(n);
if(time>0)then begin
	inc(spcmodif[n],amount);
	inc(spctime[n],time);
	if(spctime[n]>300)then spctime[n]:=300;
	end
	else msg('It is a permanent effect.');
end;

procedure lowerspc(n:byte);
begin
spctime[n]:=0;
dec(origspc[n],spcmodif[n]);
if(spcmodif[n]>0)then bad(n) else good(n);
spcmodif[n]:=0;
end;

procedure scoring;
begin
end;

procedure pray;
var
x:byte;
begin
msg('You pray.');
dec(move,70);
if((random(5)+1)>align[4])then begin
	msg('You must have gotten the words wrong.');
	exit;
	end;
if(atrib[4]<9)and(random(12)>atrib[4])then begin
	msg('A thundering voice in your head says:');
	msg('"Your dare to ask me for help ? Then take this, puny heretic !"');
	raisespc(random(3)+21,random(20)+10,1);
	exit;
	end;
x:=0;
if(hlt<orighlt)then x:=8;	{wounded}
if(status[3]=1)then x:=1;	{hungry}
if(status[4]=1)then x:=2;	{thirsty}
if(origspc[22]>0)then x:=6;	{poisoned}
if(origspc[21]>0)then x:=5;	{confused}
if(origspc[23]>0)then x:=7;	{blind}
if(hlt=2)and(orighlt>2)then x:=8;{2 HP}
if(status[3]=0)then x:=1;	{very hungry}
if(status[4]=0)then x:=2;	{very thirsty}
if(hlt=1)then x:=8;		{1 HP}
if(status[3]=-1)then x:=1;	{extremely hungry}
if(status[4]=-1)then x:=2;	{extremely thirsty}
case x of
0:msg('Nothing happens.');
1:begin
	msg('You no longer feel hunger.');
	origspc[19]:=5100;
	end;
2:begin
	msg('You no longer feel thirst.');
	origspc[20]:=500;
	end;
5:lowerspc(21);
6:lowerspc(22);
7:lowerspc(23);
8:begin
	msg('You are healed.');
	hlt:=orighlt;
	end;
end;
if(random(sqr(align[4]-1)+1)=0)and(atrib[4]>1)then raisespc(12,0,-1);
end;

procedure equipme;
var
sel:byte;
whattodo:string[10];
it,sel2:itemptr;
begin
repeat;
{sortinv;}
recompute;
it:=selequip('slot','change',sel);
if it=nil then exit;
if it^.num>-1 then
	if(not(it^.curse))then begin
		if(sel in [1,8..11])then identifyequip(sel);
		it^.curseid:=true;
		itemsortinto(inv,it^);
		it^.num:=-1;
		equip[sel].num:=-1;
		dec(move,50);
		end
	else begin
		at(1,21);write('You cannot remove it!      (more)');
		it^.curseid:=true;
		zn:=readkey;
		at(1,21);clreol;
		end
else begin
	if(sel=5)and(twohanded) then begin
		at(1,21);write('You are wielding a two-handed weapon. (more)');
		zn:=readkey;
		at(1,21);clreol;
		end
	else begin
		case sel of
		4:whattodo:='wield';
		12..14:whattodo:='use';
		else whattodo:='wear';
		end;
	sel2:=itemsel(inv,equiptype[sel],equipitem[sel],whattodo,-1);
	if(sel2<>nil)then
		if(sel=4)and(fitems[sel2^.num]^.subclass>10)and(equip[5].num>-1) then begin
			at(1,41);write('It is a two-handed weapon. (more)');
			zn:=readkey;
			at(1,41);clreol;
			end
		else begin
			equip[sel]:=sel2^;
			if(sel in [1,8..11])then identifyequip(sel);
			if(sel<>13)then equip[sel].q:=1
				else sel2^.q:=1;{takeaway(inv,sel2);end;}
			takeaway(inv,sel2);
			equip[sel].next:=nil;
			equip[sel].prev:=nil;
			{equip[sel].id:=true;
			ids[equip[sel].num]:=2;}
			dec(move,50);
			end;
		end;
	end;
if equip[4].num>-1 then wielded:=fitems[equip[4].num]^.subclass else wielded:=0;
if(wielded>10)then begin dec(wielded,10);twohanded:=true;end else twohanded:=false;
until(false);
end;









end.
