unit montalk;

interface

uses crt,mycrt,gener,monsters,player,shops,univ,spells,items,dungeons;

procedure mtalk(n:word;class:byte;namethe:string);
procedure mask;


implementation
var
s:string[80];
what:string[10];

procedure aardan;
begin
case random(3) of
0:s:='You may call me '+racename[race]+'killer.';
1:s:='You will have to do better,fool!';
2:s:='Sucker!';
end;
end;

procedure xythor;
begin
case random(3) of
0:s:='Leave me alone, puny '+racename[race]+'.';
1:s:='I''m too powerful for you to beat me!';
2:s:='Magic is fun,isn''t it?';
end;
end;

procedure grind;
begin
what:='scream';
s:='Leave my rats alone!';
end;

procedure wuwei;
begin
end;

procedure tshrukk;
begin
what:='yell';
s:='INTRUDER! INTRUDER!';
end;

procedure shirka;
begin
case random(5) of
0:s:='It''s a bit cold here.';
1:s:='I just need to warm up.';
2:s:='You''re lucky I''m so warm-hearted.';
3:s:='Stop fighting and I won''t harm you.';
4:s:='I wonder what does a barbecued '+racename[race]+' taste like.';
end;
end;

procedure rothead;
begin
what:='whisper';
s:='-f-e-e-l-t-h-e-d-e-c-a-y-';
end;

procedure lord;
begin
case random(3) of
0:begin what:='laugh';s:='Look! He''s so funny!';end;
1:s:='Do you want to join the phantoms?';
2:s:='Did anybody tell you I''m immortal?';
end;
end;

procedure headmonk;
begin
what:='sing';
s:='Hallelujah.';
end;

procedure monk;
begin
what:='pray';
s:='hmmmmmmhmmmmmmmmhmmmmmmm';
end;

procedure orc;
begin
case random(5) of
0:s:='Thake thiz!';
1:s:='Thaste my bhlade!';
2:s:='Dhie!';
3:if(race in [1,5])then s:=s+'A ghood dhay for khillin'' an '+racename[race]+'!'
	else s:=s+'A ghood dhay for khillin'' a '+racename[race]+'!';
4:s:='Phepare to meet the ghreat '+racename[race]+' in the skhy!';
end;
end;

procedure shadowling;
begin
case random(3) of
0:begin what:='whisper';s:='Now you see me...now you don''t.';end;
1:begin what:='shout';s:='WHOA! Scared you?';end;
2:begin what:='sing';s:='...carried away, by the moonlight shadow...';end;
end;
end;

procedure mtalk(n:word;class:byte;namethe:string);
begin
if(arena)then exit;
what:='say';
s:='';
case n of
0:Aardan;
1:Xythor;
2:Grind;
4:WuWei;
5:TShrukk;
7:Shirka;
9:Rothead;
10:Lord;
12:headmonk;
else case class of
	0:orc;
	9:shadowling;
	end;
end;
if(s<>'')then msg(namethe+' '+what+'s: "'+s+'".');
end;

procedure askheadmonk;
var
amountstr:string[4];
e,amount:integer;
jewel:boolean;
cur:itemptr;
begin
case vdata[0] of
0..2,4..99:begin
	case vdata[0] of
	0:begin
		msg('"Welcome, '+name+'. Do you desire to join our order?"');
		more;
		if(yesorno('Do you want to join the Order of Silent Chambers?',false))then begin
			msg('"Welcome, brother! Now I should tell you something about the rules of our order.');
			msg(' Brothers which live here in the monastery cannot own anything. Brothers which');
			msg(' spread the holy word in the outside world like you may own things and gold');
			msg(' necessary for surviving in this cruel age but no things that serve for');
			msg(' personal adornment, like rings and necklaces. Should you find them, bring them');
			msg(' to me and I will add them to the funds of our monastery. I''m sure that');
			msg(' the God will reward you for your sacrifice."');
			vdata[0]:=3;
			exit;
			end;
		msg('"Well, it''s your choice. But let me at least bless you."');
		end;
	else begin
		msg('"I''m sorry but a '+guildname[vdata[0]]+' cannot join our order.');
		msg(' But I can give you some blessing."');
		end;
	end;
{	more;
	if(not(yesorno('Do you want the headmonk to bless you?',false)))then exit;}
	msg('Sanctuarius blesses you.');
	if(random(5)=0)and(origatrib[5]<100)then inc(origatrib[5]);
	more;
	if(goldown=0)then exit;
	if(not(yesorno('Do you want to donate some gold to the order?',false)))then exit;
	at(1,y_map+1);write('How much do you want to donate?');clreol;
	amountstr:=txinput(33,y_map+1,4,'');
	at(1,y_map+1);clreol;
	val(amountstr,amount,e);
	if(e<>0)or(amount<1)then amount:=0;
	if(amount>goldown)then amount:=goldown;
	if(amount=0)then begin
		msg('You decide to donate nothing.');
		exit;
		end;
	dec(goldown,amount);
	msg('"You have my deepest thanks, generous one."');
	if(random(1000 div amount)=0)then begin
		msg('It spiritually lifts you.');
		raisespc(12,0,(amount div 1100)+1);
		end;
	end;
