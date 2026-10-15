from pathlib import Path
from PIL import Image, ImageDraw
import random, math, wave, struct
ROOT=Path(__file__).resolve().parents[1]
A=ROOT/'assets'; A.mkdir(parents=True,exist_ok=True)
random.seed(17)
def save(name,size,fn):
 im=Image.new('RGBA',size); d=ImageDraw.Draw(im); fn(d); im.save(A/(name+'.png'))
def cat(d):
 # Eight animation frames. Original hand-placed pixel clusters.
 for f in range(8):
  x=f*32; b=1 if f%4 in (1,2) else 0
  def r(box,c):d.rectangle((box[0]+x,box[1]+b,box[2]+x,box[3]+b),fill=c)
  r((7,17,10,25),'#323452');r((5,15,8,22),'#323452');r((5,14,7,18),'#e3bcb8')
  r((11,16,23,27),'#292b49');r((12,15,22,25),'#e6c8bc');r((13,23,17,28 if f%2 else 27),'#f9e3c8');r((20,23,23,27 if f%2 else 28),'#f9e3c8')
  r((10,8,25,20),'#292b49');r((11,6,15,12),'#292b49');r((21,6,25,12),'#292b49');r((12,8,15,13),'#e9c9b8');r((22,8,24,13),'#e9c9b8');r((12,11,24,19),'#f9e3c8');r((13,10,16,12),'#f9e3c8');r((21,10,23,12),'#f9e3c8');r((13,8,14,10),'#d48b9f');r((23,8,23,10),'#d48b9f')
  r((15,14,16,16),'#343650');r((22,14,23,16),'#343650');r((15,14,15,14),'#a4fff0');r((19,17,20,17),'#c68391');r((11,20,24,22),'#598fac');r((12,21,15,25),'#7cd9d5');r((20,21,23,21),'#c5fff1')
save('cat',(256,32),cat)
def slime(d):
 for f in range(4):
  x=f*32; b=f%2
  d.ellipse((x+4,10+b*2,x+28,28),fill='#1b3547');d.ellipse((x+5,9+b*2,x+27,25),fill='#527b83');d.rectangle((x+9,12+b,x+23,24),fill='#71b5aa');d.rectangle((x+10,13+b,x+16,15+b),fill='#a6e5bc');d.rectangle((x+12,19,x+14,21),fill='#1c3547');d.rectangle((x+21,19,x+23,21),fill='#1c3547');d.rectangle((x+4,5,x+7,13),fill='#d3b0dc');d.rectangle((x+2,4,x+9,7),fill='#9c83c8')
save('slime',(128,32),slime)
def moth(d):
 for f in range(4):
  x=f*32; b=(f%2)*5
  d.polygon([(x+16,16),(x+1,5+b),(x+4,23-b),(x+13,24)],fill='#513758');d.polygon([(x+17,16),(x+30,5+b),(x+28,23-b),(x+21,24)],fill='#513758');d.polygon([(x+14,16),(x+4,8+b),(x+7,19),(x+13,21)],fill='#c197c5');d.polygon([(x+19,16),(x+28,8+b),(x+25,19),(x+20,21)],fill='#c197c5');d.rectangle((x+15,12,x+18,24),fill='#ecdcaf');d.point((x+15,14),fill='#25253d');d.point((x+18,14),fill='#25253d')
save('moth',(128,32),moth)
def boar(d):
 for f in range(4):
  x=f*40;b=f%2
  d.rectangle((x+8,13+b,x+30,29),fill='#352c46');d.rectangle((x+6,12+b,x+28,25),fill='#8f708d');d.rectangle((x+10,10+b,x+22,16),fill='#b39ba7');d.rectangle((x+24,17,x+36,26),fill='#9e829d');d.rectangle((x+29,20,x+37,25),fill='#d4b0ba');d.rectangle((x+10,27,x+14,31-b),fill='#352c46');d.rectangle((x+24,27,x+28,31-b),fill='#352c46');d.rectangle((x+26,13,x+28,16),fill='#ffdd9c');d.polygon([(x+30,26),(x+31,20),(x+33,26)],fill='#f0ddbd');d.polygon([(x+9,13),(x+12,4),(x+17,13)],fill='#53425c')
