const express = require('express');
const router = express.Router();

const jwt = require('jsonwebtoken');

const db = require('../db/db');
const config = require('../config/config');

router.post('/login', async (req, res, next) => {
    db.userSchema.find().then((d)=> console.log('dd', d))
    const username = req.body.username;
    const password = req.body.password;
    const firebaseToken = req.body.firebaseToken;

    console.log('firebaseToken', firebaseToken);
   
    if (username && password) {
        // db.userSchema.deleteOne( {"_id": "62eb8d6492dedc308890ab59"}).exec();
        try {
            const isUserExists = await db.userSchema.findOne({ username, password });
            console.log('allall', await db.userSchema.find())
            console.log('isUserExists',isUserExists)
            if (isUserExists == null) {
                res.json({
                    success: false,
                    message: 'username or password is invalid'
                })
            } if (firebaseToken != null) {
                if (firebaseToken.length < 1) {
                    res.json({
                        success: false,
                        message: 'No Firebase Token'
                    }) 
                }   else {
                    const query = {deviceToken: firebaseToken}
                     db.userSchema.findByIdAndUpdate(isUserExists._id, query,  (err, doc) => {
                        if (err) throw err;
                        const token = jwt.sign(
                            { user: isUserExists._id },
                            config.secret,
                            { expiresIn: '100d' });
        
                            const refreshToken = jwt.sign(
                                {user: isUserExists._id},
                                config.secretRefreshToken,
                                {expiresIn: '2000m'}
                            )
        
                        res.json({
                            success: true,
                            token,
                            userId: isUserExists._id,
                            expireIn: '6',
                            refreshToken,
                            publicKey: doc.publicKey,
                            encryptedPrivateKey: doc.privateKeyEncrypted
                        });    
                 });
                }
            }
           
        } catch (error) {
            console.log(error)
        }
    }
});


router.post('/signup', async (req, res, next) => {
    const username = req.body.username;
    const password = req.body.password;
    const province = req.body.province;
    const gender = req.body.gender;
    const firebaseToken = req.body.firebaseToken;
    const publicKey = req.body.publicKey;
    const privateKeyEncrypted = req.body.privateKeyEncrypted;
    
     console.log('signup', req.body);
    if (username && password && province && gender && publicKey && privateKeyEncrypted && firebaseToken) {
        try {
            const isUsernameTaken = await db.userSchema.find({ username });
            if (isUsernameTaken.length > 0) {
                res.json({
                    success: false,
                    message: 'Username has already been taken'
                })
                return;
            } else {
                const newUser = new db.userSchema();
                newUser.username = username;
                newUser.password = password;
                newUser.province = province;
                newUser.gender = gender;
                newUser.deviceToken = firebaseToken;
                newUser.publicKey = publicKey;
                newUser.privateKeyEncrypted = privateKeyEncrypted;

                newUser.save((err, result) => {
                    if (err) {
                        res.json({ success: false, message: 'error in the database' });
                    } else {
                        console.log('result0', result)
                        const token = jwt.sign({ user: result._id }, config.secret, { expiresIn: '20m' });
                        const refreshToken = jwt.sign(
                            { user: result._id },
                            config.secretRefreshToken,
                            { expiresIn: '30d' }
                        )
                        res.json({
                            success: true,
                            token,
                            userId: result._id,
                            expireIn: '6',
                            refreshToken,
                            publicKey: result.publicKey,
                            encryptedPrivateKey: result.privateKeyEncrypted
                        })
                    }
                })
            }
        } catch (e) {
            console.log(e)
        }
    } else {
        res.json({ success: false, 'message': 'please provide your username and password' })
    }
});

module.exports = router;