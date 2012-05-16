unit skills;

interface
uses crt,mycrt,univ,player,gener,items,monsters,monai;

procedure initskills;
procedure typeskills;
procedure raiseskill;
procedure disarm;
procedure scribe;

implementation


procedure initskills;
var
x:byte;
begin
skillname[sk_melee]:='Melee combat';
skillname[sk_ranged]:='Ranged attack';
skillname[sk_disarm]:='Disarm traps';
skillname[sk_heal]:='Healing';
skillname[sk_medit]:='Meditation';
skillname[sk_weapid]:='Weapon&armor id';
skillname[sk_crithit]:='Critical hits';
skillname[sk_purify]:='Purification';
skillname[sk_track]:='Tracking';
skillname[sk_scribe]:='Scribing';
skilldepend[sk_melee]:=0;
skilldepend[sk_ranged]:=3;
skilldepend[sk_heal]:=4;
skilldepend[sk_medit]:=2;
skilldepend[sk_weapid]:=0;
skilldepend[sk_crithit]:=1;
skilldepend[sk_purify]:=4;
skilldepend[sk_disarm]:=1;
skilldepend[sk_track]:=3;
skilldepend[sk_scribe]:=2;
for x:=0 to skillnum do skill[x]:=align[skilldepend[x]]+random(align[skilldepend[x]]);
inc(skill[sk_melee],5+random(5));
inc(skill[sk_ranged],5+random(5));
if(align[0]<4)then skill[sk_weapid]:=0;
if(align[1]<4)then skill[sk_crithit]:=0;
if(align[2]<4)then skill[sk_scribe]:=0;
if(align[3]<4)then skill[sk_track]:=0;
if(align[4]<4)then skill[sk_purify]:=0;
end;

procedure typeskills;
var
f:byte;
begin
for f:=0 to skillnum do begin
	at(2,f+4);ink(14);write(chr(97+f),') ');
	case skill[f] of
	0:ink(4);
	1..99:ink(7);
	100:ink(10);
	end;
	write(skillname[f]);
	at(20,f+4);write(': ',scale100(skill[f]div 10),' (',
		alignname[skilldepend[f]],')');
	end;
ink(15);
at(52,2);write('Professions:');
ink(7);
at(52,4);write('FIGHTER: ',scale20(align[0]-1));
at(52,5);write('THIEF:   ',scale20(align[1]-1));
at(52,6);write('WIZARD:  ',scale20(align[2]-1));
at(52,7);write('RANGER:  ',scale20(align[3]-1));
at(52,8);write('PRIEST:  ',scale20(align[4]-1));
corner;
end;

procedure raiseskill;
var
f,sel:byte;
begin
clrscr;
for f:=3 downto 1 do begin
typeskills;
ink(15);at(1,1);write('Select skill to raise (',f,' remaining):');
corner;
repeat
repeat
select(skillnum+1,1,sel);
if(sel=99)then
	if(yesorno('Are you sure you want to exit?',false))then begin
		redraw(true);
		exit;
		end;
until(sel<>99);
until(skill[sel]in [1..99]);
inc(skill[sel],align[skilldepend[sel]]+random(4));
at(5,sel+4);ink(15);write(skillname[sel]);
corner;delay(300);
{at(5,sel+4);ink(7);write(skillname[sel]);}
if(skill[sel]>100)then skill[sel]:=100;
end;
at(1,1);clreol;
typeskills;
corner;
zn:=readkey;
redraw(true);
end;

procedure disarm;
var
dir,x,y:shortint;
begin
if(spc[23]>0)then begin
	msg('You must be joking.');
	exit;
	end;
dir:=direct;
x:=plx;y:=ply;
inc(x,pmx[dir]);
inc(y,pmy[dir]);
if(monmap[x,y]^.num>-1)then begin
	msg('A monster blocks you.');
	exit;
	end;
if(map[x,y]<>12)then begin
	msg('There is no trap to disarm.');
	exit;
	end;
if(random(100+spc[21]*100)>=(skill[sk_disarm]+50))then begin
	msg('Damn!');
	plx:=x;
	ply:=y;
	traps;
	exit;
	end;
if(random(100)>=skill[sk_disarm])then begin
	msg('You fail to disarm the trap.');
	exit;
	end;
map[x,y]:=1;
typemap[x,y]:=0;
oldseemap[x,y]:=0;
dec(move,200);
msg('Voila!');
end;

procedure scribe;
var
f,sel:byte;
n:integer;
it:item;
chance:array[0..spellnum]of byte;
begin
if(skill[sk_scribe]=0)then exit;
if(spc[21]>0)then begin
	msg('You cannot concentrate on scribing.');
	exit;
	end;
if(spc[23]>0)then begin
	msg('You cannot scribe while blinded.');
	exit;
	end;
clrscr;
at(2,2);ink(15);write('Select spell to scribe:');
ink(7);at(22,3);write('CHANCE FOR SUCCESS:');
for f:=0 to spellnum do begin
	if((101-skill[sk_scribe])<spellskill[f])then
		chance[f]:=(skill[sk_scribe]+spellskill[f])div 3
	else begin
		chance[f]:=0;
		continue;
		end;
	at(2,f+4);ink(14);write(chr(97+f),') ');
	ink(7);
	write(spellname[f]);
	at(20,f+4);write(': ',scale100(chance[f]div 10),' (',
	spellcost[f]+4,' MP)');
	end;
repeat
repeat
select(spellnum+1,1,sel);
if(sel=99)then begin
	redraw(true);
	exit;
	end;
until(sel<>99);
until(chance[sel]>0);
redraw(true);
if(spl<(spellcost[sel]+4))then begin
	msg('Not enough MP.');
	exit;
	end;
if(not(domoves(10,'scribing')))then exit;
dec(spl,spellcost[sel]+4);
if(random(100)>=chance[sel])then begin
	msg('You make a mistake.');
	exit;
	end;
msg('You are successful.');
n:=0;
repeat
inc(n);
if(n>noofitems)then break;
until(fitems[n]^.class=11)and(fitems[n]^.subclass=sel)and(pos('rune',fitems[n]^.name1)=0);
if(n>noofitems)then begin
	msg('Bug report: Couldn''t find scroll.');
	exit;
	end;
randomitem(n,99,255,255,it);
itemsortinto(inv,it);
end;





end.

