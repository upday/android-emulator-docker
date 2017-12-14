# Android Emulator on Docker

Requirements
------------

Docker is installed in your system.
Docker Compose (1.17.1 or grater) in your system.

Quick Start
-----------

1. Run in the cloned directory: 
```bash
sudo docker build -t emulator .
sudo docker-compose up -d
```

2. To stop the container:
```bash
sudo docker-compose down
```

Troubleshooting
---------------
To see if the container is running and is healthy:

```bash
sudo docker container ls
```

All logs inside container are stored under folder **/var/log/supervisor**. you can print out log file by using **docker exec**. Example:

```bash
sudo docker exec -it nexus_7.1.1_emulator tail -f /var/log/supervisor/docker-start.stderr.log
```
