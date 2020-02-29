import beads.*;
import org.jaudiolibs.beads.*;

AudioContext ac;
Music music;
Effect explosion;
Effect miss;
Gain master;

void setupAudio() {
  ac = new AudioContext();
  music = new Music("melody-130.mp3");
  explosion = new Effect("explosion.wav");
  miss = new Effect("miss.mp3");
  master = new Gain(ac, 3, 1.0);
  buildGraph();
}

void buildGraph() {
  master.addInput(music.gain);
  master.addInput(explosion.gain);
  master.addInput(miss.gain);
  ac.out.addInput(master);
  ac.start();
}


class Effect {
  SamplePlayer player;
  Gain gain;
  
  Effect(String file) {
    player = getSamplePlayer(file);
    player.pause(true);
    player.setEndListener(
      new Bead() {
        public void messageReceived(Bead msg) {
          player.pause(true);
        }
      });
      
    gain = new Gain(ac, 1, 1.0);
    gain.addInput(player);
  }
  
  void play() {
    this.player.start(0);
  }
  
  void pause() {
    this.player.pause(true);
  }
}
  

class Music {
  SamplePlayer player;
  Gain gain;
  
  Music(String file) {
    player = getSamplePlayer(file);
    player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    player.pause(true);
    
    gain = new Gain(ac, 1, 1.0);
    gain.addInput(player);
  }
  
  void play() {
    this.player.start();
  }
  
  void pause() {
    this.player.pause(true);
  }
  
  float length() {
    return (float) this.player.getSample().getLength() / 1000;
  }
  
  float position() {
    return (float) this.player.getPosition() / 1000;
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
