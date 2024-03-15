const express = require('express')
const { Client: postgres_client } = require('pg')
const winston = require('winston')
const DailyRotateFile = require('winston-daily-rotate-file')
// Load environment variables
require('dotenv').config()

// Express Server
const app = express()
const port = 3000
app.use(express.json())

// Database Connection
const client = new postgres_client({ application_name: 'Markham Recreation Summer Camp Server' })
let connected = false

// Logger setup
// Winston Log with logging to console and file, rotating logs
// TODO setup a format function to log the date and time and the application name
const logger = winston.createLogger({
  level: 'debug',
  format: winston.format.json(),
  defaultMeta: { service: 'Markham Recreation Summer Camp Server' }
})
logger.configure({
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
    ),
    transports: [
        new DailyRotateFile({
          filename: 'logs/markham_rec_server-%DATE%-error.log',
          datePattern: 'YYYY-MM-DD',
          zippedArchive: false,
          maxSize: '20m',
          level: 'error'
        }),
      new DailyRotateFile({
        filename: 'logs/markham_rec_server-%DATE%-info.log',
        datePattern: 'YYYY-MM-DD',
        zippedArchive: false,
        maxSize: '20m',
        level: 'info'
      })
    ]
})
if (process.env.NODE_ENV !== 'production' || process.env.NODE_ENV == null) {
  console.log('Logging to console')
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
    level: 'debug'
  }))
}
logger.info('Server started')


async function connect () {
  await client.connect()
  connected = true
}

connect().then(r => {
  logger.info('Connected to database')
}).catch(e => {
  logger.error('Error connecting to database')
  logger.error(e)
})

app.get('/', (req, res) => {
  res.send('Hello World')
})

app.get('/api', (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  res.send({ message: 'Hello World' })
})

app.get('/api/weekly_checklist', async (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  const { rows } = await client.query('SELECT * FROM checklist')
  res.json(rows)
  console.log(rows)
})
app.post('/api/weekly_checklist/:camp_id', async (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  const userId = req.params.camp_id
  console.log(req.body)

  const { rows } = await client.query('SELECT * FROM checklist WHERE camp_id = 1')
  res.json(req.body)
})

app.post('/api/new_absence', (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  // let camp_id = req.params.camp_id
  // console.log(camp_id)
  console.log(req.body)
  res.json(req.body)
})

app.post('/api/new_absence/:camp_id', (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  const camp_id = req.params.camp_id
  console.log(camp_id)
  // if folled up is false, change notes to empty string
  if (req.body.followedUp === 'false') {
    req.body.notes = ''
  }

  console.log(req.body)
  res.json(req.body)
})



app.listen(port, () => {
  logger.info(`Server running on port ${port}`)
})
