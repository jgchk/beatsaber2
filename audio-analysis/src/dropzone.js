import Dropzone from 'dropzone'
import 'dropzone/dist/dropzone.css'

export default function createDropzone(el) {
  return new Dropzone(el, { url: '/file/post' })
}