3:begin
	jewel:=false;
	if(equip[1].num>0)or(equip[8].num>0)or(equip[9].num>0)or(equip[10].num>0)
		or(equip[11].num>0)then jewel:=true;
	cur:=inv;
	if(not(jewel))then
		while(cur<>nil)do begin
			if(fitems[cur^.num]^.class in[7,8])then begin jewel:=true;break;end;
			cur:=cur^.next;
			end;
	if(not(jewel)){and(goldown<1001)}then begin
		msg('"I see that you resist the temptation of vanity well."');
		exit;
		end;
	if(not(yesorno('"Are you prepared to make your sacrifice?"',false)))then exit;
	amount:=0;
	if(jewel)then begin
		if(equip[1].num>0)then begin inc(amount);equip[1].num:=-1;end;
		if(equip[8].num>0)then begin inc(amount);equip[8].num:=-1;end;
		if(equip[9].num>0)then begin inc(amount);equip[9].num:=-1;end;
		if(equip[10].num>0)then begin inc(amount);equip[10].num:=-1;end;
		if(equip[11].num>0)then begin inc(amount);equip[11].num:=-1;end;
		end;
	cur:=inv;
	while(cur<>nil)do begin
		if(fitems[cur^.num]^.class in[7,8])then begin
			inc(amount,cur^.q);
			cur^.q:=1;
			takeaway(inv,cur);
			end;
		cur:=cur^.next;
		end;
	str(amount,amountstr);
	msg('You prepare to sacrifice '+amountstr+' pieces of jewelry.');
	for e:=1 to amount do begin
		if(random(3)=0)then begin
			msg('A thundering voice in your head says:');
			msg('"You will be rewarded for your modesty."');
			raisespc(random(4)+8,0,1);
			end;
		if(random(3)>0)then raisespc(12,0,1);
		end;
	end;
end;
end;

procedure mercguild;
var
money:string[5];
begin
case vdata[0] of
1:begin
	if(vdata[1]>0)then begin
		str(vdata[1],money);
		msg('"Here''s yer reward for dealin'' with da baddies."');
		msg('Sandor gives you '+money+' gp.');
		inc(goldown,vdata[1]);
		at(62,25);write('GOLD: ',goldown,'      ');
		vdata[1]:=0;
		end;
	msg('"Ye wanna buy sumthing cheap''n''nasty?"');
	more;
	if(yesorno('Do you want to visit the shop?',false))then begin
		shop[7]^.thief:=100;
		visitshop(7);redraw(true);
		end;
	end;
0:begin
	msg('"Welcome sonny! Ye wanna become a merc?"');
	more;
	if(yesorno('Do you want to become a mercenary?',false))then begin
		vdata[0]:=1;vdata[1]:=0;
		msg('"Good choice, pal! You can earn good money as a merc for killin'' da bad ones.');
		msg(' Just come back once in a while and ask me for yer reward. But don''t forget');
		msg(' dat we mercs have some pride. If ye kill just da weak ones da reward won''t');
		msg(' be worth even thinkin'' ''bout."');
		end
	else msg('"Ok. It''s your life."');
	end;
else begin
	msg('"Sorry pal. We don''t need a '+guildname[vdata[0]]+'."');
	end;
end;
end;

procedure warlockguild;
var
sel,f:byte;
trs:string[2];
begin
str(vdata[1],trs);
case vdata[0] of
2:begin
	if(vdata[1]>0)then begin
		msg('"You have '+trs+' training sessions left."');
		more;
		if(not(yesorno('Do you want to train now?',false)))then
			msg('"Well, maybe another time."')
		else begin
		while(vdata[1]>0)do begin
			clrscr;ink(15);
			at(2,2);write('Known spells:');
			for f:=0 to spellnum do
				if spellskill[f]>0 then begin
					at(2,f+4);ink(14);write(chr(97+f),') ');
					ink(7);write(spellname[f],': ',scale100(spellskill[f]div 10));
					end;
			corner;
			repeat
			select(spellnum+1,1,sel);
			if(sel=99)then break;
			until(spellskill[sel]in [1..99]);
			{redraw(true);}
			if(sel=99)then begin
				msg('"Don''t forget to find some time for another training!"');
				break;
				end;
			inc(spellskill[sel],random(atrib[2])+atrib[2]);
			if(spellskill[sel]>100)then spellskill[sel]:=100;
			dec(vdata[1]);
			end;
			redraw(true);
			end;
		end;
	msg('"Do you want to buy some useful items for special prices?"');
	more;
	if(yesorno('Do you want to visit the shop?',false))then
		begin visitshop(8);redraw(true);end;
	exit;
	end;
