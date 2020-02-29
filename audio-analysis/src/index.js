import P5 from 'p5'
import $ from 'jquery'

import sketch from './analyze'
import dropzone from './dropzone'
import '../public/css/index.css'
// import soundFile from '../public/pacific-707.opus'
import soundFile from '../public/hydrate.opus'

const rootEl = document.createElement('div')
rootEl.classList.add('app')
document.body.append(rootEl)

let p5 = new P5(sketch(soundFile), rootEl)

let $dz
function createDropzone() {
  $dz = $('<div>')
  $dz.addClass('dropzone')
  $(document.body).append($dz)
  dropzone($dz[0])
}
createDropzone()

if (module.hot) {
  module.hot.accept('./analyze.js', () => {
    console.log('hot analyze')
    p5.remove()
    p5 = new P5(sketch(soundFile), rootEl)
  })

  module.hot.accept('./dropzone.js', () => {
    console.log('hot dropzone')
    $dz.remove()
    createDropzone()
  })
}
