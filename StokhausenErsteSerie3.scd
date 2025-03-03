
(

s.boot;

~buffers = Array.new();
~structure1 = Array.new();
~structure2 = Array.new();
~structureSpielen = false;
~load = {
	var directory, files, buffers, ff;



/*
directory = "/home/crecoproject/Experimete/Karlheinz Stokausen/TestSounds";  // Pfad zum Verzeichnis mit deinen Audiodateien

files = PathName.new(directory).files;

~buffers = files.collect { |file|
		var way;
		way = file.asAbsolutePath;
		way.postln;
    Buffer.read(s, way)  // Buffer für jede Audiodatei erstellen
};*/
};

~buildSerie =  {arg sice;
	var x;
	x = Array.series(sice);
	x.scramble
};

~buildStructure1 = { arg sice;
	~structure1 = Array.fill(sice, { ~buildSerie.value(sice)});
};

~buildStructure2 = { arg sice;
	~structure2 = Array.fill(sice, { ~buildSerie.value(sice)});
};

~playSound = { arg bufnum, duration;
	var b;
	b = Synth(\playBuffer, [bufnum: bufnum, dura: duration ]);
};


~playsWholeStructure = { arg item1, item2, level;
	for(0, (~buffers.size -1 )) { arg i;
		if(( level > 1),
			{ ~playsWholeStructure.value(~structure1[item1[i]], ~structure2[item2[i]], (level -1)); },
			{
				for(0, (~buffers.size-1 )) { arg i;
					~playSound.value(~buffers[item1[i]], item2[i]*0.5);
					item2[i].wait;
				};
		});

};

};


~wind = {
	// Erstelle ein Fenster
w = Window("Material Player", Rect(100, 100, 400, 400));

// Erstelle einen Button im Fenster
b = Button(w, Rect(0, 0, 400, 100), "", {
    "Button wurde geklickt!".postln;
});

	b.string = "Lade ein Sound Vrzeichniss";
	b.action = {
	f = FileDialog({ |paths|
    postln("Selected path:" + paths[0]);
    }, {
    postln("Dialog was cancelled. Try again.");
    }, fileMode: 0,
    stripResult: true,
    path: Platform.userAppSupportDir);
		f.visible;
};

c = Button(w, Rect(0, 100, 400, 100), "Berechne eine neue Struktur mit Levels:", {
    "Button wurde geklickt!".postln;
	});

	c.string = "Berechne eine neue Struktur mit Levels:";

	d = Slider(w, Rect(0, 200, 400, 100)).action_({
		c.string = "Berechne eine neue Struktur mit Levels:" + (d.value*12).round(1);
    });

e = Button(w, Rect(0, 300, 400, 100))
        .states_([
            ["Starte Structure Spielen", Color.black, Color.white],
            ["Structure Spielt !", Color.white, Color.red]
        ])
        .action_({ arg butt;
		if(butt == 0, {~structureSpielen = false}, { ~structureSpielen = true});
        });

//
	w.front;
};

~buildStructures = {

~buildStructure1.value(~buffers.size);
~buildStructure2.value(~buffers.size);
};

~playWholeStructure = Routine.new({
	var e, a;
	while {true }
	{
		~playsWholeStructure.value(~structure1[~buffers.size.rand], ~structure2[~buffers.size.rand], 1);
	}

});

x = SynthDef(\playBuffer, { arg out = 0, bufnum, dura;
    var env, enf;
	env = Env.triangle(dur: dura, level: 1.0);
	enf = EnvGen.kr(env, doneAction: Done.freeSelf);
	Out.ar( out,
        PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)) *enf;
    )
}).add;
)

~wind.value();

~buildStructures.value();

~playsWholeStructure.value(~structure1[~buffers.size.rand], ~structure2[~buffers.size.rand], 3);

~playWholeStructure.play;
~playWholeStructure.stop;
~playWholeStructure.reset;

