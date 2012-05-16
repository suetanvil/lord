unit items;

interface
uses crt,mycrt,gener;

type
itemptr = ^item;
item=record
	num:integer;
	mb:integer;
	curse,curseid:boolean;
	id:boolean;
	q:integer;
	flag:byte;
	prev:itemptr;
	next:itemptr;
	end;
fileitem=record
		name0:string[25];
		name1:string[45];
		class:shortint;
		subclass:shortint;
		bonus:integer;
		mb:integer;
		spec:byte;
		weight:integer;
		rarity:byte;
		end;

shoptype = record
	name:string[7];
	patro:byte;
	thief:word;
	inv:itemptr;
	end;


const
{swapinv = 38;}
equip_num = 14;
spc_num = 31;
spec:array[0..spc_num] of string[4]=('','+HIT','+DAM','+DEF','+SPD','+VIS','+PER','+CAR','+STR','+AGI','+LEA','+CON','+PIE',
'+LCK','+TUN','FR','CR','LR','RES','bug','bug','CONF','POIS','BLI','+MHT','+MDM','BACK','SLAY','PAR','+STL','FIRE','ICE');
equiptype:array[0..equip_num]of byte = (4,8,9,3,1,2,6,5,7,7,7,7,16,15,14);
equipitem:array[0..equip_num]of string[8] = ('a helmet','an amulet','a cloak','an armor','a weapon','a shield','gloves',
'boots','a ring','a ring','a ring','a ring','a weapon','missiles','a tool');
equiptext:array[0..equip_num]of string[9] = ('Head     ','Neck     ','Cloak    ','Body     ','Weapon   ','Shield   ',
'Hands    ','Feet     ','Ring 1   ','Ring 2   ','Ring 3   ','Ring 4   ','M.weapon ','Missiles ','Tun.tool ');
monclass_num = 12;
monchar:array[0..monclass_num]of char = ('o','u','h','r','g','E','N','m','&','s','L','P','e');
maxitems = 200;
shop_num = 8;

var
noofitems,carcap:integer;
weight,eqweight:longint;
itmap:array[1..x_map,1..y_map]of itemptr;
fitems:array[0..maxitems] of ^fileitem;
ids:array[0..maxitems] of byte;
equip:array[0..equip_num]of item;
inv:itemptr;
shop:array[0..shop_num]of ^shoptype;
w_identify:boolean;



procedure inititems;
procedure doneitems;
procedure seznam;
function pitem(it:item;art:byte;q,details:boolean):string;
procedure randomitem(num:integer;filter,rarity,luck:byte;var it:item);
procedure takeaway(var hook,it:itemptr);
{procedure sortinv;}
{procedure selinv(filter,byte;thing,whattodo:string;var sel:byte);}
function selequip(what,whattodo:string;var sel:byte):itemptr;
function selwhich(caption,what,whattodo:string;var which:byte):itemptr;
function find(offset:integer):integer;
function itemcmp(it1,it2:item):boolean;
procedure itemsortinto(var hook:itemptr;it:item);
function itemcount(hook:itemptr):word;
function itemsel(hook:itemptr;filter:byte;what,whattodo:string;shopn:shortint):itemptr;
function itemget(hook:itemptr;n:word):itemptr;
procedure destroylist(var hook:itemptr);
function price(it:item;th:word):longint;
procedure savelist(hook:itemptr);
procedure loadlist(var hook:itemptr);
procedure burnscrolls(var hook:itemptr;show:boolean);
procedure freezepotions(var hook:itemptr;show:boolean);
procedure damageitem(var hook:itemptr;it:itemptr;show:boolean;what:string);
procedure identifyequip(n:byte);



implementation




procedure inititems;
var
itemfile:file of fileitem;
f,g,cl:integer;
begin
assign(itemfile,'item.dat');
reset(itemfile);
f:=0;
repeat
new(fitems[f]);
read(itemfile,fitems[f]^);
cl:=fitems[f]^.class;
if(cl=7)or(cl=8)or(cl=10)then fitems[f]^.subclass:=random(14)+2;
if(cl=10)and(pos('of water',fitems[f]^.name1)>0)then fitems[f]^.subclass:=3;
ids[f]:=0;
inc(f);
until(eof(itemfile));
close(itemfile);
noofitems:=f;
for f:=1 to x_map do
for g:=1 to y_map do itmap[f,g]:=nil;
inv:=nil;
end;

