const mqtt = require('mqtt')
const fs = require('fs');
const m = require('lodash');
const trilat = require('trilat');
const pg = require('pg');

module.exports.handler = async function (event, context) {

    let proxyId = ""; // Идентификатор подключения


    let proxyEndpoint = ""; // Точка входа
    let user = ""; // Пользователь БД
    console.log(context.token);
    let conString = "postgres://:" + context.token.access_token + "token";

    let dbClient = new pg.Client(conString);
    dbClient.connect();
    let errors = [];
    let beacons = {};
    let sortedBeacons = {};
    let stations = [];
    let stationCoordinates = {};
    let sta = {};

    let lastDatabaseWrite = {};


    const client = mqtt.connect('ssl://mqtt.cloud.yandex.net:8883', {
        username: '',
        password: '',
        clientId: 'mqtt_cloud_function',
        ca: fs.readFileSync('rootCA.crt'),
    });

    client.on('connect', () => {
    console.log('connected');
        client.subscribe('$registries/reg_id/events', function (err) {
         if (!err) {
    
    }
        })
    });

    client.on('message', async function (topic, message) {
      

        console.log(message.toString());
            let payload = message.toString();
            let msg;
            try {
                msg = JSON.parse(payload);
            } catch (error){
                msg = null;
                console.log(error.message);
            }

            if(msg !== null) {
                for(let i=0; i<msg.e.length;i++) {
                    let mac = msg.e[i].m.toLowerCase();
                    let station = msg.st.toLowerCase();
                    if(stations.includes(station)) {

                    } else {
                        stations.push(station);
                    }
                    if(stations.includes(mac)) {
                    } else {
                        if (typeof beacons[mac] !== 'object') {
                            beacons[mac] = {};
                        } else if (typeof beacons[mac][station] === 'object') {
                            delete beacons[mac][station];
                        }
                        beacons[mac][station] = {
                            rssi: parseInt(msg.e[i].r, 10),
                            timestamp: Math.floor(Date.now() / 1000)
                        }
                    }

                    var b = beacons;
                    if(typeof b === 'undefined' || Object.keys(b).length === 0) {
                        console.log("Beacons is undefined in stationCoordinates");
                    } else {
                        for (let beacon in b) {
                            for (let station in b[beacon]) {
                                if(typeof stationCoordinates[station] === 'undefined') {
                                    stationCoordinates[station] = {
                                        x: parseInt(msg.coords.x.toString()),
                                        y: parseInt(msg.coords.y.toString())
                                    };
                                }
                            }
                        }
                    }

                   

                    let objectList = {};
                    let list = [];
                    b = beacons;
                    if(typeof b === 'undefined' || Object.keys(b).length === 0) {
                        console.log("Beacons is undefined in objectList");
                    } else {
                        for (let beacon in b) {
                            for (let mac in b[beacon]) {
                                if(typeof objectList[mac] !== 'undefined'){
                                    if(objectList[mac].rssi < b[beacon][mac].rssi) {
                                        objectList = m.merge(objectList, b[beacon]);
                                    }
                                } else {
                                    objectList = m.merge(objectList, b[beacon]);
                                }
                            }
                        }

                        for(let beacon in objectList) {
                            list.push({mac: beacon, rssi: objectList[beacon].rssi, timestamp: objectList[beacon].timestamp})
                        }
                        sortedBeacons = list.sort(function(a, b) {
                            return a.rssi - b.rssi;
                        }).reverse();
                    }


                    console.log("beacons");
                    const beaconsMap = new Map(Object.entries(beacons));
                    console.log(Object.fromEntries([...beaconsMap]));
                    console.log("stationCoordinates");
                    console.log(stationCoordinates);

                    let beaconCoords = {};
                    if (beacons) {
                        b = beacons;
                        for (var key in b) {
                            if(Object.keys(b[key]).length >= 3 && Object.keys(stationCoordinates).length >= 3) {
                                let coords = await locate(b[key], stationCoordinates, 100);
                                if(coords !== null) {
                                    beaconCoords[key] = coords;

                                    if(lastDatabaseWrite[key] !== undefined) {
                                        console.log(`Diff is ${(Date.now()- lastDatabaseWrite[key]) / 1000}`);
                                    }
                                   
                                    if(lastDatabaseWrite[key] == undefined || (Date.now()- lastDatabaseWrite[key]) / 1000 > 5) {
                                        let result = await dbClient.query(`INSERT INTO coordinates (beacon_mac, x, y, time, geom) VALUES('${key.toString()}', ${coords.x.toString()}, ${coords.y.toString()}, to_timestamp(${Date.now()} / 1000.0), 'POINT(${coords.x.toString()} ${coords.y.toString()})') ON CONFLICT DO NOTHING`);
                                        lastDatabaseWrite[key] = Date.now();
                                    }
                                    console.log(`Key is ${key.toString()}`);
                                } else {
                                    console.log("Failed to locate:");
                                    console.debug(b[key]);
                                }
                            } else {

                            }
                        }
                    }

                    console.log("beacon coordinates:");
                    const beaconCoordinatesMap = new Map(Object.entries(beaconCoords));
                    console.log(Object.fromEntries([...beaconCoordinatesMap]));
                }
            }
    });

    await new Promise(resolve => setTimeout(resolve, 60000));

    async function locate(beacon, stations, px_meter) {

    function calculateDistance(rssi) {
        let P = -60;
        let n = 3;
        let d = Math.pow(10, ((P-rssi) / (10*n))); 
        return d*px_meter;
    }

    var keysSorted = Object.keys(beacon).sort(function (a, b) {
        return beacon[a].rssi - beacon[b].rssi
    });
    keysSorted.reverse();

    let d1 = calculateDistance(beacon[keysSorted[0]].rssi);
    let d2 = calculateDistance(beacon[keysSorted[1]].rssi);
    let d3 = calculateDistance(beacon[keysSorted[2]].rssi);
    let input = [
        [ parseInt(stations[keysSorted[0]].x, 10), parseInt(stations[keysSorted[0]].y, 10), d1],
        [ parseInt(stations[keysSorted[1]].x, 10), parseInt(stations[keysSorted[1]].y, 10), d2],
        [ parseInt(stations[keysSorted[2]].x, 10), parseInt(stations[keysSorted[2]].y, 10), d3]
    ];

    let output = trilat(input);
    let coords = {
        x: parseInt(output[0], 10),
        y: parseInt(output[1], 10)
    };
    return coords;
}
};


