/* eslint-disable no-console */
import express from 'express'
import fileUpload from 'express-fileupload'
import nanoid from 'nanoid'

const app = express()
const port = 3000

app.use(express.static('public'))
app.use(express.static('dist'))
app.use(fileUpload())

app.post('/upload', (req, res) => {
  if (!req.files || Object.keys(req.files).length === 0) {
    return res.status(400).send('No files were uploaded.')
  }

  // The name of the input field (i.e. "sampleFile") is used to retrieve the uploaded file
  const { file } = req.files

  // Use the mv() method to place the file somewhere on your server
  console.log(file)
  const [, ext] = file.name.split('.')
  return file.mv(`./uploads/${nanoid()}.${ext}`, err => {
    if (err) return res.status(500).send({ success: false })
    return res.send({ success: true })
  })
})

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
