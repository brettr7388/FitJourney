const express = require('express');
const crypto = require('crypto');
const fetch = require('node-fetch');
const { ObjectId } = require('mongodb');
require('dotenv').config();

const router = express.Router();

// Add this function before using it
function generateAuthToken(user) {
  const jwt = require('jsonwebtoken');
  const secretKey = process.env.JWT_SECRET || 'yourSecretKey'; // Use a secure key
  return jwt.sign({ id: user.id, email: user.email }, secretKey, { expiresIn: '1h' });
}

function getDB(req) {
  const client = req.app.locals.dbClient;
  return client.db("sample_mflix");
}

// Middleware to authenticate user
function authenticateToken(req, res, next) {
  const jwt = require('jsonwebtoken');
  const token = req.headers['authorization']?.split(' ')[1];
  const secretKey = process.env.JWT_SECRET || 'yourSecretKey';

  if (!token) return res.status(401).json({ error: 'Access denied. No token provided.' });

  jwt.verify(token, secretKey, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token.' });
    req.user = user;
    next();
  });
}

// Delete account endpoint
router.delete('/delete', authenticateToken, async (req, res) => {
  const db = getDB(req);
  const userEmail = req.user.email; // Extracted from the token

  try {
    const result = await db.collection('users').deleteOne({ email: userEmail });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    res.status(200).json({ message: 'Account deleted successfully.' });
  } catch (error) {
    console.error('Error deleting account:', error);
    res.status(500).json({ error: 'An error occurred while deleting the account.' });
  }
});

// Registration endpoint
router.post('/register', async (req, res) => {
  const { firstName, lastName, email, login, password } = req.body;
  const db = getDB(req);

  try {
    const errors = [];

    // Check if username already exists
    const existingUser = await db.collection('users').findOne({ login });
    if (existingUser) {
      errors.push('Username already exists');
    }

    // Check if email already exists
    const existingEmail = await db.collection('users').findOne({ email });
    if (existingEmail) {
      errors.push('Email already exists');
    }

    // If there are errors, return them
    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }
    
    // Generate verification token & links
const verificationToken = crypto.randomBytes(32).toString('hex');
const browserVerificationLink = `${process.env.BASE_URL}/api/verify-email?token=${verificationToken}`;
const appVerificationLink = `${process.env.BASE_URL}/api/verify-email-app?token=${verificationToken}`;

// Send verification email via Resend
const response = await fetch("https://api.resend.com/emails", {
  method: "POST",
  headers: {
    "Authorization": `Bearer ${process.env.RESEND_API_KEY}`,
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Verify Your Email",
    html: `
      <p>Click <a href="${browserVerificationLink}">here</a> to verify your email and set up your profile.</p>
      <p>If you're using the mobile app, click <a href="${appVerificationLink}">here</a> to verify your email. After verification, please return to the app.</p>
    `
  })
});

const data = await response.json();
if (!response.ok) {
  console.error("Resend API Error:", data);
  return res.status(500).json({ error: "Email sending failed. Please try again." });
}

// Add user to the database **only if email sending succeeds**
await db.collection('users').insertOne({
  firstName,
  lastName,
  email,
  login,
  password, // Note: Hash the password before saving
  isVerified: false,
  verificationToken,
});

    res.status(200).json({ message: 'Registration successful! Please check your email to verify your account.' });
  } catch (error) {
    console.error('Error during registration:', error);
    res.status(500).json({ error: "Registration failed. Please try again." });
  }
});

