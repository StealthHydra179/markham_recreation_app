const express = require('express')
const { Client: postgres_client } = require('pg')
require('dotenv').config()

const app = express()
const port = 3000
app.use(express.json())

const client = new postgres_client({application_name: "Markham Recreation Summer Camp Server"});
let connected = false;

async function connect() {
  await client.connect();
  connected = true;
}

connect().then(r => console.log('Connected to database')).catch(e => console.error(e));

app.get('/', (req, res) => {
  res.send('Hello World')
})

app.get('/api', (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' });
    return;
  }
  res.send({ message: 'Hello World' })
})

app.post('/api/weekly_checklist/:camp_id', (req, res) => {

  let userId = req.params.camp_id
  console.log(req.body)
  res.json(req.body)
})

app.get('/api/weekly_checklist', async (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' });
    console.log('Database not connected');
    return;
  }
  const { rows } = await client.query('SELECT * FROM checklist');
  res.json(rows);
  console.log(rows);
})

app.post('/api/new_absence/:camp_id', (req, res) => {

  let camp_id = req.params.camp_id
  console.log(camp_id)
  // if folled up is false, change notes to empty string
  if (req.body.followedUp === 'false') {
    req.body.notes = ''
  }

  console.log(req.body)
  res.json(req.body)
})

app.post('/api/new_absence', (req, res) => {

  // let camp_id = req.params.camp_id
  // console.log(camp_id)
  console.log(req.body)
  res.json(req.body)
})

app.listen(port, () => {
  console.log(`Server running on port ${port}`)
})
