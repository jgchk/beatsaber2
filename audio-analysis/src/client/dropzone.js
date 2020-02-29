import Dropzone from 'dropzone'
import 'dropzone/dist/dropzone.css'

Dropzone.autoDiscover = false

export default function createDropzone(el, onSuccess) {
  const dz = new Dropzone(el, { url: '/upload' })
  dz.on('success', (_status, response) => onSuccess(response))
  return dz
}
