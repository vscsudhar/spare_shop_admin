importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyB6hE8KVwlsg2oQzmcfrixapoa9uo_4ArM",
  authDomain: "voltspare.firebaseapp.com",
  projectId: "voltspare",
  storageBucket: "voltspare.firebasestorage.app",
  messagingSenderId: "1054138072159",
  appId: "1:1054138072159:web:22343bf821041417986fea"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);
  const notificationTitle = payload.notification?.title || 'VoltSpare Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/favicon.png',
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
