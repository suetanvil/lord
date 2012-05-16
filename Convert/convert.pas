type
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
filemonster=record
		name:string[35];
		class:byte;
		athit:shortint;
		atdam:shortint;
		def:shortint;
		color:byte;
		rarity:shortint;
		inv:integer;
		speed:integer;
		spec:word;
		spec2:word;
		hlt:byte;
		int:byte;
		mood:shortint;
		spell:word;
		end;

var
fitems:array[0..300] of fileitem;
fmons:array[0..300] of filemonster;
itemfile:text;
outitem:text;
monsterfile:text;
outmon:text;
datfile:file of fileitem;
datfile2:file of filemonster;
txt:string;
g,f,e,num:integer;
com,uncom,rare,artif,monartif,filenum:byte;
temp:string[5];
zn:char;

label
monstra,arena,konec;

function testbit(num:integer;which:byte):boolean;
begin
if odd(num shr which) then testbit:=true
	else testbit:=false;
end;

function exper(n:byte):word;
var
f:byte;
fm:filemonster;
xp:real;
begin
fm:=fmons[n];
xp:=0;
{xp:=(fm.athit/20)*(fm.atdam/20)*(fm.def/20);}
xp:=(sqrt(fm.athit)*sqrt(fm.atdam)*sqrt(fm.def))/15;
if(fm.athit>80)then xp:=xp+2;
if(fm.atdam>80)then xp:=xp+2;
if(fm.def>80)then xp:=xp+2;
xp:=xp+(fm.speed/20)-5;
xp:=xp*((9+fm.hlt)/10);
for f:=0 to 15 do
	if(testbit(fm.spec,f))then xp:=xp*1.1;
for f:=0 to 15 do
	if(testbit(fm.spec2,f))then xp:=xp*1.1;
if(testbit(fm.spec,0))then
	for f:=0 to 15 do
		if(testbit(fm.spell,f))then xp:=xp*1.4;
if(xp<1)then xp:=1;
if(xp>10000)then xp:=10000;
exper:=round(xp);
end;

begin
writeln('Konvertovat itemy? (n=ne)');
readln(zn);
if(zn='n')then goto monstra;
writeln('Converting items...');
assign(itemfile,'item.txt');
assign(outitem,'oitem.txt');
reset(itemfile);
rewrite(outitem);
com:=0;uncom:=0;rare:=0;artif:=0;monartif:=0;
f:=0;
filenum:=0;
repeat
str(f,temp);write(outitem,temp,' ');
readln(itemfile,txt);
fitems[f].name0:=txt;
readln(itemfile,txt);writeln(outitem,txt);
fitems[f].name1:=txt;
readln(itemfile,txt);
val(txt,fitems[f].class,e);
readln(itemfile,txt);
val(txt,fitems[f].subclass,e);
readln(itemfile,txt);
val(txt,fitems[f].bonus,e);
readln(itemfile,txt);
val(txt,fitems[f].mb,e);
readln(itemfile,txt);
val(txt,fitems[f].spec,e);
readln(itemfile,txt);
val(txt,fitems[f].weight,e);
readln(itemfile,txt);
val(txt,fitems[f].rarity,e);
case fitems[f].rarity of
1:inc(com);
2:inc(uncom);
3:inc(rare);
4:inc(artif);
5:inc(monartif);
else writeln(outitem,'ERROR');
end;
inc(f);
if(eof(itemfile))and(filenum=0)then begin
	close(itemfile);
	assign(itemfile,'item2.txt');
	reset(itemfile);
	inc(filenum);
	end;
until(eof(itemfile));
close(itemfile);
assign(datfile,'item.dat');
rewrite(datfile);
g:=0;
repeat
write(datfile,fitems[g]);
inc(g);
until(g=f);
close(datfile);
writeln(outitem);
writeln(outitem,'Common:   ',com:3);
writeln(outitem,'Uncommon: ',uncom:3);
writeln(outitem,'Rare:     ',rare:3);
writeln(outitem,'Artifact: ',artif:3);
writeln(outitem,'MArtifact:',monartif:3);
writeln(outitem,'         ----');
writeln(outitem,'Total:    ',com+uncom+rare+artif+monartif:3);
close(outitem);

