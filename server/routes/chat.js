var jwt = require("jsonwebtoken");
const db = require("../db/db");
const checkJwt = require("./../middleware/checkAuth");
const ObjectId = require("mongoose").Types.ObjectId;
var mongoose = require('mongoose');

function checkSocketToken(token) {
  var isValid;
  jwt.verify(token, "lol", function (err, decoded) {
    if (err) isValid = false;
    else {
      isValid = true;
      console.log('decoded', decoded);
    }
  });
  return isValid
}

function getUserIdFromSocketToken(token) {
  var id;
  jwt.verify(token, "lol", function (err, decoded) {
    if (err) return;
    else {
      id = decoded.user
    }
  })
  return id;
}

function handleSendRequest({from , to}) {
  var update1 = {
    $addToSet: { requestOut: ObjectId(to)  }
  }

  var update2 = {
    $addToSet: { requestIn: ObjectId(from)  }
  }
  
  db.userSchema.findByIdAndUpdate(from, update1).exec((err, doc) => {
    db.userSchema.findByIdAndUpdate(to, update2).exec();
  });
}


module.exports = function (io) {
  var array_of_connection = [];
  
  io.use(function (socket, next) {
   console.log('sss socket', socket.handshake.query);
    if (socket.handshake.query) {
      
         SocketUserId = socket.handshake.query.userId;
        //  console.log('aaa', SocketUserId)
        socket._userId = SocketUserId
        next();
        }
  }).on("connection", function (socket) {
    // console.log('xxxxxxxx')
    // socket.emit('hhh', 'hhh');
    if (!array_of_connection.includes(socket))
    array_of_connection.push(socket);

    socket.on('new-frien-request', async (data) => {
      const decodeData = JSON.parse(data);
    
      var status = checkSocketToken(decodeData.token);
      console.log(status);
      if (status) {
       const id = getUserIdFromSocketToken(decodeData.token)
       handleSendRequest({from: id, to: decodeData['toUserId']})

       console.log(decodeData['message'])
      }
     
     
      
    })
    socket.on('disconnect',  async () => {
      socket.removeAllListeners();
      console.log('index',array_of_connection.indexOf(socket));
      array_of_connection.splice(1, array_of_connection.indexOf(socket));
      console.log('disconnected')})
  })
}