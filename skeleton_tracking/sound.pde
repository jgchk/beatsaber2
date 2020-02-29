import beads.*;
import org.jaudiolibs.beads.*;

AudioContext ac;
Music music;
Gain master;

void setupAudio() {
  ac = new AudioContext();
  music = new Music();
  master = new Gain(ac, 1, 1.0);
}

void buildGraph() {
  master.addInput(music.player);
  ac.out.addInput(master);
  ac.start();
}

class Music {
  SamplePlayer player;
  
  Music() {
    player = getSamplePlayer("01 IM THE MAN.mp3");
    player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    player.pause(true);
  }
  
  void play() {
    this.player.start();
  }
  
  void pause() {
    this.player.pause(true);
  }
}

Sample getSample(String fileName) {
 return SampleManager.sample(dataPath(fileName));
}

SamplePlayer getSamplePlayer(String fileName, Boolean killOnEnd) {
  SamplePlayer player = null;
  try {
    player = new SamplePlayer(ac, getSample(fileName));
    player.setKillOnEnd(killOnEnd);
    player.setName(fileName);
  }
  catch(Exception e) {
    println("Exception while attempting to load sample: " + fileName);
    e.printStackTrace();
    exit();
  }

  return player;
}

SamplePlayer getSamplePlayer(String fileName) {
  return getSamplePlayer(fileName, false);
}
