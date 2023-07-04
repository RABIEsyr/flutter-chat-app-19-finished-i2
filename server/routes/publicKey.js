const express = require('express');
const router = express.Router();

const checkJwt = require('../middleware/checkAuth');
const db = require('../db/db');
router.post('/add-public-key', checkJwt, async(req, res, next) => {
    const _id = req.decoded.user;
    const publicKey = req.body['public-key'];
    console.log(publicKey);
    console.log(_id)
    const query = {publicKey: publicKey}
     db.userSchema.findByIdAndUpdate(_id, query,  (err, doc) => {
        console.log(doc)
        if(err) {
            res.json({
                success: false
            })
            throw err;  
        } else {
            res.json({
                success: true
            })
        }
    })
    
});

module.exports = router;