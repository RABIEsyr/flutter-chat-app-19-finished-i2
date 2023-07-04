const mongoose = require("mongoose");
var deepPopulate = require("mongoose-deep-populate")(mongoose);

const schema = mongoose.Schema;

const userSchema = new schema({
  name: String,
  username: String,
  password: String,
  image: { data: Buffer, contentType: String },
  gender: String,
  online: { type: Boolean, default: false },
  friends: [{ type: schema.Types.ObjectId, ref: "userSchema" }],
  requestOut: [{ type: schema.Types.ObjectId, ref: "userSchema" }],
  requestIn: [{ type: schema.Types.ObjectId, ref: "userSchema" }],
  lastSeen: Date,
  province: String,
  gender: String,
  isLoggedin: { type: Boolean, default: true },
  deviceToken: String,
  rsaKeys: [{ type: schema.Types.ObjectId, ref: "RsaKeysSchema" }],
  publicKey: String,
  privateKeyEncrypted: String
});
userSchema.plugin(deepPopulate);

const chatSchema = new schema({
  from: { type: schema.Types.ObjectId, ref: "userSchema" },
  to: { type: schema.Types.ObjectId, ref: "userSchema" },
  date: { type: Date, default: Date.now },
  pending: {type: Boolean, default: true},
  fromText: String,
  toText: String,
  // fromKeys: { type: schema.Types.ObjectId, ref: "RsaKeysSchema" },
  // toKeys: { type: schema.Types.ObjectId, ref: "RsaKeysSchema" },
  isReaded: {type: Boolean, default: false}
});

const RsaKeysSchema = new schema({
  userId: {type: schema.Types.ObjectId, ref: 'userSchema'},
  publicKey: String,
  encryptedPrivateKey: String,
  createdDate: { type: Date, default: Date.now }
});

module.exports.userSchema = mongoose.model("userSchema", userSchema);
module.exports.chatSchema = mongoose.model("chatSchema", chatSchema);
module.exports.RsaKeysSchema = mongoose.model("RsaKeysSchema", RsaKeysSchema);