procedure doneitems;
var
f,g:word;
begin
for f:=0 to noofitems-1 do
	dispose(fitems[f]);
{for f:=1 to x_map do
for g:=1 to y_map do
	dispose(itmap[f,g]);}
end;

procedure seznam;
var
f:byte;
begin
clrscr;
for f:=0 to noofitems-1 do begin
	at(1,(f mod y_map)+1);write(f,' ',fitems[f]^.name1,' ',fitems[f]^.rarity);
	if (f mod y_map)=y_map-1 then begin zn:=readkey;clrscr;end;
	end;
zn:=readkey;clrscr;
end;

function pitem(it:item;art:byte;q,details:boolean):string;
var
bon,mb,curse,qstr,ratstr:string[10];
spc:string[20];
final:string[60];
rating,no,poz:integer;
fm:fileitem;
begin
no:=it.num;
fm:=fitems[no]^;
if ids[no]=2 then final:=fm.name1
	else final:=fm.name0;
mb:='?';spc:='';curse:='';
if(fm.spec=7)then it.mb:=it.mb*5;
rating:=((fm.bonus-1) div 5)+1;
bon:='';
while(rating>4)do begin
	bon:=bon+'*';
	dec(rating,5);
	end;
for poz:=1 to rating do bon:=bon+'+';
if(fm.class=16)then str(fm.bonus,bon);
{spc:=spec[fitems[no]^.spec];}
if(it.id)then begin
	str(it.mb,mb);
	if(it.mb>=0)and(fm.spec<>0)then mb:='+'+mb;
	if(wizard)then final:='('+mb+')'+final;
	end;
if(it.curse)and(it.curseid)then curse:=' (cursed)';
poz:=pos('$bon',final);
if poz>0 then begin
	delete(final,poz,4);
	insert(bon,final,poz);
	end;
spc:=spec[fm.spec];
if(fm.spec in[1..14,24..26,29])and(it.id){and(details)}and(not(fm.class in[10..13,17]))then begin
	rating:=abs(it.mb);
	if(fm.spec in mbtimes5)or(fm.spec=7)then rating:=(rating+4) div 5;
	if(fm.spec in [14,26]){or(fm.rarity>3)}then rating:=rating div 2;
	if(it.mb<0)then rating:=-rating;
	if(not(it.curseid))and(it.curse)then inc(rating,2);
	if(rating<-6)then rating:=-6;
	if(rating>6)then rating:=6;
	case rating of
	-6:ratstr:='fatal';
	-5:ratstr:='disastrous';
	-4:ratstr:='horrible';
	-3:ratstr:='very bad';
	-2:ratstr:='bad';
	-1:ratstr:='poor';
	 0:ratstr:='normal';
	 1:ratstr:='fine';
	 2:ratstr:='good';
	 3:ratstr:='very good';
	 4:ratstr:='great';
	 5:ratstr:='superb';
	 6:ratstr:='ultimate';
	end;
	if(fm.rarity<4)then final:=ratstr+' '+final
		else spc:=spc+','+ratstr;
	end;
poz:=pos('$mb',final);
if(fm.spec=26)and(it.id)then begin mb:=mb+'0% ';delete(mb,1,1);end;
if(fm.spec=27)and(it.id)then mb:=''''+monchar[it.mb]+'''';
if poz>0 then begin
	delete(final,poz,3);
	insert(mb,final,poz);
	end
else if(spc<>'')then spc:='('+spc+')';
poz:=pos('$spc',final);
if(poz>0)and(not(fm.spec in[30,31]))then begin
	delete(final,poz,4);
	insert(spc,final,poz);
	end;
if ids[no]=1 then final:=final+' (tried)';
if(fm.class=1)and(fm.subclass>10)then final:=final+' (2hand)';
if(it.id)then begin
	case ord(testbit(it.flag,0))+2*ord(testbit(it.flag,1)) of
	1:final:=final+' (FR)';
	2:final:=final+' (CR)';
	3:final:=final+' (LR)';
	end;
	end;
