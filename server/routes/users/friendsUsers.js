const express = require('express');
const router = express.Router();

const checkAuth = require('../../middleware/checkAuth');
const db = require('../../db/db');

router.get('/get-friends', checkAuth, async (req, res) => {
    const currentUserId = req.decoded.user;

    const result = await db.userSchema.findById(currentUserId).lean().populate('friends').select('username publicKey');
    const resFriends = result.friends;

    const arrFriends = getFriends(resFriends)

    res.json(arrFriends);
});

function getFriends(arr) {
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
module.exports = router;