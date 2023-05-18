const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotificationOnNewDocument = functions.firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (snapshot, context) => {
    const notificationData = snapshot.data();

    // Assuming that you have a field 'deviceToken' in your user document
    const userSnapshot = await admin.firestore().doc(`users/${context.params.userId}`).get();
    const user = userSnapshot.data();

    const message = {
      notification: {
        title: 'New Notification from ' + notificationData.adminName,
        body: notificationData.taskTitle,
      },
      data: {
        taskId: notificationData.taskId,
        // Add more fields as you need
      },
      token: user.deviceToken, // now it's defined
      webpush: {
        fcmOptions: {
          link: 'https://achievio-3f4fa.web.app' // Replace with your app URL
        }
      }
    };

    return admin.messaging().send(message);
  });