0:begin
	msg('"Welcome, seeker of knowledge! Do you wish to join our ranks?"');
	more;
	if(yesorno('Do you want to become a warlock?',false))then begin
		vdata[0]:=2;
		msg('"Well, now go and seek thy destiny. And if you find some interesting spells,');
		msg(' visit me and I may train with you a bit."');
		end
	else msg('"Well, then. Come back if you change your mind."');
	end;
else begin
	msg('"I''m sorry. We cannot reveal our secrets to a '+guildname[vdata[0]]+'."');
	exit;
	end;
end;
end;

procedure marko;
begin
visitshop(6);
redraw(true);
end;

procedure princelashikar;
begin
msg('"Welcome, '+name+'. I can''t do anything for you yet, but I might be able to');
msg(' give you some quests in the future versions."');
end;

procedure willie;
var
it:item;
begin
msg('"Do you want to buy a flask of water from my underground spring? Just 40 gp!"');
if(goldown<40)then begin
	msg('"You do not have the money? Oh, what a pity!"');
	msg('Willie looks disappointed.');
	exit;
	end;
more;
if(not(yesorno('Do you want to buy a potion of water?',false)))then exit;
msg('Willie smiles happily.');
randomitem(find(101),99,255,50,it);
ids[it.num]:=2;
itemsortinto(inv,it);
dec(goldown,40);
end;

procedure father;
begin
if(explev>3)and(vdata[2]=0)then vdata[2]:=3;
if(explev>3)and(vdata[2]=1)then begin
	msg('"Remember the rat hole in the shed? I covered it with a few wooden boards and');
	msg(' the rats cause problems no more. How simple!"');
	map[22,15]:=1;
	vdata[2]:=3;
	exit;
	end;
case vdata[2] of
0:begin
	msg('"It''s nice to see you again, son. I know you don''t have much free time now when');
	msg(' you are adventuring but I need some help. I discovered a hole in the shed from');
	msg(' which rats are constantly coming out. I''m sure there must be a large rat');
	msg(' colony under the floor but I must care for other things. Please do something');
	msg(' with it."');
	vdata[2]:=1;
	end;
1:msg('"Why don''t you go and kill the rats under the shed?"');
2:begin
	msg('You tell your father about what you found under the shed.');
	msg('"A shadowling under our shed? And you killed him alone? Son, I''m really proud of');
	msg(' you! I''m sure that one day you will become a great hero!"');
	vdata[2]:=3;
	end;
3:msg('"Hello, '+name+', I''m glad to see you again (and alive)."');
end;
end;

procedure mother;
var
it:item;
begin
msg('"Hello, my little boy."');
if(status[3]<2)then begin
	msg('"You are hungry, aren''t you?"');
	msg('Your mother gives you a bread. You quickly eat it.');
	inc(origspc[19],1200);
	end;
if(status[4]<2)then begin
	msg('"Oh, you must be thirsty."');
	msg('Your mother gives you some lemonade. Tasty!');
	inc(origspc[20],1000);
	end;
end;

procedure gladiators;
var
tr,attrib:byte;
trs:string[2];
begin
if(vdata[1]>0)then tr:=0
	else tr:=(abs(vdata[1])div 5)+1;
str(tr,trs);
case vdata[0] of
0:begin
	msg('"Welcome, o warrior! I guess you came to join our famous Gladiator Union!');
	msg(' Am I right?"');
	more;
	if(not(yesorno('Do you want to become a gladiator?',false)))then begin
		msg('"Ok, I''m sure that you will come back sooner or later. You are always welcome."');
		exit;
		end;
	vdata[0]:=4;
	vdata[1]:=0;
	msg('"Great! Here''s your first ticket for a free visit in our MagicMuscles Gym. You');
	msg(' will get more when you are more experienced. We also cooperate with the Guild');
	msg(' of Mercenaries so I can get you some items from their stock for very reasonable');
	msg(' prices."');
	end;