save('boar',(160,40),boar)
def boss(d):
 for f in range(4):
  x=f*96;b=f%2
  # Branching antlers, moon crown, deer skull and cloak.
  for side in (-1,1):
   pts=[(x+48+side*13,30),(x+48+side*25,16),(x+48+side*29,3)]
   d.line(pts,fill='#a5d3cd',width=3);d.line([(x+48+side*25,16),(x+48+side*38,12),(x+48+side*39,4)],fill='#a5d3cd',width=3);d.line([(x+48+side*21,21),(x+48+side*14,7)],fill='#a5d3cd',width=2)
  d.polygon([(x+34,45+b),(x+61,45+b),(x+75,82),(x+48,89),(x+22,82)],fill='#272d4d');d.polygon([(x+37,48+b),(x+58,48+b),(x+66,77),(x+49,84),(x+30,77)],fill='#4d6577');d.line([(x+48,52),(x+48,82)],fill='#8bb0b1',width=2)
  d.polygon([(x+30,29+b),(x+65,29+b),(x+61,48+b),(x+48,59+b),(x+34,46+b)],fill='#c4dfd0');d.polygon([(x+36,33+b),(x+45,36+b),(x+43,42+b),(x+35,40+b)],fill='#26344d');d.polygon([(x+51,36+b),(x+60,33+b),(x+60,40+b),(x+53,42+b)],fill='#26344d');d.rectangle((x+37,37+b,x+42,39+b),fill='#7affd6');d.rectangle((x+54,37+b,x+58,39+b),fill='#7affd6');d.polygon([(x+47,48+b),(x+50,48+b),(x+49,53+b)],fill='#4d6577');d.ellipse((x+42,16,x+54,28),fill='#dfdbac');d.ellipse((x+46,14,x+57,24),fill='#00000000')
save('boss',(384,96),boss)
def tree(d):
 d.rectangle((42,77,55,123),fill='#232b3c');d.rectangle((46,78,50,121),fill='#3c3e4d');d.polygon([(48,121),(27,131),(43,127),(62,130),(55,120)],fill='#283747')
 for cy,w in [(36,35),(59,44),(80,48)]:
  d.polygon([(48,cy-31),(48+w,cy+22),(48+24,cy+19),(48+14,cy+29),(48-15,cy+24),(48-w,cy+22)],fill='#142d39')
  d.polygon([(48,cy-27),(48+w-8,cy+16),(48+17,cy+14),(48+10,cy+21),(48-21,cy+17),(48-w+5,cy+17)],fill='#244958')
  d.line([(48,cy-24),(48-21,cy+12),(48-6,cy+9)],fill='#386271',width=2)
 for i in range(22):
  x=random.randint(24,70);y=random.randint(33,95);d.rectangle((x,y,x+2,y+1),fill='#47727a')
save('tree',(96,136),tree)
def decor(d):
 for i in range(8):
  x=i*24
  if i<3:
   d.polygon([(x+3,18),(x+5,9),(x+13,5),(x+21,11),(x+20,20)],fill='#293747');d.polygon([(x+5,10),(x+13,5),(x+20,11),(x+13,13)],fill='#536775');d.line([(x+6,15),(x+13,14)],fill='#6f8b86',width=2)
  elif i<5:
   d.rectangle((x+10,12,x+13,22),fill='#b4a3b9');d.rectangle((x+5,9,x+19,14),fill='#755e9c');d.rectangle((x+8,7,x+16,9),fill='#b6a5d0');d.point((x+9,11),fill='#f8d6dd');d.point((x+16,12),fill='#f8d6dd')
  else:
   d.line([(x+12,21),(x+12,10)],fill='#507b72',width=2);d.rectangle((x+9,7,x+14,11),fill=['#d4acbf','#94c9b9','#af9adb'][i-5]);d.point((x+11,9),fill='#f9e1b2');d.line([(x+12,17),(x+6,13)],fill='#507b72')
save('decor',(192,24),decor)
# Fully original synthesized audio. PCM WAV, no samples or third-party dependencies.
RATE=22050
def wav(name,sec,fn):
 n=int(sec*RATE)
 with wave.open(str(A/(name+'.wav')),'wb') as w:
  w.setparams((1,2,RATE,n,'NONE','not compressed'));w.writeframes(b''.join(struct.pack('<h',max(-32767,min(32767,int(fn(i/RATE)*32767)))) for i in range(n)))
wav('swipe',.16,lambda t:(random.random()*2-1)*.20*(1-t/.16)+math.sin(2*math.pi*(750*t-1600*t*t))*.08*(1-t/.16))
wav('hit',.18,lambda t:(math.sin(2*math.pi*(130*t-210*t*t))*.5+(random.random()*2-1)*.16)*math.exp(-27*t))
wav('roll',.22,lambda t:(random.random()*2-1)*.15*math.sin(math.pi*t/.22))
wav('chime',.8,lambda t:sum(math.sin(2*math.pi*f*t)*math.exp(-5*t) for f in [523.25,783.99,1046.5])*.11)
wav('hurt',.3,lambda t:math.sin(2*math.pi*(210*t-180*t*t))*.3*math.exp(-12*t))
notes=[220,261.63,329.63,392,329.63,261.63,196,293.66,349.23,440,349.23,293.66,174.61,261.63,329.63,392]
def music(t):
 beat=int(t/.6);u=t% .6;f=notes[beat%16]
 melody=math.sin(2*math.pi*f*2*u)*math.exp(-u*5)*.055+math.sin(2*math.pi*f*4*u)*math.exp(-u*11)*.016
 bass=[110,98,87.307,98][int(t/2.4)%4]
 pad=sum(math.sin(2*math.pi*bass*m*t) for m in [1,1.5,2])*.018
 return (melody+pad)*min(1,t*4, (19.2-t)*4)
wav('grove',19.2,music)
print(ROOT)
