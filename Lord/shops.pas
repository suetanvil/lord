unit shops;

interface
uses crt,mycrt,items,player;


procedure initshops;
procedure doneshops;
{function price(it:item;th:word):longint;}
procedure visitshop(n:byte);

implementation


function unwanteditem(it:item):boolean;
begin
unwanteditem:=false;
if(fitems[it.num]^.class=10)and(fitems[it.num]^.spec in[100..199])then unwanteditem:=true;
if(fitems[it.num]^.class=7)and(fitems[it.num]^.mb<1)then unwanteditem:=true;
end;

procedure initshops;
const
names:array[0..20]of string[7] = ('Baldior','Hamior','Fionn','Daon','Samael','Derael','Omiun',
	'Delviun','Terzew','Dorhal','Matanan','Hirataj','Quinter','Doniter','Xamen',
	'Hatanan','Ultiac','Mord','Kim','Bastos','Fageron');
var
f,g,r1,r2:byte;
it:item;
begin
for f:=0 to shop_num do begin
	new(shop[f]);
	shop[f]^.patro:=0;
	shop[f]^.thief:=random(200)+100;
	shop[f]^.name:=names[random(21)];
	shop[f]^.inv:=nil;
	end;
for f:=0 to shop_num do	begin
	shop[f]^.patro:=random(8)+2+f*8;
	if(wizard=true)then begin at(1,f+1);write(shop[f]^.patro);end;
	end;
{for f:=0 to shop_num do
	for g:=0 to shopswapinv do shop[f]^.inv[g].num:=-1;}
for f:=0 to 6 do
for g:=0 to 35+30*ord(f=6) do begin
	r1:=random(25);
	r2:=1;
	if(r1>8)then r2:=2;
	if(r1>17)then r2:=3;
	if(r1=24)then r2:=4;
	repeat
	randomitem(-1,99,r2,50,it);
	until(it.curse=false)and(it.num>0)and
		(not(unwanteditem(it)));
{	if(fitems[shop[f]^.inv[shopswapinv].num]^.rarity=4)then
		fitems[shop[f]^.inv[shopswapinv].num]^.rarity:=10;}
	if(fitems[it.num]^.rarity=10)then fitems[it.num]^.rarity:=11;
	it.id:=true;it.curseid:=true;
	itemsortinto(shop[f]^.inv,it);
	end;
shop[6]^.name:='Marko';
shop[6]^.thief:=120;
{mercenary}
for g:=0 to 35 do begin
	r1:=random(25);
	r2:=1;
	if(r1>8)then r2:=2;
	if(r1>17)then r2:=3;
	if(r1=24)then r2:=4;
	repeat
	randomitem(-1,99,r2,50,it);
	until(it.curse=false)and(it.num>0)and(fitems[it.num]^.class in[1..6,13])and
		(not(unwanteditem(it)));
	if(fitems[it.num]^.rarity=10)then fitems[it.num]^.rarity:=11;
	it.id:=true;it.curseid:=true;
	itemsortinto(shop[7]^.inv,it);
	end;
shop[7]^.name:='Sandor';
shop[7]^.thief:=100;
{warlock}
for g:=0 to 35 do begin
	r1:=random(25);
	r2:=1;
	if(r1>8)then r2:=2;
	if(r1>17)then r2:=3;
	if(r1=24)then r2:=4;
	repeat
	randomitem(-1,99,r2,50,it);
	until(it.curse=false)and(it.num>0)and(fitems[it.num]^.class in[7,8,11..13])and
		(not(unwanteditem(it)));
	if(fitems[it.num]^.rarity=10)then fitems[it.num]^.rarity:=11;
	it.id:=true;it.curseid:=true;
	itemsortinto(shop[8]^.inv,it);
	end;
shop[8]^.name:='Anarion';
shop[8]^.thief:=100;
for f:=0 to noofitems-1 do begin
	if(fitems[f]^.rarity=10)then fitems[f]^.rarity:=4;
	if(fitems[f]^.rarity=11)then fitems[f]^.rarity:=10;
	end;
end;

procedure doneshops;
var
f:byte;
begin
for f:=0 to shop_num do begin
	destroylist(shop[f]^.inv);
	dispose(shop[f]);
	end;
