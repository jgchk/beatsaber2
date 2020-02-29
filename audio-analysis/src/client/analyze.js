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
      const minPeaks = parseInt(sound.duration() / 0.75, 10)
      console.log('minPeaks', minPeaks)
      sound.processPeaks(callback, 0.9, 0.22, minPeaks)
    })
  }

  const noiseOffset = 10000

  function randomPos(i) {
    const noiseScale = 0.4
    const x = p.noise(i * noiseScale)
    const y = p.noise(i * noiseScale + noiseOffset)
    return { x, y }
  }

  function createNote(timestamp, i) {
    const leftChance = 0.45
    const rightChance = 0.45
    const bothChance = 0.1

    const note = { timestamp, left: null, right: null }

    const sideRand = p.random()
    if (sideRand < leftChance) {
      note.left = randomPos(i)
    } else if (sideRand < leftChance + rightChance) {
      note.right = randomPos(i)
    } else if (sideRand < leftChance + rightChance + bothChance) {
      note.left = randomPos(i)
      note.right = randomPos(i + 10 * noiseOffset)
    }

    return note
  }

  function createNoteMap(beats) {
    const beginningPadding = 5
    const noteChance = 1
    const noiseScale = 0.4
    return beats
      .filter(timestamp => timestamp > beginningPadding)
      .map((timestamp, i) => {
        const rand = p.noise(i * noiseScale)
        if (rand < noteChance) return createNote(timestamp, i)
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
    p.noiseDetail(8, 0.5)
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

  function drawNote(timestamp, pos, side) {
    if (!pos) return
    const color = side === 'left' ? p.color(0, 0, 255) : p.color(255, 0, 0)
    const x = p.map(timestamp, 0, sound.duration(), 0, p.width)
    const y = p.map(pos.y, 0, 1, 0, p.height)
    const size = p.map(pos.x, 0, 1, 5, 15)
    p.fill(color)
    p.square(x, y, size)
  }

  p.draw = () => {
    if (!notes) return
    if (!sound.isPlaying()) sound.play()
    p.background(255)
    notes.forEach(({ timestamp, left, right }) => {
      drawNote(timestamp, left, 'left')
      drawNote(timestamp, right, 'right')
    })

    const pos = p.map(sound.currentTime(), 0, sound.duration(), 0, p.width)
    p.line(pos, 0, pos, p.height)
  }
}

export default sketch
