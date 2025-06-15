import express from 'express';
import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { v4 as uuidv4 } from 'uuid';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const dataDir = path.join(__dirname, 'data');
const recordingsDir = path.join(__dirname, 'recordings');

async function readJSON(file, def) {
  try {
    const data = await fs.readFile(path.join(dataDir, file), 'utf8');
    return JSON.parse(data);
  } catch (e) {
    return def;
  }
}

async function writeJSON(file, data) {
  await fs.writeFile(path.join(dataDir, file), JSON.stringify(data, null, 2));
}

// User management
app.get('/api/users', async (req, res) => {
  const users = await readJSON('users.json', []);
  res.json(users);
});

app.post('/api/users', async (req, res) => {
  const users = await readJSON('users.json', []);
  const user = { id: uuidv4(), ...req.body };
  users.push(user);
  await writeJSON('users.json', users);
  res.json(user);
});

app.put('/api/users/:id', async (req, res) => {
  const users = await readJSON('users.json', []);
  const idx = users.findIndex(u => u.id === req.params.id);
  if (idx === -1) return res.status(404).end();
  users[idx] = { ...users[idx], ...req.body };
  await writeJSON('users.json', users);
  res.json(users[idx]);
});

app.delete('/api/users/:id', async (req, res) => {
  let users = await readJSON('users.json', []);
  const idx = users.findIndex(u => u.id === req.params.id);
  if (idx === -1) return res.status(404).end();
  const removed = users.splice(idx, 1)[0];
  await writeJSON('users.json', users);
  res.json(removed);
});

// Events
app.get('/api/events', async (req, res) => {
  const events = await readJSON('events.json', []);
  res.json(events);
});

// Download recording
app.get('/recordings/:file', (req, res) => {
  const filePath = path.join(recordingsDir, path.basename(req.params.file));
  res.download(filePath);
});

// Config
app.get('/api/config', async (req, res) => {
  const cfg = await readJSON('config.json', { recordingDuration: 30 });
  res.json(cfg);
});

app.post('/api/config', async (req, res) => {
  const cfg = { recordingDuration: req.body.recordingDuration || 30 };
  await writeJSON('config.json', cfg);
  res.json(cfg);
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Web admin running on port ${port}`);
});