monstra:
writeln('Konvertovat monstra? (n=ne)');
readln(zn);
if(zn='n')then goto arena;
writeln('Converting monsters...');
assign(monsterfile,'monster.txt');
assign(outmon,'omon.txt');
reset(monsterfile);
rewrite(outmon);
f:=0;
filenum:=0;
repeat
str(f,temp);write(outmon,temp,' ');
readln(monsterfile,txt);write(outmon,txt,' ');
fmons[f].name:=txt;
readln(monsterfile,txt);
val(txt,fmons[f].class,e);
readln(monsterfile,txt);
val(txt,fmons[f].athit,e);
readln(monsterfile,txt);
val(txt,fmons[f].atdam,e);
readln(monsterfile,txt);
val(txt,fmons[f].def,e);
readln(monsterfile,txt);
val(txt,fmons[f].color,e);
readln(monsterfile,txt);
val(txt,fmons[f].rarity,e);
readln(monsterfile,txt);
val(txt,fmons[f].inv,e);
readln(monsterfile,txt);
val(txt,fmons[f].speed,e);
readln(monsterfile,txt);
val(txt,fmons[f].spec,e);
readln(monsterfile,txt);
val(txt,fmons[f].spec2,e);
readln(monsterfile,txt);
val(txt,fmons[f].hlt,e);
readln(monsterfile,txt);
val(txt,fmons[f].int,e);
readln(monsterfile,txt);
val(txt,fmons[f].mood,e);
readln(monsterfile,txt);
val(txt,fmons[f].spell,e);
writeln(outmon,exper(f),' xp');
inc(f);
if(eof(monsterfile))and(filenum=0)then begin
	close(monsterfile);
	assign(monsterfile,'monster2.txt');
	reset(monsterfile);
	inc(filenum);
	end;
until(eof(monsterfile));
close(monsterfile);
assign(datfile2,'monster.dat');
rewrite(datfile2);
g:=0;
repeat
write(datfile2,fmons[g]);
inc(g);
until(g=f);
close(datfile2);
close(outmon);
assign(outmon,'omondist.txt');
rewrite(outmon);
for g:=1 to 100 do
	for e:=0 to f do
		if(fmons[e].rarity=g)then writeln(outmon,g,' '+fmons[e].name,' ',exper(e),' xp');
close(outmon);

arena:
writeln('Konvertovat arenu? (n=ne)');
readln(zn);
if(zn='n')then goto konec;
writeln('Converting arena opponents...');
assign(monsterfile,'arena.txt');
assign(outmon,'oarena.txt');
reset(monsterfile);
rewrite(outmon);
f:=0;
filenum:=0;
repeat
str(f,temp);write(outmon,temp,' ');
readln(monsterfile,txt);write(outmon,txt,' ');
fmons[f].name:=txt;
readln(monsterfile,txt);
val(txt,fmons[f].class,e);
readln(monsterfile,txt);
val(txt,fmons[f].athit,e);
readln(monsterfile,txt);
val(txt,fmons[f].atdam,e);
readln(monsterfile,txt);
val(txt,fmons[f].def,e);
readln(monsterfile,txt);
val(txt,fmons[f].color,e);
readln(monsterfile,txt);
val(txt,fmons[f].rarity,e);
readln(monsterfile,txt);
val(txt,fmons[f].inv,e);
readln(monsterfile,txt);
val(txt,fmons[f].speed,e);
readln(monsterfile,txt);
val(txt,fmons[f].spec,e);
readln(monsterfile,txt);
val(txt,fmons[f].spec2,e);
readln(monsterfile,txt);
val(txt,fmons[f].hlt,e);
readln(monsterfile,txt);
val(txt,fmons[f].int,e);
readln(monsterfile,txt);
val(txt,fmons[f].mood,e);
readln(monsterfile,txt);
val(txt,fmons[f].spell,e);
writeln(outmon,exper(f),' xp');
inc(f);
{if(eof(monsterfile))and(filenum=0)then begin
	close(monsterfile);
	assign(monsterfile,'monster2.txt');
	reset(monsterfile);
	inc(filenum);
	end;}
until(eof(monsterfile));
close(monsterfile);
assign(datfile2,'arena.dat');
rewrite(datfile2);
g:=0;
repeat
write(datfile2,fmons[g]);
inc(g);
until(g=f);
close(datfile2);
close(outmon);

konec:
end.
