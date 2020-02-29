/* eslint-disable no-bitwise */
/* eslint-disable no-console */
/* eslint-disable no-param-reassign */
import $ from 'jquery'
import 'p5/lib/addons/p5.sound'

const sketch = soundFile => p => {
  let sound
  let dl
  let notes

  function getBeats() {
    return new Promise(resolve => {
      const callback = beats => {
        resolve(beats.sort((a, b) => a - b))
      }
      const minPeaks = parseInt(sound.duration() / 4, 10)
      console.log('minPeaks', minPeaks)
      sound.processPeaks(callback, 0.9, 0.22, minPeaks)
    })
  }

  function createNoteMap(beats) {
    const noteChance = 1
    const leftChance = 0.45
    const rightChance = 0.45
    const bothChance = 0.1
    const noiseScale = 0.4
    p.noiseDetail(8, 0.5)
    return beats
      .map((timestamp, i) => {
        let note
        const rand = p.noise(i * noiseScale)
        if (rand < noteChance) {
          const sideRand = p.random()
          const heightRand = p.noise(i * noiseScale + 10000)
          if (sideRand < leftChance) {
            note = [heightRand, null]
          } else if (sideRand < leftChance + rightChance) {
            note = [null, heightRand]
          } else if (sideRand < leftChance + rightChance + bothChance) {
            note = [heightRand, heightRand]
          }
          return [timestamp, ...note]
        }
        return null
      })
      .filter(x => !!x)
  }

  function createDownloadUrl(data) {
    const blob = new Blob([JSON.stringify(data)], { type: 'application/json' })
    if (dl) window.URL.revokeObjectURL(dl)
    dl = window.URL.createObjectURL(blob)
    return dl
  }

  function createDownloadLink(data) {
    let dlLink = document.querySelector('.dl')
    if (dlLink) dlLink.parentNode.removeChild(dlLink)
    dlLink = document.createElement('a')
    dlLink.textContent = 'Download'
    dlLink.setAttribute('download', 'notes.json')
    dlLink.classList.add('dl')
    dlLink.href = createDownloadUrl(data)
    $(document.body).prepend(dlLink)
    return dlLink
  }

  function createSeed(str) {
    let hash = 0
    let i
    let chr
    if (str.length === 0) return hash
    for (i = 0; i < str.length; i += 1) {
      chr = str.charCodeAt(i)
      hash = (hash << 5) - hash + chr
      hash |= 0 // Convert to 32bit integer
    }
    return hash
  }

  p.preload = () => {
    const seed = createSeed(soundFile)
    p.noiseSeed(seed)
    p.randomSeed(seed)
    sound = p.loadSound(soundFile)
  }

  p.setup = async () => {
    const beats = await getBeats()
    console.log('beats', beats)
    notes = createNoteMap(beats)
    console.log('notes', notes)
    createDownloadLink(notes)
    p.createCanvas(p.windowWidth, 100)
  }

  p.draw = () => {
    if (!notes) return
    if (!sound.isPlaying()) sound.play()
    p.background(255)
    notes.forEach(([timestamp, ...note]) => {
      const x = p.map(timestamp, 0, sound.duration(), 0, p.width)
      const y = p.map(
        note.find(n => !!n),
        0,
        1,
        0,
        p.height
      )
      const color =
        // eslint-disable-next-line no-nested-ternary
        note[0] && note[1]
          ? p.color(255, 0, 255)
          : note[0]
          ? p.color(0, 0, 255)
          : p.color(255, 0, 0)
      p.fill(color)
      p.square(x, y, 10)
    })

    const pos = p.map(sound.currentTime(), 0, sound.duration(), 0, p.width)
    p.line(pos, 0, pos, p.height)
  }
}

export default sketch
