const express = require('express');
const router = express.Router();
const ObjectId = require("mongoose").Types.ObjectId;

const checkAuth = require('../../middleware/checkAuth');
const db = require('../../db/db');

router.post('/get-messages', checkAuth, async (req, res) => {
    const fromUserId = req.decoded.user;
    const toUserId = req.body.userId;

    db.chatSchema.find({
        $or: [
               { $and: [ 
                    {to: ObjectId(fromUserId)},
                    {from: ObjectId(toUserId)}
                ]},{
                $and: [
                    {to: ObjectId(toUserId)},
                    {from: ObjectId(fromUserId)}
                ]}
            
        ]
    }).exec((err, messages) => {
        if (err) throw err;
        console.log('chatMessge', messages);
        res.json(messages);
    })
});

module.exports = router;