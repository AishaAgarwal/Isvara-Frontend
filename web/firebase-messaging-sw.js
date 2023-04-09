importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyAB7rcLzvPERowbPbVSD-K9kMrISLwaJR0",
  authDomain: "isvara-bd2eb.firebaseapp.com",
  projectId: "isvara-bd2eb",
  storageBucket: "isvara-bd2eb.appspot.com",
  messagingSenderId: "578896536791",
  appId: "1:578896536791:web:7a1ad85941800e9d577c92",
  measurementId: "G-LN40FSMB78"
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/

  
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });