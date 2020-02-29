import P5 from 'p5'
import $ from 'jquery'

import sketch from './analyze'
import dropzone from './dropzone'
import '../../public/css/index.css'

const rootEl = document.createElement('div')
rootEl.classList.add('app')
document.body.append(rootEl)

let p5
function onUpload(response) {
  if (!response.success) return
  if (p5) p5.remove()
  p5 = new P5(sketch(response.location, response.filename), rootEl)
}

let $dz
function createDropzone() {
  $dz = $('<div>')
  $dz.addClass('dropzone')
  $(document.body).append($dz)
  dropzone($dz[0], onUpload)
}
createDropzone()
