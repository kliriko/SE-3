const express = require('express');
const { connect } = require('mongoose');
const mongoose = require('mongoose');
const cors = require('cors');
const { MongoMemoryServer } = require('mongodb-memory-server');
const path = require('path');

require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const PORT = process.env.PORT || 4000;
let memoryMongoServer;

const disciplineSchema = new mongoose.Schema({
  title: { type: String, required: true },
  code: { type: String, required: true, unique: true },
  isSelfEnrollmentOpen: { type: Boolean, required: true }
});

const enrollmentSchema = new mongoose.Schema(
  {
    discipline: { type: mongoose.Schema.Types.ObjectId, ref: 'Discipline', required: true },
    mode: { type: String, enum: ['vulnerable', 'secure'], required: true }
  },
  {
    timestamps: true
  }
);

enrollmentSchema.index({ discipline: 1, mode: 1 }, { unique: true });

const Discipline = mongoose.model('Discipline', disciplineSchema, 'Disciplines');
const Enrollment = mongoose.model('Enrollment', enrollmentSchema, 'Enrollments');

async function seedDisciplines() {
  const existingCount = await Discipline.countDocuments();
  if (existingCount > 0) {
    return;
  }

  await Discipline.insertMany([
    {
      title: 'Web Development Basics',
      code: 'WEB-101',
      isSelfEnrollmentOpen: true
    },
    {
      title: 'Restricted Security Seminar',
      code: 'SEC-404',
      isSelfEnrollmentOpen: false
    }
  ]);

  console.log('Seeded demo disciplines');
}

async function connectToDatabase() {
  memoryMongoServer = await MongoMemoryServer.create();
  const memoryUri = memoryMongoServer.getUri();
  await connect(memoryUri);
  console.log('Successfully connected to local in-memory MongoDB');
}

function formatEnrollment(enrollment) {
  return {
    id: enrollment._id,
    discipline: enrollment.discipline,
    mode: enrollment.mode,
    createdAt: enrollment.createdAt
  };
}

async function createEnrollment(req, res, mode, options = {}) {
  try {
    const discipline = await Discipline.findById(req.params.disciplineId);
    if (!discipline) {
      return res.status(404).json({ error: 'Discipline not found' });
    }

    if (options.enforceBusinessRule && !discipline.isSelfEnrollmentOpen) {
      return res.status(403).json({
        error: 'This discipline is closed for enrollment. The protected version blocks direct URL access.'
      });
    }

    const enrollment = await Enrollment.findOneAndUpdate(
      { discipline: discipline._id, mode },
      { discipline: discipline._id, mode },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    ).populate('discipline', 'title code');

    const message = discipline.isSelfEnrollmentOpen
      ? `Enrolled in ${mode} mode`
      : 'Vulnerable direct URL allowed enrollment into a closed discipline';

    return res.status(201).json({
      message,
      enrollment: formatEnrollment(enrollment)
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ error: 'Already enrolled in this discipline for this mode' });
    }

    return res.status(500).json({ error: error.message });
  }
}

async function getMyEnrollments(req, res, mode) {
  try {
    const enrollments = await Enrollment.find({ mode })
      .populate('discipline', 'title code')
      .sort({ createdAt: -1 });

    res.json(enrollments.map((enrollment) => formatEnrollment(enrollment)));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

app.get('/api/disciplines', async (req, res) => {
  try {
    const disciplines = await Discipline.find().sort({ code: 1 });
    res.json(disciplines);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/vulnerable/enroll/:disciplineId', async (req, res) => {
  await createEnrollment(req, res, 'vulnerable', { enforceBusinessRule: false });
});

app.get('/api/vulnerable/enrollments', async (req, res) => {
  await getMyEnrollments(req, res, 'vulnerable');
});

app.post('/api/secure/enroll/:disciplineId', async (req, res) => {
  await createEnrollment(req, res, 'secure', { enforceBusinessRule: true });
});

app.get('/api/secure/enrollments', async (req, res) => {
  await getMyEnrollments(req, res, 'secure');
});

app.delete('/api/enrollments/:mode/:enrollmentId', async (req, res) => {
  try {
    const deletedEnrollment = await Enrollment.findOneAndDelete({
      _id: req.params.enrollmentId,
      mode: req.params.mode
    });

    if (!deletedEnrollment) {
      return res.status(404).json({ error: 'Enrollment not found' });
    }

    return res.json({ message: 'Enrollment removed from demo list' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

async function startServer() {
  try {
    await connectToDatabase();
    await seedDisciplines();

    app.listen(PORT, () => {
      console.log(`REST Server ready at http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('Unable to start the demo application:', error);
    process.exit(1);
  }
}

process.on('SIGINT', async () => {
  await mongoose.disconnect();
  if (memoryMongoServer) {
    await memoryMongoServer.stop();
  }
  process.exit(0);
});

startServer();