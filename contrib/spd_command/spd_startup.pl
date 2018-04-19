use JSON;
use Getopt::Long 'GetOptions';

$filepath = 'spd_config.json';
open ( my $fh , '<' , $filepath ) || die "cannot open $!" ; 
my $data ;
my $spd_ip;
my $spd_port;
my $spd_user;
my $spd_pass;
my $spd_dbpath;
my @spd_extensions;

my @enable_extensions;

$spd_extensions[0]="file_fdw";
$spd_extensions[1]="spd_fdw";
$spd_extensions[2]="postgres_fdw";
$spd_extensions[3]="sqlite_fdw";
$spd_extensions[4]="tinybrace_fdw";
$spd_extensions[5]="mysql_fdw";
$spd_extensions[6]="griddb_fdw";


GetOptions(
    'enable_sqlite'  => \$enable_extensions[0],
    'enable_tinybrace'  => \$enable_extensions[1],
    'enable_mysql'  => \$enable_extensions[2],
    'enable_griddb'  => \$enable_extensions[3]
    );

sub rewrite_setting(){
    open (FH, ">> $spd_dbpath/postgresql.conf");
    print FH "listen_addresses = '$spd_ip'\n";
    print FH "port = $spd_port\n";
    close(FH);
}

sub initdb_spd(){
    $cmd = "./initdb -D ".$spd_dbpath.";";
    if (-d $spd_dbpath) {
        print "db dir is exist. skip initdb\n";
    }
    else{
        $result = system($cmd);
        if($result != 0){
            print "Can not create spd db path = $spd_dbpath";
            exit(0);
        }
        rewrite_setting();
    }
}

sub start_spd(){
    $cmd = "./pg_ctl -D ".$spd_dbpath." start &";
    $result = system($cmd);
    if($result != 0){
        print "Can not start spd server. Please check there is another spd server.";
        stop_spd();
    }
    sleep(3);
}

sub stop_spd(){
    $cmd = "./pg_ctl -D ".$spd_dbpath." stop";
    $result = system($cmd);
    if($result != 0){
        print "Can not stop spd server. Please check process.";
        exit(0);
    }
}

sub create_roll(){
    $cmd = "./psql postgres -c \"CREATE ROLE postgres SUPERUSER LOGIN;\" -t";
    $result = system($cmd);
    if($result != 0){
        print "Can not create roll.";
    }
}
sub check_psql{
    if($_[0] =~/FATAL/){
        print "failed to initialize.\n";
        exit(0);
    }
}

sub delete_allserver{
    my $i=0;
    printf("-------------------------------------------\nDelete All spd settings start. \n");
    printf("-------------------------------------------\n");
	
    sleep(1);
#get foreign servers
    $cmd = "./psql postgres -c \"select srvname from pg_foreign_server;\" -t";
    open my $rs, "$cmd 2>&1 |";
    my @rlist = <$rs>;
    close $rs;
    my $result = join '', @rlist;
    my @rlist2 = split(/\n/, $result);
#delete all foreign servers
    foreach my $item (@rlist2){
        chomp($item);
        if($item){
            $sql = "DROP SERVER ".$item." CASCADE;";
            $cmd = "./psql postgres -t -c \"".$sql."\"\n";
            $result = system($cmd);
            if($result != 0 ){
                printf("Failed to add node %s. Please check setting.json. \n",$fdw_name);
                exit();
            }
        }
    }
    foreach my $item (@spd_extensions){
        $cmd = "./psql postgres -c \"DROP EXTENSION ".$item." CASCADE;\"";
        $result = system($cmd);
        #		printf("drop extention = %d \n", $result);
    }
    stop_spd();
	  printf("-------------------------------------------\nCompliete delete all spd settings. Please check error message. \n");
}

sub create_extention{
    my $i=0;
    foreach my $item (@spd_extensions){
       	if($i<3 || ($i>=3 && $enable_extensions[$i-3] eq 1)){
            $cmd = "./psql postgres -c \"CREATE EXTENSION ".$item.";\"";
            $result = system($cmd);
            if($result != 0){
                delete_allserver();
                exit(0);
            }
        }
        else{
            printf("skip create extention = %s \n",$item);
        }
        $i++;
    }
}

sub import_schema{
    my $cmd;

    $cmd = "./psql postgres -c \"DROP SCHEMA if exists temp_schema;\"";
    $result = system($cmd);
    if($result !=0){
        delete_allserver;
        exit(0);
    }

    $cmd = "./psql postgres -c \"CREATE SCHEMA temp_schema;\"";
    $result = system($cmd);
    if($result !=0){
        delete_allserver;
        exit(0);
    }

	if($_[1] eq NULL){
		$cmd = "./psql postgres -c \"import foreign schema public from server ".$_[0]." into temp_schema;\" -t";
	}
	else{
		$cmd = "./psql postgres -c \"import foreign schema ".$_[1]." from server ".$_[0]." into temp_schema;\" -t";	    
	}
	
    $result = system($cmd);
    if($result !=0){
        delete_allserver;
        exit(0);
    }
}

