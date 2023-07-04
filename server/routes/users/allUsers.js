const express = require('express');
const router = express.Router();

const checkAuth = require('../../middleware/checkAuth');
const db = require('../../db/db');

router.post('/all-users', checkAuth, async (req, res, next) => {
    const province = req.body.province;
    const currentUserId = req.decoded.user;
    if (province) {
        if (province == 'all') {
            // console.log(province);
            const filter = { $and: [ { _id: { $ne: currentUserId } }] };
            const query = db.userSchema.find(filter).select('username gender province publicKey')
           
            query.exec(async (err, users) => {
                 
                var finalResult = await removeReauestsFromAll(users, currentUserId)
                console.log('query22', finalResult)
                if (err) throw err;
                res.json(finalResult)
            })
           
        } else {
            const filter = { $and: [{ province }, { _id: { $ne: currentUserId } }] };
            const query = db.userSchema.find(filter).select('username gender province publicKey')
            query.exec(async (err, users) => {
                if (err) throw err;
                var finalResult = await removeReauestsFromAll(users, currentUserId)
                console.log(users)
                res.json(finalResult)
            })
        }
    }
})


module.exports = router;

async function removeReauestsFromAll(arr, userId) {
    var outArr = await db.userSchema.findById(userId).select('requestOut')
    var inArr = await db.userSchema.findById(userId).select('requestIn')
    var friendsArr = await db.userSchema.findById(userId).select('friends')

    outArr = outArr.requestOut;
    inArr = inArr.requestIn
    friendsArr = friendsArr.friends;
    console.log('outArr', outArr)
    console.log('inArr', inArr)

    if (Array.isArray(arr)) {
       
        arr.forEach((el) => {
            if(outArr.includes(el._id)) {
                console.log('done33', arr.indexOf(el))
                arr.splice(arr.indexOf(el), 1);
            }
        })
        arr.forEach((el) => {
            if(inArr.includes(el._id)) {
                arr.splice(arr.indexOf(el), 1);
            }
        })
        arr.forEach((el) => {
            if (friendsArr.includes(el._id)) {
                arr.splice(arr.indexOf(el), 1)
            }
        });
    }

    return arr;




}