case 4*ord(testbit(it.flag,2))+8*ord(testbit(it.flag,3)) of
4:final:=final+' (FIRE)';
8:final:=final+' (ICE)';
end;
if(fm.spec=30)then final:=final+' (FIRE)';
if(fm.spec=31)then final:=final+' (ICE)';
final:=final+curse;
if(q)and(it.q>1)then begin
	str(it.q,qstr);
	final:=final+' ('+qstr+' pcs)';
	end;
if(fm.rarity>3)and(art<>0)and(ids[it.num]=2)then art:=2;
if(fm.name0[length(fm.name0)]='s')and(fm.name0[length(fm.name0)-1]<>'s')and(art=1)then art:=0;
if(art=1)then
	if(final[1] in ['a','e','i','o','u','y'])then final:='an '+final
		else final:='a '+final;
if(art=2)then
	if(fm.rarity>3)and(ids[no]=2)then final:='The '+final
		else final:='the '+final;
if(not(details))and(pos('[',final)>0)then begin
	delete(final,pos('[',final),99);
	end;
while(final[length(final)]=' ')do delete(final,length(final),1);
pitem:=final;
end;

procedure randomitem(num:integer;filter,rarity,luck:byte;var it:item);
var
mb,c:integer;
count,realrar,failed,spc:byte;
fitem:fileitem;
lucky,badluck:boolean;
begin
lucky:=false;badluck:=false;
if(random(100)<luck)then lucky:=true;
if(random(100)>=luck)then badluck:=true;
if((lucky)and(badluck))or(luck=255)then begin lucky:=false;badluck:=false;end;
count:=0;
failed:=0;
if num=-1 then
	repeat
	num:=random(noofitems);
	fitem:=fitems[num]^;
	if(failed>0)and(fitem.mb<99)then begin num:=0;break;end;
	inc(count);
	if(count=255)and(not(filter in [1..6,13]))then begin
		count:=0;
		dec(rarity);
		inc(failed);
		num:=0;
		end;
	until((fitem.class=filter)or(filter=99))and
	((fitem.rarity=rarity)or((rarity=255)and(fitem.rarity<5)))
else
	rarity:=fitems[num]^.rarity;
fitem:=fitems[num]^;
realrar:=fitem.rarity;
if(rarity=255)then rarity:=realrar;
if failed>0 then begin
	badluck:=false;
	lucky:=true;
	inc(rarity);
	end;
if(realrar=4)then fitems[num]^.rarity:=10;
if(lucky)and(fitem.mb>=99)then inc(rarity);
if(badluck)and(random(100)>=luck)and((fitem.mb<=-100)or(fitem.mb=99))then inc(rarity);
mb:=rarity-realrar;
if(abs(fitem.mb)=101) then begin mb:=rarity;if mb>2 then dec(mb);end;
if(num=0)then mb:=sqr(mb)*12;
spc:=fitem.spec;
if(spc in mbtimes5)then mb:=mb*4;
if(mb>0)then
	if failed>0 then mb:=(random(mb)+mb*2)*failed
		else mb:=random(mb*2)+mb;
if(num=0)and(failed>0)then mb:=mb*3;
if(fitem.class=12)then begin
	mb:=random(5)+1;
	if(lucky)then begin
		inc(mb,2);
		mb:=mb*2;
		end;
	if(badluck)then mb:=0;
	end;
it.curse:=false;
if fitem.mb<=-100 then begin
	mb:=-mb;
	it.curse:=true;
	end;
if(fitem.mb=99)and(badluck) then
	begin
	it.curse:=true;
	mb:=-mb;
	end;
if abs(fitem.mb)<99 then mb:=fitem.mb;
if mb<0 then it.curse:=true;
if(it.curse)and(random(4)=0)and(realrar<4)then it.curse:=false;
if(fitem.class<>10)then begin
	if(spc=14)then inc(mb,mb);
	if(spc=26)and(mb>10)then mb:=random(5)+mb-12;
	if(spc=27)and(mb>monclass_num)then mb:=random(monclass_num+1);
	end;
