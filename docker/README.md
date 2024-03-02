Usage of PGSpider docker image and PGSpider RPM packages
=====================================

This directory contains the source code to create the PGSpider docker image and the PGSpider rpm packages.

Environment for creating rpm of PGSpider
=====================================
1. Docker
	- Install Docker
		```sh
		sudo yum install -y yum-utils
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum install -y docker-ce docker-ce-cli containerd.io
		sudo systemctl enable docker
		sudo systemctl start docker
		```
	- Enable the currently logged in user to use docker commands
		```sh
		sudo gpasswd -a $(whoami) docker
		sudo chgrp docker /var/run/docker.sock
		sudo systemctl restart docker
		```
	- Proxy settings (If your network must go through a proxy)
		```sh
		sudo mkdir -p /etc/systemd/system/docker.service.d
		sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
		[Service]
		Environment="HTTP_PROXY=http://proxy:port/"
		Environment="HTTPS_PROXY=http://proxy:port/"
		Environment="NO_PROXY=localhost,127.0.0.1"
		EOF
		sudo systemctl daemon-reload
		sudo systemctl restart docker
		```
2. rpm Tools
	- rpmdevtools
		```sh
		sudo yum install -y rpmdevtools
		```
	- rpm-build
		```sh
		sudo yum install -y gcc gcc-c++ make automake autoconf rpm-build
		```
3. Get the required files  
	```sh
	git clone https://tccloud2.toshiba.co.jp/swc/gitlab/db/PGSpider.git
	```

Creating PGSpider rpm packages
=====================================
1. File used here
	- rpm/*
	- rpm/PGSpider.spec
	- docker/env_rpm_optimize_image.conf
	- docker/Dockerfile_rpm
	- docker/create_rpm_binary.sh
2. Configure `docker/env_rpm_optimize_image.conf` file
	- Configure proxy
		```sh
		proxy=http://username:password@proxy:port
		no_proxy=localhost,127.0.0.1
		```
	- Configure the registry location to publish the package and version of the packages
		```sh
		location=gitlab 					# Fill in <gitlab> or <github>. In this project, please use <gitlab>
		ACCESS_TOKEN=						# Fill in the Access Token for authentication purposes to publish rpm packages to Package Registry
		PGSPIDER_PROJECT_ID=16				# Fill in the ID of the PGSpider project.
		PGSPIDER_BASE_POSTGRESQL_VERSION=16 # Base Postgres version of PGSpider
		PGSPIDER_RELEASE_VERSION=4.0.0		# Version of PGSpider rpm package
		RPM_DISTRIBUTION_TYPE="rhel8"		# Distribution version of RedHat that the PGSpider rpm packages supports.
		```
3. Build execution
	```sh
	chmod +x docker/create_rpm_binary.sh
	./docker/create_rpm_binary.sh
	```
4. Confirmation after finishing executing the script
	- Terminal displays a success message. 
		```
		{"message":"201 Created"}
		...
		{"message":"201 Created"}
		```
	- rpm Packages are stored on the Package Registry of its repository
		```sh
		Menu TaskBar -> Deploy -> Package Registry
		```

Creating Postgres rpm packages
=====================================
1. File used here
	- docker/make_postgres_rpm.patch
2. To create Postgres rpm packages
	- Apply `docker/make_postgres_rpm.patch` patch file firstly.
		```sh
		patch -p0 < docker/make_postgres_rpm.patch
		```
	- The next steps are same with [Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)

Creating PGSpider docker images
=====================================
The PGSpider rpm packages are created [above](#creating-pgspider-rpm-packages) will be taken from the Package Registry to build PGSpider image.
1. File used here
	- docker/env_rpm_optimize_image.conf
	- docker/Dockerfile
	- docker/docker-entrypoint.sh
	- docker/create_pgspider_image.sh
2. Configure `docker/env_rpm_optimize_image.conf` file
	- Configure proxy: Same [Configure of Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)
	- Configure the registry location to publish the package
		```sh
		location=gitlab 					# Fill in <gitlab> or <github>. In this project, please use <gitlab>
		ACCESS_TOKEN=						# Fill in the Access Token for authentication purposes to get PGSpider rpm packages from the Package Registry.
		```
	- Configure version of rpm packages: Same [Configure of Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)
	- Configure PGSpider docker image
		```sh
		IMAGE_NAME=pgspider					# Name of PGSpider image
		PGSPIDER_RPM_ID=11816				# ID of PGSpider rpm package on the Package Registry
		PGSPIDER_CONTAINER_REGISTRY=		# Container registry name
		USERNAME_PGS_CONTAINER_REGISTRY=	# User name for authentication
		PASSWORD_PGS_CONTAINER_REGISTRY=	# Password for authentication
		```
3. Build execution
	```sh
	chmod +x docker/create_pgspider_image.sh
	./docker/create_pgspider_image.sh
	```
4. Confirmation after finishing executing the script
	- For `gitlab` location, PGSpider image is stored on the Container Registry of its repository
		```sh
		Menu TaskBar -> Deploy -> Container Registry
		```
	- For `github` location, PGSpider image is stored on the Packages registry on its repository

Usage of PGSpider image
=====================================
1. Pull PGSpider image from the Registry (Unnecessary if already available)
	```sh
	echo $PASSWORD | docker login --username $USERNAME --password-stdin swc.registry.benzaiten.toshiba.co.jp
	docker pull swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:11724
	```
2. Start a PGSpider container instance
	- Via `psql`
		```sh
		$ docker run -it swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:11724
		psql (16.0)
		Type "help" for help.

		pgspider=#
		```
	- Via detach mode
		```sh
		$ docker run -d swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:11724 DETACH_MODE
		```
	The default `pgspider` user and database are created in the entrypoint with initdb.
3. Forwarding Port
	```sh
	$ docker run -p 4813:4813 -d swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:11724 DETACH_MODE
	$ psql -h 127.0.0.1 -p 4813 -U pgspider -d pgspider
	psql (16.0)
	Type "help" for help.

	pgspider=#
	```
4. Extend database name

	This optional environment variable can be used to define a different name for the default database that is created when the image is first started.
	```sh
	$ docker run -p 4813:4813 -e PGSPIDER_DB=new_db swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:11724 DETACH_MODE
	$ psql -h 127.0.0.1 -p 4813 -U pgspider -d pgspider
	psql: error: connection to server at "127.0.0.1", port 4813 failed: FATAL:  database "pgspider" does not exist
	$ psql -h 127.0.0.1 -p 4813 -U pgspider -d new_db
	psql (16.0)
	Type "help" for help.

	new_db=#
	```
Usage of Run CI/CD pipeline
=====================================
1. Go to Pipelines Screen
	```sh
	Menu TaskBar -> Build -> Pipelines
	```
2. Click `Run Pipeline` button
![Alt text](images/pipeline_screen.PNG)
3. Choose `Branch` or `Tag` name
4. Provide `Access Token` through `Variabes`
	- Input variable key: ACCESS_TOKEN
	- Input variable value: Your access token
5. Click `Run Pipeline` button  
![Alt text](images/run_pipeline.PNG)