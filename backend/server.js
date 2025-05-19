require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
const apiRouter = require('./routes/user.js');


const app = express();
const port = process.env.PORT || 5001;

// Configure CORS (only one call is needed)
app.use(cors({
  origin: [
    "http://fitjourneyhome.com",
    "http://localhost:5001",
    "http://localhost:5173",
    "http://localhost:5175",
    "http://localhost:5177"
  ],
  methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  allowedHeaders: "Content-Type, Authorization",
  credentials: true
}));

// Parse JSON bodies
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`Received request: ${req.method} ${req.url}`);
  next();
});

// MongoDB connection
const url = process.env.MONGO_URI;
if (!url) {
  throw new Error('MONGO_URI is not defined in the environment variables');
}
const client = new MongoClient(url);

client.connect()
  .then(() => {
    console.log('MongoDB Connected');
    // Make the client accessible in your routes
    app.locals.dbClient = client;

    // Use the API routes with the '/api' prefix
    app.use('/api', apiRouter);

    // Error handling middleware
    app.use((err, req, res, next) => {
      console.error(err.stack);
      res.status(500).json({ error: 'Something went wrong!' });
    });

    // Start the server
    app.listen(port, '0.0.0.0', () => {
      console.log(`Server running on http://localhost:${port}`);
    });
  })
  .catch(err => {
    console.error("Failed to connect to MongoDB:", err);
    process.exit(1);
  });

  /* User API endpoints
  const userRouter = require('./routes/user.js');
  app.use('/user', userRouter);*/