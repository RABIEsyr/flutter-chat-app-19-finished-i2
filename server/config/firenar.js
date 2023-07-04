var admin = require("firebase-admin");

var serviceAccount = require("./skidrowfriend-firebase-adminsdk-bmrmo-928376814e");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // databaseURL: "url_for_ur_project_in_setup_on_firebase"
});

// var token = 'cIj7L9K3SoOLZ0lVwGEAwj:APA91bHQECOxyAbLDor7TKPleQFN9MqYI8WfRJLflROrfLOsHaHqY407sQOmdk5ql2coGE3wdTLzD8ykXBWQTCGLCfd90uua5o7VdOVwu7k8N6ceR_hO9oBYpvSM-UO5YpruuQ3XjcQA'

const options = {
    priority: "normal",
    timeToLive: 60 * 60 * 24
};
// const payload = {
//  notification: {
//     title: "New Notification",
//     body: "Either you run the day or the day runs you.",
//     },
// };

module.exports = async ({token, senderId, message, senderPublikKey, senderName}) => {
 const det = {
    username: senderName,
    title: senderName,
    senderId: senderId,
    bodyLocKey: senderPublikKey,
   };
  const customData = JSON.stringify(det)
  const payload = {
    data: {
      title: senderName,
        body: message,
       bodyLocKey: senderPublikKey,
       username: senderName,
       message: message,
       senderId: senderId,
       det: customData
       },
      //  notification: {
      //   title: senderName,
      //   // body: message,
      //   bodyLocKey: senderPublikKey,
      //   username: senderName,
      //   message: message,
      //   senderId: senderId
      //   },
   };

  //  const payload = {
  //   data: {
  //      title: senderId,
  //      body: message,
  //      bodyLocKey: senderPublikKey,
  //      username: senderName
  //      },
  //      notification: {
  //       title: senderId,
  //       body: message,
  //       bodyLocKey: senderPublikKey,
  //       username: senderName
  //       },
  //  };

     try{
      let result = await admin.messaging().sendToDevice(token, payload, options);
      console.log('resultfirebase',result);
      return true;
     }catch(err){
      console.log('resultfirebaseerror',err);
      return false;
     }
 };