// GET userId by email
router.get('/get-user-id', async (req, res) => {
  const { email } = req.query;
  const db = getDB(req);

  try {
    const user = await db.collection('users').findOne({ email });
    if (!user) return res.status(404).json({ error: 'User not found' });

    return res.status(200).json({ userId: user._id });
  } catch (error) {
    console.error('Fetch user ID error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST profile info
router.post('/user-info', async (req, res) => {
  const { userId, gender, height, weight, age, goal } = req.body;
  const db = getDB(req);

  try {
    if (!ObjectId.isValid(userId)) {
      return res.status(404).json({ error: 'Invalid user ID' });
    }
        
    const result = await db.collection('userStats').updateOne(
      {userId: new ObjectId(userId)},
      { 
        $set : {
          userId: new ObjectId(userId),
          gender, 
          height, 
          weight, 
          age, 
          goal,
          streaks : 0,
          isProfileComplete: true, 
          updatedAt: new Date(), },
      },
      { upsert: true } // Create the document if it doesn't exist
    );

    if (result.modifiedCount === 0 && result.upsertedCount === 0) return res.status(404).json({ error: 'User not found or unchanged' });

    res.status(200).json({ message: 'Profile added' });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Email verification browser endpoint
router.get('/verify-email', async (req, res) => {
  const token = req.query.token; // Extract token from query parameters
  const db = getDB(req);

  try {
    console.log("Verification token received:", token);

    // Find user by verification token
    const user = await db.collection('users').findOne({ verificationToken: token });

    console.log("Retrieved user:", user);

    if (!user) {
      return res.status(400).json({ error: 'Invalid or expired token' });
    }

    // Update the user's verification status
    const updateResult = await db.collection('users').updateOne(
      {verificationToken: token }, // Use the userId from the token
      { 
        $set: { isVerified: true },
        $unset: { verificationToken: 1 }
      }
    );

    //console.log("Update result:", updateResult);
    res.redirect(`${process.env.FRONTEND_URL}/setup-profile?email=${user.email}`);
  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Email Verification for app users
router.get('/verify-email-app', async (req, res) => {
  const { token } = req.query;
  const db = getDB(req);

  try {
    console.log("Verification token received for app:", token);

    // Find user by verification token
    const user = await db.collection('users').findOne({ verificationToken: token });

    if (!user) {
      return res.status(400).send('Invalid or expired token.');
    }

    // Update the user's verification status
    await db.collection('users').updateOne(
      { verificationToken: token },
      { 
        $set: { isVerified: true },
        $unset: { verificationToken: 1 }
      }
    );

    // Display a message for app users
    res.send(`
      <html>
        <body>
          <h1>You have been verified!</h1>
          <p>Please go back to the app to continue.</p>
        </body>
      </html>
    `);
  } catch (error) {
    console.error('Verification error for app users:', error);
    res.status(500).send('An error occurred while verifying your email.');
  }
});

// Request password reset endpoint
router.post('/request-password-reset', async (req, res) => {
  const { email } = req.body;
  const db = getDB(req);

  try {
    // Check if the user exists
    const user = await db.collection('users').findOne({ email });
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // Generate a reset token and expiration time
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenExpires = new Date(Date.now() + 3600000); // 1 hour from now

    // Save the token and expiration in the database
    await db.collection('users').updateOne(
      { email },
      { $set: { resetToken, resetTokenExpires } }
    );

    // Generate the reset link
    const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

    // Send the reset email
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.RESEND_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Password Reset Request",
        html: `
          <p>Click <a href="${resetLink}">here</a> to reset your password.</p>
          <p>This link will expire in 1 hour.</p>
        `
      })
    });

    const data = await response.json();
    if (!response.ok) {
      console.error("Resend API Error:", data);
      return res.status(500).json({ error: "Failed to send reset email. Please try again." });
    }

    res.status(200).json({ message: 'Password reset email sent successfully.' });
  } catch (error) {
    console.error('Error requesting password reset:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// Reset password endpoint
router.post('/reset-password', async (req, res) => {
  const { token, newPassword } = req.body;
  const db = getDB(req);

  try {
    // Find the user by reset token
    const user = await db.collection('users').findOne({
      resetToken: token,
      resetTokenExpires: { $gt: new Date() }, // Ensure the token is not expired
    });

    if (!user) {
      return res.status(400).json({ error: 'Invalid or expired token.' });
    }

    // Save the new password directly without hashing
    await db.collection('users').updateOne(
      { resetToken: token },
      {
        $set: { password: newPassword }, // Save the plain text password
        $unset: { resetToken: 1, resetTokenExpires: 1 }, // Remove the reset token
      }
    );

    res.status(200).json({ message: 'Password reset successfully.' });
  } catch (error) {
    console.error('Error resetting password:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// Login endpoint
router.post('/login', async (req, res) => {
  const { login, password } = req.body;
  const db = getDB(req);

  try {
    const errors = [];

    // Check if login exists
    const user = await db.collection('users').findOne({ login });
    if (!user) {
      errors.push('Invalid username');
    }

    // Check if password matches
    if (!user || (user && user.password !== password)) {
      errors.push('Invalid password');
    }

    // If not verified, block login
    if (user && !user.isVerified) {
      errors.push('Email not verified. Please check your email.');
    }

    // If there are errors, return them
    if (errors.length > 0) {
      return res.status(400).json({ errors });
    }

    // Proceed with login logic (e.g., generating a token)
    const token = generateAuthToken(user);

    // Log the user's login information to the terminal
    console.log(`User logged in: ${user.login}`);

    // Return the token and user data
    return res.status(200).json({
      token,
      user: {
        id: user._id,
        login: user.login,
        email: user.email,
      },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

//increment streak endpoint
router.post('/increment-streak', async (req, res) => {
  const { userId } = req.body;
  const db = getDB(req);

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required.' });
  }

  try {
    const result = await db.collection('userStats').updateOne(
      { userId: new ObjectId(userId) },
      { $inc: { streaks: 1 } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    res.status(200).json({ message: 'Streak incremented successfully.' });
  } catch (error) {
    console.error('Error incrementing streak:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

//Set streak to 0
router.post('/reset-streak', async (req, res) => {
  const { userId } = req.body;
  const db = getDB(req);

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required.' });
  }

  try {
    const result = await db.collection('userStats').updateOne(
      { userId: new ObjectId(userId) },
      { $set: { streaks: 0 } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    res.status(200).json({ message: 'Streak reset successfully.' });
  } catch (error) {
    console.error('Error resetting streak:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get current streak for a user
router.get('/streak', async (req, res) => {
  const db = getDB(req);
  const { userId } = req.query;

  if (!userId || !ObjectId.isValid(userId)) {
    return res.status(400).json({ error: 'Invalid or missing user ID.' });
  }

  try {
    const userStats = await db.collection('userStats').findOne(
      { userId: new ObjectId(userId) },
      { projection: { streaks: 1 } }
    );

    if (!userStats) {
      return res.status(404).json({ error: 'User stats not found.' });
    }

    res.status(200).json({ streaks: userStats.streaks });
  } catch (error) {
    console.error('Error fetching streak:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});


router.get('/get-profile', async (req, res) => {
  const { userId } = req.query; // Expecting userId as a query parameter
  const db = getDB(req);

  if (!userId || !ObjectId.isValid(userId)) {
    return res.status(400).json({ error: 'Invalid or missing user ID.' });
  }

  try {
    // Fetch the login from the users collection
    const user = await db.collection('users').findOne(
      { _id: new ObjectId(userId) },
      { projection: { login: 1 } } // Only fetch the login field
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found in users collection.' });
    }

    // Fetch the weight, height, age, and goal from the userStats collection
    const userStats = await db.collection('userStats').findOne(
      { userId: new ObjectId(userId) },
      { projection: { weight: 1, height: 1, age: 1, goal: 1 } } // Only fetch the required fields
    );

    if (!userStats) {
      return res.status(404).json({ error: 'User stats not found in userStats collection.' });
    }

    // Combine the data and send the response
    const profile = {
      login: user.login,
      weight: userStats.weight,
      height: userStats.height,
      age: userStats.age,
      goal: userStats.goal,
    };

    res.status(200).json(profile);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// Leaderboard endpoint
router.get('/leaderboard', async (req, res) => {
  const db = getDB(req);

  try {
    // Fetch the top 5 users with the highest streaks
    const leaderboard = await db.collection('userStats')
      .aggregate([
        {
          $lookup: {
            from: 'users', // Join with the 'users' collection
            localField: 'userId',
            foreignField: '_id',
            as: 'userDetails',
          },
        },
        {
          $unwind: '$userDetails', // Flatten the joined user details
        },
        {
          $sort: { streaks: -1 }, // Sort by streaks in descending order
        },
        {
          $limit: 5, // Limit to the top 5 users
        },
        {
          $project: {
            _id: 0, // Exclude the MongoDB ID
            login: '$userDetails.login', // Include the login from the 'users' collection
            streaks: 1, // Include the streaks
          },
        },
      ])
      .toArray();

    res.status(200).json(leaderboard);
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// Edit user stats endpoint
router.patch('/update-user-stats', async (req, res) => {
  const { userId, weight, height, age, goal } = req.body; // Extract fields from the request body
  const db = getDB(req);

  if (!userId || !ObjectId.isValid(userId)) {
    return res.status(400).json({ error: 'Invalid or missing user ID.' });
  }

  // Build the update object dynamically
  const updateFields = {};
  if (weight !== undefined) updateFields.weight = weight;
  if (height !== undefined) updateFields.height = height;
  if (age !== undefined) updateFields.age = age;
  if (goal !== undefined) updateFields.goal = goal;

  if (Object.keys(updateFields).length === 0) {
    return res.status(400).json({ error: 'No fields to update.' });
  }

  try {
    // Update the userStats document
    const result = await db.collection('userStats').updateOne(
      { userId: new ObjectId(userId) },
      { $set: updateFields }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'User stats not found.' });
    }

    res.status(200).json({ message: 'User stats updated successfully.' });
  } catch (error) {
    console.error('Error updating user stats:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