it.num:=num;
it.mb:=mb;
it.id:=false;
it.curseid:=false;
if(num=0)then it.id:=true;
if w_identify=true then begin
	ids[num]:=2;
	it.id:=true;
	end;
it.q:=1;
if(fitem.class=15)and(realrar<4)then
	if(fitem.subclass>0)then it.q:=random(10)+1
	else it.q:=random(3)+1;
it.flag:=0;
if(lucky)and(random(100)<luck)and(fitem.class in [2..6,9])and(fitem.rarity<4)and
	(fitem.spec=3)then begin
		case random(2) of
		0:it.flag:=random(3)+1;
		1:it.flag:=random(2)*4+4;
		end;
		if(random(100)>luck)and(it.mb>0)then it.mb:=0;
		end;
if(lucky)and(random(100)<luck)and(fitem.class=1)and(fitem.rarity<4)and(fitem.spec=2)then begin
	it.flag:=random(2)*4+4;
	if(random(100)>luck)and(it.mb>0)then it.mb:=0;
	end;
it.prev:=nil;
it.next:=nil;
if(fitem.class in [1..6])and(random(100)<skill[sk_weapid])and(ids[it.num]=2)then it.id:=true;
end;

function selequip(what,whattodo:string;var sel:byte):itemptr;
var
f:byte;
begin
clrscr;
ink(15);
at(1,1);write('Select ',what,' to ',whattodo,':');
at(58,1);write((eqweight/10):7:1);
at(70,1);write('Carrying');
at(70,2);write('capacity:');
at(70,3);write((carcap/10):7:1);
for f:=0 to equip_num do
begin
	ink(14);
	at(1,f+2);write(chr(f+97),') ');
	write(equiptext[f],' - ');
	if equip[f].num>-1 then begin
		ink(7);
		if(equip[f].curseid)and(fitems[equip[f].num]^.class in[1..9,15,16])then
			if(equip[f].curse)then ink(12)
				else ink(2);
		if(f<>13)then write(pitem(equip[f],1,false,true))
		else write(pitem(equip[f],1,true,true));
		at(60,f+2);write((fitems[equip[f].num]^.weight/10):5:1);
		end;
end;
ink(7);
at(50,20);write('- press SPACE to cancel -');
select(equip_num+1,1,sel);
if(sel<>99)then selequip:=@equip[sel] else selequip:=nil;
end;

function selwhich(caption,what,whattodo:string;var which:byte):itemptr;
var
sel:byte;
it:itemptr;
begin
clrscr;
at(2,5);write(caption);
at(2,7);write('Do you wish to select from inventory or equipment?');
ink(14);at(29,7);write('i');
at(42,7);write('e');ink(7);
corner;
repeat
zn:=readkey;
until(zn='e')or(zn='i');
case zn of
'e':begin it:=selequip(what,whattodo,sel);which:=0;end;
'i':begin it:=itemsel(inv,99,what,whattodo,-1);which:=1;end;
end;
selwhich:=it;
end;

function price(it:item;th:word):longint;
var
fit:fileitem;
bonpri,mbpri,pri:longint;
bon:word;
begin
fit:=fitems[it.num]^;
bonpri:=0;
case fit.class of
1:bonpri:=fit.bonus div 5;
2..6:bonpri:=(fit.subclass*fit.bonus)div 5;
7,8:bonpri:=10;
9:bonpri:=fit.bonus div 5;
10:bonpri:=1;
11,12:bonpri:=5;
13:bonpri:=fit.bonus div 5;
14:bonpri:=1;
16:bonpri:=fit.bonus*2;
15:bonpri:=fit.bonus div 15;
end;
bonpri:=bonpri*12;
mbpri:=0;
case fit.spec of
1..3,6,7,24:mbpri:=it.mb;
4:mbpri:=it.mb*2;
5:mbpri:=it.mb*30;
8..12:mbpri:=it.mb*5;
13:mbpri:=it.mb*5;
14:mbpri:=it.mb div 3;
15..17:mbpri:=it.mb*6;
18:mbpri:=it.mb*17;
25:mbpri:=it.mb div 3;
26:case it.mb of
	0..4:mbpri:=0;
	5..7:mbpri:=2;
	8..9:mbpri:=4;
	10:mbpri:=15;
	end;
