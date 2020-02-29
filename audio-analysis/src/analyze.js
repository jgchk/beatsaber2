/* eslint-disable no-console */
/* eslint-disable no-param-reassign */
import 'p5/lib/addons/p5.sound'

const sketch = soundFile => p => {
  let sound

  function getBeats() {
    return new Promise(resolve => {
      const callback = beats => {
        resolve(beats.sort((a, b) => a - b))
      }
      sound.processPeaks(callback)
    })
  }

  function createNoteMap(beats) {
    const noteChance = 0.5
    const leftChance = 0.45
    const rightChance = 0.45
    const bothChance = 0.1
    return Object.assign(
      {},
      ...beats.map((timestamp, i) => {
        let note
        const rand = p.noise(i)
        if (rand < noteChance) {
          if (rand < leftChance * noteChance) {
            note = [true, false]
          } else if (rand < (leftChance + rightChance) * noteChance) {
            note = [false, true]
          } else if (
            rand <
            (leftChance + rightChance + bothChance) * noteChance
          ) {
            note = [true, true]
          }
          return { [timestamp]: note }
        }
        return {}
      })
    )
  }

  p.preload = () => {
    sound = p.loadSound(soundFile)
  }

  p.setup = async () => {
    p.createCanvas(p.windowWidth, p.windowHeight - 10)

    const beats = await getBeats()
    const notes = createNoteMap(beats)
    console.log(notes)
  }
}

export default sketch
