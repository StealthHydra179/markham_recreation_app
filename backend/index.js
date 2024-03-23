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
  logger.debug('POST /api/weekly_checklist/:camp_id') // TODO, add camp ID and request body to the log
  const campid = req.params.camp_id
  console.log(req.body)

  const { rows } = await client.query('SELECT * FROM checklist WHERE camp_id = ' + campid)
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
  logger.warn('soon to be deprecated new_absence: use get_absence instead')
})

app.get('/api/get_absences/:camp_id', (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  const camp_id = req.params.camp_id

  const query = 'SELECT * FROM absent WHERE camp_id = $1 ORDER BY date DESC'
  const values = [camp_id]
  client.query(query, values, (err, result) => {
    if (err) {
      logger.error(err)
      return
    }
    res.json(result.rows)
  })
})

app.post('/api/new_absence/:camp_id', (req, res) => {
  if (!connected) {
    res.status(500).send({ message: 'Database not connected' })
    logger.warn('Database not connected')
    return
  }
  const camp_id = req.params.camp_id
  logger.debug('POST /api/new_absence/:camp_id ' + camp_id + ' ' + req.body.name + ' ' + req.body.date + ' ' + req.body.followedUp + ' ' + req.body.notes)
  logger.warn('TODO do input data validation') // TODO

  // if followed up is false, change notes to empty string
  if (req.body.followedUp === 'false') {
    req.body.notes = ''
  }

  // Add to database
  const addQuery = 'INSERT INTO absent (camp_id, camper_name, date, followed_up, reason, date_modified,upd_by) VALUES ($1, $2, $3, $4, $5, $6, $7)'
  const addQueryValues = [camp_id, req.body.name, req.body.date, req.body.followedUp, req.body.notes, (new Date()).toISOString(), 0]
  console.log(addQueryValues)
  client.query(addQuery, addQueryValues, (err, res) => {
    if (err) {
      logger.error(err) // TODO send an error to the client // TODO figure out why logger.error gave undefined?
      console.log(err)
      return
    }
    logger.info('Added to database')
  })
  res.json(req.body)
})

//TODO sanitize before putting into logger
app.post('/api/edit_absence/:camp_id', (req, res) => {
    if (!connected) {
        res.status(500).send({ message: 'Database not connected' })
        logger.warn('Database not connected')
        return
    }
    const camp_id = req.params.camp_id
    logger.debug('POST /api/edit_absence/:camp_id ' + camp_id + ' ' + req.body.camper_name + ' ' + req.body.date + ' ' + req.body.followed_up + ' ' + req.body.reason)
    logger.warn('TODO do input data validation') // TODO

    // if followed up is false, change notes to empty string
    if (req.body.followed_up === 'false') {
        req.body.reason = ''
    }

  /*
  body: jsonEncode(<String, String>{
                  'absent_id': widget.absence.absent_id.toString(),
                  'camp_id': widget.absence.camp_id.toString(),
                  'camper_name': _name_controller.text,
                  'date': selectedDate.toString(),
                  'followed_up': followedUp.toString(),
                  'reason': _notes_controller.text,
                  'date_modified': DateTime.now().toString(),
                }),
   */

    // update specific query
    const updateQuery = 'UPDATE absent SET camper_name = $1, date = $2, followed_up = $3, reason = $4, date_modified = $5, upd_by = $6 WHERE absent_id = $7'
    const updateQueryValues = [req.body.camper_name, req.body.date, req.body.followed_up, req.body.reason, (new Date()).toISOString(), 0, req.body.absent_id]
    console.log(updateQueryValues)
    client
          .query(updateQuery, updateQueryValues)
            .then(res => {
                console.log('Updated')
            })
            .catch(e => {
                console.error(e.stack)
            })
    res.json(req.body)
})

app.listen(port, () => {
  logger.info(`Server running on port ${port}`)
})