27:mbpri:=20;
29:mbpri:=round(it.mb*1.5);
30,31:mbpri:=it.mb*10;
end;
if(testbit(it.flag,0))or(testbit(it.flag,1))then inc(mbpri,5);
if(testbit(it.flag,2))or(testbit(it.flag,3))then inc(mbpri,8);
if(fit.class in[11,12])then mbpri:=sqr(spellcost[fit.subclass]+1);
{	case fit.subclass of
	0:mbpri:=3;
	1:mbpri:=2;
	2:mbpri:=4;
	3:mbpri:=2;
	4:mbpri:=2;
	5:mbpri:=8;
	6:mbpri:=1000;
	7:mbpri:=6;
	8:mbpri:=6;
	9:mbpri:=6;
	10:mbpri:=12;
	11:mbpri:=18;
	12:mbpri:=12;
	13:mbpri:=25;
	14:mbpri:=25;
	15:mbpri:=20;
	end;}
if(fit.class=10)then
	case fit.spec of
	0:mbpri:=0;
	1..4:mbpri:=3;
	5..8:mbpri:=30;
	9:mbpri:=5;
	255:mbpri:=30;
	end;
if(fit.class=12)then mbpri:=(mbpri div 4)*it.mb;
if(pos('rune',fit.name1)<>0)and(fit.class=11)then inc(mbpri,5);
mbpri:=mbpri*12;
pri:=bonpri+mbpri;
{writeln(fit.name1,' ',bonpri,' ',mbpri,' ',pri);zn:=readkey;}
if(pri<1)then pri:=1;
if(fit.rarity>3)then pri:=pri*8
	else pri:=pri*fit.rarity;
pri:=(pri*th)div 100;
if(pri<1)then pri:=1;
price:=pri;
end;

function find(offset:integer):integer;
var
cl,r,f:shortint;
strn:string[4];
n:integer;
begin
if(offset=-1)then begin
	find:=-1;
	exit;
	end;
cl:=offset div 10;
if(cl>30)then dec(cl,30);
r:=offset mod 10;
n:=0;
while(fitems[n]^.class<>cl)or(fitems[n]^.rarity>3)do inc(n);
if(r>1)then for f:=n to n+r-2 do inc(n);
str(offset,strn);
if(n=0)then begin msg('BUG REPORT: FIND('+strn+') failed.');more;end;
find:=n;
{writeln('FIND CALLED ',offset,' ',cl,' ',r,',FOUND ',n);zn:=readkey;}
end;

procedure takeaway(var hook,it:itemptr);
begin
dec(it^.q);
if(it^.q>0)then exit;
it^.num:=-1;
{if(it^.prev=nil)then writeln('PREV NIL');
if(it^.next=nil)then writeln('NEXT NIL');
zn:=readkey;}
if(it^.prev<>nil)then (it^.prev)^.next:=it^.next
	else hook:=it^.next;
if(it^.next<>nil)then (it^.next)^.prev:=it^.prev;
dispose(it);
{sortinv;}
end;

function itemcmp(it1,it2:item):boolean;
begin
if(it1.num=it2.num)and(it1.mb=it2.mb)and(it1.id=it2.id)and(it1.flag=it2.flag)and
	(it1.curse=it2.curse)and(it1.curseid=it2.curseid)and(fitems[it2.num]^.class<>12)
	then itemcmp:=true
else itemcmp:=false;
end;

function itemcount(hook:itemptr):word;
var
f:word;
cur:itemptr;
begin
if(hook=nil)then begin
	itemcount:=0;
	exit;
	end;
cur:=hook;
f:=0;
repeat
{writeln(cur^.num);}
cur:=cur^.next;
inc(f);
until(cur=nil);
itemcount:=f;
end;

function itemget(hook:itemptr;n:word):itemptr;
var
f:word;
cur:itemptr;
begin
f:=itemcount(hook);
if(f<n)then begin itemget:=nil;exit;end;
cur:=hook;
for f:=2 to n do
	cur:=cur^.next;