end;

procedure shopsay(text:string);
begin
at(1,1);
ink(15);
write(text);
clreol;
corner;
ink(7);
end;

procedure drawshop(n:byte);
var
f:byte;
maxprice:longint;
max,cur:itemptr;
begin
{sortshop(n);}
{for f:=0 to itemcount(shop[n]^.inv)-1 do
	ids[shop[n]^.inv[f].num]:=2;}
clrscr;
cur:=shop[n]^.inv;
while(cur<>nil)do begin
	ids[cur^.num]:=2;
	cur:=cur^.next;
	end;
ink(7);
at(40,7);write('O');
at(39,8);write('/ \');
at(38,9);write('/   \');
window(10,10,70,30);paper(6);clrscr;
at(5,3);write(shop[n]^.name,'''s Ye Olde Shoppe');
if(wizard)then begin
	at(5,4);write('thievery rating ',shop[n]^.thief,'%');
	end;
at(10,8);ink(15);write('OFFER OF THE DAY:');
cur:=shop[n]^.inv;
maxprice:=0;max:=nil;
while(cur<>nil)do begin
	if(price(cur^,100)>maxprice)then begin
		max:=cur;maxprice:=price(cur^,100);
		end;
	cur:=cur^.next;
	end;
at(7,12);ink(14);
if(max<>nil)then begin
	write(pitem(max^,1,false,false));
	at(8,14);write('for mere ',price(max^,shop[n]^.thief),' gp');
	end
else write('Stock exhausted.');
paper(0);window(1,1,80,50);
{for f:=0 to shopswapinv-1 do
	if(shop[n]^.inv[f].num>-1)then begin
		ink(14);at(1,f+2);write(choice[f+1],') ');
		ink(7);write(pitem(shop[n]^.inv[f],false));clreol;
		if(wizard)then begin at(70,f+2);write(price(shop[n]^.inv[f],100));end;
		at(50,f+2);write(price(shop[n]^.inv[f],shop[n]^.thief):8,' gp');
		if(shop[n]^.inv[f].q>1)then write(' (',shop[n]^.inv[f].q,' pcs)');
		end
	else begin
		at(1,f+2);clreol;
		end;
}
ink(7);
at(1,43);write('p) purchase an item');
at(1,44);write('s) sell an item');
at(50,43);write('e) equipment');
at(50,44);write('i) check inventory');
at(1,45);write('SPACE) leave shop');
at(50,45);write('Your gold:',goldown,' gp');clreol;
corner;
end;

function purchase(n:byte):boolean;
var
sel:byte;
it:item;
selit:itemptr;
begin
{for sel:=0 to shopswapinv-1 do if(shop[n]^.inv[sel].num>-1) then inc(kolik);}
purchase:=false;
{shopsay('Select item to buy (SPACE to cancel)');}
selit:=itemsel(shop[n]^.inv,99,'item','buy',n);
if(selit=nil)then begin at(1,1);clreol;exit;end;
if(price(selit^,shop[n]^.thief)>goldown)then begin
	shopsay('You cannot afford it !');
	zn:=readkey;
	exit;
	end;
it:=selit^;it.q:=1;
itemsortinto(inv,it);
{inv[swapinv]:=shop[n]^.inv[sel];inv[swapinv].q:=1;
sortinv;
if(inv[swapinv].num>-1)then begin
	inv[swapinv].num:=-1;inv[swapinv].q:=0;
	shopsay('You have no room in your backpack !');
	zn:=readkey;
	exit;
	end;}
dec(goldown,price(it,shop[n]^.thief));
{sortinv;}
shopsay('Bought '+pitem(it,1,false,true)+'.');zn:=readkey;
takeaway(shop[n]^.inv,selit);
purchase:=true;
{sortshop(n);}
end;

procedure sell(n:byte);
var
perc:byte;
it,it2:item;
sellit:itemptr;
begin
sellit:=itemsel(inv,99,'item','sell',-1);
drawshop(n);
if(sellit=nil)then begin at(1,1);clreol;exit;end;
perc:=90;
it:=sellit^;it.q:=1;
it2:=it;
if(unwanteditem(it))and(ids[it.num]=2)then begin
	shopsay('I have no use for such things.');
	zn:=readkey;
	exit;
	end;
if{((it.id)and(it.mb<0))or}((it.curse)and(it.curseid))then begin
	shopsay('I do not buy damned stuff !');
	zn:=readkey;
	exit;
	end;
if(not(it.id))then begin perc:=50;it.mb:=0;end;
if(not(it.curseid))then dec(perc,20);
if(ids[it.num]<2)then perc:=20;
{if(it.mb<0)and(perc<90)then it.mb:=1;}
at(1,1);ink(15);write('I will pay ',price(it,perc),' gp. (Y/n)');clreol;corner;ink(7);
zn:=readkey;
if(zn='n')then begin at(1,1);clreol;ink(7);exit;end;
takeaway(inv,sellit);
if(it2.curse=true){or(it2.mb<0)}then begin
	ids[it2.num]:=2;it2.id:=true;it2.curseid:=true;
	inc(goldown,price(it,perc));
	shopsay('Sold '+pitem(it2,1,false,true)+'.');
	zn:=readkey;
	shopsay('!!! DAMN !!!');
	zn:=readkey;
	exit;
	end;
ids[it2.num]:=2;it2.id:=true;it2.curseid:=true;
itemsortinto(shop[n]^.inv,it2);
{sortshop(n);}
{if(shop[n]^.inv[shopswapinv].num>-1)then begin
	shop[n]^.inv[shopswapinv].num:=-1;shop[n]^.inv[shopswapinv].q:=0;
	shopsay('Oh,I forgot I have no room for that !');
	zn:=readkey;
	exit;
	end;}
shopsay('Sold '+pitem(it2,1,false,true)+'.');
zn:=readkey;
inc(goldown,price(it,perc));
end;

{procedure equipshop(n:byte);
var
sel,sel2:byte;
whattodo:string[10];
begin
repeat;
sortinv;
recompute;
selequip('slot','change',sel);
if sel=99 then begin drawshop(n);exit;end;
if equip[sel].num>-1 then
	if equip[sel].curse=false then begin
		inv[swapinv]:=equip[sel];
		sortinv;
		if inv[swapinv].num>-1 then begin msg('There is no room in your backpack!');inv[swapinv].num:=-1;end
		else begin
			equip[sel].num:=-1;
			end
		end
	else begin
		at(1,21);write('You cannot remove it!      (more)');
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
	whattodo:='wear';if sel=4 then whattodo:='wield';if(sel in[12..14])then whattodo:='use';
	selinv(equiptype[sel],equipitem[sel],whattodo,sel2);
	if sel2<99 then
		if(sel=4)and(fitems[inv[sel2].num]^.subclass>10)and(equip[5].num>-1) then begin
			at(1,21);write('It is a two-handed weapon. (more)');
			zn:=readkey;
			at(1,21);clreol;
			end
		else begin
			equip[sel]:=inv[sel2];
			takeaway(inv[sel2]);
			if(sel<>13)then equip[sel].q:=1
				else inv[sel2].num:=-1;
			equip[sel].id:=true;
			ids[equip[sel].num]:=2;
			sortinv;
			end;
		end;
	end;
if equip[4].num>-1 then wielded:=fitems[equip[4].num]^.subclass else wielded:=0;
if(wielded>10)then begin dec(wielded,10);twohanded:=true;end else twohanded:=false;
until(false);
end;
}

procedure visitshop(n:byte);
var
f:byte;
begin
clrscr;
ink(15);at(1,1);
write('Welcome at ',shop[n]^.name,'''s Ye Olde Shoppe.');
if(wizard=true)then write('thievery rating ',shop[n]^.thief,'%');
drawshop(n);
{sortinv;}
zn:=readkey;
while(zn<>' ') do
begin
	case zn of
	'p':while(purchase(n))do;
	's':sell(n);
	'e':begin equipme;drawshop(n);end;
	'i':itemsel(inv,99,'','',-1);
	end;
	drawshop(n);
	at(1,1);clreol;
	corner;
	zn:=readkey;
end;
clrscr;
end;





end.