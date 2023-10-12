# EHR-FABRIC

# Set up the application

1. Close the repository
   
   ```https://github.com/anurag-iitk/ehr-fabric.git```
   
3. Download the required binaries for bin folder
   
```curl https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s -- 2.5.4 2.5.4 -d -s```

4. Go to this folder
   
```ls```
``` 
bin
test-network
```
```cd test-network```

6. Start the fabric application
   
   ```./run.sh```
7. Stop the application
   
   ```./stop.sh```
