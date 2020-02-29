import analyze from './analyze'

analyze()

if (module.hot) {
  module.hot.accept('./analyze.js', function() {
    console.log('Accepting the updated analyze module!')
    analyze()
  })
}
