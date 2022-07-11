# Access to Student VSI

In your IBM Cloud Account it has been created a VSI you can use to execute CLI commands described in the labs.

## Gather private key

You should have in your inbox a mail containing the private key you will use to access to the student VSI by ssh.

## Gather VSI public IP

![image-20220711114128272](.pastes/image-20220711114128272.png)

![image-20220711114235604](.pastes/image-20220711114235604.png)

Scroll down on the VSI instance overview page and note your Floating IP. 169.63.100.152 in this case

![image-20220711114332639](.pastes/image-20220711114332639.png)

## Connect to VSI

Now using any SSH CLI you want connect using the private key and floating IP.

Copy the private key to your system and give it needed privileges.

With Linux:

```
vi student_rsa

-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAACFwAAAAdzc2gtcn
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MfqXCg4LPJp6fQAAAAt0ZWNoYWNhZGVteQECAwQFBg==
-----END OPENSSH PRIVATE KEY-----

chmod 400 student_rsa
```

```
ssh -i student_rsa root@169.63.100.152
```

