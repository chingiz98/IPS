const pg = require('pg');

module.exports.handler = async function (event, context) {

    let conString = "postgres://user1:" + context.token.access_token + "token";

    let params = event.queryStringParameters;

    console.log(`mac:${params.mac} interval:${params.interval} distance:${params.distance}`)

    if(params.mac == undefined || params.interval == undefined || params.distance == undefined) {
        return {
            statusCode: 500,
            body: 'No required parameters'
        };
    }


    let dbClient = new pg.Client(conString);
    dbClient.connect();
    let result = await dbClient.query(
`SELECT DISTINCT ON (distance)
c1.id as id1, c2.id as id2,
  c1.beacon_mac AS mac1, c2.beacon_mac AS mac2, c1.time as time1, c2.time as time2,
  ST_AsText(c1.geom) AS p1,
  ST_AsText(c2.geom) AS p2,
  ST_Distance(c1.geom,c2.geom) AS distance
FROM coordinates c1, coordinates c2
WHERE 
  c1.beacon_mac <> c2.beacon_mac AND
  (c1.beacon_mac = '${params.mac}' OR
  c2.beacon_mac = '${params.mac}') AND 
  (c1.time BETWEEN c2.time - (interval '${params.interval}s') AND c2.time + (interval '${params.interval}s')) AND
  ST_Distance(c1.geom,c2.geom) <= ${params.distance}`
    );

    let traceResult = await dbClient.query(
        `SELECT id, beacon_mac, time, ST_AsText(geom) as p FROM coordinates WHERE beacon_mac = '${params.mac}' ORDER BY time`
    )

    return {
        statusCode: 200,
        body: {
            intersections: result.rows,
            trace: traceResult.rows
        }
    };

};