4:begin
	if(tr>0)then begin
		case tr of
		1:msg('"You have a free ticket to the MagicMuscles Gym."');
		else msg('"You have '+trs+' tickets to the MagicMuscles Gym."');
		end;
		if(origspc[20]<50)then begin
			msg('"But you look very exhausted! I won''t let you in in such condition!"');
			more;
			exit;
			end;
		more;
		if(not(yesorno('Do you want to do some exercising now?',false)))then
			msg('"You''re doing a mistake."')
		else begin
			while(vdata[1]<1)do begin
				for tr:=1 to 100 do begin
					attrib:=random(3);
					if(attrib=2)then attrib:=3;
					if(origatrib[attrib]<20)then break;
					end;
				raisespc(attrib+8,0,1);
				inc(vdata[1],5);
				end;
			redraw(false);
			end;
		end
	else msg('"I''m sorry, you have no tickets."');
	msg('"Do you want to buy something from Sandor''s shop?"');
	more;
	if(yesorno('Do you want to visit the shop?',false))then begin
		shop[7]^.thief:=120;
		visitshop(7);redraw(true);
		end;
	end;
else msg('"Get lost, filthy '+guildname[vdata[0]]+'!"');
end;
end;

procedure arenaclerk;
var
n,f,x,y:byte;
begin
if((movecount mod 20000)<19000)then begin
	msg('"Sorry, no championship is taking place right now.');
	exit;
	end;
msg('"Good day to you, sir! I guess you came to fight and win in our famous Arena!');
msg(' If you are interested, I will sign you up. I can also tell you something about');
msg(' the rules and prizes."');
more;
if(yesorno('Do you want to ask about the rules&prizes?',false))then begin
	msg('"First of all: there is no real death in the Arena. The Gods placed a mighty');
	msg(' enchantment that prevents death on the whole place. If you fall you will awake');
	msg(' again after a while but will not be allowed to continue fighting. Second: the');
	msg(' signing fee is 5000 gp. Third: if you manage to be the last one standing, your');
	msg(' signign fee will be returned to you along with ten thousand bucks!');
	msg(' And the most important rule: NO SAVING! Gods know what this one means..."');
	end;
more;
if(goldown<5000)then begin
	msg('You do not have the necessary money.');
	exit;
	end;
if(not(yesorno('Do you want to fight in the arena?',false)))then exit;
dec(goldown,5000);
arena:=true;
storefmons;
initmonsters('arena.dat',false);
monmap[14,y_map-9]^.num:=-1;
plx:=random(x_map-22)+12;
ply:=random(y_map-22)+12;
for f:=1 to 8 do begin
	repeat
	x:=random(x_map-22)+12;
	y:=random(y_map-22)+12;
	until(map[x,y]=1)and(monmap[x,y]^.num=-1)and((x<>plx)or(y<>ply));
	repeat
	n:=random(noofmons);
	until(fmons[n]^.rarity>-2);
	randommon(n,99,255,monmap[x,y]^);
	if(fmons[n]^.rarity=-1)then fmons[n]^.rarity:=-99
		else inc(monmap[x,y]^.level,random(25)+1);
	monmap[x,y]^.flag:=0;
	end;
see(spc[5]);
msg('You enter the Arena. Remember, even the Gods will watch this fight. You should');
msg('get the best of you!');
more;
redraw(false);
end;

procedure mask;	{monster ask}
var
c,dir:byte;
x,y:shortint;
m:mon;
begin
c:=0;
for x:=-1 to 1 do
for y:=-1 to 1 do
	if(monmap[plx+x,ply+y]^.num>-1)then begin inc(c);dir:=x+2+(1-y)*3;end;
case c of
0:begin
	msg('Nobody here.');
	exit;
	end;
1:;{only one monster to talk to}
else dir:=direct;
end;
if(dir=5)then begin
	msg('"Hello, my name is '+name+' and I will help you to spend some time with this');
	msg(' wonderful game."');
	exit;
	end;
m:=monmap[plx+pmx[dir],ply+pmy[dir]]^;
if(m.num=-1)then begin
	msg('Nobody there.');
	exit;
	end;
if(abs(m.mood)<>99)then begin
	msg('This one doesn''t seem to be in mood for a chat.');
	exit;
	end;
case m.num of
12:askheadmonk;
14:mercguild;
15:warlockguild;
17:marko;
20:princelashikar;
23:willie;
24:father;
25:mother;
32:gladiators;
33:arenaclerk;
else msg('This one isn''t interested in helping you.');
end;
end;


end.
