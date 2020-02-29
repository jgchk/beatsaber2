import P5 from 'p5'

import sketch from './analyze'
import '../public/css/index.css'
// import soundFile from '../public/pacific-707.opus'
import soundFile from '../public/hydrate.opus'

const rootEl = document.createElement('div')
rootEl.classList.add('app')
document.body.append(rootEl)

let p5 = new P5(sketch(soundFile), rootEl)

if (module.hot) {
  // eslint-disable-next-line func-names
  module.hot.accept('./analyze.js', function() {
    // eslint-disable-next-line no-console
    console.log('Accepting the updated analyze module!')
    p5.remove()
    p5 = new P5(sketch(soundFile), rootEl)
  })
}
