
///////////SuperCollider Workspace////////////
SuperDirt.start;

//s.reboot;
//Server.killAll
/////////////////////////////////////////////
~valdict = ();

(
var addr = NetAddr.new("127.0.0.1", 3333);
OSCdef(\tidalOSC, { |msg, time, tidalAddr|
	var latency = time - Main.elapsedTime;
	msg = msg ++ ["time", time, "latency", latency];
	addr.sendBundle(latency, msg);

	(1, 3 .. msg.size).do { |i|
 		~valdict.put(msg[i], msg[i+1]);
 	};
	~valdict.postcs;
	{ ~textfunc.value }.defer;
}, '/play2').fix;
)

(
var win, text;
win = Window.new("bots", 300@600);
text = TextView(win, win.view.bounds);
~textfunc = {
		text.string = ~valdict.asString
};
text.syntaxColorize;
win.front;
text.mouseUpAction_{|key, val|
	var ndef = Ndef("node: " ++ val.asString, {
		SinOsc.ar(\freq.kr(100, 0.3));
	});
	ndef[1] = \set -> Pbind(\dur, ~valdict.delta, \freq, Pfunc{~valdict.speed + val});
	ndef[1..8] = \filter -> {arg in; GVerb.ar(in, mul:0.1)};
	ndef.play(0,2)
};

NdefMixer(s);
)

Ndef(\test).play;
Ndef(\test)[0] = {SinOsc.ar(\freq.kr(240, 0.03))}
Ndef(\test)[1] = \set -> Pbind(\dur, 0.25, \freq, Prand((100..120), inf))

Ndef.

OSCdef('tidalOSC').disable
OSCdef('tidalOSC').enable

///////////////////////////////

///////////////////////////////
Ndef(\lfbass).fadeTime = 2;
Ndef(\darth).fadeTime = 2;

(
n=LFNoise1;
Ndef(\lfbass,{
		LPF.ar(
		SinOsc.ar(
			freq:60,
		phase: LFNoise1.kr(0.1).range(1, 2)*pi,
		mul:SinOsc.kr(0.01).range(0.1, 1.0)
	).tanh * EnvGen.kr(Env.perc(0.01, 0.4), Impulse.kr(8.5))
	)
}).play(0, 2);
)

NdefMixer(s)

Ndef(\lfbass)[1] = \filter -> {|in|  FreqShift.ar(in, Stepper.kr(Impulse.kr(10/60), 10, 40, 100, 10, 40) )};

(
n=LFNoise1;
Ndef(\darth,{
	a=SinOscFB.ar(65,
		Ndef(\darth).ar*n.ar(0.1, 3), n.ar(3,6)).tanh;
	9.do{a=AllpassL.ar(a,0.3,{0.2.rand+0.1}!2,5)};a.tanh})
)

Ndef(\darth).clear(60);
Ndef(\lfbass).clear(90);

NdefMixer(s)

Ndef(\darth).vol = 0.1;
Ndef(\lfbass).vol = 0.3

/////TidalCode
d1 $ every 1 (slow 8) $ sound "wobble"
# gain "1.5"
# legato 1
# speed 0.8
|*| pan saw

NetAddr("172.20.10.9", 57120).sendMsg('/piOSC', "Hello PI")