sub load_filefdw{
	#delete_allserver();
	my @file= glob "$_[0]*.csv";
	
	foreach my $item (@file) {
		($tempitem = $item) =~ s/^\/*//;
		($filename = $tempitem) =~s!.*/|.*\\(.*)$!$1!;
		@splitemp = split(/\./,$tempitem);
		($tablename = $splitemp[0]) =~ tr/\//_/;
		
		$command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." file ".$tablename.";";

		$result = system($command);

		if($result != 0 ){
		    printf("Failed to add node %s. Please check setting.json. \n",$fdw_name); 
		    delete_allserver();
		    exit();
		}
		my $sql3 = "CREATE FOREIGN TABLE IF NOT EXISTS ".$tablename."(".$_[1].")server spd;";
		my $cmd3 = "./psql postgres -t -c \"".$sql3."\"\n";
		$result = system($cmd3);
		if($result !=0){
			delete_allserver;
			exit(0);
		}
		$command = "./spd_command/spd_mapping_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$tablename." '".$_[1]."' ".$tablename." ".$item." csv";

		$result = system($command);
		if($result !=0){
			#delete_allserver;
			exit(0);
		}
	}
}

sub rename_foreign_table{
    $cmd = "./psql postgres -c \"select foreign_table_name from information_schema.foreign_tables where foreign_table_schema='temp_schema';\" -t";
    $cmd2 = "./psql postgres -c \"select foreign_server_name from information_schema.foreign_tables where foreign_table_schema='temp_schema';\" -t";
    open my $rs, "$cmd 2>&1 |";
    my @rlists = <$rs>;
    close $rs;

    printf "%s\n",$cmd2;
    open my $rs, "$cmd2 2>&1 |";
    my @rlists2 = <$rs>;
    close $rs;

    my $result = join '', @rlists;
    my @rlist = split(/\n/, $result);

    my $result2 = join '', @rlists2;
    my @rlist2 = split(/\n/, $result2);

    my $childtable = shift(@rlit2);
    chomp($childtable);
    $childtable =~ s/^\s*//;

    foreach my $item (@rlist) {
        chomp($item);
        if($item) {
            my $cmd1;
            my $cmd2;
            my $sql1;
            my $sql2;
            $item =~ s/^\s*//;
            $newtable = $item."__".$_[0]."__0";
            
            #Get spd table
            $sql1="select column_name from information_schema.columns where table_name = '".$item."';";
            $cmd1 = "./psql postgres -t -c \"".$sql1."\"\n";
            open my $rs, "$cmd1 2>&1 |";
            my @attr_rlists = <$rs>;
            close $rs;
            my $column_result = join '', @attr_rlists;

            $sql2="select data_type from information_schema.columns where table_name = '".$item."';";
            $cmd2 = "./psql postgres -t -c \"".$sql2."\"\n";
            open my $rs, "$cmd2 2>&1 |";
            my @type_rlists = <$rs>;
            close $rs;
            my $type_result = join '', @type_rlists;
            
            #change table name			
            $sql = "ALTER TABLE temp_schema.".$item." RENAME to ".$newtable.";";
            $cmd = "./psql postgres -t -c \"".$sql."\"\n";
            $result = system($cmd);
            #			printf("%s result = %d \n",$cmd, $result);
            if($result !=0){
                delete_allserver;
                exit(0);
            }
            
            #change schema name	
            $sql = "ALTER TABLE temp_schema.".$newtable." set schema public;";
            $cmd = "./psql postgres -t -c \"".$sql."\"\n";
            $result = system($cmd);
            if($result !=0){
                delete_allserver;
                exit(0);
            }
            if ($items->{FDW} eq "tinybrace") {
                $sql = "ALTER TABLE ".$newtable." options (set table_name '".$item."');";
                $cmd = "./psql postgres -t -c \"".$sql."\"\n";
                $result = system($cmd);
                $result = system($cmd);
                if($result !=0){
                    delete_allserver;
                    exit(0);
                }
            }
            elsif($items->{FDW} eq "mysql") {
                $sql = "ALTER TABLE ".$newtable." options (set tablename '".$item."');";
                $cmd = "./psql postgres -t -c \"".$sql."\"\n";
                $result = system($cmd);
                if($result !=0){
                    delete_allserver;
                    exit(0);
                }
            }
            elsif($items->{FDW} eq "sqlite") {
                $sql = "ALTER TABLE ".$newtable." options (set table '".$item."');";
                $cmd = "./psql postgres -t -c \"".$sql."\"\n";
                $result = system($cmd);
                if($result !=0){
                    delete_allserver;
                    exit(0);
                }
            }
            my @typelist = split(/\n/, $type_result);
            my @columnlist = split(/\n/, $column_result);
            my $i=0;
            my $sql3 = "CREATE FOREIGN TABLE IF NOT EXISTS ".$item."(";
            foreach my $item (@typelist) {
                if($i != 0){
				$sql3 = $sql3.",";
			    }
			    $sql3 = $sql3.$columnlist[$i].$item;
			    $i+=1;
            }
            $sql3 = $sql3." )server spd;";
            my $cmd3 = "./psql postgres -t -c \"".$sql3."\"\n";
            $result = system($cmd3);
            if($result !=0){
                delete_allserver;
                exit(0);
            }
        }
    }
}

