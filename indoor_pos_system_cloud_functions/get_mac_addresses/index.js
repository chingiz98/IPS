const pg = require('pg');

module.exports.handler = async function (event, context) {
    let conString = "postgres://user1:" + context.token.access_token + "token";

    let dbClient = new pg.Client(conString);
    dbClient.connect();

    let result = await dbClient.query(`select distinct beacon_mac from coordinates`);

     return {
        statusCode: 200,
        body: result.rows
    };
};