itemget:=cur;
end;

procedure itemsortinto(var hook:itemptr;it:item);
var
f:word;
p,cur:itemptr;
begin
if(it.num<0)then exit;
if(it.num=0)and(it.mb<1)then begin
	msg('BUG REPORT: Trying to add nonsense amount of gold pieces.');
	exit;
	end;
if(pos('$bon',fitems[it.num]^.name1)=0)and(pos('$spc',fitems[it.num]^.name1)=0)and
	(pos('$mb',fitems[it.num]^.name1)=0)and(ids[it.num]=2)
	then it.id:=true;
if(fitems[it.num]^.class in[10..14])then it.curseid:=true;
cur:=hook;
while(cur<>nil)do begin
	if(itemcmp(cur^,it))and(fitems[it.num]^.class<>12)then begin
		inc(cur^.q,it.q);
		exit;
		end;
	cur:=cur^.next;
	end;
new(p);
p^:=it;
if(hook=nil)then begin
	{write('NIL HOOK');zn:=readkey;}
	p^.prev:=nil;
	p^.next:=nil;
	hook:=p;
	exit;
	end;
cur:=hook;
while(fitems[cur^.num]^.class<fitems[it.num]^.class)and(cur^.next<>nil)do cur:=(cur^.next);
if(cur^.next=nil)and(fitems[cur^.num]^.class<fitems[it.num]^.class)then begin
	{writeln('SORTING BEHIND:',pitem(cur^,true));}
	p^.prev:=cur;
	p^.next:=nil;
	cur^.next:=p;
	exit;
	end;
{writeln('SORTING TO FRONT OF:',pitem(cur^,true));zn:=readkey;}
p^.prev:=cur^.prev;
p^.next:=cur;
cur^.prev:=p;
if(p^.prev=nil)then hook:=p
	else (p^.prev)^.next:=p;
end;

function itemsel(hook:itemptr;filter:byte;what,whattodo:string;shopn:shortint):itemptr;
var
max,page,pos:word;
f,g:byte;
mark:array[0..255]of byte;
slct:array[0..39]of byte;
cur:itemptr;
begin
for f:=0 to 255 do mark[f]:=0;
if(hook<>nil)then begin
	pos:=0;g:=1;
	cur:=hook;
	repeat
	if(fitems[cur^.num]^.class=filter)or(filter=99)then begin
		if((pos mod 40)=0)then mark[pos div 40]:=g;
		inc(pos);
		end;
	cur:=cur^.next;
	inc(g);
	until(cur=nil);
	end;
for f:=0 to 39 do slct[f]:=0;
clrscr;
if(hook=nil)or(mark[0]=0)then begin
	gotoxy(2,2);
	if(what<>'')then writeln('- nothing to ',whattodo,' -')
		else writeln('You are not carrying anything.');
	zn:=readkey;
	itemsel:=nil;
	exit;
	end;
page:=0;
repeat
repeat
at(1,1);ink(15);
if(what='')then write('You are carrying:')
	else write('Select ',what,' to ',whattodo,':');
if(shopn=-1)then begin
	at(70,1);write('Carrying');
	at(70,2);write('capacity:');
	at(70,3);write((carcap/10):7:1);
	at(48,1);write((weight/10):7:1);
	end
else begin
	at(40,43);write('Gold: ',goldown,' gp');
	end;
