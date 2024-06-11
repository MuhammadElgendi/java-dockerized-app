import { createRequire } from "module";
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

import express from "express";
import { MongoClient } from 'mongodb';
import bodyParser from 'body-parser';
import os from 'os';
import { publicIp, publicIpv4, publicIpv6 } from 'public-ip';

const mongoUrl = 'mongodb://mongo:27017/';
const client = new MongoClient(mongoUrl, {
  serverSelectionTimeoutMS: 5000, // Increase the timeout to 5 seconds (adjust as needed)
});

const db = client.db('mydatabase');
const collection = db.collection('mycollection');

async function connectToMongoDB() {
  try {
    await client.connect();
    console.log('Connected to MongoDB server');
  } catch (error) { 
    console.error('Error connecting to MongoDB Server:', error);
    process.exit(1); // Exit the process if connection fails
  }
}

connectToMongoDB();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(bodyParser.json());
app.use(express.static('/'));

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

app.post('/insertData', async (req, res) => {
  const data = req.body;

  try {
    const existingData = await collection.findOne({ email: data.email });

    if (existingData) {
      return res.status(400).send('Email already exists, user adding failed!');
    }

    await collection.insertOne(data);
    res.status(200).send('Data added successfully');
  } catch (error) {
    console.error('Error inserting data:', error);
    res.status(500).send('Error adding data');
  }
});

app.get('/fetchData', async (req, res) => {
  try {
    const data = await collection.find({}).limit(12).sort({ _id: -1 }).toArray();
    res.json(data);
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).send('Error fetching data');
  }
});

app.get('/hostinfo', async (req, res) => {
  const hostname = os.hostname();
  const networkInterfaces = os.networkInterfaces();
  let privateIp = '';

  for (const iface in networkInterfaces) {
    for (let i = 0; i < networkInterfaces[iface].length; i++) {
      if (networkInterfaces[iface][i].family === 'IPv4' && !networkInterfaces[iface][i].internal) {
        privateIp = networkInterfaces[iface][i].address;
        break;
      }
    }
    if (privateIp) break;
  }

  let publicIpAddress = '';
  try {
    publicIpAddress = await publicIpv4();
  } catch (error) {
    console.error('Error getting public IP address:', error);
  }

  const hostinfo = {
    hostname,
    privateIp,
    publicIpAddress
  };
  res.json(hostinfo);
});

app.listen(PORT, () => {
  console.log('Server is running on', PORT);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
  // You can also choose to exit the process here if needed
  // process.exit(1);
});