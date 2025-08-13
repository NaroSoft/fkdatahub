const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Define the cloud function to check the app version
exports.checkAppVersion = functions.https.onRequest(async (req, res) => {
  try {
    // Fetch the version from Firestore
    const versionDoc = await admin.firestore().collection('appVersions').doc('latest').get();

    // Check if the document exists
    if (!versionDoc.exists) {
      return res.status(404).send('Version info not found.');
    }

    // Extract the version data
    const latestVersion = versionDoc.data().version;

    // Send the version to the client
    return res.status(200).send({ version: latestVersion });
  } catch (error) {
    console.error('Error fetching version:', error);
    return res.status(500).send('Internal Server Error');
  }
});
