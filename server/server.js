const app = require("express")();
const http = require("http").Server(app);
const morgan = require("morgan");
const bodyparser = require("body-parser");
const mongoose = require("mongoose");
const cors = require("cors");
let io = require("socket.io")(3010, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});
// const io = require("socket.io")(http);

const config = require("./config/config");




mongoose.Promise = global.Promise;
const ConnectionUri = config.db;
mongoose.connect(ConnectionUri, (err) => {
  if (err) {
    console.log("Error in connecting to MongoDB !!");
    throw err;
  }
  console.log("successfully connected to database ..");
});

const authRoute = require('./routes/auth');
const addPublickKeyRoute = require('./routes/publicKey');
const regenerateRefreshToken = require('./routes/refreshToken');
const getAllUsers = require('./routes/users/allUsers');
const getRequestUsers = require('./routes/users/requestUser');
const messagesRoute = require('./routes/messages/messages');
const friendsUsersRoute = require('./routes/users/friendsUsers');

// require("./routes/chat")(io)
require('./routes/video_call/videoCall')(io)

app.use(bodyparser.json());
app.use(bodyparser.urlencoded({ extended: true }));
app.use(morgan("dev"));
app.use(cors());


app.use('/auth', authRoute);
app.use('/public-key', addPublickKeyRoute);
app.use('/refresh-token', regenerateRefreshToken);
app.use('/users', getAllUsers);
app.use('/request-users', getRequestUsers);
app.use('/messages', messagesRoute);
app.use('/friends-users', friendsUsersRoute);

// const aaa = require('./config/firenar');
// aaa();

const port = process.env.PORT || config.port || 8000;
http.listen(port, (err) => {
  if (err) {
    throw err;
  } else {
    console.log(`server running on port ${port}`);
  }
});

