// clean data
use setup_cluster
db.tbl_mongo.drop();

db.tbl_mongo.insertMany([
    {c1 : "Caichao", c2 : NumberInt(989839), c3 : NumberDecimal(332.8) },
    {c1 : "simple", c2 : NumberInt(-28391322), c3 : NumberDecimal(8657.2) },
    {c1 : "two", c2 : NumberInt(25452), c3 : NumberDecimal(54562563.21514) },
    {c1 : "0YJ_gG7l000", c2 : NumberInt(-9892), c3 : NumberDecimal(-2563.21514) },
    {c1 : "nine", c2 : NumberInt(1111), c3 : NumberDecimal(0.31318) }
 ]);