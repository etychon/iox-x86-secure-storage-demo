# iox-x86-secure-storage-demo

IOx applicaton to show how to use Cisco IOx Secure Storage (SS) on x86-based platforms (Cisco IR809, Cisco IR829, Cisco IC3000)

IOx Secure Storage is a Cisco IOx Core service to store and retrieve securely pieces of information. The data is stored in the application partition but encrypted by a key stored in Cisco ACT2 (Anti Counterfeit Technology v2) chip, part of the Trusted Platform Module (TPM).

Objects stored in IOx Secure Storage can be accessed by using a [REST API interface documented on Cisco DevNet](https://developer.cisco.com/docs/iox/#!secure-storage-service-and-api).

## Use Case Description

For this purpose we will build a Docker-based IOx application with [Cisco's recommended rootfs](https://developer.cisco.com/docs/iox/#!docker-images-and-packages-repository) based on Yocto Linux.

# Building the IOx Application

A [ready-to-use IOx application](https://github.com/etychon/iox-x86-secure-storage-demo/releases) application can be downloaded from the releases tab, or it can be built like below.

Start by cloning the current project with:

```
git clone https://github.com/etychon/iox-x86-secure-storage-demo.git
cd iox-x86-secure-storage-demo
```

The application can be built directly with:

```
sh ./build
```

What this command does is two folds:

* it builds a Docker image named `iox-x86-secure-storage-demo` leveraging the Dockerfile present in the directory. For more details on how this works refer to more basic examples or to the Docker documentation:

```
docker build -t iox-x86-secure-storage-demo .                                      
```

* Then it makes an IOx application based on that image, and using the `package.yaml` which is [IOx package descriptor](https://developer.cisco.com/docs/iox/#!package-descriptor/iox-package-descriptor) file:

```
ioxclient docker package iox-x86-secure-storage-demo . -n iox-x86-secure-storage-demo --use-targz
```

The output is a file called `iox-x86-secure-storage-demo.tar.gz` in your current working directory.

## Installation

This application that's been built or downloaded in the previous section can be uploaded in an IOx-enabled gateway using IOx Local Manager or any other method.

Details are already covered in other places but the following steps will need to be done:

* Log in your gateway IOx Local Manager
* Applications > Add New, select the IOx Application file from your computer and give it a name. Click ok and wait.

## Configuration

* On your application, click 'Activate', then 'Activate App' on the upper right.
* Click Applications > Start
* Once the application is in state 'running', click on 'Manage' > 'Logs', and if everything works as expected you should see something like this:

```
Starting...
Getting the TOKEN from SSS service using http://192.168.1.6:9443/SS/TOKEN/sss/622b677d-c881-4352-b42f-2ddc4720dc5f...
Got it: x5aA9oHPzECj6Eet86Y0nL92qd3BH%2FndG1fr8zm0l%2B4%3D
Storing an object in SS...
Processing CompletedStoring done.
Getting the object from SS...
testKeyContentdone
List of objects in SS:
testKey[end]
Deleting object in SS...
Delete done.
```

It shows that the script uses REST API to request a token from the Secure Storage API, and then uses that token to store, get, list, and delete a secure object which in this case is a key called 'testKey' and content is 'testKeyContent'.

## Poking around

Using 'ioxclient' one can have access to the application console, which means getting access to a shell inside the running container. From there you can directly play with the API as the `curl` utility is installed.

You need to create an ioxclient profile that is configured to run with your gateway, and use the following command to get a shell access assuming your running application is called `sss`:

```
ioxclient app session sss
```

For example, once in the shell, one can load environment variables and ask for an IOx Secure Storage Token like so:

```
/ # source /data/.env
/ # curl  --silent "http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/TOKEN/$CAF_APP_ID/$CAF_SYSTEM_UUID"
```
