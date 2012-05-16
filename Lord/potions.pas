unit potions;

interface
uses mycrt,univ,items,player;

procedure drink;

implementation
var
num:integer;

procedure water;
begin
if(origspc[20]>800)and(ids[num]=2)then begin
	msg('You are not thirsty.');
	exit;
	end;
if(random(10)=0)then begin
	msg('It was salt water!');
	ids[num]:=2;
	if(origspc[20]>550)then dec(origspc[20],500)
		else origspc[20]:=50;
	exit;
	end;
msg('It tasted like water.');
inc(origspc[20],900);	{+300 like other potions}
ids[num]:=2;
end;

procedure mud;
begin
if(origspc[20]>400)and(ids[num]=2)then begin
	msg('You are not thirsty enough to drink this.');
	exit;
	end;
msg('It tasted like mud but your thirst is smaller.');
inc(origspc[20],200);	{+300 like other potions}
ids[num]:=2;
end;

procedure tempatrib(n:byte);
begin
raisespc(n+8,random(20)+10,5);
ids[num]:=2;
end;

procedure permatrib(n:byte);
begin
raisespc(n+8,0,1);
ids[num]:=2;
end;

procedure berserk;
var
time:byte;
begin
time:=random(30)+20;
raisespc(1,time,30);
raisespc(2,time,50);
raisespc(3,time,-20);
ids[num]:=2;
end;

procedure healing;
begin
msg('You feel much better.');
hlt:=orighlt;
if(spc[21]>0)then lowerspc(21);
if(spc[23]>0)then lowerspc(23);
ids[num]:=2;
end;

procedure curepoison;
begin
if(spc[22]=0)then begin
	msg('Nothing happens.');
	exit;
	end;
lowerspc(22);
ids[num]:=2;
end;

procedure poison;
begin
msg('You feel very very bad.');
raisespc(22,5+random(15),2);
ids[num]:=2;
end;

procedure blindness;
begin
msg('Your eyes hurt.');
raisespc(23,5+random(15),1);
ids[num]:=2;
end;

procedure confusion;
begin
msg('You feel very dizzy.');
raisespc(21,5+random(15),2);
ids[num]:=2;
end;

procedure divinity;
begin
raisespc(8,100*align[0],30-atrib[0]);
raisespc(9,100*align[1],30-atrib[1]);
raisespc(10,100*align[2],30-atrib[2]);
raisespc(11,100*align[3],30-atrib[3]);
raisespc(12,100*align[4],30-atrib[4]);
raisespc(4,round(spc[4]*1.5),50);
ids[num]:=2;
end;

procedure drink;
var
sel,eff:byte;
w:integer;
it:itemptr;
begin
it:=itemsel(inv,10,'potion','drink',-1);
redraw(true);
if(it=nil)then exit;
num:=it^.num;
eff:=fitems[num]^.spec;
w:=origspc[20];
case eff of
0:water;
1..4:tempatrib(eff-1);
5..8:permatrib(eff-5);
9:berserk;
10:healing;
11:curepoison;
100:poison;
101:blindness;
102:confusion;
103:mud;
255:divinity;
end;
if(eff=0)and(origspc[20]<=w)then exit;
inc(origspc[20],300);
takeaway(inv,it);
if(ids[num]=0)then ids[num]:=1;
dec(move,70);
end;




end.
