use mongo_pg_modify2

db.tntbl2.drop();
db.tntbl3.drop();
db.createCollection("tntbl2");
db.createCollection("tntbl3");

db.tntbl2.insertMany([
    {"c1": NumberInt(3), "c2": "foo", "c3": true, "c4": -1928.121, "c5": NumberLong(3000)},
    {"c1": NumberInt(4), "c2": "varchar", "c3": false, "c4": 2000.0, "c5": NumberLong(4000)}
 ]);

db.tntbl3.insertMany([
    {"c1": NumberInt(3), "c2": -19.1, "c5": NumberLong(3000)},
    {"c1": NumberInt(4), "c2": 20.0, "c5": NumberLong(4000)}
 ]);
