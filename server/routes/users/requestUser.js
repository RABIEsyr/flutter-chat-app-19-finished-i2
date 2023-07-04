const express = require('express');
const router = express.Router();
const ObjectId = require("mongoose").Types.ObjectId;

const checkAuth = require('../../middleware/checkAuth');
const db = require('../../db/db');

const firebaseNotification = require('../../config/firenar');
router.get('/in', checkAuth, async (req, res) => {
    const userId = req.decoded.user;
    const result = await db.userSchema.findById(userId).lean().populate('requestIn').select('username publicKey');
    const requestInRequestIn = result.requestIn;

    const ar1 = getOutInRequests(requestInRequestIn)
    res.json(ar1);
})

router.get('/out', checkAuth, async (req, res) => {
    const userId = req.decoded.user;

    const result = await db.userSchema.findById(userId).lean().populate('requestOut').select('username publicKey');
    const requestOutRequestOut = result.requestOut

    const ar1 = getOutInRequests(requestOutRequestOut)

    res.json(ar1);
})

router.post('/new-request', checkAuth, async (req, res, next) => {
    const fromUserId = req.decoded.user;
    const toUserId = req.body.toUserId;
    const toMessage = req.body.toMessage;
    const fromMessage = req.body.fromMessage;
    console.log('aaa', fromUserId, '   ', toUserId, 'fromMessage', fromMessage, 'toMessage', toMessage);
    // const res1 = await db.userSchema.find({_id: toUserId, requestIn: fromUserId});
    // const res2 = await db.userSchema.find({_id: fromUserId, requestOut: toUserId});
    const isDone = await handleSendRequest({ from: fromUserId, to: toUserId });
    const isDoneSaveMessage = await saveRequestMessage({ from: fromUserId, to: toUserId, fromMessage: fromMessage, toMessage: toMessage });
    console.log('isDone', isDone)
    if (isDone && isDoneSaveMessage) {
        res.json({
            success: true
        })
    } else {
        res.json({
            success: false
        })
    }
});


router.post('/repeat-request', checkAuth, async (req, res) => {
    const fromUserId = req.decoded.user;
    const toUserId = req.body.toUserId;
    const toMessage = req.body.toMessage;
    const fromMessage = req.body.fromMessage;

    const isDoneSaveMessage = await saveRequestMessage({ from: fromUserId, to: toUserId, fromMessage: fromMessage, toMessage: toMessage });
    const isDoneSendNotification = await sendNotification({from: fromUserId, to: toUserId, toMessage: toMessage });
    if (isDoneSaveMessage == true && isDoneSendNotification == true) {
        res.json({
            success: true
        })
    } else {
        res.json({
            success: false
        })
    }
});

router.post('/is-friend', checkAuth, async (req, res) => {
    const fromUserId = req.decoded.user;
    const toUserId = req.body.userId;

   try {
    var result = await db.userSchema.findOne({_id: fromUserId, friends: ObjectId(toUserId)});
    console.log(result)
    if (result) {
        res.json({
            friend: true
        });
    } else {
        res.json({
            friend: false
        });
    }
   } catch (error) {
    throw error;
   }
});

router.post('/set-as-friend', checkAuth, async (req, res) => {
    const fromUserId = req.decoded.user;
    const toUserId = req.body.userId;

    db.userSchema.updateOne({_id: fromUserId}, {
        $pull: {
            requestIn: ObjectId(toUserId)
        },
        $addToSet: { 
            friends: ObjectId(toUserId)
         }
    }, {multi: true}, (err, affected) => {
        if (err) {
            throw err
        } else {
            console.log('numaff11', affected);
            db.userSchema.updateOne({_id: toUserId}, {
                $pull: {
                    requestOut: ObjectId(fromUserId)
                },
                $addToSet: { 
                    friends: ObjectId(fromUserId)
                 }
            }, {multi: true}, (err, affected2) => {
                if (err) {
                    res.json({
                        success: false
                    });
                    throw err;
                } else {
                    console.log('numaff22', affected2);
                    res.json({
                        success: true
                    });
                }
            })
        }
    })
})

module.exports = router;


function getOutInRequests(arr) {
    arr.forEach((el) => {
        delete el['online']
        delete el['friends']
        delete el['requestOut']
        delete el['requestIn']
        delete el['password']
        delete el['__v']
    })

    return arr;
}


async function handleSendRequest({ from, to }) {
    done = false
    var update1 = {
        $addToSet: { requestOut: ObjectId(to) }
    }

    var update2 = {
        $addToSet: { requestIn: ObjectId(from) }
    }

    try {
        await db.userSchema.findByIdAndUpdate(from, update1);
        await db.userSchema.findByIdAndUpdate(to, update2);
        done = true;
    } catch (e) {
        done = false
    }

    return done;
}

async function saveRequestMessage({ from, to, toMessage, fromMessage }) {
    done = false;

    const cs = new db.chatSchema();
    cs.to = to;
    cs.from = from;
    cs.toText = toMessage;
    cs.fromText = fromMessage;

    try {
        cs.save();
        done = true
    } catch (error) {
        done = false
    }

    return done;
}

async function sendNotification({ from, to, toMessage }) {
    const receiverUser = await db.userSchema.findById(to);
    const receiverToken = receiverUser.deviceToken;
    const senderUser = await db.userSchema.findById(from);
    const senderPublicKey = senderUser.publicKey;
    console.log('tokenfirebase', receiverToken);
    const { username} = await db.userSchema.findById(from).select('username -_id');
    console.log('uname', username);
    const result = await firebaseNotification({ token: receiverToken, message: toMessage, senderId: from, senderPublikKey: senderPublicKey, senderName: username });
    return result;
}