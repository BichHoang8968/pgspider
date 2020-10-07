# This is a test for KeepAlive feature of PGSpider (Manual test)
## How to execute:
### Step 1: setup environment
 - Setup TinyBrace on PC1
 - Setup InfluxDB on PC2
 - Setup PostgreSQL on PC3
 - Setup MySQL on PC4
 - Setup PGSpider2 on current PC5
 - Setup PGSpider3 on current PC6
 - Setup PGSpider1 on current PC
 - Setup GridDB on current PC
 - Setup SQLite on current PC
### Step 2: setup data
 - Modify init_table/init.sh: set correct host, port, username, passwords for each database
 - Execute init_table/init.sh to setup data for each database
### Step 3: run setup_cluster
 - This test use multi-layer structure as described in node_structure.json
 - The information of each node is described in node_information.json
 - Modify keepalive/node_information.json file: set correct host, port, username, passwords for each node.
 - Copy keepalive/node_information.json and keepalive/node_structure.json to setup_cluster then execute setup from setup_cluster
 ```sh
$ cd pgspider_path/contrib/setup_cluster/
$ # copy node_information.json and node_structure.json
$ make clean && make && ./setup_cluster
 ```
 - Setup tool should return success and user can select from PGSpider1
### Step 4: Execute test
 - Modify test.sh: set port, database name, user, passwords of PGSpider1
 - Execute test.sh
 - Follow the instruction during the test (start and stop server)
### Step 5: Check result
 - Test result is displayed in the console