# Test setup cluster with file_fdw in single layer:
# Create 2 multi tenant table:
# - 1 table has 2 child server. Server 1 has 2 child foreign table, server 2 has 1 child foreign table.
# - 1 table has 1 child server.
./setup_cluster