#main
eval{
   local $/ = undef;
   my $json_txt = <$fh>;
   my $fdw_name;
   my $server_name;

   close $fh;
   $data = decode_json( $json_txt );
   if(!$data->{SPD_SETTING}){
       do_delete();
       return;
   }
   foreach my $item ($data->{SPD_SETTING}){
       $spd_ip = $item->{SPD_IP};
       $spd_port = $item->{SPD_PORT};
       $spd_user = $item->{SPD_USER};
       $spd_pass = $item->{SPD_PASS};
       $spd_dbpath = $item->{SPD_DBPATH};

       #initdb
       initdb_spd();
       #start up server
       start_spd();
       #create roll
       create_roll();
       #create extention
       create_extention();

       $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." spd ". "spd ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass;
       printf("%s %s %s %s",$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass);
	   $result = system($command);
	   if($result != 0 ){
		   printf("Failed to add node spd_fdw. Please check setting.json. %d\n",$result); 
		   delete_allserver();
		   exit();
	   }
   }
   foreach my $item ($data->{nodes}){
       printf("========FDW===========\n");
       foreach my $items (@$item){
		   $db_name = NULL;
           $fdw_name = $items->{FDW};
           $server_name = $items->{Name};
           if(!$items->{FDW}){
               do_delete();
               return;
           }
           if($items->{FDW} eq "postgres") {
               printf("========postgres=========\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{IP}." ".$items->{Port}." ".$items->{user}." ".$items->{password};
               printf "%s\n",$command;
           }
           elsif($items->{FDW} eq "spd") {
               printf("========spd=========\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{IP}." ".$items->{Port}." ".$items->{user}." ".$items->{password};
               printf "%s\n",$command;
           }
           elsif($items->{FDW} eq "mysql") {
               printf("========mysql=========\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{IP}." ".$items->{Port}." ".$items->{user}." ".$items->{password};
			   $db_name = $items->{dbname};
               printf "%s\n",$command;
           }
           elsif($items->{FDW} eq "tinybrace") {
               printf("======tinybrace=======\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{IP}." ".$items->{Port}." ".$items->{user}." ".$items->{password}." ".$items->{dbname};
               printf "%s\n",$command;
				   }
           elsif($items->{FDW} eq "sqlite") {
               printf("========sqlite=========\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{dbpath};
               printf "%s\n",$command;
           }
           elsif($items->{FDW} eq "filefdw") {
               printf("========filefdw=========\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{FilePath}." ".$items->{TableName}." \"".$items->{Column}."\"";
               printf "%s\n",$command;
			   load_filefdw($items->{FilePath},$items->{Column});
           }
           elsif($items->{FDW} eq "griddb") {
               printf("========filefdw=========\n");
               $command = "./spd_command/spd_node_set ".$spd_ip." ".$spd_port." ".$spd_user." ".$spd_pass." ".$items->{FDW}." ".$items->{Name}." ".$items->{FilePath}." ".$items->{TableName}." \"".$items->{Column}."\"";
               printf "%s\n",$command;
			   load_filefdw($items->{FilePath},$items->{Column});
           }
           else{
               printf("Failed to add node %s. Please check setting.json. \n",$fdw_name); 
               delete_allserver();
               exit();
           }
		   if($items->{FDW} ne "filefdw"){
			   $result = system($command);
			   printf("result = %d \n", $result);
			   if($result != 0 ){
				   printf("Failed to add node %s. Please check setting.json. \n",$fdw_name); 
				   delete_allserver();
				   exit();
			   }
			   import_schema($server_name, $db_name);
			   rename_foreign_table($items->{Name});
		   }
       }
   }
   stop_spd();
   print "-------------------------------------------\nSuccess To SPD initialize!\n";
   print "server start command: \"pg_ctl start -D ".$spd_dbpath."\"\n";
};

if ( $@ ) {
   print STDERR ( "Invalid JSON text : $@\n" );
   exit 1;
}

