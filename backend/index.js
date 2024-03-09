const express = require('express')
const { postgress_client: postgres_client } = require('pg')
require('dotenv').config()

const app = express()
const port = 3000

const client = new postgres_client()
await client.connect()

app.get('/', (req, res) => {
  res.send('Hello World')
})

app.get('/api', (req, res) => {
  res.send({ message: 'Hello World' })
})

app.listen(port, () => {
  console.log(`Server running on port ${port}`)
})
