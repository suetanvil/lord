unit gener;

interface
uses mycrt,crt;

var
map:array[1..x_map,1..y_map]of integer;
			{      ^^^^^^^          }
		     {zmenu hlasit v editoru !!!!!!!!!!}

typemap,oldseemap,seemap:array[1..x_map,1..y_map]of byte;
					  {         ^^^^               }
					  {zmenu hlasit v editoru !!!!!}

procedure mapgen(r,p:shortint);
function pass(x,y:byte):boolean;

implementation

var
rx1,rx2,ry1,ry2:array[1..20]of shortint;
f,g,room,path,door:shortint;
zn:char;

procedure swap(var v1,v2:integer);
var
dum:integer;
begin
dum:=v1;
v1:=v2;
v2:=dum;
end;

procedure genroom(kol:integer);
var
jak,h,g,f,x1,x2,y1,y2:shortint;
begin
for x1:=2 to x_map-1 do
for y1:=2 to y_map-1 do
	map[x1,y1]:=0;
for f:=1 to kol do
begin
	repeat
	x1:=random(x_map-6)+2;y1:=random(y_map-6)+2;
	x2:=random(7)+x1+3;y2:=random(5)+y1+3;
	if x2>(x_map-1) then x2:=x_map-1;
	if y2>(y_map-1) then y2:=y_map-1;
	until(map[x1,y1]=0)and(map[x1,y2]=0)and(map[x2,y1]=0)and(map[x2,y2]=0)and(x2-x1>1)and(y2-y1>1);
	rx1[f]:=x1;rx2[f]:=x2;
	ry1[f]:=y1;ry2[f]:=y2;
	for g:=x1 to x2 do
	for h:=y1 to y2 do
	map[g,h]:=1;
	for g:=x1-1 to x2+1 do
	begin
		map[g,y1-1]:=3;
		map[g,y2+1]:=3;
	end;
	for h:=y1-1 to y2+1 do
	begin
		map[x1-1,h]:=3;
		map[x2+1,h]:=3;
	end;
end;
for g:=1 to x_map do
for h:=1 to y_map do
if map[g,h]=3 then map[g,h]:=0;
for x1:=1 to x_map do
begin
	map[x1,1]:=99;
	map[x1,y_map]:=99;
	end;
for y1:=1 to y_map do
begin
	map[1,y1]:=99;
	map[x_map,y1]:=99;
	end;
end;

procedure genpath(kol:integer);
var
x1,x2,y1,y2,f,g,jak,r1,r2:shortint;
begin
repeat
r1:=random(room)+1;r2:=random(room)+1;
until(r1<>r2);
kol:=room-1;
for g:=1 to kol do
begin
repeat
	jak:=random(4);r1:=r1+1;
	if r1>room then r1:=1;
	case jak of
	0:begin
	x1:=rx1[r1];y1:=random(ry2[r1]-ry1[r1])+ry1[r1];
	end;
	1:begin
	x1:=rx2[r1];y1:=random(ry2[r1]-ry1[r1])+ry1[r1];
	end;
	2:begin
	y1:=ry1[r1];x1:=random(rx2[r1]-rx1[r1])+rx1[r1];
	end;
	3:begin
	y1:=ry2[r1];x1:=random(rx2[r1]-rx1[r1])+rx1[r1];
	end;
	end;

	jak:=random(4);r2:=r2+1;
	if r2>room then r2:=1;
	case jak of
	0:begin
	x2:=rx1[r2];y2:=random(ry2[r2]-ry1[r2])+ry1[r2];
	end;
	1:begin
	x2:=rx2[r2];y2:=random(ry2[r2]-ry1[r2])+ry1[r2];
	end;
	2:begin
	y2:=ry1[r2];x2:=random(rx2[r2]-rx1[r2])+rx1[r2];
	end;
	3:begin
	y2:=ry2[r2];x2:=random(rx2[r2]-rx1[r2])+rx1[r2];
	end;
	end;
until(abs(x1-x2)>1)and(abs(y1-y2)>1);
	jak:=random(2);
	case jak of
		0:begin
		if x1<x2 then for f:=x1 to x2 do map[f,y1]:=1
			else for f:=x1 downto x2 do map[f,y1]:=1;
		if y1<y2 then for f:=y1 to y2 do map[x2,f]:=1
			else for f:=y1 downto y2 do map[x2,f]:=1;
		end;
		1:begin
		if y1<y2 then for f:=y1 to y2 do map[x1,f]:=1
			else for f:=y1 downto y2 do map[x1,f]:=1;
		if x1<x2 then for f:=x1 to x2 do map[f,y2]:=1
			else for f:=x1 downto x2 do map[f,y2]:=1;
		end;
	end;
{zn:=readkey; }
end;
end;

procedure putd(x,y,d:integer);
var
wx,wy,c:integer;
begin
c:=0;
if(map[x-1,y]=0)and(map[x+1,y]=0)then c:=1;
if(map[x,y-1]=0)and(map[x,y+1]=0)then c:=1;
if c=1 then map[x,y]:=d;
end;

