const express = require('express');
const router = express.Router();

const jwt = require('jsonwebtoken');

const verifyRefreshToken = require('../middleware/verifyRefreshToken');
const config = require('../config/config');
const db = require('../db/db');


const fire = require('../config/firenar');

router.post('/', async (req, res) => {
    // fire();
    const refreshToken = req.body.refreshToken;
    verifyRefreshToken(refreshToken)
        .then(async(tokenDetails) => {
            if (!tokenDetails.error) {
                const token = jwt.sign({ user: tokenDetails.decoddedRefreshToken.user }, config.secret, { expiresIn: '1d' });
                const refreshToken = jwt.sign(
                    { user: tokenDetails.decoddedRefreshToken.user },
                    config.secretRefreshToken,
                    { expiresIn: '30d' }
                )
                const userPrivateKey = await db.userSchema.findById(tokenDetails.decoddedRefreshToken.user).select('privateKeyEncrypted');
                res.json({
                    success: true,
                    token,
                    userId: tokenDetails.decoddedRefreshToken.user,
                    expireIn: '6',
                    refreshToken,
                    privateKey: userPrivateKey.privateKeyEncrypted
                })
            }
        }).catch(e => {
            console.log(e)
            res.json(e)
        })
})

module.exports = router;