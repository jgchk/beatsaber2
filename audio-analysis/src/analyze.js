/* eslint-disable no-console */
/* eslint-disable no-param-reassign */
import 'p5/lib/addons/p5.sound'

const sketch = soundFile => p => {
  let sound
  let dl

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
    const noiseScale = 0.2
    p.noiseDetail(8, 0.5)
    return Object.assign(
      {},
      ...beats.map((timestamp, i) => {
        let note
        const rand = p.noise(i * noiseScale)
        console.log(rand)
        if (rand < noteChance) {
          const sideRand = p.map(rand, 0, noteChance, 0, 1)
          const heightRand = p.noise(i * noiseScale + 10000)
          if (sideRand < leftChance) {
            note = [heightRand, false]
          } else if (sideRand < leftChance + rightChance) {
            note = [false, heightRand]
          } else if (sideRand < leftChance + rightChance + bothChance) {
            note = [heightRand, heightRand]
          }
          return { [timestamp]: note }
        }
        return {}
      })
    )
  }

  function createDownloadUrl(data) {
    const blob = new Blob([JSON.stringify(data)], { type: 'application/json' })
    if (dl !== null) window.URL.revokeObjectURL(dl)
    dl = window.URL.createObjectURL(blob)
    return dl
  }

  function createDownloadLink(data) {
    const link = document.createElement('a')
    link.textContent = 'Download'
    link.setAttribute('download', 'notes.json')
    link.href = createDownloadUrl(data)
    document.body.appendChild(link)
    return link
  }

  p.preload = () => {
    sound = p.loadSound(soundFile)
  }

  p.setup = async () => {
    const beats = await getBeats()
    const notes = createNoteMap(beats)
    console.log(notes)
    createDownloadLink(notes)
  }
}

export default sketch