procedure gendoor(door:integer);
var
f,r,x,y,jak,d:shortint;
begin
for f:=1 to door do
begin
	r:=random(room)+1;
	d:=random(100);
	jak:=random(4);
	case jak of
	0:begin
	for x:=rx1[r] to rx2[r] do
	begin
		if (map[x,ry1[r]-1]>0) then putd(x,ry1[r]-1,2);
		if (map[x,ry1[r]-1]>0)and(d<70) then putd(x,ry1[r]-1,3);
		if (map[x,ry1[r]-1]>0)and(d<30) then putd(x,ry1[r]-1,4);
	end;
	end;
	1:begin
	for x:=rx1[r] to rx2[r] do
	begin
		if (map[x,ry2[r]+1]>0) then putd(x,ry2[r]+1,2);
		if (map[x,ry2[r]+1]>0)and(d<70) then putd(x,ry2[r]+1,3);
		if (map[x,ry2[r]+1]>0)and(d<30) then putd(x,ry2[r]+1,4);
	end;
	end;
	2:begin
	for y:=ry1[r] to ry2[r] do
	begin
		if (map[rx1[r]-1,y]>0) then putd(rx1[r]-1,y,2);
		if (map[rx1[r]-1,y]>0)and(d<70) then putd(rx1[r]-1,y,3);
		if (map[rx1[r]-1,y]>0)and(d<30) then putd(rx1[r]-1,y,4);
	end;
	end;
	3:begin
	for y:=ry1[r] to ry2[r] do
	begin
		if (map[rx2[r]+1,y]>0) then putd(rx2[r]+1,y,2);
		if (map[rx2[r]+1,y]>0)and(d<70) then putd(rx2[r]+1,y,3);
		if (map[rx2[r]+1,y]>0)and(d<30) then putd(rx2[r]+1,y,4);
	end;
	end;
	end;
end;
end;

procedure genmisc;
var
x,y,f,r:shortint;
ok:boolean;
begin
repeat
	r:=random(room)+1;
	x:=random(rx2[r]-rx1[r]-2)+rx1[r]+1;
	y:=random(ry2[r]-ry1[r]-2)+ry1[r]+1;
	ok:=true;
	for f:=1 to 9 do
		if(map[x+pmx[f],y+pmy[f]]<>1)then ok:=false;
until(ok);
map[x,y]:=5;
repeat
	r:=random(room)+1;
	x:=random(rx2[r]-rx1[r]-2)+rx1[r]+1;
	y:=random(ry2[r]-ry1[r]-2)+ry1[r]+1;
	ok:=true;
	for f:=1 to 9 do
		if(map[x+pmx[f],y+pmy[f]]<>1)then ok:=false;
until(ok);
map[x,y]:=6;
if(random(10)=0)then begin
	repeat
	x:=random(x_map-2)+2;
	y:=random(y_map-2)+2;
	until (map[x,y]=1);
	typemap[x,y]:=random(10)*10+10;
	map[x,y]:=13;
	if(wizard)then msg('POOL');
	end;
for f:=1 to random(10) do begin
	repeat
	r:=random(room)+1;
	x:=random(rx2[r]-rx1[r]-2)+rx1[r]+1;
	y:=random(ry2[r]-ry1[r]-2)+ry1[r]+1;
	until (map[x,y]=1);
	map[x,y]:=7;
	end;
{traps}
for f:=1 to random(10) do begin
	repeat
	r:=random(room)+1;
	x:=random(rx2[r]-rx1[r]-2)+rx1[r]+1;
	y:=random(ry2[r]-ry1[r]-2)+ry1[r]+1;
	until (map[x,y]=1);
	map[x,y]:=11;
	typemap[x,y]:=random(5)+1;
	end;
end;

procedure speclev99; {cave}
var
x,y:byte;
begin
for x:=1 to x_map do begin
	map[x,1]:=99;
	map[x,y_map]:=99;
	end;
for y:=1 to y_map do begin
	map[1,y]:=99;
	map[x_map,y]:=99;
	end;
for x:=2 to x_map-1 do
for y:=2 to y_map-1 do
	map[x,y]:=1;
room:=1;
rx1[1]:=2;rx2[1]:=x_map-1;
ry1[1]:=2;ry2[1]:=y_map-1;
genmisc;
end;

procedure speclev100;	{labyrinth}
var
x,y:byte;
f:word;
begin
for x:=1 to x_map do begin
	map[x,1]:=99;
	map[x,y_map]:=99;
	end;
for y:=1 to y_map do begin
	map[1,y]:=99;
	map[x_map,y]:=99;
	end;
for x:=2 to x_map-1 do
for y:=2 to y_map-1 do
	map[x,y]:=0;
for x:=1 to ((x_map-2)div 2) do
for y:=1 to ((y_map-2)div 2) do
	map[x*2,y*2]:=1;
for f:=0 to ((x_map*y_map)div 3) do begin
	x:=(random((x_map-2)div 2)+1)*2;
	y:=random(y_map-2)+2;
	if(not(odd(y)))then inc(x);
	map[x,y]:=1;
	end;
for f:=0 to 25 do begin
	x:=(random((x_map-2)div 2)+1)*2;
	y:=random(17)+2;
	if(not(odd(y)))then inc(x);
	map[x,y]:=random(3)+2;
	end;
room:=1;
rx1[1]:=2;rx2[1]:=x_map-1;
ry1[1]:=2;ry2[1]:=y_map-1;
genmisc;
end;



procedure mapgen(r,p:shortint);
begin
room:=r;
path:=p;
door:=room*10;
if(wizard)then begin at(1,25);write('gen ',r,' ',p);end;
if(r<50)then begin
	genroom(room);
	genpath(path);
	gendoor(door);
	genmisc;
	end
else
	case r of
	99:speclev99;  {cave}
	100:speclev100; {labyrinth}
	end;
end;

function pass(x,y:byte):boolean;
var
qx:byte;
begin
qx:=map[x,y];
if(qx in [0,99,3,4,7,8,10]) then pass:=false else pass:=true;
end;






end.
