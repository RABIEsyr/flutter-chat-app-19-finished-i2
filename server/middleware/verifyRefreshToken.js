const jwt = require('jsonwebtoken');
const config = require('../config/config');

module.exports = function(refreshToken) {
    const refresToken = refreshToken;
    //  console.log(refresToken)
    return new Promise((resolve, reject) => {
        jwt.verify(refresToken, config.secretRefreshToken, (err, decoddedRefreshToken) => {
            if (err) {
                console.log('invalidrefresToken');
                reject({
                    error: true,
                    message: 'invalid refresh token'
                })
            } else {
                resolve({
                    error: false,
                    message: 'valid refresh token',
                    decoddedRefreshToken
                })
            }
        })
    })
}