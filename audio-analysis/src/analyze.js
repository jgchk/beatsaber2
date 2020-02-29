/* eslint-disable no-console */
/* eslint-disable no-param-reassign */
import 'p5/lib/addons/p5.sound'

function getPeaks(sound, length) {
  console.log('getPeaks')
  return Array.from(sound.getPeaks(length))
}

function getBeats(sound) {
  return new Promise(resolve => {
    const callback = beats => {
      console.log('callback')
      resolve(beats)
    }
    sound.processPeaks(callback)
    console.log('getBeats')
  })
}

const sketch = soundFile => p => {
  let sound

  p.preload = () => {
    console.log('preload')
    sound = p.loadSound(soundFile)
  }

  p.setup = async () => {
    console.log('setup')
    p.createCanvas(p.windowWidth, p.windowHeight - 10)

    const peaks = getPeaks(sound, p.windowWidth)
    console.log(peaks)
    const beats = await getBeats(sound)
    console.log(beats)
  }
}

export default sketch
