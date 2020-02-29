/* eslint-disable no-console */
/* eslint-disable no-param-reassign */
import 'p5/lib/addons/p5.sound'
import soundFile from '../public/pacific-707.opus'

let sound

const sketch = p => {
  p.preload = () => {
    console.log('preload')
    sound = p.loadSound(soundFile)
  }

  p.setup = () => {
    console.log('setup')
    sound.setVolume(1)
    sound.play()
  }
}

export default sketch