at(1,43);if(page>0)then write('''-'' previous page ');
if(mark[page+1]<>0)then write('''+'' next page');
at(1,44);write('''SPACE'' cancel');
ink(7);
cur:=itemget(hook,mark[page]);
pos:=mark[page];
max:=0;
for f:=0 to 39 do begin
	at(1,f+2);ink(14);write(choice[f+1],') ');ink(7);
	if(cur^.curseid)and(fitems[cur^.num]^.class in [1..9,15,16])then
		if(cur^.curse)then ink(12)
			else ink(2);
	write(pitem(cur^,1,false,true));
	if(cur^.q>1)then begin
		at(47,f+2);write(cur^.q:2,'x',(fitems[cur^.num]^.weight/10):5:1);
		end
	else begin
		at(50,f+2);write((fitems[cur^.num]^.weight/10):5:1);
		end;
	if(shopn>-1)then begin
		if(wizard)then begin at(70,f+2);write(price(cur^,100));end;
		at(55,f+2);write(price(cur^,shop[shopn]^.thief):8,' gp');
		end;
	slct[f]:=pos;
	inc(max);
	repeat
	cur:=cur^.next;
	inc(pos);
	until(fitems[cur^.num]^.class=filter)or(filter=99)or(cur=nil);
	if(cur=nil)then break;
	end;
corner;
zn:=readkey;
if(zn='+')and(mark[page+1]<>0)then begin clrscr;inc(page);end;
if(zn='-')and(page>0)then begin clrscr;dec(page);end;
until(zn in ['a'..'z','A'..'Z',' ']);
if(zn=' ')then begin itemsel:=nil;exit;end;
g:=0;
repeat inc(g) until(choice[g]=zn);
until(g<=max);
itemsel:=itemget(hook,slct[g-1]);
end;

procedure destroylist(var hook:itemptr);
var
cur,next:itemptr;
begin
if(hook=nil)then exit;
cur:=hook;
repeat
if(cur^.num<0)or(cur^.num>noofitems)then begin
	msg('WARNING ! POSSIBLE CRASH !');
	if(iyesorno('Continue destroying this itemlist? ("no" recommended)')=false)then begin
		hook:=nil;
		exit;
		end;
	end;
next:=cur^.next;
dispose(cur);
{writeln('DISPOSED');}
cur:=next;
until(cur=nil);
hook:=nil;
end;

procedure savelist(hook:itemptr);
var
n,size:byte;
cur:itemptr;
begin
{writeln('SAVE');zn:=readkey;}
n:=itemcount(hook);
diskop(@n,1,1);
if(n=0)then exit;
cur:=hook;
size:=sizeof(item);
repeat
diskop(cur,size,1);
{writeln('SAVED');}
cur:=cur^.next;
until(cur=nil);
end;

procedure loadlist(var hook:itemptr);
var
n,f,size:byte;
last,cur:itemptr;
begin
{if(wizard)then writeln('LOADLIST');}
if(hook<>nil)then {destroylist(hook);}
	begin msg('BUG REPORT: Initialized pointer passed to LOADLIST.');
	more;end;
size:=sizeof(item);
diskop(@n,1,0);
hook:=nil;
if(n=0)then exit;
last:=nil;
for f:=1 to n do begin
	new(cur);
	diskop(cur,size,0);
	if(f=1)then hook:=cur;
	cur^.prev:=last;
	if(last<>nil)then last^.next:=cur;
	last:=cur;
	end;
cur^.next:=nil;
end;

procedure damageitem(var hook:itemptr;it:itemptr;show:boolean;what:string);
var
s,s0:string[40];
f,classspc:byte;
itm:item;
begin
case fitems[it^.num]^.class of
1:classspc:=2;
2..6,9:classspc:=3;
end;
s:=pitem(it^,0,true,false);
s0:=fitems[it^.num]^.name0;
if(s0[length(s0)]='s')and(s0[length(s0)-1]<>'s')then s:=s+' weren''t'
	else s:=s+' wasn''t';
if(fitems[it^.num]^.rarity>3)then begin
	if(show)then msg('Your '+s+' affected by '+what+'.');
	exit;
	end;
if(fitems[it^.num]^.subclass>2)and(classspc=3)and(fitems[it^.num]^.class<>9)then begin
	if(show)then msg('Your '+s+' affected by '+what+'.');
	exit;
	end;
s:=pitem(it^,0,true,false);
if(show)then msg(what+' has damaged your '+s+'.');
itm:=it^;
if(fitems[itm.num]^.spec<>classspc)or(itm.flag>0)then begin
	if(fitems[itm.num]^.spec<>classspc)then begin
		repeat
		inc(itm.num);
		until(fitems[itm.num]^.spec=classspc);
		itm.mb:=0;
		itm.id:=true;
		ids[itm.num]:=2;
		end;
	itm.flag:=0;
	if(show)then msg('It lost its magic power.');
	end
else dec(itm.mb);
for f:=1 to itm.q do begin
if(-itm.mb>(random(fitems[itm.num]^.bonus)+5))then begin
	if(show)then msg('It crumbles to pieces.');
	dec(itm.q);
	end;
end;
if(itm.q<1)then itm.num:=-1;
if(hook=nil)then it^:=itm	{equipment}
	else if(itm.num=-1)then begin	{item list}
		it^.q:=1;
		takeaway(hook,it);
		end
		else it^:=itm;
{	else begin
		it^.q:=1;
		takeaway(hook,it);
		itemsortinto(hook,itm);
		end;}

end;

procedure burnscrolls(var hook:itemptr;show:boolean);
var
f:byte;
amount:integer;
cur,new:itemptr;
itm:item;
begin
cur:=nil;
if(hook=inv)then
	for f:=0 to 7 do
	if(equip[f].num>-1)then
		if(fitems[equip[f].num]^.class in [2..6,9])and(fitems[equip[f].num]^.subclass=1)
		and(random(3)=0)then
			damageitem(cur,@equip[f],show,'fire');
if(random(2)=0)then exit;
cur:=hook;new:=nil;
while(cur<>nil)do begin
amount:=round((cur^.q*random(100))/100);
if(amount=0)or(fitems[cur^.num]^.rarity>3)then begin cur:=cur^.next;continue;end;
if(amount<0)then begin msg('BUG REPORT: Trying to damage negative amount.');continue;end;
case fitems[cur^.num]^.class of
11:begin
	f:=cur^.q;cur^.q:=amount;
	if(show)then msg(pitem(cur^,1,true,true)+' is burned to ashes.');
	cur^.q:=f-amount+1;
	takeaway(hook,cur);
	continue;
	end;
2..6:if(fitems[cur^.num]^.subclass=1)then begin
	itm:=cur^;
	f:=cur^.q;cur^.q:=amount;
	itm.q:=f-amount;
	damageitem(hook,cur,show,'fire');
	if(itm.q>0)and(wizard)then begin writeln('NEW Q:',itm.q);itemsortinto(new,itm);end;
	end;
9:begin
	itm:=cur^;
	f:=cur^.q;cur^.q:=amount;
	itm.q:=f-amount;
	damageitem(hook,cur,show,'fire');
	if(itm.q>0)and(wizard)then begin writeln('NEW Q:',itm.q);itemsortinto(new,itm);end;
	end;
end;
cur:=cur^.next;
end;
cur:=new;
while(cur<>nil)do begin
if(wizard)then msg('NEW '+pitem(cur^,1,true,true));
itemsortinto(hook,cur^);
cur:=cur^.next;
end;
destroylist(new);
end;

procedure freezepotions(var hook:itemptr;show:boolean);
var
f:byte;
amount:integer;
cur:itemptr;
begin
cur:=hook;
while(cur<>nil)do begin
amount:=round((cur^.q*random(100))/100);
if(amount=0)or(fitems[cur^.num]^.rarity>3)then begin cur:=cur^.next;continue;end;
if(amount<0)then begin msg('BUG REPORT: Trying to damage negative amount.');continue;end;
if(fitems[cur^.num]^.class=10)then begin
	f:=cur^.q;cur^.q:=amount;
	if(show)then msg(pitem(cur^,1,true,true)+' shatters.');
	cur^.q:=f-amount+1;
	takeaway(hook,cur);
	end;
cur:=cur^.next;
end;
end;

procedure identifyequip(n:byte);
begin
if(equip[n].num<0)then exit;
if(equip[n].id)then exit;
if(random(50)=0)and(ids[equip[n].num]=2)then begin
	equip[n].id:=true;
	msg('You have some idea about the magical nature of '+pitem(equip[n],2,false,false)+'.');
	end;
if(ids[equip[n].num]=2)then exit;
if(random(5)=0)then begin
	ids[equip[n].num]:=2;
	msg('You find out the usual quality of '+pitem(equip[n],2,false,false)+'.');
	end;
end;











end.
