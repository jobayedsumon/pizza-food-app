importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
      apiKey: "AIzaSyCy30ySSmyzIYyxXMrw5FgxItrGdcfGEpE",
      authDomain: "pizza-corner-e2f6f.firebaseapp.com",
      projectId: "pizza-corner-e2f6f",
      storageBucket: "pizza-corner-e2f6f.appspot.com",
      messagingSenderId: "1066475948869",
      appId: "1:1066475948869:web:b4bd5ea6ad0cf59ea10c2c",
      measurementId: "G-DZ5T8BLR87",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
});
